#!/usr/bin/env python3
"""
feverdream-order: CLI to spend RTC and commission a video from BoTTube
Bounty: 20 RTC — https://github.com/Scottcjn/rustchain-bounties/issues/13477

Usage:
    python feverdream_order.py --prompt "your prompt" --seconds 6 --wallet mykey.json
"""

import argparse
import json
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# Constants
FEVERDREAM_API = "https://api.bottube.io/api/feverdream"
RUSTCHAIN_API = "https://rustchain.org/wallet/transfer/signed"
STUDIO_WALLET = "feverdream_studio"


def fetch_quote(prompt: str, seconds: int) -> dict:
    """Get a quote from feverdream API."""
    url = f"{FEVERDREAM_API}/info"
    payload = json.dumps({"prompt": prompt, "seconds": seconds}).encode()
    req = urllib.request.Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        print(f"[ERROR] Quote failed: HTTP {e.code} — {body}")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] Quote failed: {e}")
        sys.exit(1)


def load_wallet(wallet_path: str) -> dict:
    """Load wallet key from JSON file."""
    p = Path(wallet_path)
    if not p.exists():
        print(f"[ERROR] Wallet file not found: {wallet_path}")
        sys.exit(1)
    with open(p, "r", encoding="utf-8") as f:
        return json.load(f)


def sign_transfer(wallet: dict, to_address: str, amount_rtc: float, nonce: int) -> dict:
    """
    Sign a RustChain transfer using Ed25519.
    Reuses rustchain_crypto.py logic if available, otherwise provides stub.
    """
    try:
        # Try to import the official rustchain crypto module
        from rustchain_crypto import sign_message
        from_address = wallet.get("address", "")
        message = f"{from_address}:{to_address}:{amount_rtc}:{nonce}"
        signature = sign_message(message, wallet["private_key"])
        return {
            "from_address": from_address,
            "to_address": to_address,
            "amount_rtc": amount_rtc,
            "nonce": nonce,
            "signature": signature,
            "public_key": wallet.get("public_key", ""),
        }
    except ImportError:
        # Stub for environments without rustchain_crypto
        print("[WARN] rustchain_crypto not available; generating unsigned payload (dev mode)")
        return {
            "from_address": wallet.get("address", ""),
            "to_address": to_address,
            "amount_rtc": amount_rtc,
            "nonce": nonce,
            "signature": "stub-signature-dev-mode",
            "public_key": wallet.get("public_key", ""),
        }


def send_rtc_transfer(signed_payload: dict) -> dict:
    """Submit signed transfer to RustChain."""
    payload = json.dumps(signed_payload).encode()
    req = urllib.request.Request(
        RUSTCHAIN_API,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        print(f"[ERROR] Transfer failed: HTTP {e.code} — {body}")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] Transfer failed: {e}")
        sys.exit(1)


def submit_order(prompt: str, seconds: int, tx_hash: str, wallet_address: str) -> dict:
    """Submit video order to feverdream after payment."""
    url = f"{FEVERDREAM_API}/order"
    payload = json.dumps({
        "prompt": prompt,
        "seconds": seconds,
        "payment_tx": tx_hash,
        "customer_wallet": wallet_address,
    }).encode()
    req = urllib.request.Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        print(f"[ERROR] Order failed: HTTP {e.code} — {body}")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] Order failed: {e}")
        sys.exit(1)


def poll_status(order_id: str, max_attempts: int = 30) -> dict:
    """Poll order status until completion or timeout."""
    url = f"{FEVERDREAM_API}/status/{order_id}"
    for attempt in range(1, max_attempts + 1):
        try:
            with urllib.request.urlopen(url, timeout=10) as resp:
                data = json.loads(resp.read().decode())
                status = data.get("status", "unknown")
                print(f"  [{attempt}/{max_attempts}] Status: {status}")
                if status in ("completed", "ready", "done"):
                    return data
                if status in ("failed", "error"):
                    print("[ERROR] Order failed on server.")
                    sys.exit(1)
        except Exception as e:
            print(f"  [{attempt}/{max_attempts}] Poll error: {e}")
        time.sleep(5)
    print("[ERROR] Polling timed out.")
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Commission a BoTTube video via feverdream using RTC."
    )
    parser.add_argument("--prompt", required=True, help="Video generation prompt")
    parser.add_argument("--seconds", type=int, default=6, help="Video length in seconds")
    parser.add_argument("--wallet", required=True, help="Path to wallet JSON key file")
    args = parser.parse_args()

    print("=" * 60)
    print("feverdream-order v1.0 — BoTTube Video Commission CLI")
    print("=" * 60)

    # 1. Fetch quote
    print(f"\n[1/4] Getting quote for '{args.prompt}' ({args.seconds}s)...")
    quote = fetch_quote(args.prompt, args.seconds)
    rtc_cost = quote.get("rtc_cost", quote.get("price_rtc", 0.014))
    print(f"  Quote received: {rtc_cost} RTC")

    # 2. Load wallet
    print(f"\n[2/4] Loading wallet from {args.wallet}...")
    wallet = load_wallet(args.wallet)
    wallet_addr = wallet.get("address", "unknown")
    print(f"  Wallet loaded: {wallet_addr}")

    # 3. Sign and send transfer
    print(f"\n[3/4] Signing transfer of {rtc_cost} RTC to {STUDIO_WALLET}...")
    nonce = int(time.time())  # Simple nonce
    signed = sign_transfer(wallet, STUDIO_WALLET, rtc_cost, nonce)
    result = send_rtc_transfer(signed)
    tx_hash = result.get("tx_hash") or result.get("pending_id") or "unknown"
    print(f"  Transfer submitted: tx_hash={tx_hash}")

    # 4. Submit order + poll
    print(f"\n[4/4] Submitting order with payment proof...")
    order = submit_order(args.prompt, args.seconds, tx_hash, wallet_addr)
    order_id = order.get("order_id", order.get("id", "unknown"))
    print(f"  Order submitted: id={order_id}")

    print(f"\n[4.5/4] Polling order status (max 30 attempts, 5s interval)...")
    final = poll_status(order_id)

    watch_url = final.get("watch_url", final.get("url", "N/A"))
    print("\n" + "=" * 60)
    print("SUCCESS!")
    print(f"Watch URL: {watch_url}")
    print("=" * 60)


if __name__ == "__main__":
    main()
