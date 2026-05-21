# Cursor Project Context

## Response style (default)

- **Minimal replies** — user trusts the work; do not narrate every step.
- **No architecture summaries** unless explicitly requested.
- After code changes: list **files touched** + **one-line test** (if needed) only.
- Do **not** update `CHANGELOG.md` unless asked.
- Prefer narrow tasks and `@file` over full-project exploration when the target is known.
- Still follow in-place edit rules and GameMaker accuracy below; brevity is for chat output, not code quality.

---

## IMPORTANT DEVELOPMENT RULES

This project uses an **in-place update system**.

When modifying code:
- NEVER rewrite entire systems unless explicitly requested.
- NEVER replace large sections of working code.
- ONLY modify the specific functions, events, or blocks necessary.
- Preserve existing architecture, formatting, comments, and naming conventions.
- Maintain compatibility with current object structures and event flow.
- Avoid introducing unnecessary abstractions or refactors.

---

# Update Strategy

Preferred workflow:
1. Locate the exact section needing modification.
2. Patch only the required logic.
3. Keep all unrelated code untouched.
4. Maintain backwards compatibility with existing systems.
5. Minimize file diffs whenever possible.

---

# GameMaker / GML Rules

This is a GameMaker Studio project using GML.

## Naming
- **`NAMING.md`** — canonical prefixes and feature-first script rules (`Dialogue_*`, `Quest_*`, `obj_`, `spr_`, `rm_`).
- New code: feature-prefixed functions and script assets; avoid `scr_` and new unprefixed globals.

## Code Style
- Prefer modular helper scripts.
- Use modern GML syntax.
- Keep Step events lightweight.
- Avoid giant rewrites.
- Avoid converting systems into completely different architectures.

## DO NOT:
- Rewrite entire objects for small fixes.
- Rename existing resources unless requested.
- Replace event-based systems with frameworks.
- Change folder structure automatically.
- Introduce unnecessary managers/controllers.

---

# Existing Architecture Must Be Preserved

The project already contains interconnected systems.

Cursor should:
- extend systems carefully
- patch logic in-place
- preserve compatibility
- avoid breaking references
- avoid deleting existing behaviors

When unsure:
- append functionality instead of replacing it
- create additive changes rather than destructive changes

---

# Preferred Modification Style

GOOD:
- small targeted edits
- helper functions
- additive features
- localized bug fixes
- preserving existing flow

BAD:
- complete rewrites
- massive refactors
- restructuring unrelated systems
- changing naming conventions
- deleting old logic automatically

---

# Output Expectations

When generating code:
- provide minimal diffs
- preserve surrounding code
- avoid placeholder pseudocode
- generate production-ready GML

When replying after edits (see Response style above):
- short file list + what changed in plain language; skip long rationale unless asked
