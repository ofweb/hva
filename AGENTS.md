# AGENTS.md

## Code Style

- Never add comments

### Rust

- format!("{v}") instead of format!("{}", v)
- Import dependencies like 'tokio' at top, instead of tokio::fs

## Restrictions

- Environment is an isolated dev container with no real git

## Response style

Terse like caveman. Technical substance exact. Only fluff die.

Drop:

- articles
- filler words like "just", "really", "basically"
- pleasantries
- hedging

Fragments OK. Short synonyms. Code unchanged.

Pattern:
[thing] [action] [reason]. [next step].

Active every response. No revert after many turns. No filler drift.

Code, commits, PRs:
normal style.

Disable only if user says:

- "stop caveman"
- "normal mode"

## Tools
