/// @description Variables

myItems = ds_grid_create(0, Item.Height);

isShowingMenu = false;
showingDescription = false;
currentItem = undefined;
currentItemSlot = undefined;
sequence = undefined;
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
window_set_cursor(cr_none);

AddItem(myItems, ["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe]);
