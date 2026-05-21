# Naming Conventions

Canonical naming rules for this GameMaker project. **New work follows this doc.** Existing assets may predate it; rename only with an explicit migration (update `.yyp`, `.yy`, and all references).

## Principles

1. **Feature-first** — group logic by gameplay system (`Dialogue`, `Quest`, `Inventory`), not by asset type alone.
2. **Grep-friendly** — function names start with the feature prefix (`DialogueConversation_Start`, not `StartConversation`).
3. **Stable asset IDs** — GameMaker resource names are identifiers; renames are costly. Prefer correct names on **new** resources.
4. **Thin objects, fat scripts** — objects (`obj_*`) hold instance state and thin events; shared rules live in script assets under `scripts/<Feature>/`. Use `<Feature>_Register(id)` from Create; Step/Draw call one bound method (e.g. `StepDialogueInput()`, `DrawFixedUI()`). Avoid 200+ line object events.
5. **Systems ≠ content** — reusable engines do not embed story text, NPC-specific quest checks, or one-off lines. See [Systems vs content](#systems-vs-content).

---

## Systems vs content

Narrative RPGs rot when dialogue engines, UI, quest state, and writer copy live in one file. Split by **layer**:

| Layer | Role | Examples in this project | Must not contain |
|-------|------|--------------------------|------------------|
| **System** | Reusable rules, no story | `DialogueConversation`, `DialogueTypewriter`, `DialogueInput`, `DialogueLayout`, `Quest`, `GameState`, `Pathfinding` | Welcomer lines, trainer names, quest-specific branch text |
| **Presentation** | Draw/layout/chrome | `DialogueUI`, `DialogueLayout`, `ControllerUI`, `UIDraw` | Quest progress checks, beat copy |
| **Content** | Copy, catalogs, beat tables | `DialogueWelcomerData` | `Quest_Woodcutting_GetState`, session routing |
| **Director** | One NPC/quest flow wiring | `DialogueWelcomer`, `GuidedIntro` | Long prose strings (delegate to `*Data`) |
| **Progress adapter** | Map global state → flow IDs | `WelcomerProgress` | Dialogue lines, `DialogueBeat_*` assembly |
| **Instance** | `obj_dialogue`, `obj_welcomer` | State fields, `interact()`, tour motion | Full beat tables, BFS, inventory draw |

### Dependency direction (allowed calls)

```
Content (*Data)     → may read Progress for dynamic prompt variants only
Director (*Welcomer) → System + Content + Progress + GameState/Quest side effects via Progress
Progress             → GameState, Quest, Quest_* (never DialogueBeat_*, never UI draw)
System (Dialogue*)   → other Dialogue* only; never Quest_* or Welcomer copy
Quest                → inventory/state; never Welcomer node text
```

### Adding a new NPC conversation

**Simple trainer / menu NPC (copy Woodcutting pattern):**

1. **`DialogueNpcName.gml`** — `DialogueNpcName_Open(_inst)`, `GetGreeting`, `BuildChoices`, action helpers.
2. **`Open`** calls `Dialogue_PresentMenu` only; quest flags read `Quest_*` / `GameState_*`, not Create.
3. **Object** — `OpenDialogueMenu = function() { DialogueNpcName_Open(id); }` (+ `interact` → `Dialogue_InteractNpc`).
4. **`NpcNameData`** (optional) — static lines if the NPC grows beyond a single menu.

**Welcomer-style (beats + branches):**

1. **`DialogueWelcomerData`** — copy tables.
2. **`WelcomerProgress`** — briefing/trial gates.
3. **`DialogueWelcomer`** — `DialogueWelcomer_Open`, node/branch directors.
4. **`obj_welcomer`** — `DialogueWelcomer_Open(id)` only from `OpenDialogueMenu`.

Do **not** extend `DialogueConversation` with story-specific branches.

### Welcomer stack (reference)

| Asset | Layer |
|-------|--------|
| `DialogueConversation`, `DialogueSession`, `DialogueTypewriter`, `DialogueInput`, `DialogueLayout` | System |
| `DialogueUI` | Presentation |
| `DialogueWelcomerData` | Content |
| `WelcomerProgress` | Progress adapter |
| `DialogueWelcomer` | Director |
| `GuidedIntro` | Director (tour motion + beat timing) |
| `GameState`, `Quest` | System / progression |

### Create events (thin only)

**Do not** put dialogue trees, quest setup, item catalogs, or `Build*Choices()` bodies in object Create events.

| Create may contain | Move to script |
|--------------------|----------------|
| `event_inherited()` | — |
| Field defaults / room creation-code placeholders | — |
| One `Feature_Register(id)` call | `TrainerWoodcutting`, `WelcomerNpc`, `ResourceGather`, … |
| Singleton guard (`instance_number`) | — |
| Global enums (`Item`, `Type`) if loaded once | optional `ItemsCatalog` for rows only |

**Pattern:** `OpenDialogueMenu()`, `BuildWoodcuttingChoices()`, `GetWoodcuttingGreeting()`, `ItemsCatalog_Bootstrap()` live in scripts; Create only wires the instance.

### Red flags (fix before merging)

- `Quest_*` or `GameState_*` inside `DialogueWelcomerData` beat tables (except dynamic prompt variant via `WelcomerProgress_*`).
- Multi-paragraph strings inside `DialogueConversation` or `obj_dialogue`.
- More than ~40 lines in a Create event (excluding inherited call + field defaults).
- `draw_*` in `Quest.gml` or `DialogueWelcomer.gml`.
- New trainer dialogue copy pasted into `DialogueUI`.

---

## Resource type prefixes (required)

| Prefix | Asset type | Example |
|--------|------------|---------|
| `obj_` | Object | `obj_player`, `obj_dialogue` |
| `spr_` | Sprite | `spr_player` |
| `rm_` | Room | `rm_tutorial`, `rm_init` |
| `fnt_` | Font | `fntSmaller` (legacy camelCase OK for fonts) |
| `snd_` | Sound | (when added) |
| `seq_` | Sequence | (when added) |

**Do not** create new `scr_` script assets (legacy GameMaker style). Use a **feature folder + script asset** instead (see Scripts).

**Avoid** inventing parallel short prefixes (`dlg_`, `gs_`, `ui_`, `npc_`) for script *functions* — they fight the feature-prefix model below. Use them only if a future *object* family needs a distinct ID (e.g. `obj_npc_trainer` child of `obj_npc`).

---

## Scripts (preferred pattern)

### Script asset & folder

- One **feature** per script asset: `DialogueConversation`, `Quest`, `PlayerMovement`.
- Files live at `scripts/<FeatureName>/<FeatureName>.gml` (matches Asset Browser folder).
- Script asset **name** = folder name = primary feature identifier.

### Functions

```
<Feature>_<Action>
```

Examples already in the project:

- `DialogueBeat_Line`, `DialogueConversation_Start`, `DialogueLayout_Register`
- `GameState_Init`, `GameState_InitSkillsAndRng`
- `Quest_Woodcutting_Start`, `Quest_Woodcutting_CanComplete`
- `Inventory_GrantItem`, `PlayerMovement_Register`
- `DialogueWelcomer_PlayIntroNode`, `DebugOverlay_Init`

**Register pattern** (bind methods onto an instance from Create):

```
<Feature>_Register(_inst)
```

Use for: `DialogueConversation_Register`, `DialogueLayout_Register`, `PlayerMovement_Register`, etc.

### Sub-features

When a system grows, split script assets by **sub-feature**, still PascalCase:

| Sub-feature | Script assets |
|-------------|----------------|
| Dialogue core | `Dialogue`, `DialogueSession`, `DialogueConversation`, `DialogueLayout`, `DialogueInput`, `DialogueTypewriter`, `DialogueUI` |
| Welcomer NPC | `DialogueWelcomer`, `DialogueWelcomerData` |
| Player | `PlayerMovement`, `PlayerPathing`, `PlayerInteraction`, `PlayerAnimation` |
| Quest / story | `Quest`, `StoryOpening`, `GuidedIntro` |
| World / boot | `GameState`, `Camera` |
| Controller input/UI | `Pathfinding`, `ContextMenu`, `ControllerUI`, `UIHelpers` |
| Debug | `DebugOverlay` |

### Macros & constants

Use **SCREAMING_SNAKE** with a **feature prefix**:

```gml
#macro DIALOGUE_BEAT_LINE "line"
#macro QUEST_WOODCUTTING_ITEM "Normal Log"
#macro DIALOGUE_WELCOMER_NODE_ARRIVAL "arrival"
```

Quest keys and global flags: prefer `quest_*` / `global.*` names documented next to `Quest_*` functions in `Quest.gml` / `GameState.gml`.

### Data-only scripts

Static tables and catalogs: suffix `Data` — `DialogueWelcomerData` (nodes, branches, copy IDs). Runtime API stays in `DialogueWelcomer`.

---

## Objects (`obj_`)

| Pattern | Use |
|---------|-----|
| `obj_<role>` | Singleton-style actors / systems: `obj_player`, `obj_controller`, `obj_dialogue`, `obj_init` |
| `obj_<npc_role>` | Specific NPC types: `obj_welcomer`, `obj_woodcutting_trainer` |
| `obj_<parent>_…` | Inheritance: children of `obj_npc`, `obj_resource`, `obj_items` |
| `obj_<item_id>` | Pickup / item instances: `obj_copper_ore`, `obj_bronze_axe` (match inventory item names) |
| `obj_debug_*` | Debug-only instances: `obj_debug_overlay` |

**Parent objects** keep the family prefix: `obj_resource` → `obj_resource_tree`, `obj_resource_ore`, `obj_npc` → trainers.

Instance variables: `snake_case` (`move_target_x`, `resource_depleted`). Booleans: `is_*` / `has_*` where the project already does (`is_moving`).

---

## Sprites (`spr_`)

- Match the primary object or item: `spr_player`, `spr_welcomer`.
- Shared UI/world art: `spr_<description>` (`spr_speech_bubble`).

---

## Rooms (`rm_`)

- `rm_init` — boot / loader
- `rm_<location>` — gameplay spaces: `rm_tutorial`

Room instance creation code: set **data fields** only; call feature APIs (`DialogueWelcomer_*`, `resource_name = "…"`) instead of duplicating logic.

---

## UI & drawing

- World draw: object Draw events.
- Screen-space UI: Draw GUI (`Draw_64`) on `obj_controller`, `obj_dialogue`, `obj_debug_overlay`.
- Layout helpers: `DialogueUI_*`, `DialogueLayout_*`, `UIHelpers_*` — prefer **`Dialogue*`** for dialogue-specific UI; generic chrome stays in `UIHelpers` until a rename migration.

---

## Feature map (where new code goes)

| Domain | Script prefix / assets | Primary object(s) |
|--------|------------------------|-------------------|
| Dialogue & prompts | `Dialogue*` | `obj_dialogue` |
| Welcomer story | `DialogueWelcomer_Open`, `DialogueWelcomerData`, `WelcomerProgress` | `obj_welcomer` → `DialogueWelcomer_Open` |
| Woodcutting trainer | `DialogueWoodcuttingTrainer_Open`, `GetGreeting`, `BuildChoices` | `obj_woodcutting_trainer` → `DialogueWoodcuttingTrainer_Open` |
| Global progression | `GameState_*`, `StoryOpening_*`, `GuidedIntro_*` | `obj_controller`, `obj_init` |
| Quests | `Quest_*` | `obj_controller` (UI), trainers |
| Inventory & skills | `Inventory_*`, `Skill*` (legacy names inside `Inventory.gml`) | `obj_player`, grids on controller |
| Player | `Player*` | `obj_player` |
| Path / click / menu | `Pathfinding_*`, `ContextMenu_*`, `ControllerUI_*`, `UIHelpers_*` | `obj_controller` |
| UI primitives | `UI_DrawPanel`, `UI_DrawBorderedPanel`, `UI_DrawChoiceList` (`UIDraw`) | any Draw GUI |
| Player path queue | `PlayerPathing_*` | `obj_player` |
| Dialogue session | `DialogueSession_*` (instance: `show`, `hide`, `prompt`) | `obj_dialogue` |
| Resources | instance fields + `obj_resource` events | `obj_resource_*` |
| Camera | `Camera_*` | (bound from player/controller) |
| Debug | `DebugOverlay_*`, `debug_panel_*` globals | `obj_debug_overlay` |

---

## Legacy names (do not extend; migrate when touching)

| Current | Preferred direction |
|---------|---------------------|
| `scr_*` script assets | Feature folder script (`Dialogue`, `Quest`, …) |
| `Pathfinding`, `ContextMenu`, `UIHelpers` | `ControllerPathfinding` or keep folder but use `Controller_*` functions |
| `AddItem`, `HasItem`, `GetSkillLevel` in `Inventory.gml` | `Inventory_AddItem`, `Inventory_HasItem`, `Inventory_GetSkillLevel` (gradual) |
| `UIHelpers` | `ControllerUI_*` if split from dialogue |
| Font `fntSmaller` | Accept; new fonts use `fnt_` |

Renaming a script asset requires: IDE rename (or careful `.yy` + `.yyp` edit), update every `function` call site, and re-run the game.

---

## Checklist for new resources

- [ ] Object/sprite/room uses the correct `obj_` / `spr_` / `rm_` prefix.
- [ ] Script asset is named after the **feature**, not `scr_` or a vague verb.
- [ ] Public functions use `<Feature>_<Action>`.
- [ ] Macros use `<FEATURE>_<NAME>`.
- [ ] Item / resource strings match inventory master list exactly.
- [ ] Debug or dev-only code is behind `debug_*` / `DebugOverlay_*` gates.
- [ ] Asset Browser folder matches feature (`Scripts/Dialogue/`, `Objects/Actors/`, …).

---

## AI / contributor note

When adding code, **match the nearest existing feature** before inventing a new prefix. If unsure, read `scripts/` and mirror `DialogueConversation` / `Quest` / `PlayerMovement` — not one-off `scr_` or un-prefixed globals.

See also `AGENTS.md` (engineering rules) and `PROJECT_CONTEXT.md` (update strategy).
