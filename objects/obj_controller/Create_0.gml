/// @description Variables

myItems = ds_grid_create(0, Item.Height);

currentItem = undefined;
currentItemSlot = undefined;
hoveredItemSlot = undefined;
menuTabInventory = 0;
menuTabSpells = 1;
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
window_set_cursor(cr_none);

GetItemTypeName = function(_type) {
	switch (_type) {
		case Type.Weapon: return "Weapon";
		case Type.Armor: return "Armor";
		case Type.Tool: return "Tool";
		case Type.Consumable: return "Consumable";
	}
	return "Item";
};

DrawHoverItemDetails = function(_item) {
	if (_item == undefined || _item == noone) {
		return;
	}
	
	var viewWidth = room_width;
	var viewHeight = room_height;
	if (view_camera[0] >= 0) {
		viewWidth = camera_get_view_width(view_camera[0]);
		viewHeight = camera_get_view_height(view_camera[0]);
	}
	
	var panelWidth = 210;
	var panelHeight = 126;
	var panelGap = 12;
	var viewLeft = CameraX();
	var viewTop = CameraY();
	var viewRight = viewLeft + viewWidth;
	var viewBottom = viewTop + viewHeight;
	var panelX = mouse_x + panelGap;
	var panelY = mouse_y + panelGap;
	
	if (panelX + panelWidth > viewRight - 8) {
		panelX = mouse_x - panelWidth - panelGap;
	}
	if (panelY + panelHeight > viewBottom - 8) {
		panelY = mouse_y - panelHeight - panelGap;
	}
	
	panelX = clamp(panelX, viewLeft + 8, viewRight - panelWidth - 8);
	panelY = clamp(panelY, viewTop + 8, viewBottom - panelHeight - 8);
	
	draw_set_alpha(0.9);
	draw_set_color(c_black);
	draw_rectangle(panelX, panelY, panelX + panelWidth, panelY + panelHeight, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(panelX, panelY, panelX + panelWidth, panelY + panelHeight, true);
	
	draw_set_font(fntSmaller);
	draw_set_color(c_white);
	draw_text(panelX + 10, panelY + 8, _item.name);
	draw_text(panelX + 10, panelY + 28, GetItemTypeName(_item.type) + "  |  " + string(_item.price) + " gold");
	
	if (variable_instance_exists(_item, "damage") && _item.damage != undefined) {
		draw_text(panelX + 10, panelY + 48, "Damage: " + string(_item.damage));
	}
	if (variable_instance_exists(_item, "defense") && _item.defense != undefined) {
		draw_text(panelX + 10, panelY + 48, "Defense: " + string(_item.defense));
	}
	
	if (variable_instance_exists(_item, "description") && _item.description != undefined) {
		draw_text_ext(panelX + 10, panelY + 70, _item.description, 16, panelWidth - 20);
	}
};


