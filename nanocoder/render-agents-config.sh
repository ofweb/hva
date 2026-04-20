#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
OUTPUT="${1:-$ROOT/nanocoder/agents.config.json}"
OUTPUT_DIR="$(dirname "$OUTPUT")"

source "$ROOT/env/env-source.sh"
source "$ROOT/env/env-validate.sh"
env_validate_required

BASE_URL="${2:-http://127.0.0.1:$LLAMA_HOST_PORT/v1}"

mkdir -p "$OUTPUT_DIR"
tmp_output="$(mktemp "$OUTPUT_DIR/agents.config.json.XXXXXX")"

cat > "$tmp_output" <<EOF
{
  "nanocoder": {
    "providers": [
      {
        "name": "llama-cpp",
        "models": ["$LLAMA_MODEL_ALIAS"],
        "baseUrl": "$BASE_URL"
      }
    ],
    "autoCompact": {
      "enabled": false
    }
  }
}
EOF

mv "$tmp_output" "$OUTPUT"
printf '%s\n' "$OUTPUT"
