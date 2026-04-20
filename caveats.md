# Caveats

## Nanocoder patches

- `docker/Dockerfile.safeprison` patches `@nanocollective/nanocoder` compiled JS directly with `sed` at build time
- nanocoder has no official env var hooks for dev mode, auto-accept, or container trust — hence the patching
- each patch verified with `grep -q`, so docker build fails loudly if they stop matching after a nanocoder update
- if nanocoder updates and it breaks: rebuild, it'll fail on the grep, fix the sed targets

## C# LSP

- csharp-ls is registered with nanocoder's LSP server discovery via the same sed mechanism
- opt-in: `HVA_CSHARP=true hva --build-docker-prison` (off by default)
- same caveat as above — more sed surface area for a narrow use case
- even when installed, `HVA_LSP_ENABLED` / `HVA_LSP_DISABLED` can still mask it at runtime

## Docker flags

- opt-in: `HVA_UNSAFE=1`
- `--cap-add SYS_PTRACE` + `--security-opt seccomp=unconfined`: needed for debuggers (gdb, strace, valgrind) inside the container
- `-v /var/run/docker.sock:/var/run/docker.sock`: lets the container run docker commands on the host
- NOTE: the container is not a strong security boundary when unsafe mode is on

## Host config mounts

- `~/.gitconfig` and `~/.config/nvim` are no longer auto-mounted
- opt-in with `HVA_MOUNT_GITCONFIG=1` and `HVA_MOUNT_NVIM=1`
- `~/.ssh` stays opt-in through `HVA_MOUNT_SSH=1`
