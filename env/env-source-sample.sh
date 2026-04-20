#!/usr/bin/env bash

LLAMA_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
LLAMA_ENV_ROOT="$(cd "$LLAMA_ENV_DIR/.." && pwd -P)"

# Directory containing model files
export LLAMA_MODELS="$LLAMA_ENV_ROOT/models"

# Model filename. Use empty string only when LLAMA_MODELS contains exactly one .gguf file.
export LLAMA_MODEL="Qwen3.6-35B-A3B-UD-Q5_K_XL.gguf"

# Stable API model name exposed by llama.cpp and used by Nanocoder.
export LLAMA_MODEL_ALIAS="local"

# Docker container name (used by internals/run-hva-llama-cpp.sh and hva)
export LLAMA_CONTAINER="hva-llama-server"

# Host port for llama server API (used by internals/run-hva-llama-cpp.sh and hva)
export LLAMA_HOST_PORT="8080"

# Context size in tokens
export LLAMA_CONTEXT_SIZE="262144"

# Reasoning budget tokens
export LLAMA_REASONING_BUDGET="-1"

# MoE expert cap (higher -> more cpu and less gpu usage)
export LLAMA_NCMOE="11"

# MCP servers to enable (comma-separated)
# All available: github,ripgrep,rust-docs,pypi,npm-search,duckduckgo-search,brave-search
# If you remove from here, add to HVA_MCP_DISABLED
export HVA_MCP_ENABLED="rust-docs,ripgrep,duckduckgo-search"

# MCP servers to disable
export HVA_MCP_DISABLED="github,pypi,npm-search,brave-search"

# LSPs to enable (comma-separated)
# All available: rust,typescript,python,json,html,css,yaml,bash,docker,go,clangd,csharp
# clangd covers C/C++. csharp also needs HVA_CSHARP=true and rebuild.
export HVA_LSP_ENABLED="rust,typescript,python,json,html,css,yaml,bash,docker,go,clangd"

# LSPs to disable
export HVA_LSP_DISABLED="csharp"

# Behavior flags (must be explicitly set to 0 or 1; can be overridden inline: HVA_UNSAFE=1 hva)
export HVA_COPY_AGENTS="${HVA_COPY_AGENTS:-1}"   # copy example-agent.md to new workspaces as AGENTS.md
export HVA_LOAD_MCP_ENV="${HVA_LOAD_MCP_ENV:-1}" # load ~/.config/nanocoder/mcp.env for API keys
export HVA_MOUNT_GITCONFIG="${HVA_MOUNT_GITCONFIG:-0}" # mount ~/.gitconfig into container (read-only)
export HVA_MOUNT_NVIM="${HVA_MOUNT_NVIM:-0}"      # mount ~/.config/nvim into container (read-only)
export HVA_MOUNT_SSH="${HVA_MOUNT_SSH:-0}"        # mount ~/.ssh into container (read-only)
export HVA_UNSAFE="${HVA_UNSAFE:-0}"              # SYS_PTRACE, seccomp=unconfined, docker socket — see caveats.md

# Build flags (require rebuild: hva --build-docker-prison)
export HVA_CSHARP="${HVA_CSHARP:-false}"          # include C# LSP (csharp-ls + dotnet); true or false
