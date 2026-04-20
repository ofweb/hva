#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
OUTPUT_DIR="${1:-${NANOCODER_CONFIG_DIR:-$HOME/.config/nanocoder}/bin/lsp-mask}"

source "$ROOT/env/env-source.sh"
source "$ROOT/env/env-validate.sh"
env_validate_lsp_lists

mkdir -p "$OUTPUT_DIR"
find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -type f -delete

is_enabled() {
  local name="$1"
  [[ ",$HVA_LSP_ENABLED," == *",$name,"* ]]
}

write_disabled_shim() {
  local command_name="$1"
  local lsp_name="$2"
  cat > "$OUTPUT_DIR/$command_name" <<EOF
#!/usr/bin/env bash
echo "$command_name disabled by HVA_LSP_DISABLED entry: $lsp_name" >&2
exit 127
EOF
  chmod 0755 "$OUTPUT_DIR/$command_name"
}

maybe_mask() {
  local lsp_name="$1"
  shift
  if is_enabled "$lsp_name"; then
    return
  fi
  local command_name
  for command_name in "$@"; do
    write_disabled_shim "$command_name" "$lsp_name"
  done
}

maybe_mask rust rust-analyzer
maybe_mask typescript typescript-language-server
maybe_mask python pyright-langserver
maybe_mask json vscode-json-language-server
maybe_mask html vscode-html-language-server
maybe_mask css vscode-css-language-server
maybe_mask yaml yaml-language-server
maybe_mask bash bash-language-server
maybe_mask docker docker-langserver
maybe_mask go gopls
maybe_mask clangd clangd
maybe_mask csharp csharp-ls

printf '%s\n' "$OUTPUT_DIR"
