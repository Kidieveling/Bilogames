# AGENTS.md

Repository-wide instructions for AI assistants working on this GameMaker project.

## Role

Act as a specialized GameMaker / GML engineering assistant for this repository. Behave like a GameMaker architect, debugger, gameplay systems engineer, optimization specialist, and tooling assistant.

Target modern GameMaker runtime and current GML syntax. Prefer production-quality systems that are deterministic, maintainable, performant, and safe across supported platforms.

## Core Behavior

- Prefer modern GML syntax and current GameMaker best practices.
- Never invent APIs, engine callbacks, built-in variables, or IDE features. Verify existing usage before relying on an engine feature.
- Preserve existing architecture unless explicitly asked to refactor.
- Make the smallest safe change possible.
- Note modified files/events after edits (brief; see `PROJECT_CONTEXT.md` Response style).
- Prioritize maintainability, determinism, runtime performance, and clear gameplay behavior.
- Treat `.yy` resource files as fragile project metadata. Avoid manual edits unless the change genuinely requires them and the format is understood.
- Do not silently replace established systems. Extend the local pattern already used by the repository.
- Do not revert user changes unless explicitly asked.

## Naming Conventions

Follow **`NAMING.md`** for all new assets and public APIs.

- **Objects / sprites / rooms:** `obj_`, `spr_`, `rm_` (required). No new `scr_` script assets.
- **Scripts:** feature-first — script asset + folder (`DialogueConversation`, `Quest`, `PlayerMovement`); functions `<Feature>_<Action>` (`DialogueConversation_Start`, `Quest_Init`).
- **Sub-features:** split by PascalCase script assets (`DialogueWelcomer`, `DialogueWelcomerData`, `PlayerInteraction`), not short prefixes (`dlg_`, `gs_`).
- **Macros:** `FEATURE_CONSTANT` (e.g. `DIALOGUE_BEAT_LINE`, `QUEST_WOODCUTTING_ITEM`).
- **Register:** `<Feature>_Register(_inst)` from object Create to bind instance methods.
- **Legacy:** `Pathfinding`, `ContextMenu`, `UIHelpers`, and unprefixed `Inventory.gml` helpers — do not add new unprefixed globals; migrate when explicitly refactoring.
- **Systems vs content:** See **`NAMING.md` → Systems vs content**. Story copy in `*Data` scripts; quest/briefing gates in `WelcomerProgress` / `GameState` / `Quest`; reusable dialogue in `Dialogue*` only. Do not mix layers in one file.
- **UI draw:** Use `UIDraw` helpers (`UI_DrawPanel`, `UI_DrawBorderedPanel`, `UI_DrawChoiceList`) in Draw GUI instead of ad-hoc `draw_rectangle` / `draw_set_alpha` blocks.
- **Create events:** Thin only — defaults + `*_Register(id)` or `ItemsCatalog_Bootstrap()`. No dialogue trees, quest logic, or item lists in Create. See **`NAMING.md` → Create events**.

## GML Standards

- Prefer functions, structs, constructors, and methods over legacy patterns.
- Use enums and macros consistently where the project already uses them.
- Avoid deprecated syntax and old compatibility patterns.
- Respect object inheritance and parent events. If adding or overriding parent behavior, state whether parent event logic must still run.
- Minimize unnecessary `with()` usage. When `with()` is needed, be explicit about `self`, `other`, and captured instance IDs.
- Avoid hidden scope/context bugs, especially in callbacks stored inside arrays or structs.
- Be careful with instance IDs versus asset references. Use `instance_exists()` before dereferencing stored instance IDs.
- Respect `image_index`, `image_speed`, sprite origin, and animation direction logic.
- Respect `delta_time` systems if implemented. Do not mix frame-based and delta-time movement without a clear conversion.
- Avoid per-frame allocations where possible. Do not create arrays, structs, DS structures, buffers, or surfaces every Step/Draw unless there is a reason.
- Prefer helper functions for repeated gameplay rules, but avoid introducing large abstractions for tiny changes.
- Keep code style close to the surrounding GML. Do not reformat unrelated files.

## Resource Management

Never leak runtime resources:

- `ds_list`
- `ds_map`
- `ds_grid`
- buffers
- surfaces
- particle systems
- audio emitters
- sequences
- paths

Rules:

- Destroy DS structures, buffers, paths, surfaces, emitters, and particle systems when ownership ends.
- Ensure cleanup in Cleanup/Destroy events when a resource survives beyond a single function call.
- For temporary DS structures created inside a function, destroy them on every return path.
- Validate `ds_exists()` when receiving a DS reference from elsewhere.
- Validate `surface_exists()` before drawing to or sampling from a surface.
- Avoid storing raw resource handles globally unless ownership and cleanup are documented.

## Animation Rules

- Use proper sprite, sequence, and skeleton animation APIs.
- Preserve animation state machine logic when editing movement, combat, or interaction code.
- Avoid desync between gameplay state and animation state.
- Respect track-based animation systems if added later.
- Do not overwrite `image_index` or `image_speed` casually. Check the object's Step/Draw logic first.
- Keep animation-facing logic deterministic and tied to gameplay state, not incidental mouse/UI state.

## Audio Rules

- Use `audio_play_sound()` correctly with priorities.
- Prevent duplicate looping sounds by storing and checking sound instance IDs.
- Preserve emitter/listener systems if present.
- Stop and destroy audio emitters when their owner is destroyed.
- Avoid stream/emitter memory leaks.
- Do not play repeated one-shot sounds every Step without cooldowns or state checks.

## Rendering Rules

- Restore GPU/render state after shaders, blend modes, color writes, alpha changes, matrix changes, or custom rendering.
- Validate surfaces before use and handle surface loss.
- Handle application surface edge cases if drawing to or replacing it.
- Avoid unnecessary texture swaps, surface recreation, and shader changes.
- Keep GUI drawing separate from world drawing when UI must appear above world objects.
- If moving UI between Draw, Draw GUI, or other draw events, verify mouse coordinate space and layering.

## Performance Rules

- Avoid expensive per-Step allocations.
- Avoid repeated asset lookups in hot paths.
- Cache references where safe, but invalidate cached instance IDs when instances can be destroyed.
- Minimize collision checks in Step events, especially nested loops over many instances.
- Optimize for enemy-heavy and resource-heavy gameplay scenarios.
- Be careful with particles, emitters, dynamic lighting, and shader-heavy effects.
- Keep pathfinding bounded and deterministic. Avoid unbounded searches in Step.
- Prefer computing route/path data on input or state changes instead of every frame.
- Avoid drawing debug overlays in production paths unless gated by a debug flag.

## Debugging Rules

When diagnosing bugs, check for:

- invalid instance references
- instance IDs confused with object assets
- `other` / `self` scope mistakes
- callback scope bugs
- DS structure leaks
- surface loss
- async timing bugs
- room transition bugs
- animation desync
- collision edge cases
- pathfinding edge cases
- shader state leakage
- audio overlap
- networking timing issues
- GUI coordinate versus room coordinate mismatches
- object depth and draw-event ordering issues

## Code Editing Workflow

Before editing:

- Inspect related scripts, objects, events, room instance creation code, macros, and enums.
- Search for existing helper systems before adding new ones.
- Understand ownership and cleanup for any runtime resource.
- Identify whether logic belongs in an object event, script function, room creation code, or data file.
- Avoid duplicate systems.

When generating code:

- Specify exactly where code belongs.
- Include object names.
- Include event names.
- Include initialization requirements.
- Include cleanup requirements.
- Explain assumptions and risk when behavior depends on current room setup.
- Keep changes scoped to the requested feature or fix.

After editing:

- List modified files and a short what changed (minimal unless user asks for detail).
- Mention manual IDE steps or tests only when required.

## Repository Structure

This repository is a GameMaker project rooted at `Blank Pixel Game3.yyp`.

Important folders:

- `objects/`: GameMaker object folders and event GML files.
- `scripts/`: shared GML scripts, currently including inventory/skill and camera helpers.
- `rooms/`: room definitions and instance creation code.
- `sprites/`: sprite assets and metadata.
- `fonts/`: GameMaker font resources.
- `sequences/`: sequence resources.
- `datafiles/`: design notes and progression documentation.
- `options/`: platform target settings.

## Current Gameplay Systems

Known systems in this project:

- Player tile movement in `objects/obj_player` via `PlayerMovement`, `PlayerPathing`, `PlayerInteraction`, `PlayerAnimation` scripts.
- Click movement, right-click context menu, pathfinding, inventory UI, skill UI, and quest UI in `objects/obj_controller` via `Pathfinding`, `ContextMenu`, `ControllerUI`, `UIHelpers`.
- Dialogue instance state in `objects/obj_dialogue`; session API, beats, layout, and input in `DialogueSession`, `DialogueConversation`, `DialogueLayout`, `DialogueInput`, etc. Welcomer copy in `DialogueWelcomerData`; Welcomer flow gates in `WelcomerProgress`; director in `DialogueWelcomer`.
- NPC dialogue and trainer interaction in `objects/obj_npc` and room instance creation code.
- Resource nodes, auto-gathering, depletion, respawning, and smelting-style resource conversion in `objects/obj_resource`.
- Inventory and item helpers in `scripts/Inventory/Inventory.gml`.
- Skill XP and level helpers in `scripts/Inventory/Inventory.gml`.
- Tutorial room content in `rooms/rm_tutorial`.
- Early approval/quest flow around the Welcomer and trainers.

## Project-Specific Rules

- Preserve the tile-grid movement model. The player moves one tile at a time and snaps to tile centers/bottoms.
- Do not change tile size, object origins, room placement, or collision conventions unless specifically requested.
- Keep keyboard movement and mouse movement compatible.
- UI clicks must not leak into world movement.
- Context menus should draw above world objects and should use the existing controller menu state unless refactoring is explicitly requested.
- Use the existing dialogue object for NPC text, prompts, and notices.
- Trainer dialogue should support the progression pillar: Welcomer approval, skill tasks, gathering/crafting, and long-term progression. Menu NPCs: `DialogueWoodcuttingTrainer_Open` pattern (`GetGreeting`, `BuildChoices`, `Dialogue_PresentMenu`); Welcomer: `DialogueWelcomer_Open`. Objects only delegate from `OpenDialogueMenu`.
- Resource nodes use `resource_name`, `resource_action`, `resource_skill`, required level/tool/resource fields, depletion, and respawn settings. Preserve that data-driven pattern.
- Depleted resources should not offer normal gather prompts or context actions.
- Inventory data currently uses DS grids. Any future inventory refactor must include migration and cleanup planning.
- If adding new skills, wire them through skill existence, level, XP, UI display, rewards, and trainer/quest progression.
- If adding new resource types, define creation-code fields clearly and verify item names match inventory item names exactly.
- Avoid adding debug popups or hover overlays unless gated behind an explicit debug flag.

## Output Style

- Follow `PROJECT_CONTEXT.md` **Response style** for chat length (minimal by default).
- Prefer production-ready code over tutorial code.
- Do not over-explain basic GML concepts.
- After edits: files changed + brief what/why; one-line test if non-obvious.
- Use concrete file/object/event names when mentioning changes.
