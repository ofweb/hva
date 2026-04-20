# Hva'? (hva) - Local Vibecode Setup

- Local llama.cpp server
- Nanocoder in a yolo-mode dev container (with lsp + mcp setup)
- Setup by default for `Qwen3.6-35B-A3B`

## Quick start

```bash
./print-setup-instructions.sh docker
```

Run from any project:

```bash
hva
```

Docker mode runs Nanocoder in yolo mode and trusts container/workspace paths by
default. Expect no approval prompts inside the dev container.

## Useful commands

- `hva --bash`: shell in dev container
- `hva --prompt "text"`: one-shot Nanocoder run
- `hva --prompt-file FILE`: one-shot Nanocoder run from file
- `hva --diff-review-main`: code review diff vs main/master
- `hva --diff-review-branch BRANCH`: code review diff from merge-base(BRANCH)
- `hva --diff-review-unstaged`: code review unstaged changes
- `hva --diff-review-staged`: code review staged changes
- `hva --diff-review-all`: code review all tracked + untracked changes
- `hva --diff-review SHA`: code review from SHA to HEAD
- `hva --stop`: stop llama server
- `hva --daemon`: start llama server in background
- `hva --healthcheck`: compact llama health verdict
- `hva --llama-cpp-logs-full`: full llama container logs
- `hva --build-docker-prison`: build dev image if missing/outdated (`--force` to rebuild anyway)
- `hva --check-versions`: check pinned vs latest upstream versions
- `hva --llama-cpp-update`: update pinned llama.cpp image digest, then pull it

## More Info

- More [Docker Setup Docs](docs/docker.md)
- Extra Optional [Native Nanocoder setup](docs/local.md)
- [Model used on a 5090 24GB (Qwen3.6-35B-A3B-GGUF)](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF)
- [Direct Link: Qwen3.6-35B-A3B-UD-Q5_K_XL.gguf](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen3.6-35B-A3B-UD-Q5_K_XL.gguf)
