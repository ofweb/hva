#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
HVA_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd -P)"

usage() {
  cat <<EOF
Usage:
  ./benchmarking.sh

Runs every .gguf in LLAMA_MODELS, probes -ncmoe for about 1 GB free VRAM, then
records one long prompt result as CSV under benchmarking/results/.

CSV includes model size, selected -ncmoe, target/free/used/total VRAM, token
counts, completion tokens/sec, and the post-prompt health verdict.
EOF
}

case "${1:-}" in
  -h|--help|help)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    echo "unknown argument: $1" >&2
    usage >&2
    exit 1
    ;;
esac

source "$HVA_ROOT/env/env-source.sh"
source "$HVA_ROOT/env/env-validate.sh"
env_validate_common

# Edit these constants when changing the benchmark shape.
TARGET_FREE_VRAM_MB=1024
NCMOE_MIN=1
NCMOE_MAX="$LLAMA_NCMOE"
MAX_TOKENS=1024
PROBE_SETTLE_SECONDS=3
HEALTHCHECK_TAIL=800
PROMPT="Retell a fairy tale in extreme detail."
OUTPUT="$HVA_ROOT/benchmarking/results/$(date +%Y%m%d-%H%M%S).csv"

for tool in curl jq awk; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool is required" >&2
    exit 1
  fi
done

gpu_stats() {
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "NA NA NA"
    return
  fi

  nvidia-smi --query-gpu=memory.free,memory.used,memory.total --format=csv,noheader,nounits \
    | awk -F, '
        NR == 1 {
          for (index = 1; index <= 3; index++) {
            gsub(/^ +| +$/, "", $index)
          }
          print $1, $2, $3
        }
        END {
          if (NR == 0) print "NA NA NA"
        }
      '
}

gpu_free_mb() {
  local free_mb used_mb total_mb
  read -r free_mb used_mb total_mb < <(gpu_stats)
  echo "$free_mb"
}

wait_for_llama() {
  local url="http://127.0.0.1:$LLAMA_HOST_PORT/v1/models"
  local timeout=180
  local waited=0

  until curl -fsS --max-time 2 "$url" >/dev/null 2>&1; do
    if (( waited >= timeout )); then
      echo "llama server did not become ready within ${timeout}s: $url" >&2
      return 1
    fi
    sleep 2
    waited=$((waited + 2))
  done
}

start_model() {
  local model="$1"
  local ncmoe="$2"

  if ! "$HVA_ROOT/internals/run-hva-llama-cpp.sh" restart --model "$model" --ncmoe "$ncmoe" >/dev/null; then
    return 1
  fi
  wait_for_llama
}

cleanup() {
  "$HVA_ROOT/internals/run-hva-llama-cpp.sh" stop >/dev/null 2>&1 || true
}

csv_field() {
  local value="${1:-}"
  value="${value//\"/\"\"}"
  printf '"%s"' "$value"
}

write_row() {
  local first=1
  local value

  for value in "$@"; do
    if (( first == 0 )); then
      printf ',' >> "$OUTPUT"
    fi
    first=0
    csv_field "$value" >> "$OUTPUT"
  done
  printf '\n' >> "$OUTPUT"
}

probe_ncmoe() {
  local model="$1"
  local model_size_bytes="$2"
  local ncmoe="$3"
  local free_mb used_mb total_mb status

  status="ok"
  if ! start_model "$model" "$ncmoe"; then
    status="start_failed"
    free_mb="NA"
    used_mb="NA"
    total_mb="NA"
  else
    sleep "$PROBE_SETTLE_SECONDS"
    read -r free_mb used_mb total_mb < <(gpu_stats)
  fi

  write_row \
    "$(date -Iseconds)" \
    "$model" \
    "$model_size_bytes" \
    "$ncmoe" \
    "probe" \
    "$status" \
    "$TARGET_FREE_VRAM_MB" \
    "$free_mb" \
    "$used_mb" \
    "$total_mb" \
    "" \
    "" \
    "" \
    "" \
    "" \
    ""

  [[ "$status" == "ok" ]] && [[ "$free_mb" != "NA" ]] && (( free_mb >= TARGET_FREE_VRAM_MB ))
}

find_ncmoe() {
  local model="$1"
  local model_size_bytes="$2"
  local low="$NCMOE_MIN"
  local high="$NCMOE_MAX"
  local best=""
  local mid

  if [[ "$(gpu_free_mb)" == "NA" ]]; then
    echo "$LLAMA_NCMOE"
    return
  fi

  while (( low <= high )); do
    mid=$(((low + high) / 2))
    echo "  probing -ncmoe $mid" >&2

    if probe_ncmoe "$model" "$model_size_bytes" "$mid"; then
      best="$mid"
      low=$((mid + 1))
    else
      high=$((mid - 1))
    fi
  done

  if [[ -z "$best" ]]; then
    echo "$NCMOE_MIN"
  else
    echo "$best"
  fi
}

run_prompt() {
  local model="$1"
  local model_size_bytes="$2"
  local ncmoe="$3"
  local started_ms ended_ms elapsed_ms response free_mb used_mb total_mb status prompt_tokens completion_tokens total_tokens tokens_per_s health
  local payload

  payload="$(
    jq -n \
      --arg model "$LLAMA_MODEL_ALIAS" \
      --arg prompt "$PROMPT" \
      --argjson max_tokens "$MAX_TOKENS" \
      '{model: $model, messages: [{role: "user", content: $prompt}], max_tokens: $max_tokens, temperature: 0.7, stream: false}'
  )"

  status="ok"
  started_ms="$(date +%s%3N)"
  if ! response="$(
    curl -fsS \
      -H 'Content-Type: application/json' \
      -d "$payload" \
      "http://127.0.0.1:$LLAMA_HOST_PORT/v1/chat/completions"
  )"; then
    status="prompt_failed"
    response='{}'
  fi
  ended_ms="$(date +%s%3N)"
  elapsed_ms=$((ended_ms - started_ms))

  read -r free_mb used_mb total_mb < <(gpu_stats)
  prompt_tokens="$(jq -r '.usage.prompt_tokens // 0' <<< "$response")"
  completion_tokens="$(jq -r '.usage.completion_tokens // 0' <<< "$response")"
  total_tokens="$(jq -r '.usage.total_tokens // 0' <<< "$response")"
  tokens_per_s="$(
    awk -v tokens="$completion_tokens" -v ms="$elapsed_ms" \
      'BEGIN { if (ms > 0) printf "%.2f", tokens * 1000 / ms; else printf "0.00" }'
  )"

  health="OK"
  if "$HVA_ROOT/internals/healthcheck.sh" --tail "$HEALTHCHECK_TAIL" >/dev/null; then
    health="OK"
  else
    case "$?" in
      1) health="WARN" ;;
      2) health="BAD" ;;
      *) health="UNKNOWN" ;;
    esac
  fi

  write_row \
    "$(date -Iseconds)" \
    "$model" \
    "$model_size_bytes" \
    "$ncmoe" \
    "prompt" \
    "$status" \
    "$TARGET_FREE_VRAM_MB" \
    "$free_mb" \
    "$used_mb" \
    "$total_mb" \
    "$elapsed_ms" \
    "$prompt_tokens" \
    "$completion_tokens" \
    "$total_tokens" \
    "$tokens_per_s" \
    "$health"
}

mkdir -p "$(dirname "$OUTPUT")"
write_row timestamp model model_size_bytes ncmoe phase status target_free_vram_mb free_vram_mb used_vram_mb total_vram_mb elapsed_ms prompt_tokens completion_tokens total_tokens completion_tokens_per_s health
trap cleanup EXIT

mapfile -d '' model_paths < <(find "$LLAMA_MODELS" -maxdepth 1 -type f -name '*.gguf' -print0 | sort -z)
if (( ${#model_paths[@]} == 0 )); then
  echo "no .gguf files found in LLAMA_MODELS: $LLAMA_MODELS" >&2
  exit 1
fi

for model_path in "${model_paths[@]}"; do
  model_name="$(basename "$model_path")"
  model_size_bytes="$(stat -c '%s' "$model_path" 2>/dev/null || stat -f '%z' "$model_path")"
  echo "benchmarking model: $model_name"

  selected_ncmoe="$(find_ncmoe "$model_name" "$model_size_bytes")"
  echo "  selected -ncmoe $selected_ncmoe"

  start_model "$model_name" "$selected_ncmoe"
  sleep "$PROBE_SETTLE_SECONDS"
  run_prompt "$model_name" "$model_size_bytes" "$selected_ncmoe"
done

trap - EXIT
cleanup
echo "benchmark results: $OUTPUT"
