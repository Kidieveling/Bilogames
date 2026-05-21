/// @description Persistent UI controller: inventory grid, pathfinding, context menu.
/// Fixed HUD draw/input and GameState init are bound from scripts on Create.

GameState_Init();

#region Inventory Grid

myItems = ds_grid_create(0, Item.Height);

currentItem = undefined;
currentItemSlot = undefined;
hoveredItemSlot = undefined;

menuTabInventory = 0;
menuTabSpells = 1;
menuTabQuests = 2;
selectedMenuTab = menuTabInventory;
menuWidth = 6;
menuHeight = 48;
itemSeperation = 38;
itemScale = 2;
sortType = SortType.Name;

draggedItem = undefined;
draggingItem = false;
draggedItemSlot = undefined;
maxInventorySlots = 40;

itemLocked = false;
lockedItemX = undefined;
lockedItemY = undefined;

#endregion

#region Presentation

window_set_cursor(cr_none);

#endregion

#region World Context Menu

menu_open = false;
menu_target = noone;
menu_world_x = 0;
menu_world_y = 0;
menu_actions = [];
menu_width = 132;
menu_option_height = 22;
interaction_range_tiles = 1;

#endregion

#region Script Bindings

UIHelpers_Register(id);
ControllerUI_Register(id);
Pathfinding_Register(id);
ContextMenu_Register(id);

#endregion
