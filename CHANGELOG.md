# Project change log

Record of edits made during Cursor / agent sessions. GameMaker resource changes are noted by path; IDE-only work (new sprites, etc.) should be listed under **Manual (IDE)**.

## How to use

Add a new dated section at the **top** (newest first). Each entry should include:

- **What** — short summary of the change
- **Why** — goal or bug fixed (optional)
- **Files** — paths touched (objects, scripts, rooms, creation code)
- **Test** — what to verify in-game (optional)

---

## 2026-05-18

### Crafting trainer knife grant shows dialogue

- **What:** After granting a Knife, crafting trainer now calls `obj_dialogue.show()` like other branches.
- **Why:** Player got the item with no feedback and stale dialogue choices.
- **Files:** `objects/obj_crafting_trainer/Create_0.gml`
- **Test:** Meet prerequisites, talk to Crafting Trainer, choose "Can you teach me?" without a Knife.

### Fix missing interact on mining and crafting trainers

- **What:** Added `interact` to `obj_mining_trainer` and `obj_crafting_trainer` Create events (child Create overrides parent, so `obj_npc.interact` never ran).
- **Why:** Talk-to / context-menu dialogue crashed or failed with undefined `interact`.
- **Files:** `objects/obj_mining_trainer/Create_0.gml`, `objects/obj_crafting_trainer/Create_0.gml`
- **Test:** Talk to Mining Trainer and Crafting Trainer; dialogue opens with choices.

### Fix context-menu Move here on NPCs and resources

- **What:** Added `StartMoveToAdjacentWalkableTile` to pick the nearest **path-reachable** walkable tile around a target. Context-menu "Move here" on NPCs/resources uses the target's tile; plain clicks still use the mouse tile.
- **Why:** Old logic picked the first walkable tile near the click without checking pathfinding, so moves onto blocked tiles did nothing.
- **Files:** `objects/obj_controller/Create_0.gml`
- **Test:** Right-click NPC or tree → Move here; player should walk to closest reachable adjacent tile.

### NPC instance creation code moved to dedicated objects

- **What:** Added `obj_mining_trainer` and `obj_crafting_trainer` (child objects of `obj_npc`). Moved room instance creation code into each object's Create event. Updated `rm_tutorial` to place dedicated trainer objects; removed placeholder `inst_Null` and duplicate `obj_npc` woodcutting instance.
- **Why:** NPC dialogue and setup belong on objects, not per-room creation code.
- **Files:** `objects/obj_mining_trainer/`, `objects/obj_crafting_trainer/`, `objects/obj_controller/Create_0.gml`, `rooms/rm_tutorial/rm_tutorial.yy`, `Blank Pixel Game3.yyp`; deleted `InstanceCreationCode_inst_mining_trainer.gml`, `InstanceCreationCode_inst_crafting_trainer.gml`
- **Test:** Run `rm_tutorial`; talk to Welcomer, Woodcutting Trainer (112,160), Mining Trainer, Crafting Trainer; verify pickaxe/knife quests and pathfinding.

### Added unused-data manual checklist

- **What:** Created `UNUSED_DATA_CHECKLIST.md` for manual review of orphan assets, unused resources, and smoke tests.
- **Why:** Follow-up to unused-data audit; track keep/remove decisions.
- **Files:** `UNUSED_DATA_CHECKLIST.md`, `CHANGELOG.md`
- **Test:** Open checklist; no in-game effect.

### Added change log file

- **What:** Created `CHANGELOG.md` to track session edits.
- **Why:** Simple record of changes made with the AI assistant.
- **Files:** `CHANGELOG.md`
- **Test:** Open this file in the repo; no in-game effect.
