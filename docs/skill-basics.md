# Skill Basics

## Three tiers

### Extensions

TypeScript, hooked into `before_agent_start`. Runs every turn, no LLM involved.

- `pi/extensions-src/agent-guidance.ts` (response style + MCP list)

### Skills

Pi injects a catalog at session start with just name + description (~50 tokens each). LLM reads the full `SKILL.md` via the `read` tool when the task matches.

- `pi/skills/hva-runtime` (LLM reads it immediately, it's obviously inside HVA)

### Manual skills

Add `disable-model-invocation: true` to frontmatter. Hidden from the catalog, LLM never sees it. User loads it with `/skill:name`.

- `pi/skills/hva-pr-review` (chunky checklist, only when reviewing an HVA PR)

20 skills loaded = ~1000 tokens for the catalog. Full skill body only read on demand.

## Other agents

|                     | always on                      | auto                      | manual                           |
| ------------------- | ------------------------------ | ------------------------- | -------------------------------- |
| Pi                  | extension `before_agent_start` | skill catalog + LLM reads | `disable-model-invocation: true` |
| Cursor              | rule always                    | rule auto-attach          | rule manual                      |
| Claude Code / Codex | `CLAUDE.md` / `AGENTS.md`      | n/a                       | n/a                              |

Cursor's auto-attach fires on file patterns. Pi doesn't have that natively but a `resources_discover` extension can do it.
