# Cursor Project Context

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
- explain exactly what changed
- preserve surrounding code
- avoid placeholder pseudocode
- generate production-ready GML
