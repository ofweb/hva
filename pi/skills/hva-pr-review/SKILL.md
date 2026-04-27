---
name: hva-pr-review
description: Review a PR or diff of changes made to the HVA repository itself.
disable-model-invocation: true
---

# HVA PR Review

Go through each section that applies. Note yes/no and what you found.

## New CLI flag

- In `completions/hva.bash` flags array?
- In `completions/hva.fish`?
- If it takes a value, handled in the `prev` case?

## New config key

- In `env/env-validate.sh` `ENV_CONFIG_KEYS` and the right validation array?
- In `config/hva-conf.json.sample`?

## New MCP

- In `KNOWN_MCP_KEYS` in `env/env-validate.sh`?
- In `KNOWN_MCP` in `agent-guidance.ts`?
- Wired up in `mcp-tools.ts`?

## General

- User-facing changes documented in `readme.md` or `docs/`?
- New workspace writes cleaned up in `cleanup()` in `scripts/hva`?
