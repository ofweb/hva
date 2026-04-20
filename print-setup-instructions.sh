#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
NANOCODER_DIR="${NANOCODER_CONFIG_DIR:-$HOME/.config/nanocoder}"
MODE="${1:-help}"

source "$ROOT/docker/versions.env"

usage() {
  cat <<EOF
Usage:
  ./print-setup-instructions.sh docker
  ./print-setup-instructions.sh local
EOF
}

print_docker() {
  cat <<EOF
- Run command -
cd "$ROOT" && mkdir -p models && "$ROOT/internals/sync-env-source.sh"

- Put .gguf file in $ROOT/models -
- Set LLAMA_MODEL in ./env/env-source.sh -
- Add $ROOT/scripts to PATH -
EOF
}

print_local() {
print_docker
  cat <<EOF

-- SETUP --

- Run command -
"$ROOT/internals/overwrite-local-confs.sh"

-- TOOLS --

npm install -g "@nanocollective/nanocoder@$HVA_V_NANOCODER_VERSION"
cargo install rust-docs-mcp --version "$HVA_V_RUST_DOCS_MCP_VERSION"


- OPTIONAL: github MCP (only if you care and enable it) run command -
docker pull "$HVA_V_GITHUB_MCP_SERVER_IMAGE"

-- LSP --

- Run commands -
rustup component add rust-analyzer
npm install -g "typescript@$HVA_V_TYPESCRIPT_VERSION" "typescript-language-server@$HVA_V_TYPESCRIPT_LS_VERSION" "prettier@$HVA_V_PRETTIER_VERSION" "eslint@$HVA_V_ESLINT_VERSION" "tsx@$HVA_V_TSX_VERSION" "pyright@$HVA_V_PYRIGHT_VERSION" "vscode-langservers-extracted@$HVA_V_VSCODE_LANGSERVERS_VERSION" "yaml-language-server@$HVA_V_YAML_LS_VERSION" "bash-language-server@$HVA_V_BASH_LS_VERSION" "dockerfile-language-server-nodejs@$HVA_V_DOCKERFILE_LS_VERSION"
go install "golang.org/x/tools/gopls@$HVA_V_GOPLS_VERSION"
dotnet tool install --global csharp-ls --version "$HVA_V_CSHARP_LS_VERSION"  # optional: only if you want C# LSP in native mode

- Clangd run either: pacman -S clang / apt install clangd / brew install llvm -
- Put "$NANOCODER_DIR/bin/lsp-mask" first in PATH before running nanocoder if you want HVA_LSP_ENABLED/HVA_LSP_DISABLED to apply in native mode -

-- OPTIONAL SECRETS --
- Run command -
cp -n "$ROOT/nanocoder/mcp.env.example" "$NANOCODER_DIR/mcp.env"
EOF
}

case "$MODE" in
  docker)
    print_docker
    ;;
  local|native)
    print_local
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "unknown mode: $MODE" >&2
    usage >&2
    exit 1
    ;;
esac
