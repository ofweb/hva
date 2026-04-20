#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
OUTPUT="${1:-${NANOCODER_CONFIG_DIR:-$HOME/.config/nanocoder}/.mcp.json}"
OUTPUT_DIR="$(dirname "$OUTPUT")"

source "$ROOT/env/env-source.sh"
source "$ROOT/env/env-validate.sh"
env_validate_mcp_lists

if [[ -f "$OUTPUT_DIR/mcp.env" ]]; then
  set -a
  source "$OUTPUT_DIR/mcp.env"
  set +a
fi

if [[ -z "${GITHUB_PERSONAL_ACCESS_TOKEN-}" && -n "${GITHUB_TOKEN-}" ]]; then
  export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

split_csv() {
  local value="${1:-}"
  tr ',' '\n' <<< "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; /^$/d'
}

selected_mcp_servers="$(split_csv "$HVA_MCP_ENABLED" | sort)"

if [[ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]]; then
  selected_mcp_servers="$(grep -vxF github <<< "$selected_mcp_servers" || true)"
fi

if [[ -z "${BRAVE_API_KEY:-}" ]]; then
  selected_mcp_servers="$(grep -vxF brave-search <<< "$selected_mcp_servers" || true)"
fi

mkdir -p "$OUTPUT_DIR"
tmp_output="$(mktemp "$OUTPUT_DIR/.mcp.json.XXXXXX")"

if [[ -z "$selected_mcp_servers" ]]; then
  printf '%s\n' '{"mcpServers":{}}' > "$tmp_output"
else
  selected_mcp_json="$(printf '%s\n' "$selected_mcp_servers" | jq -R -s 'split("\n") | map(select(length > 0))')"
  jq --argjson selected_mcp "$selected_mcp_json" '
    {mcpServers: (.mcpServers | with_entries(select(.key as $name | $selected_mcp | index($name)) | .value.enabled = true))}
  ' "$ROOT/nanocoder/.mcp.json" > "$tmp_output"
fi

mv "$tmp_output" "$OUTPUT"
printf '%s\n' "$OUTPUT"
