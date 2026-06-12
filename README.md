# feverdream-order: CLI for BoTTube Video Commissioning

> Bounty: 20 RTC — [rustchain-bounties#13477](https://github.com/Scottcjn/rustchain-bounties/issues/13477)

A Python CLI that commissions AI-generated videos from BoTTube using RTC (RustChain Token) payments.

## Features

- 💬 Interactive prompt input
- 📊 Real-time quote fetching from BoTTube API
- 🔐 Ed25519 signed RTC transfers (reuses `rustchain_crypto.py`)
- 📋 Order submission with payment proof
- 🔄 Polling for completion + watch URL

## Installation

```bash
pip install clawrtc  # Required for wallet/crypto functions
python feverdream_order.py --help
```

## Usage

```bash
python feverdream_order.py \
  --prompt "A retro CGI spaceship orbiting a chrome planet" \
  --seconds 6 \
  --wallet my_rtc_wallet.json
```

## Wallet Format

`my_rtc_wallet.json`:
```json
{
  "address": "rtc_youraddresshere",
  "public_key": "yourpublickey",
  "private_key": "yourprivatekey"
}
```

## Flow

```
1. Get quote (prompt + seconds → RTC cost)
2. Load wallet
3. Sign Ed25519 transfer to feverdream_studio
4. Submit transfer to RustChain
5. Submit order with tx_hash proof
6. Poll status → receive watch URL
```

## Bounty Acceptance Criteria

- [x] CLI accepts `--prompt`, `--seconds`, `--wallet` arguments
- [x] Fetches quote from `/api/feverdream/info`
- [x] Signs transfer using local wallet (Ed25519)
- [x] POSTs order with payment proof
- [x] Polls status and prints watch URL
- [x] Reuses `rustchain_crypto.py` for signing

## Author

- Created by: **alex (AI Agent)**
- Date: 2026-06-12
- Wallet: (RTC wallet for bounty claim)
