# Unused data — manual review checklist

Work through each section in order. Check boxes when you have **opened the asset in GameMaker or the folder in Explorer**, confirmed the notes, and decided keep / remove / defer.

**Legend**
- **Remove** — safe to delete after backup (or already decided)
- **Keep** — still needed or planned
- **Defer** — decide later; leave unchecked until done

---

## Before you start

- [ ] Commit or back up the project (git commit or zip copy)
- [ ] Close GameMaker, or save all, before deleting folders on disk
- [ ] Note today’s date: ___________

---

## 1. Orphan folders (on disk, NOT in `Blank Pixel Game3.yyp`)

GameMaker does not compile these. They are likely old tutorial leftovers.

### Orphan objects (`objects/`)

- [ ] `objects/objBowTeal/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objCape/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objArmorCrystal/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objJellyBlue/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objJellyRed/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objKnife/` (duplicate of registered `obj_knife`) — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objStaff/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `objects/objSword/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer

### Orphan sprites (`sprites/`)

- [ ] `sprites/sprBowTeal/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprCape/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprCrystalArmor/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprJellyBlue/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprJellyRed/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprKnife/` (duplicate of registered `spr_knife`) — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprStaff/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer
- [ ] `sprites/sprSword/` — **Decision:** ☐ Keep ☐ Remove ☐ Defer

### Orphan sequence

- [ ] `sequences/sqDescriptionAnimation/` (uses `spr_description`; not in `.yyp`) — **Decision:** ☐ Keep ☐ Remove ☐ Defer

### Batch action (after individual review)

- [ ] Deleted all orphan folders marked **Remove** (or moved to `_archive/` outside the project)
- [ ] Re-opened project in GameMaker — no missing-resource errors

---

## 2. Registered resources — verify use in game

Open each in the Asset Browser. Search project (Ctrl+Shift+F) for the asset name if unsure.

### Likely unused

- [ ] **`obj_furnace`** — No events; furnace in room is `obj_resource` + `spr_furnace`. Remove from project? ☐ Yes ☐ No ☐ Defer
- [ ] **`spr_ui_sheet`** — No `.gml` references. Still needed for future UI? ☐ Keep ☐ Remove ☐ Defer
- [ ] **`spr_description`** — Only tied to orphan sequence. ☐ Keep ☐ Remove ☐ Defer
- [ ] **`fntLarger`** — All UI uses `fntSmaller`. ☐ Keep ☐ Remove ☐ Defer
- [ ] **`fonts/fntLarger/fntLarger.old.yy`** — IDE backup file on disk. ☐ Delete ☐ Keep

### Used indirectly (confirm before removing)

- [ ] **`spr_npc`** — Default on `obj_npc`; room NPCs usually override `sprite_index`. Any instance still showing generic NPC sprite? ☐ Keep ☐ Remove ☐ Defer
- [ ] **`spr_init`** — Default on `obj_init` (bootstrap room only). ☐ Keep ☐ Remove ☐ Defer
- [ ] **`spr_furnace`** — Used by furnace **resource** creation code (keep if furnace stays)

### Item objects (inventory preview only — not world pickups)

Confirm hover inventory still shows icons; then decide if you need world-drop versions later.

- [ ] `obj_bronze_axe` — ☐ Keep ☐ Remove from project ☐ Defer
- [ ] `obj_bronze_pickaxe` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `obj_knife` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `obj_simple_staff` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `obj_normal_log` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `obj_copper_ore` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `obj_copper_bar` — ☐ Keep ☐ Remove ☐ Defer

---

## 3. Included files (`datafiles/` — not loaded in GML)

Runtime UI uses **`spr_ui_*`** sprites. These PNGs may be source art only.

- [ ] `datafiles/ui_slices/ui_panel.png` — ☐ Keep as source ☐ Remove from Included Files ☐ Defer
- [ ] `datafiles/ui_slices/ui_slot.png` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `datafiles/ui_slices/ui_slot_selected.png` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `datafiles/ui_slices/ui_skill_row.png` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `datafiles/ui_slices/ui_tab.png` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `datafiles/ui_slices/ui_xp_bar_back.png` — ☐ Keep ☐ Remove ☐ Defer
- [ ] `datafiles/ui_slices/ui_xp_bar_fill.png` — ☐ Keep ☐ Remove ☐ Defer

### Design docs (documentation — not game runtime)

- [ ] `datafiles/proof_of_concept_the_markless.md` — ☐ Keep ☐ Archive elsewhere
- [ ] `datafiles/skill_progression_system.md` — ☐ Keep ☐ Archive elsewhere
- [ ] `datafiles/npc_trainer_direction.md` — ☐ Keep ☐ Archive elsewhere

---

## 4. Dead or stale code (optional code cleanup)

Only change code when you intend to; check when reviewed.

- [ ] `enum Ailment` in `objects/obj_items/Create_0.gml` — unused by active game ☐ Remove later ☐ Keep for future ☐ Defer
- [ ] `global.story_opening_seen` — never set to `true` ☐ Wire up ☐ Remove ☐ Defer
- [ ] `global.spawn_x` / `global.spawn_y` — never set ☐ Wire up room transitions ☐ Remove ☐ Defer
- [ ] `menuHeight` on `obj_controller` — assigned, never read ☐ Remove ☐ Keep ☐ Defer
- [ ] `CameraMiddleY()` in `scripts/Camera/Camera.gml` — never called ☐ Remove ☐ Keep ☐ Defer
- [ ] `Type.Armor` / `Type.Consumable` — no master-list items yet ☐ Keep for future ☐ Defer

---

## 5. Room instances (`rm_tutorial`)

Open room in IDE; run game and click each instance.

- [ ] **`inst_Null`** (`obj_npc` @ 144, 288) — Placeholder “UPDATE” dialogue; creation code flag but **no** `.gml` file ☐ Delete instance ☐ Add creation code ☐ Keep
- [ ] **`inst_woodcutting_trainer`** (`obj_npc` @ 432, 272) — No creation code; duplicate of real trainer? ☐ Delete ☐ Configure ☐ Keep
- [ ] **`inst_5DC201E7`** (`obj_woodcutting_trainer` @ 112, 160) — Real woodcutting trainer ☐ Confirmed working
- [ ] Welcomer, mining trainer, crafting trainer, tree, ore, furnace — ☐ All interact correctly after any cleanup

---

## 6. After cleanup — smoke test

- [ ] Project opens in GameMaker without errors
- [ ] Run game from `rm_init` → tutorial room loads
- [ ] Move (WASD + click), open inventory, all three tabs
- [ ] Talk to Welcomer; woodcutting quest flow still works
- [ ] Chop tree, mine ore, smelt at furnace
- [ ] No missing sprites / pink squares
- [ ] Git commit cleanup (if using git): message ___________

---

## Notes

_Use this space for decisions, IDE-only steps, or assets you re-added._

```
Date:
Reviewed by:




```
