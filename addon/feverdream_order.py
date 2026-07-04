#!/usr/bin/env python3
"""
feverdream-order 鈥?CLI for ordering AI video generation on BoTTube

Orders AI-generated videos (feverdreams) by:
1. Getting a price quote from /api/feverdream/info
2. Signing an RTC transfer to feverdream_studio
3. POSTing the order
4. Polling for completion
5. Returning the watch URL

Usage:
  feverdream-order --prompt "A cat on a surfboard" --seconds 6 --wallet wallet.json
  feverdream-order --prompt "Neon city rain" --seconds 10 --wallet wallet.json --dry-run
  feverdream-order --info                    # Show current pricing
"""

import argparse, getpass, hashlib, json, os, sys, time, urllib.request, urllib.error
from pathlib import Path

NODE = "https://50.28.86.131"

def api_get(path):
    try:
        with urllib.request.urlopen(f"{NODE}{path}", timeout=15) as r:
            return json.loads(r.read())
    except Exception as e:
        return {"error": str(e)}

def api_post(path, data):
    req = urllib.request.Request(f"{NODE}{path}", data=json.dumps(data).encode(), headers={"Content-Type":"application/json"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read())
    except Exception as e:
        return {"error": str(e)}

def sha256(data):
    return hashlib.sha256(data.encode() if isinstance(data, str) else data).hexdigest()

def fmt_time(epoch):
    return time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(epoch))

def cmd_info():
    """Show feverdream pricing info."""
    data = api_get("/api/feverdream/info")
    if "error" in data:
        print(f"鉂?{data['error']}")
        return 1
    print("\n馃幀 FeverDream Pricing\n")
    if isinstance(data, dict):
        for k, v in data.items():
            print(f"  {k}: {v}")
    else:
        print(f"  {data}")
    return 0

def cmd_order(args):
    """Place a feverdream order."""
    wallet_path = Path(args.wallet)
    if not wallet_path.exists():
        print(f"鉂?Wallet file not found: {wallet_path}")
        return 1

    # Load wallet
    with open(wallet_path) as f:
        keystore = json.load(f)

    try:
        import sys, os
        sys.path.append(os.path.join(os.path.dirname(__file__), "..", "..", "Rustchain", "wallet"))
        from rustchain_crypto import RustChainWallet
    except ImportError:
        print("❌ rustchain_crypto required. Please ensure the wallet package is available.")
        return 1

    # Try to decrypt if encrypted
    if "ciphertext" in keystore:
        password = getpass.getpass("Wallet password: ")
        try:
            wallet = RustChainWallet.from_encrypted(keystore, password)
        except Exception as e:
            print(f"❌ Decryption failed: {e}")
            return 1
    else:
        privkey = keystore.get("private_key") or keystore.get("privkey", "")
        if not privkey:
            print("❌ Wallet missing private key")
            return 1
        wallet = RustChainWallet.from_private_key(privkey)

    address = wallet.address

    # Get quote
    print(f"\n馃幀 FeverDream Order")
    print(f"  Prompt: {args.prompt}")
    print(f"  Duration: {args.seconds}s")
    print(f"  Wallet: {address}")

    info = api_get("/api/feverdream/info")
    if "error" in info:
        print(f"鈿?Using default pricing (0.014 RTC per 6s)")
        cost = 0.014
    else:
        cost = info.get("price_per_6s", 0.014) * (args.seconds / 6)

    print(f"  Cost: {cost:.4f} RTC")
    print(f"  Pay to: feverdream_studio")

    if args.dry_run:
        print("\n鉁?Dry run 鈥?no transaction sent")
        print(f"  Would send: {cost:.4f} RTC to feverdream_studio")
        print(f"  Would POST order for: {args.prompt}")
        return 0

    # Create and sign transfer using wallet pkg
    print(f"\n  Signing {cost:.4f} RTC transfer...")
    try:
        tx = wallet.sign_transaction("feverdream_studio", cost, "feverdream order")
    except Exception as e:
        print(f"❌ Signing failed: {e}")
        return 1

    # Place order (the endpoint will forward the transfer)
    order = {
        "prompt": args.prompt,
        "duration": args.seconds,
        "payer_address": address,
        "transfer": tx,
    }

    print(f"  Placing order...")
    result = api_post("/api/feverdream/order", order)
    if "error" in result:
        print(f"鉂?Order failed: {result['error']}")
        return 1

    order_id = result.get("order_id") or result.get("id", "?")
    watch_url = result.get("watch_url") or result.get("url", f"{NODE}/feverdream/watch/{order_id}")
    print(f"  鉁?Order placed! ID: {order_id}")
    print(f"\n馃帴 Watch URL: {watch_url}")

    # Poll for completion
    if args.wait:
        print(f"\n  Waiting for completion...")
        for i in range(30):
            status = api_get(f"/api/feverdream/status/{order_id}")
            if status.get("status") in ("completed", "done", "ready"):
                print(f"  鉁?Complete!")
                final_url = status.get("watch_url") or status.get("url") or watch_url
                print(f"  Final URL: {final_url}")
                break
            if status.get("status") in ("failed", "error"):
                print(f"  鉂?Failed: {status.get('error', 'unknown')}")
                break
            time.sleep(2)
            print(f"  .", end="", flush=True)
        else:
            print(f"\n  鈿?Still processing. Check: {watch_url}")

    return 0

def main():
    parser = argparse.ArgumentParser(description="FeverDream CLI 鈥?Order AI video generation")
    parser.add_argument("--info", action="store_true", help="Show pricing info")
    parser.add_argument("--prompt", help="Video description prompt")
    parser.add_argument("--seconds", type=int, default=6, help="Video duration in seconds")
    parser.add_argument("--wallet", help="Path to wallet JSON file")
    parser.add_argument("--dry-run", action="store_true", help="Preview without sending RTC")
    parser.add_argument("--wait", action="store_true", help="Wait for video to complete")
    parser.add_argument("--version", action="version", version="feverdream-order 1.0.0")

    args = parser.parse_args()

    if args.info:
        return cmd_info()
    if args.prompt and args.wallet:
        return cmd_order(args)

    parser.print_help()
    return 1

if __name__ == "__main__":
    sys.exit(main())
