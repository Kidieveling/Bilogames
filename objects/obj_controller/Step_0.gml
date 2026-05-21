/// @description Fixed UI input: tab switching, inventory hover preview, middle-click drag reorder.
/// World clicks are handled on obj_player — this event only touches the menu chrome.

#region Cursor

window_set_cursor(cr_none);

#endregion

#region Menu Tabs

if (mouse_check_button_pressed(mb_left)) {
	var viewWidth = room_width;
	var viewHeight = room_height;
	if (view_camera[0] >= 0) {
		viewWidth = camera_get_view_width(view_camera[0]);
		viewHeight = camera_get_view_height(view_camera[0]);
	}
	
	var menuMargin = 16;
	var menuLeft = CameraX() + viewWidth - 296 - menuMargin;
	var menuTop = CameraY() + viewHeight - 296 - menuMargin + 18;
	var tabY1 = menuTop - 27;
	var tabY2 = tabY1 + 28;
	var inventoryTabX1 = menuLeft + 22;
	var inventoryTabX2 = inventoryTabX1 + 80;
	var spellsTabX1 = inventoryTabX2 + 8;
	var spellsTabX2 = spellsTabX1 + 72;
	var questsTabX1 = spellsTabX2 + 8;
	var questsTabX2 = questsTabX1 + 72;
	
	if (point_in_rectangle(mouse_x, mouse_y, inventoryTabX1, tabY1, inventoryTabX2, tabY2)) {
		selectedMenuTab = menuTabInventory;
	}
	if (point_in_rectangle(mouse_x, mouse_y, spellsTabX1, tabY1, spellsTabX2, tabY2)) {
		selectedMenuTab = menuTabSpells;
	}
	if (point_in_rectangle(mouse_x, mouse_y, questsTabX1, tabY1, questsTabX2, tabY2)) {
		selectedMenuTab = menuTabQuests;
	}
}

#endregion

#region Inventory Drag

var viewWidth = room_width;
var viewHeight = room_height;
if (view_camera[0] >= 0) {
	viewWidth = camera_get_view_width(view_camera[0]);
	viewHeight = camera_get_view_height(view_camera[0]);
}

var menuMargin = 16;
var menuLeft = CameraX() + viewWidth - 296 - menuMargin;
var menuTop = CameraY() + viewHeight - 296 - menuMargin + 18;

if (selectedMenuTab == menuTabInventory && ds_exists(myItems, ds_type_grid)) {
	var slotSize = 34;
	var slotHalf = slotSize / 2;
	var slotSpacingX = 37;
	var slotSpacingY = 37;
	var inventoryGridX = menuLeft + 38;
	var inventoryGridY = menuTop + 50;
	var hoveredSlot = undefined;
	
	for (var i = 0; i < ds_grid_width(myItems); i++) {
		var itemColumn = i mod menuWidth;
		var itemRow = i div menuWidth;
		var itemSlotX = inventoryGridX + (itemColumn * slotSpacingX);
		var itemSlotY = inventoryGridY + (itemRow * slotSpacingY);
		var itemX = itemSlotX + 16;
		var itemY = itemSlotY + 16;
		
		if (point_in_rectangle(mouse_x, mouse_y, itemX - slotHalf, itemY - slotHalf, itemX + slotHalf, itemY + slotHalf)) {
			hoveredSlot = i;
			break;
		}
	}
	
	if (hoveredSlot != undefined) {
		currentItemSlot = hoveredSlot;
		
		// Hidden menu-layer instance powers tooltip text without drawing in the grid cell.
		if (!draggingItem && !itemLocked && (hoveredItemSlot != hoveredSlot || currentItem == undefined || !instance_exists(currentItem))) {
			if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
				instance_destroy(currentItem);
			}
			
			currentItem = instance_create_layer(-32, -32, "MenuItems", myItems[# hoveredSlot, Item.Object]);
			currentItem.visible = false;
			currentItem.price = myItems[# hoveredSlot, Item.Price];
			currentItem.type = myItems[# hoveredSlot, Item.Type];
			currentItem.name = myItems[# hoveredSlot, Item.Name];
			currentItem.isInMenu = true;
			hoveredItemSlot = hoveredSlot;
		}
	} else if (!draggingItem) {
		currentItemSlot = undefined;
		hoveredItemSlot = undefined;
		
		if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
			instance_destroy(currentItem);
		}
		currentItem = undefined;
	}
	
	if (mouse_check_button(mb_middle)) {
		draggedItem = currentItem;
		if (draggedItem != undefined && instance_exists(draggedItem)) {
			draggedItem.x = mouse_x;
			draggedItem.y = mouse_y;
			draggedItem.visible = true;
			draggedItem.image_xscale = itemScale;
			draggedItem.image_yscale = itemScale;
			draggingItem = true;
		}
	}
	if (mouse_check_button_pressed(mb_middle)) {
		draggedItemSlot = currentItemSlot;
	}
	// Defer grid swap to Alarm 0 so release and press are not confused in one frame.
	if (mouse_check_button_released(mb_middle) && draggedItem != undefined && instance_exists(draggedItem)) {
		draggedItem.x = -100;
		draggedItem.y = -100;
		draggedItem.visible = false;
		draggingItem = false;
		alarm[0] = 1;
	}
} else {
	draggingItem = false;
	hoveredItemSlot = undefined;
	currentItemSlot = undefined;
	
	if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
		instance_destroy(currentItem);
	}
	currentItem = undefined;
}

#endregion
