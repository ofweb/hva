---
name: git
description: "Use first for git status, history, branches, commits, diffs, review, and repo-history questions."
---

# Git

Use this when the user asks about:

- `git status`
- commit history
- branches
- diffs
- merge-base
- "what changed?"
- local review

If the runtime says git is not mounted, do not use git commands here.

Say git is not available in this session.

If the runtime says git is mounted, git commands are allowed inside the session.

Never push.

For local diff review inside the session, prefer `/git`.

It prepares the diff first and then sends the review prompt.

For direct git lookups, use plain git commands that match the question.

Examples:

- `git status --short`
- `git log --oneline --decorate -n 20`
- `git branch --all`
- `git diff --stat`

For explicit review targets, `/git` or `/hva/internals/git-diff.sh` are the better path.
