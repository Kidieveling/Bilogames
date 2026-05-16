/// @description Variables

myItems = ds_grid_create(0, Item.Height);

isShowingMenu = false;
currentItem = undefined;
currentItemSlot = undefined;
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
	var panelX = clamp(mouse_x + 24, CameraX() + 8, CameraX() + viewWidth - panelWidth - 8);
	var panelY = clamp(mouse_y + 24, CameraY() + 8, CameraY() + viewHeight - panelHeight - 8);
	
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
	
	if (_item.damage != undefined) {
		draw_text(panelX + 10, panelY + 48, "Damage: " + string(_item.damage));
	}
	if (_item.defense != undefined) {
		draw_text(panelX + 10, panelY + 48, "Defense: " + string(_item.defense));
	}
	
	if (_item.description != undefined) {
		draw_text_ext(panelX + 10, panelY + 70, _item.description, 16, panelWidth - 20);
	}
};

AddItem(myItems, ["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe]);
