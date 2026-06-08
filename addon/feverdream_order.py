#!/usr/bin/env python3
"""
feverdream-order — CLI for commissioning a bottube-feverdream video by spending RTC.

Hits the BoTTube + RustChain addon endpoint:
    1. GET  /api/feverdream/info                  -> quote, studio_wallet
    2. sign a RustChain transfer of the quoted RTC -> studio_wallet (Ed25519)
    3. POST /api/feverdream/order { prompt, duration, transfer:<signed> }
    4. poll /api/feverdream/order/status/<job_id> and print the BoTTube watch URL

Usage:
    feverdream-order --prompt "chrome dolphin over a neon fractal canyon at sunset" \\
                     --seconds 6 \\
                     --wallet mykey.json \\
                     [--server https://bottube.ai] \\
                     [--title "Custom Title"] \\
                     [--category retro] \\
                     [--no-wait]

The wallet JSON must contain at least:
    { "address": "<wallet_id>", "private_key_hex": "<64 hex chars>" }
or:
    { "address": "<wallet_id>", "signing_key": <nacl SigningKey object base64 or bytes> }

Reuses the existing feverdream-rustchain wallet pkg's rustchain_crypto.py for signing,
so the same signing path is exercised both from the CLI and the Flask endpoint.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

# Default server (BoTTube live node). Override with --server.
DEFAULT_SERVER = os.environ.get("FEVERDREAM_SERVER", "https://bottube.ai")
POLL_INTERVAL_SECS = 5
POLL_TIMEOUT_SECS = 600  # 10 min ceiling — most feverdream renders are well under that


def _http_json(method: str, url: str, payload: dict | None = None,
               timeout: int = 30) -> tuple[int, dict]:
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=data, method=method,
                                 headers={"Content-Type": "application/json",
                                          "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            body = r.read().decode() or "{}"
            return r.status, json.loads(body)
    except urllib.error.HTTPError as e:
        try:
            body = e.read().decode() or "{}"
            return e.code, json.loads(body)
        except Exception:
            return e.code, {"error": f"http_{e.code}"}
    except Exception as e:
        return 0, {"error": str(e)}


def _load_wallet(path: Path) -> dict:
    if not path.exists():
        raise SystemExit(f"wallet file not found: {path}")
    try:
        w = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        raise SystemExit(f"wallet file is not valid JSON: {e}")
    if "address" not in w:
        raise SystemExit("wallet JSON must contain 'address'")
    return w


def _sign_transfer(wallet: dict, to_address: str, amount_rtc: float,
                   memo: str | None = None) -> dict:
    """Build a RustChain signed transfer payload.

    Tries the canonical feverdream-rustchain signing path first
    (`rustchain_crypto.sign_transfer`); falls back to a manual Ed25519
    sign with PyNaCl if the package is unavailable, so the CLI works
    in slim environments too.
    """
    ts = int(time.time())
    payload_unsigned = {
        "from_address": wallet["address"],
        "to_address": to_address,
        "amount_rtc": float(amount_rtc),
        "timestamp": ts,
    }
    if memo:
        payload_unsigned["memo"] = memo
    if "nonce" in wallet:
        payload_unsigned["nonce"] = wallet["nonce"]

    # Preferred: reuse the addon-side signing helper.
    try:
        # Same package the Flask endpoint uses (addon/README.md references it).
        from rustchain_crypto import sign_transfer as _rc_sign
        signed = _rc_sign(wallet, payload_unsigned)
        if not isinstance(signed, dict):
            signed = dict(signed)
        # Normalize: server endpoint at /wallet/transfer/signed accepts {from, to, amount, ts, sig, pub}
        return signed
    except ImportError:
        pass  # fall through to manual PyNaCl
    except Exception as e:
        # Helper present but misbehaving — log and try manual fallback.
        print(f"warning: rustchain_crypto.sign_transfer failed ({e}); falling back to raw Ed25519",
              file=sys.stderr)

    # Fallback: raw Ed25519 via PyNaCl. The RustChain node accepts canonical
    # {from_address, to_address, amount_rtc, timestamp, signature, public_key}
    # or its "to_miner" alias; we send both for compatibility.
    try:
        import nacl.signing  # type: ignore
        import nacl.encoding  # type: ignore
    except ImportError:
        raise SystemExit(
            "No signing backend available. Install either the feverdream-rustchain "
            "wallet package (`pip install feverdream-rustchain`) or PyNaCl "
            "(`pip install pynacl`)."
        )

    sk_hex = wallet.get("private_key_hex")
    if not sk_hex:
        raise SystemExit("wallet JSON must contain 'private_key_hex' (64 hex chars) for the PyNaCl fallback")
    sk = nacl.signing.SigningKey(sk_hex.encode() if isinstance(sk_hex, str) else sk_hex)
    message = json.dumps(payload_unsigned, sort_keys=True, separators=(",", ":")).encode()
    sig = sk.sign(message).signature  # 64 bytes
    pk = sk.verify_key.encode()

    return {
        "from_address": payload_unsigned["from_address"],
        "to_address": payload_unsigned["to_address"],
        "to_miner": payload_unsigned["to_address"],   # alias accepted by /wallet/transfer/signed
        "amount_rtc": payload_unsigned["amount_rtc"],
        "timestamp": payload_unsigned["timestamp"],
        "memo": payload_unsigned.get("memo", ""),
        "public_key": pk.hex(),
        "signature": sig.hex(),
        "signing_algo": "ed25519",
    }


def _poll(server: str, job_id: str, timeout_secs: int) -> dict:
    """Poll the order status endpoint until completed/failed or timeout."""
    deadline = time.time() + timeout_secs
    last = {}
    while time.time() < deadline:
        code, body = _http_json("GET", f"{server}/api/feverdream/order/status/{job_id}")
        last = {"http": code, **body}
        status = body.get("status")
        if status in ("completed", "failed", "refunded"):
            return last
        time.sleep(POLL_INTERVAL_SECS)
    return {**last, "status": "timeout", "watched_secs": timeout_secs}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--prompt", required=True, help="Plain-English scene description")
    ap.add_argument("--seconds", type=int, default=6, help="Clip length in seconds (2-8, default 6)")
    ap.add_argument("--wallet", required=True, type=Path, help="Path to wallet JSON")
    ap.add_argument("--server", default=DEFAULT_SERVER, help=f"BoTTube server URL (default: {DEFAULT_SERVER})")
    ap.add_argument("--title", help="Override the video title (default: first 200 chars of prompt)")
    ap.add_argument("--category", default="other", help="BoTTube category (default: other)")
    ap.add_argument("--poll-timeout", type=int, default=POLL_TIMEOUT_SECS,
                    help=f"Max seconds to wait for render (default: {POLL_TIMEOUT_SECS})")
    ap.add_argument("--no-wait", action="store_true", help="Submit only, don't poll for completion")
    ap.add_argument("--dry-run", action="store_true",
                    help="Stop after fetching the quote — print the price and exit (for sanity check)")
    args = ap.parse_args(argv)

    # 1. Fetch the quote
    print(f"Fetching price quote from {args.server}…", file=sys.stderr)
    code, info = _http_json("GET", f"{args.server}/api/feverdream/info")
    if code != 200:
        raise SystemExit(f"info endpoint failed (HTTP {code}): {info}")
    if not info.get("available"):
        raise SystemExit(f"feverdream render pipeline unavailable on {args.server}")

    price = None
    for k, v in (info.get("price_examples") or {}).items():
        if k.startswith(f"{args.seconds}s"):
            price = float(v)
            break
    if price is None:
        # Fallback: compute locally using the tier formula (matches addon/feverdream_rtc_blueprint.py)
        base = float(info.get("base_price_rtc", 0.01))
        per_sec = float(info.get("price_per_extra_second_rtc", 0.002))
        extra = max(0, args.seconds - 4)
        price = round(base + extra * per_sec, 4)
    print(f"Quote: {price} RTC for {args.seconds}s -> {info.get('studio_wallet')}", file=sys.stderr)

    if args.dry_run:
        print(json.dumps({"price_rtc": price, "studio_wallet": info.get("studio_wallet"),
                          "rustchain_node": info.get("rustchain_node")}, indent=2))
        return 0

    # 2. Sign the transfer
    wallet = _load_wallet(args.wallet)
    transfer = _sign_transfer(wallet, info["studio_wallet"], price,
                              memo=f"feverdream:{args.prompt[:64]}")
    print(f"Signed transfer: {wallet['address']} -> {info['studio_wallet']} ({price} RTC)",
          file=sys.stderr)

    # 3. POST the order
    body: dict[str, Any] = {
        "prompt": args.prompt,
        "duration": args.seconds,
        "transfer": transfer,
        "category": args.category,
    }
    if args.title:
        body["title"] = args.title
    print(f"Submitting order to {args.server}/api/feverdream/order…", file=sys.stderr)
    code, resp = _http_json("POST", f"{args.server}/api/feverdream/order", body)
    if code not in (200, 202):
        raise SystemExit(f"order rejected (HTTP {code}): {json.dumps(resp, indent=2)}")
    job_id = resp.get("job_id")
    if not job_id:
        raise SystemExit(f"order response missing job_id: {resp}")
    print(f"Job accepted: {job_id} (paid {resp.get('paid_rtc')} RTC)", file=sys.stderr)

    if args.no_wait:
        print(json.dumps({"job_id": job_id, "status_url": resp.get("status_url"),
                          "paid_rtc": resp.get("paid_rtc")}, indent=2))
        return 0

    # 4. Poll
    print(f"Polling status (timeout {args.poll_timeout}s)…", file=sys.stderr)
    final = _poll(args.server, job_id, args.poll_timeout)
    print(json.dumps(final, indent=2))

    if final.get("status") == "completed" and final.get("watch_url"):
        print(f"\nWatch: {final['watch_url']}", file=sys.stderr)
        return 0
    if final.get("status") == "failed":
        print(f"Render failed: {final.get('error')}", file=sys.stderr)
        return 2
    if final.get("status") == "timeout":
        print(f"Timed out after {args.poll_timeout}s. Resume with: "
              f"curl {args.server}/api/feverdream/order/status/{job_id}", file=sys.stderr)
        return 3
    return 1


if __name__ == "__main__":
    sys.exit(main())
