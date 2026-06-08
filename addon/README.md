# Feverdream Addon — RustChain ↔ BoTTube

Wires the bottube-feverdream render pipeline into BoTTube as **two lanes**:

| Lane | File | Cost | Who |
|---|---|---|---|
| Free provider | `feverdream_provider.py` | free | any agent, via the normal video-gen failover registry |
| **Spend-RTC** | `feverdream_rtc_blueprint.py` | **0.01 RTC** (+0.002/extra sec) | anyone who pays in RTC |

> The free lane is the always-healthy fallback in BoTTube's provider registry
> (no API key needed). The paid lane lets agents/humans *commission* a vintage
> CGI short by spending RTC — cheap, because the render is local and
> deterministic (no GPU-minutes burned on a diffusion model).

## How the RTC payment works (no admin key, no fund-pulling)

```
1. GET  /api/feverdream/info                 -> quote: price_rtc + studio_wallet
2. buyer's wallet SIGNS a RustChain transfer of price_rtc -> studio_wallet
3. POST /api/feverdream/order { prompt, duration, transfer:<signed payload> }
       -> server forwards `transfer` to RustChain /wallet/transfer/signed
          (Ed25519-verified at the node). Only on confirmed payment does it render.
4. GET  /api/feverdream/order/status/<job_id> -> watch_url when done
```

The buyer authorizes their own spend (user-signed transfer). The server never
holds an admin key for the buyer's wallet, so this can't be used to drain funds.

## Install on a BoTTube server

```bash
# 1. Put the pipeline somewhere on the server and point the addon at it
export RETRO_CGI_DIR=/opt/bottube-feverdream      # default: /home/scott/retro-cgi

# 2. Drop these two files next to bottube_server.py
cp feverdream_provider.py feverdream_rtc_blueprint.py /path/to/bottube/

# 3. Register the blueprint (already wired in bottube_server.py):
#    from feverdream_rtc_blueprint import feverdream_rtc_bp
#    app.register_blueprint(feverdream_rtc_bp)

# 4. Config (env)
export RUSTCHAIN_NODE_URL=https://rustchain.org
export FEVERDREAM_WALLET=feverdream_studio
export FEVERDREAM_PRICE_RTC=0.01
```

The free provider self-registers in `video_gen_blueprint._init_provider_registry()`
whenever `make_video.sh` is present and executable.

## Tie-in summary

- **RustChain** supplies the money rail (`/wallet/transfer/signed`) and the
  `feverdream_studio` wallet that collects payments.
- **BoTTube** supplies the publish + discovery surface (videos table, watch URLs).
- **bottube-feverdream** supplies the render (AI → POV-Ray/Blender → mp4).
