#!/usr/bin/env python3
"""
feverdream-order — CLI for ordering AI video generation on BoTTube

Orders AI-generated videos (feverdreams) by:
1. Getting a price quote from /api/feverdream/info
2. Signing an RTC transfer to feverdream_studio (Ed25519)
3. POSTing the order
4. Polling for completion
5. Returning the watch URL

Usage:
  feverdream-order --prompt "A cat on a surfboard" --seconds 6 --wallet wallet.json
  feverdream-order --prompt "Neon city rain" --seconds 10 --wallet wallet.json --dry-run
  feverdream-order --info                    # Show current pricing
"""

import argparse
import getpass
import json
import os
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# Add rustchain_sdk to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "Rustchain", "sdk", "python"))

try:
    from rustchain_sdk.wallet import RustChainWallet
except ImportError:
    RustChainWallet = None
    print("⚠️  rustchain_sdk not found. Install with: pip install -e ../../Rustchain/sdk/python")
    print("   Or ensure Rustchain repo is at ../Rustchain")

# Use the proper RustChain node URL (certificate is valid for this domain)
NODE = os.environ.get("RUSTCHAIN_NODE_URL", "https://rustchain.org")


def api_get(path):
    try:
        with urllib.request.urlopen(f"{NODE}{path}", timeout=15) as r:
            return json.loads(r.read())
    except Exception as e:
        return {"error": str(e)}


def api_post(path, data):
    req = urllib.request.Request(
        f"{NODE}{path}",
        data=json.dumps(data).encode(),
        headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read())
    except Exception as e:
        return {"error": str(e)}


def fmt_time(epoch):
    return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(epoch))


def load_wallet(wallet_path: Path):
    """Load wallet from JSON file, supporting RustChain SDK export format (seed_phrase).

    Supported formats:
    - RustChain SDK export: {"seed_phrase": [...], "derivation_path": "..."}
    - Legacy encrypted keystore with "ciphertext", "salt", "nonce"
    - Legacy JSON with "seed_phrase" inside

    NOT supported: raw private_key/privkey hex strings (export seed phrase instead).
    """
    with open(wallet_path) as f:
        keystore = json.load(f)

    # If it's already a RustChain SDK export
    if "seed_phrase" in keystore:
        words = keystore["seed_phrase"]
        return RustChainWallet.from_seed_phrase(words)

    # If it's a legacy encrypted keystore
    if "ciphertext" in keystore:
        password = getpass.getpass("Wallet password: ")
        try:
            from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
            from cryptography.hazmat.primitives.ciphers.aead import AESGCM
            from cryptography.hazmat.primitives import hashes
            salt = bytes.fromhex(keystore["salt"])
            nonce = bytes.fromhex(keystore["nonce"])
            ct = bytes.fromhex(keystore["ciphertext"])
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,
                iterations=keystore.get("iterations", 100000)
            )
            key = kdf.derive(password.encode())
            wallet_data = json.loads(AESGCM(key).decrypt(nonce, ct, None))
        except ImportError:
            print("⛔ cryptography required for encrypted wallets")
            return None
        except Exception as e:
            print(f"⛔ Decryption failed: {e}")
            return None
    else:
        wallet_data = keystore

    # Legacy format: try to extract seed phrase or private key
    if "seed_phrase" in wallet_data:
        words = wallet_data["seed_phrase"]
        return RustChainWallet.from_seed_phrase(words)

    if "private_key" in wallet_data or "privkey" in wallet_data:
        privkey_hex = wallet_data.get("private_key") or wallet_data.get("privkey")
        # Need to derive seed from private key - not directly supported
        # User should migrate to seed phrase format
        print("⛔ Legacy private_key format not directly supported.")
        print("   Please export wallet as seed phrase from RustChain wallet.")
        return None

    print("⛔ Wallet format not recognized. Expected RustChain SDK export with 'seed_phrase'.")
    return None


def cmd_info():
    """Show feverdream pricing info."""
    data = api_get("/api/feverdream/info")
    if "error" in data:
        print(f"⛔ {data['error']}")
        return 1
    print("\n🌟 FeverDream Pricing\n")
    if isinstance(data, dict):
        for k, v in data.items():
            print(f"  {k}: {v}")
    else:
        print(f"  {data}")
    return 0


def cmd_order(args):
    """Place a feverdream order."""
    if RustChainWallet is None:
        print("⛔ rustchain_sdk not available. Cannot sign transfers.")
        return 1

    wallet_path = Path(args.wallet)
    if not wallet_path.exists():
        print(f"⛔ Wallet file not found: {wallet_path}")
        return 1

    wallet = load_wallet(wallet_path)
    if wallet is None:
        return 1

    address = wallet.address
    pubkey = wallet.public_key_hex

    # Get quote
    print(f"\n🌟 FeverDream Order")
    print(f"  Prompt: {args.prompt}")
    print(f"  Duration: {args.seconds}s")
    print(f"  Wallet: {address}")

    info = api_get("/api/feverdream/info")
    if "error" in info:
        print(f"⚠️  Using default pricing (0.01 RTC base + 0.002/sec)")
        cost = 0.01 + max(0, args.seconds - 4) * 0.002
    else:
        # Parse tier pricing
        tier = getattr(args, "tier", "cute")
        tiers = info.get("tiers", {})
        if tier in tiers:
            base = tiers[tier].get("base_rtc", 0.01)
        else:
            base = 0.01
        extra_sec = max(0, args.seconds - 4)
        price_per_sec = info.get("price_per_extra_second_rtc", 0.002)
        cost = round(base + extra_sec * price_per_sec, 4)

    print(f"  Cost: {cost:.4f} RTC")
    print(f"  Pay to: feverdream_studio")

    if args.dry_run:
        print("\n💡 Dry run — no transaction sent")
        print(f"  Would send: {cost:.4f} RTC to feverdream_studio")
        print(f"  Would POST order for: {args.prompt}")
        return 0

    # Create signed transfer using RustChainWallet
    print(f"\n  Signing transfer with Ed25519...")
    try:
        transfer = wallet.sign_transfer(
            to_address="feverdream_studio",
            amount=cost,
            fee=0.0,
            memo=f"feverdream:{args.prompt[:50]}",
        )
        print(f"  ✅ Transfer signed!")
        print(f"     From: {transfer['from_address']}")
        print(f"     To: {transfer['to_address']}")
        print(f"     Amount: {transfer['amount_rtc']} RTC")
        print(f"     Nonce: {transfer['nonce']}")
    except Exception as e:
        print(f"⛔ Signing failed: {e}")
        return 1

    # Send transfer
    print(f"\n  Sending {cost:.4f} RTC...")
    result = api_post("/wallet/transfer/signed", transfer)
    if "error" in result:
        print(f"⚠️  Transfer may still go through: {result['error']}")
        print("   Proceeding with order...")
    else:
        print(f"  ✅ Payment sent!")
        if "txid" in result:
            print(f"     TXID: {result['txid']}")

    # Place order
    order = {
        "prompt": args.prompt,
        "seconds": args.seconds,
        "payer_address": address,
        "transfer": transfer,
    }

    order["tier"] = args.tier
    if args.title:
        order["title"] = args.title
    if args.category:
        order["category"] = args.category

    print(f"  Placing order...")
    result = api_post("/api/feverdream/order", order)
    if "error" in result:
        print(f"⛔ Order failed: {result['error']}")
        return 1

    order_id = result.get("order_id") or result.get("id", "?")
    watch_url = result.get("watch_url") or result.get("url", f"{NODE}/feverdream/watch/{order_id}")
    print(f"  ✅ Order placed! ID: {order_id}")
    print(f"\n📺 Watch URL: {watch_url}")

    # Poll for completion
    if args.wait:
        print(f"\n  Waiting for completion...")
        for i in range(30):
            status = api_get(f"/api/feverdream/order/status/{order_id}")
            if status.get("status") in ("completed", "done", "ready"):
                print(f"  ✅ Complete!")
                final_url = status.get("watch_url") or status.get("url") or watch_url
                print(f"  Final URL: {final_url}")
                break
            if status.get("status") in ("failed", "error"):
                print(f"  ⛔ Failed: {status.get('error', 'unknown')}")
                break
            time.sleep(2)
            print(f"  .", end="", flush=True)
        else:
            print(f"\n  ⚠️  Still processing. Check: {watch_url}")

    return 0


def main():
    parser = argparse.ArgumentParser(description="FeverDream CLI — Order AI video generation")
    parser.add_argument("--info", action="store_true", help="Show pricing info")
    parser.add_argument("--prompt", help="Video description prompt")
    parser.add_argument("--seconds", type=int, default=6, help="Video duration in seconds")
    parser.add_argument("--wallet", help="Path to wallet JSON file")
    parser.add_argument("--dry-run", action="store_true", help="Preview without sending RTC")
    parser.add_argument("--wait", action="store_true", help="Wait for video to complete")
    parser.add_argument("--tier", choices=["cute", "textured", "studio"], default="cute", help="Quality tier")
    parser.add_argument("--title", help="Video title (optional)")
    parser.add_argument("--category", help="Video category (optional)")
    parser.add_argument("--version", action="version", version="feverdream-order 2.0.0")

    args = parser.parse_args()

    if args.info:
        return cmd_info()
    if args.prompt and args.wallet:
        return cmd_order(args)

    parser.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())