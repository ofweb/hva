---
name: hva-new-skill
description: Help create a new Pi skill or extension for HVA.
disable-model-invocation: true
---

# New Skill

Pick the right tier:

- Needs to run every turn: extension in `pi/extensions-src/`
- Context relevant, LLM decides when to use it: normal skill in `pi/skills/`
- Only when explicitly asked: skill with `disable-model-invocation: true`

## Naming

Generic skills use plain names. HVA specific ones use the `hva-` prefix.

## Creating a skill

Drop a directory in `pi/skills/my-skill/SKILL.md`. It auto-loads. Write just enough for the LLM to know what to do.

## Creating an extension

Add the `.ts` file to `pi/extensions-src/`, add it to the copy list in `hva_ensure_pi_extension_deps` in `internals/pi-runtime.sh`, and add `--extension "$ext_dir/my-extension.ts"` to `hva_pi_base_args`.
