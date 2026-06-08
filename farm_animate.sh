#!/usr/bin/env bash
# farm_animate.sh — split a POV-Ray animation across N ssh-reachable nodes
#                   in parallel, rsync the frames back, and mux the final mp4.
#
# This is the "vintage render fleet" lane.  The RustChain side celebrates
# CPU-only, even POWER8-class antiquity — the same hardware becomes the
# production line.  Single-host render stays a baseline; the farm wins
# when there are >= 2 reachable nodes.
#
#   ./farm_animate.sh scene.pov SECONDS FPS [WIDTH HEIGHT] --nodes NODE1,NODE2[,NODE3...]
#                     [--crt] [--ssh-user USER] [--per-node-concurrency N]
#                     [--povray-bin POVRAY] [--ffmpeg-bin FFMPEG]
#                     [--rsync-bin RSYNC] [--keep-frames]
#
# Each NODE entry in `--nodes` can be:
#   * host            (uses current SSH user and ~/.ssh config; `nproc` probed)
#   * user@host       (uses that user, `nproc` probed)
#   * user@host:CPUS  (uses that user and a fixed concurrency override, e.g. guciolek@power8.lab:128)
#
# Frames are sharded into roughly-equal contiguous ranges (e.g. for 240
# frames and 3 nodes, 80-80-80).  Per-node concurrency is capped by
# min(node CPUs, ceil(shard_size / 8)) so a 4-thread box never gets a
# 240-frame shard.
#
# A dead node's frames re-queue onto surviving nodes (one re-assignment
# pass, then we surface the gap as an error).  Output is the same mp4
# filename as `animate.sh` for a single-host render, so downstream tooling
# doesn't care which lane produced the clip.
#
# Acceptance: ./farm_animate.sh scene.pov 10 24 --nodes power8,g5,victus
# renders ~240 frames across nodes faster than single-host, and the mp4
# is identical (frame-bytewise, modulo POV-Ray +KFF0.0 non-determinism
# that we paper over by rendering with the same +A settings on every node).
set -euo pipefail
shopt -s lastpipe

HERE="$(cd "$(dirname "$0")" && pwd)"

# ---------- help (early — first arg) ----------
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,40p' "$0"
  exit 0
fi

POV="${1:?usage: farm_animate.sh scene.pov SECONDS FPS [W H] --nodes N[,N...]}"
SECS="${2:?missing SECONDS}"
FPS="${3:?missing FPS}"
W="${4:-1280}"; H="${5:-720}"

# ---------- arg parsing ----------
SSH_USER="${USER:-$(id -un)}"
PER_NODE_CONCURRENCY=0
POVRAY_BIN="${POVRAY_BIN:-povray}"
FFMPEG_BIN="${FFMPEG_BIN:-ffmpeg}"
RSYNC_BIN="${RSYNC_BIN:-rsync}"
CRT=0
NODES_CSV=""
KEEP_FRAMES=0

shift 5 2>/dev/null || true
while [ $# -gt 0 ]; do
  case "$1" in
    --nodes)            NODES_CSV="${2:?--nodes needs a value}"; shift 2;;
    --ssh-user)         SSH_USER="${2:?--ssh-user needs a value}"; shift 2;;
    --per-node-concurrency) PER_NODE_CONCURRENCY="${2:?--per-node-concurrency needs a value}"; shift 2;;
    --povray-bin)       POVRAY_BIN="${2:?--povray-bin needs a value}"; shift 2;;
    --ffmpeg-bin)       FFMPEG_BIN="${2:?--ffmpeg-bin needs a value}"; shift 2;;
    --rsync-bin)        RSYNC_BIN="${2:?--rsync-bin needs a value}"; shift 2;;
    --crt)              CRT=1; shift;;
    --keep-frames)      KEEP_FRAMES=1; shift;;
    -h|--help)          sed -n '2,40p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 64;;
  esac
done

[ -n "$NODES_CSV" ] || { echo "--nodes is required" >&2; exit 64; }
[ -f "$POV" ] || { echo "scene not found: $POV" >&2; exit 64; }

# ---------- shard math ----------
NFRAMES=$(( SECS * FPS ))
base="$(basename "${POV%.pov}")"
fdir="$HERE/frames/$base"
out="$HERE/output/${base}.mp4"
rm -rf "$fdir"; mkdir -p "$fdir" "$HERE/output"

IFS=',' read -ra NODES <<< "$NODES_CSV"
N_NODES=${#NODES[@]}
# Roughly even shard boundaries: node i gets frames [i*q+1, (i+1)*q] (1-based)
# with the remainder spread across the first (NFRAMES mod N_NODES) nodes.
PER=$(( NFRAMES / N_NODES ))
REM=$(( NFRAMES % N_NODES ))

# ---------- per-node probe (CPUs) ----------
# Cache the per-node nproc in a temp file so the dispatcher + the worker
# can read it from the same one-shot SSH call.
NPROC_CACHE="$(mktemp -t farm_nproc.XXXXXX)"
trap 'rm -f "$NPROC_CACHE"' EXIT

probe_nproc() {
  # $1 = node spec, prints its probed nproc (or override if user@host:CPUS).
  local spec="$1"
  if [[ "$spec" == *:* ]]; then
    echo "${spec##*:}"; return
  fi
  local target="$spec"
  [[ "$target" == *@* ]] || target="${SSH_USER}@${target}"
  if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" nproc </dev/null 2>/dev/null; then
    echo 0
  fi
}

# Pre-probe in parallel-light (sequential is fine, cheap).
for n in "${NODES[@]}"; do
  np=$(probe_nproc "$n")
  printf '%s %s\n' "$n" "$np" >> "$NPROC_CACHE"
  echo "  node $n -> nproc=$np"
done

# Cap per-node concurrency: min(node cpus, ceil(shard_size/8) + 1)
cap_for_node() {
  local spec="$1" shard="$2"
  local np
  np=$(awk -v k="$spec" '$1==k{print $2}' "$NPROC_CACHE")
  if [ "${np:-0}" -le 0 ]; then
    # Unreachable node — give it 1 just in case it comes back, dispatcher
    # will skip the shard otherwise.
    echo 1; return
  fi
  local cap=$(( (shard + 7) / 8 + 1 ))
  if [ "$cap" -gt "$np" ]; then echo "$np"; else echo "$cap"; fi
}

if [ "$PER_NODE_CONCURRENCY" -gt 0 ]; then
  PER_NODE_CONC_DEFAULT="$PER_NODE_CONCURRENCY"
else
  PER_NODE_CONC_DEFAULT=0   # 0 = auto from cap_for_node
fi

# ---------- per-shard render worker (runs over SSH) ----------
render_shard_remote() {
  # Runs on the remote node.  Args:  pov_path shard_start shard_end width height
  #                                out_dir pov_lpath povray_bin
  local pov_path="$1" shard_start="$2" shard_end="$3" W="$4" H="$5"
  local out_dir="$6" pov_lpath="$7" povray_bin="$8" conc="$9"
  local shard_count=$(( shard_end - shard_start + 1 ))
  mkdir -p "$out_dir"
  "$povray_bin" \
    "+I$pov_path" "+O${out_dir}/f.png" "+W$W" "+H$H" +A0.3 \
    "+L$(dirname "$pov_lpath")/lib" "+WT$conc" \
    +KFI"$shard_start" "+KFF$shard_end" +KI0.0 +KF1.0 -D \
    >"${out_dir}/render.log" 2>&1
  ls "${out_dir}"/f*.png 2>/dev/null | wc -l
}

# ---------- dispatch a single shard to a node ----------
dispatch_shard() {
  local spec="$1" shard_start="$2" shard_end="$3" idx="$4" conc="$5"
  local target="$spec"
  [[ "$target" == *:* ]] && target="${target%:*}"   # drop :CPUS suffix for ssh
  [[ "$target" == *@* ]] || target="${SSH_USER}@${target}"

  local remote_fdir="/tmp/farm_${base}_${idx}"
  local pov_basename; pov_basename="$(basename "$POV")"
  local remote_pov="${remote_fdir}/${pov_basename}"

  # Ship the scene (+ lib/) to the node; cheap on local LAN, idempotent.
  $RSYNC_BIN -az --delete \
    --include="/${pov_basename}" --include="/lib/" --include="/lib/**" --exclude="*" \
    -e "ssh -o BatchMode=yes -o ConnectTimeout=5" \
    "$HERE/" "$target:$remote_fdir/" >/dev/null

  # Run the worker.  Capture exit code AND frame count, separately.
  local rc=0 frames=0
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" \
    "bash -s -- '$POV' '$shard_start' '$shard_end' '$W' '$H' '$remote_fdir' '$remote_pov' '$POVRAY_BIN' '$conc'" <<'REMOTE_SCRIPT'
set -euo pipefail
pov_path="$1" shard_start="$2" shard_end="$3" W="$4" H="$5"
out_dir="$6" pov_lpath="$7" povray_bin="$8" conc="$9"
mkdir -p "$out_dir"
"$povray_bin" \
  "+I$pov_path" "+O${out_dir}/f.png" "+W$W" "+H$H" +A0.3 \
  "+L$(dirname "$pov_lpath")/lib" "+WT$conc" \
  +KFI"$shard_start" "+KFF$shard_end" +KI0.0 +KF1.0 -D \
  >"${out_dir}/render.log" 2>&1
ls "${out_dir}"/f*.png 2>/dev/null | wc -l
REMOTE_SCRIPT
  rc=$?
  if [ $rc -ne 0 ]; then echo "0"; return $rc; fi
  # Frame count is on stdout already (worker prints it).
  # The remote prints it as final line, captured by ssh stdout; we need it.
  # Re-run the count via ssh to be sure.
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" \
    "ls '${remote_fdir}'/f*.png 2>/dev/null | wc -l" </dev/null
}

# ---------- split the work into shards ----------
declare -a SHARD_SPECS=()
declare -a SHARD_START=()
declare -a SHARD_END=()
declare -a SHARD_CONC=()
declare -a SHARD_OUT=()

cur=1
for i in "${!NODES[@]}"; do
  spec="${NODES[$i]}"
  this_per=$PER
  if [ $i -lt $REM ]; then this_per=$(( PER + 1 )); fi
  s=$cur
  e=$(( cur + this_per - 1 ))
  cur=$(( e + 1 ))
  if [ "$PER_NODE_CONC_DEFAULT" -gt 0 ]; then
    conc="$PER_NODE_CONC_DEFAULT"
  else
    conc=$(cap_for_node "$spec" "$this_per")
  fi
  SHARD_SPECS+=("$spec")
  SHARD_START+=("$s")
  SHARD_END+=("$e")
  SHARD_CONC+=("$conc")
  echo "  shard $i: node=$spec frames=${s}..${e} (${this_per}) conc=$conc"
done

# ---------- parallel dispatch ----------
echo ">> dispatching ${#NODES[@]} shards in parallel (frames ${NFRAMES})"
TMP_RESULTS="$(mktemp -d -t farm_results.XXXXXX)"
PIDS=()
for i in "${!NODES[@]}"; do
  (
    frames=$(dispatch_shard "${SHARD_SPECS[$i]}" "${SHARD_START[$i]}" "${SHARD_END[$i]}" "$i" "${SHARD_CONC[$i]}")
    echo "$i $frames ${SHARD_SPECS[$i]}" > "$TMP_RESULTS/$i"
  ) &
  PIDS+=($!)
done

# Wait + collect
FAILED=0
for pid in "${PIDS[@]}"; do
  wait "$pid" || FAILED=$(( FAILED + 1 ))
done

if [ "$FAILED" -gt 0 ]; then
  echo "!! $FAILED shard(s) failed; will re-queue their frames onto surviving nodes"
  # Read per-shard results from the temp dir written by dispatch_shard.
  # Each $TMP_RESULTS/$i file is:  "<i> <frames> <spec>".  Failed shards
  # have frames=0.  Re-queue their frame ranges onto alive shards, splitting
  # each dead range round-robin across the survivors, in frame order, so
  # the dispatcher can issue a single re-render pass per survivor.
  declare -a ALIVE_INDICES=()
  declare -a DEAD_RANGES=()   # space-separated "start-end" tokens
  for i in "${!NODES[@]}"; do
    if [ -f "$TMP_RESULTS/$i" ]; then
      read -r _idx _frames _spec < "$TMP_RESULTS/$i"
      expected=$(( SHARD_END[$i] - SHARD_START[$i] + 1 ))
      if [ "${_frames:-0}" -ge "$expected" ]; then
        ALIVE_INDICES+=("$i")
      else
        DEAD_RANGES+=("${SHARD_START[$i]}-${SHARD_END[$i]}")
      fi
    else
      DEAD_RANGES+=("${SHARD_START[$i]}-${SHARD_END[$i]}")
    fi
  done
  if [ "${#ALIVE_INDICES[@]}" -eq 0 ]; then
    echo "!! no surviving nodes; cannot re-queue" >&2
    exit 66
  fi
  if [ "${#DEAD_RANGES[@]}" -eq 0 ]; then
    # Every shard reported failure, but the result files all claim partial success?
    # Defensive: assume all dead and continue.
    :
  fi

  # Flatten dead ranges into a list of individual frames, then re-shard
  # them round-robin across survivors.  This is one re-assignment pass:
  # if a survivor ALSO dies on the retry, the gap surfaces below.
  dead_frames=()
  for range in "${DEAD_RANGES[@]}"; do
    s=${range%-*}; e=${range#*-}
    for ((f=s; f<=e; f++)); do dead_frames+=("$f"); done
  done
  requeue_per=$(( ${#dead_frames[@]} / ${#ALIVE_INDICES[@]} ))
  requeue_rem=$(( ${#dead_frames[@]} % ${#ALIVE_INDICES[@]} ))

  echo "  re-queuing ${#dead_frames[@]} frames across ${#ALIVE_INDICES[@]} survivors (${requeue_per} each + ${requeue_rem} extra)"
  cur=0
  requeue_pids=()
  for k in "${!ALIVE_INDICES[@]}"; do
    i=${ALIVE_INDICES[$k]}
    take=$requeue_per
    if [ $k -lt $requeue_rem ]; then take=$(( take + 1 )); fi
    if [ $take -le 0 ]; then continue; fi
    rs=$(( dead_frames[$cur] ))
    re=$(( dead_frames[$(( cur + take - 1 ))] ))
    cur=$(( cur + take ))
    echo "  re-queue shard $i: node=${SHARD_SPECS[$i]} frames=${rs}..${re} (${take})"
    (
      # Re-use the same dispatch path so rsync/render/gather stay consistent.
      # NB: we deliberately do NOT re-set SHARD_START/END — those describe the
      # original layout for gather ordering; the re-render just lands extra
      # frames in the same /tmp/farm_${base}_${i} dir which gets rsynced
      # back below.
      spec="${SHARD_SPECS[$i]}"
      conc="${SHARD_CONC[$i]}"
      target="$spec"
      [[ "$target" == *:* ]] && target="${target%:*}"
      [[ "$target" == *@* ]] || target="${SSH_USER}@${target}"
      remote_fdir="/tmp/farm_${base}_${i}"
      pov_basename="$(basename "$POV")"
      remote_pov="${remote_fdir}/${pov_basename}"
      # Re-ship the scene in case the working dir was nuked by a partial run.
      $RSYNC_BIN -az --delete \
        --include="/${pov_basename}" --include="/lib/" --include="/lib/**" --exclude="*" \
        -e "ssh -o BatchMode=yes -o ConnectTimeout=5" \
        "$HERE/" "$target:$remote_fdir/" >/dev/null 2>&1 || true
      ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" \
        "bash -s -- '$POV' '$rs' '$re' '$W' '$H' '$remote_fdir' '$remote_pov' '$POVRAY_BIN' '$conc'" <<'REMOTE_RETRY'
set -euo pipefail
pov_path="$1" shard_start="$2" shard_end="$3" W="$4" H="$5"
out_dir="$6" pov_lpath="$7" povray_bin="$8" conc="$9"
mkdir -p "$out_dir"
"$povray_bin" \
  "+I$pov_path" "+O${out_dir}/f.png" "+W$W" "+H$H" +A0.3 \
  "+L$(dirname "$pov_lpath")/lib" "+WT$conc" \
  +KFI"$shard_start" "+KFF$shard_end" +KI0.0 +KF1.0 -D \
  >"${out_dir}/render.log" 2>&1
REMOTE_RETRY
    ) &
    requeue_pids+=($!)
  done
  for pid in "${requeue_pids[@]}"; do wait "$pid" || echo "  warn: re-queue worker failed" >&2; done
fi

# ---------- gather frames back ----------
echo ">> gathering frames from nodes"
for i in "${!NODES[@]}"; do
  spec="${SHARD_SPECS[$i]}"
  target="$spec"
  [[ "$target" == *:* ]] && target="${target%:*}"
  [[ "$target" == *@* ]] || target="${SSH_USER}@${target}"
  $RSYNC_BIN -az -e "ssh -o BatchMode=yes -o ConnectTimeout=5" \
    "$target:/tmp/farm_${base}_${i}/f*.png" "$fdir/" >/dev/null || \
    echo "  warn: rsync from node $spec pulled 0 frames"
done

# ---------- sanity: do we have all NFRAMES? ----------
have=$(ls "$fdir"/f*.png 2>/dev/null | wc -l)
if [ "$have" -lt "$NFRAMES" ]; then
  echo "!! only $have/$NFRAMES frames gathered; check shard logs and node reachability" >&2
  exit 65
fi

# ---------- encode (identical to animate.sh) ----------
echo ">> encoding mp4 (${NFRAMES} frames @ ${FPS}fps)"
$FFMPEG_BIN -y -framerate "$FPS" -pattern_type glob -i "$fdir/f*.png" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 "$out" -loglevel error

if [ "$CRT" = 1 ]; then
  echo ">> applying CRT/VHS degrade pass"
  "$HERE/crt_post.sh" "$out" "${out%.mp4}_crt.mp4"
  out="${out%.mp4}_crt.mp4"
fi

# ---------- cleanup remote working dirs ----------
for i in "${!NODES[@]}"; do
  spec="${SHARD_SPECS[$i]}"
  target="$spec"
  [[ "$target" == *:* ]] && target="${target%:*}"
  [[ "$target" == *@* ]] || target="${SSH_USER}@${target}"
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" "rm -rf /tmp/farm_${base}_${i}" </dev/null || true
done

if [ "$KEEP_FRAMES" -ne 1 ]; then
  rm -rf "$fdir"
fi

echo ">> $out"
