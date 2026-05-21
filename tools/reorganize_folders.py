"""Asset Browser folder reorganization - updates folder .yy files and resource parents only."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FOLDERS_DIR = ROOT / "folders"

FOLDER_PATHS = [
    "Objects.yy", "Objects/Actors.yy", "Objects/Actors/Player.yy", "Objects/Actors/NPCs.yy",
    "Objects/Actors/NPCs/Welcomer.yy", "Objects/Actors/NPCs/Trainers.yy",
    "Objects/Systems.yy", "Objects/Systems/Dialogue.yy", "Objects/Systems/Controller.yy",
    "Objects/World.yy", "Objects/World/Resources.yy", "Objects/World/Init.yy",
    "Objects/Items.yy", "Objects/Items/Resources.yy", "Objects/Items/Tools.yy", "Objects/Items/Weapons.yy",
    "Objects/Debug.yy",
    "Sprites.yy", "Sprites/Actors.yy", "Sprites/Actors/Player.yy", "Sprites/Actors/NPCs.yy",
    "Sprites/Actors/NPCs/Welcomer.yy", "Sprites/Actors/NPCs/Trainers.yy",
    "Sprites/World.yy", "Sprites/World/Resources.yy", "Sprites/World/Init.yy",
    "Sprites/Items.yy", "Sprites/Items/Resources.yy", "Sprites/Items/Tools.yy", "Sprites/Items/Weapons.yy",
    "Sprites/UI.yy", "Sprites/UI/Inventory.yy", "Sprites/UI/SkillBar.yy", "Sprites/UI/Cursor.yy",
    "Sprites/Debug.yy",
    "Scripts.yy", "Scripts/Actors/Player.yy", "Scripts/Actors/NPCs/Welcomer.yy",
    "Scripts/Systems/Dialogue.yy", "Scripts/Systems/GameState.yy", "Scripts/Systems/Quest.yy",
    "Scripts/Systems/Inventory.yy", "Scripts/Systems/Camera.yy", "Scripts/Systems/GuidedIntro.yy",
    "Scripts/Systems/Controller.yy",
    "Rooms.yy", "Rooms/World.yy", "Rooms/World/Init.yy",
    "Fonts.yy", "Debug.yy", "Sequences.yy",
]

# resource name (from yy %Name or folder) -> (folder display name, folder path)
PARENT_MAP = {
    # Objects
    "obj_player": ("Player", "folders/Objects/Actors/Player.yy"),
    "obj_welcomer": ("Welcomer", "folders/Objects/Actors/NPCs/Welcomer.yy"),
    "obj_intro_marker": ("Welcomer", "folders/Objects/Actors/NPCs/Welcomer.yy"),
    "obj_woodcutting_trainer": ("Trainers", "folders/Objects/Actors/NPCs/Trainers.yy"),
    "obj_mining_trainer": ("Trainers", "folders/Objects/Actors/NPCs/Trainers.yy"),
    "obj_crafting_trainer": ("Trainers", "folders/Objects/Actors/NPCs/Trainers.yy"),
    "obj_npc": ("NPCs", "folders/Objects/Actors/NPCs.yy"),
    "obj_dialogue": ("Dialogue", "folders/Objects/Systems/Dialogue.yy"),
    "obj_controller": ("Controller", "folders/Objects/Systems/Controller.yy"),
    "obj_resource": ("Resources", "folders/Objects/World/Resources.yy"),
    "obj_resource_tree": ("Resources", "folders/Objects/World/Resources.yy"),
    "obj_resource_ore": ("Resources", "folders/Objects/World/Resources.yy"),
    "obj_resource_furnace": ("Resources", "folders/Objects/World/Resources.yy"),
    "obj_init": ("Init", "folders/Objects/World/Init.yy"),
    "objItemParent": ("Items", "folders/Objects/Items.yy"),
    "obj_items": ("Items", "folders/Objects/Items.yy"),
    "obj_normal_log": ("Resources", "folders/Objects/Items/Resources.yy"),
    "obj_copper_ore": ("Resources", "folders/Objects/Items/Resources.yy"),
    "obj_copper_bar": ("Resources", "folders/Objects/Items/Resources.yy"),
    "obj_bronze_axe": ("Tools", "folders/Objects/Items/Tools.yy"),
    "obj_bronze_pickaxe": ("Tools", "folders/Objects/Items/Tools.yy"),
    "obj_knife": ("Tools", "folders/Objects/Items/Tools.yy"),
    "obj_simple_staff": ("Weapons", "folders/Objects/Items/Weapons.yy"),
    "obj_debug_overlay": ("Debug", "folders/Objects/Debug.yy"),
    # Sprites
    "spr_player": ("Player", "folders/Sprites/Actors/Player.yy"),
    "spr_welcomer": ("Welcomer", "folders/Sprites/Actors/NPCs/Welcomer.yy"),
    "spr_woodcutting_trainer": ("Trainers", "folders/Sprites/Actors/NPCs/Trainers.yy"),
    "spr_mining_trainer": ("Trainers", "folders/Sprites/Actors/NPCs/Trainers.yy"),
    "spr_crafting_trainer": ("Trainers", "folders/Sprites/Actors/NPCs/Trainers.yy"),
    "spr_npc": ("NPCs", "folders/Sprites/Actors/NPCs.yy"),
    "spr_tree_spawn": ("Resources", "folders/Sprites/World/Resources.yy"),
    "spr_ore_spawn": ("Resources", "folders/Sprites/World/Resources.yy"),
    "spr_furnace": ("Resources", "folders/Sprites/World/Resources.yy"),
    "spr_resource": ("Resources", "folders/Sprites/World/Resources.yy"),
    "spr_init": ("Init", "folders/Sprites/World/Init.yy"),
    "spr_normal_log": ("Resources", "folders/Sprites/Items/Resources.yy"),
    "spr_copper_ore": ("Resources", "folders/Sprites/Items/Resources.yy"),
    "spr_copper_bar": ("Resources", "folders/Sprites/Items/Resources.yy"),
    "spr_bronze_axe": ("Tools", "folders/Sprites/Items/Tools.yy"),
    "spr_bronze_pickaxe": ("Tools", "folders/Sprites/Items/Tools.yy"),
    "spr_knife": ("Tools", "folders/Sprites/Items/Tools.yy"),
    "spr_simple_staff": ("Weapons", "folders/Sprites/Items/Weapons.yy"),
    "spr_ui_panel": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_slot": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_slot_selected": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_tab": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_xp_bar_back": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_xp_bar_fill": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_skill_row": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_ui_sheet": ("Inventory", "folders/Sprites/UI/Inventory.yy"),
    "spr_skillBar": ("SkillBar", "folders/Sprites/UI/SkillBar.yy"),
    "spr_cursor": ("Cursor", "folders/Sprites/UI/Cursor.yy"),
    "spr_tile_floor": ("Debug", "folders/Sprites/Debug.yy"),
    # Scripts
    "PlayerMovement": ("Player", "folders/Scripts/Actors/Player.yy"),
    "PlayerInteraction": ("Player", "folders/Scripts/Actors/Player.yy"),
    "PlayerAnimation": ("Player", "folders/Scripts/Actors/Player.yy"),
    "DialogueWelcomer": ("Welcomer", "folders/Scripts/Actors/NPCs/Welcomer.yy"),
    "DialogueWelcomerData": ("Welcomer", "folders/Scripts/Actors/NPCs/Welcomer.yy"),
    "Dialogue": ("Dialogue", "folders/Scripts/Systems/Dialogue.yy"),
    "DialogueConversation": ("Dialogue", "folders/Scripts/Systems/Dialogue.yy"),
    "DialogueTypewriter": ("Dialogue", "folders/Scripts/Systems/Dialogue.yy"),
    "DialogueInput": ("Dialogue", "folders/Scripts/Systems/Dialogue.yy"),
    "DialogueLayout": ("Dialogue", "folders/Scripts/Systems/Dialogue.yy"),
    "DialogueUI": ("Dialogue", "folders/Scripts/Systems/Dialogue.yy"),
    "GameState": ("GameState", "folders/Scripts/Systems/GameState.yy"),
    "StoryOpening": ("GameState", "folders/Scripts/Systems/GameState.yy"),
    "Quest": ("Quest", "folders/Scripts/Systems/Quest.yy"),
    "Inventory": ("Inventory", "folders/Scripts/Systems/Inventory.yy"),
    "Camera": ("Camera", "folders/Scripts/Systems/Camera.yy"),
    "GuidedIntro": ("GuidedIntro", "folders/Scripts/Systems/GuidedIntro.yy"),
    "Pathfinding": ("Controller", "folders/Scripts/Systems/Controller.yy"),
    "ContextMenu": ("Controller", "folders/Scripts/Systems/Controller.yy"),
    "UIHelpers": ("Controller", "folders/Scripts/Systems/Controller.yy"),
    # Rooms
    "rm_tutorial": ("World", "folders/Rooms/World.yy"),
    "rm_init": ("Init", "folders/Rooms/World/Init.yy"),
    # Fonts
    "fntSmaller": ("Fonts", "folders/Fonts.yy"),
    # Sequences
    "sqDescriptionAnimation": ("Sequences", "folders/Sequences.yy"),
}


def write_folder_file(rel: str) -> None:
    name = Path(rel).stem
    path = FOLDERS_DIR / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "{",
        '  "$GMFolder":"",',
        f'  "%Name":"{name}",',
        f'  "folderPath":"folders/{rel}",',
        f'  "name":"{name}",',
        '  "resourceType":"GMFolder",',
        '  "resourceVersion":"2.0",',
        "}",
    ]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def patch_parent_in_yy(yy_path: Path, folder_name: str, folder_path: str) -> bool:
    text = yy_path.read_text(encoding="utf-8")
    m = re.search(r'"%Name"\s*:\s*"([^"]+)"', text)
    if not m:
        m = re.search(r'\n\s*"name"\s*:\s*"([^"]+)"', text)
    if not m:
        return False
    res_name = m.group(1)
    if res_name not in PARENT_MAP:
        return False
    expected = PARENT_MAP[res_name]
    if expected != (folder_name, folder_path):
        pass  # we drive from map by res name
    folder_name, folder_path = expected
    new_parent = (
        '  "parent":{\n'
        f'    "name":"{folder_name}",\n'
        f'    "path":"{folder_path}",\n'
        "  }"
    )
    if not re.search(r'"parent"\s*:', text):
        return False
    new_text, n = re.subn(
        r'"parent"\s*:\s*\{[^}]*\}',
        new_parent.strip(),
        text,
        count=1,
        flags=re.DOTALL,
    )
    if n == 0:
        return False
    yy_path.write_text(new_text, encoding="utf-8")
    return True


def update_yyp_folders() -> None:
    yyp_path = ROOT / "Blank Pixel Game3.yyp"
    text = yyp_path.read_text(encoding="utf-8")
    entries = []
    for rel in FOLDER_PATHS:
        name = Path(rel).stem
        entries.append(
            f'    {{"$GMFolder":"","%Name":"{name}","folderPath":"folders/{rel}","name":"{name}",'
            f'"resourceType":"GMFolder","resourceVersion":"2.0",}},'
        )
    block = "\n".join(entries)
    new_text, n = re.subn(
        r'"Folders"\s*:\s*\[[^\]]*\]',
        '"Folders":[\n' + block + "\n  ]",
        text,
        count=1,
        flags=re.DOTALL,
    )
    if n:
        yyp_path.write_text(new_text, encoding="utf-8")


def main() -> None:
    for rel in FOLDER_PATHS:
        write_folder_file(rel)
    updated = 0
    skipped = []
    for yy in ROOT.rglob("*.yy"):
        if "folders" in yy.parts or yy.name.endswith(".old.yy"):
            continue
        text = yy.read_text(encoding="utf-8")
        m = re.search(r'"%Name"\s*:\s*"([^"]+)"', text)
        if not m:
            m = re.search(r'\n\s*"name"\s*:\s*"([^"]+)"', text)
        if not m:
            continue
        name = m.group(1)
        if name not in PARENT_MAP:
            continue
        fn, fp = PARENT_MAP[name]
        if patch_parent_in_yy(yy, fn, fp):
            updated += 1
        else:
            skipped.append(str(yy))
    update_yyp_folders()
    print(f"Updated {updated} resource parents")
    if skipped:
        print("Skipped:", skipped)


def repatch_parents_only() -> None:
    updated = 0
    for yy in ROOT.rglob("*.yy"):
        if "folders" in yy.parts or yy.name.endswith(".old.yy"):
            continue
        text = yy.read_text(encoding="utf-8")
        m = re.search(r'"%Name"\s*:\s*"([^"]+)"', text)
        if not m:
            m = re.search(r'\n\s*"name"\s*:\s*"([^"]+)"', text)
        if not m:
            continue
        name = m.group(1)
        if name not in PARENT_MAP:
            continue
        fn, fp = PARENT_MAP[name]
        if patch_parent_in_yy(yy, fn, fp):
            updated += 1
    print(f"Re-patched {updated} resource parents")


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "--repatch":
        repatch_parents_only()
    else:
        main()
