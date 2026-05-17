/// @description Control Fixed UI

window_set_cursor(cr_none);

if (mouse_check_button_pressed(mb_left)) {
	var viewWidth = room_width;
	var viewHeight = room_height;
	if (view_camera[0] >= 0) {
		viewWidth = camera_get_view_width(view_camera[0]);
		viewHeight = camera_get_view_height(view_camera[0]);
	}
	
	var menuMargin = 16;
	var menuX = CameraX() + viewWidth - sprite_get_width(spr_inventoryBackDrop) / 2 - menuMargin;
	var menuY = CameraY() + viewHeight - sprite_get_height(spr_inventoryBackDrop) / 2 - menuMargin;
	var menuLeft = menuX - sprite_get_xoffset(spr_inventoryBackDrop);
	var menuTop = menuY - sprite_get_yoffset(spr_inventoryBackDrop);
	var tabY1 = menuTop + 42;
	var tabY2 = tabY1 + 26;
	var inventoryTabX1 = menuLeft + 32;
	var inventoryTabX2 = inventoryTabX1 + 88;
	var spellsTabX1 = inventoryTabX2 + 8;
	var spellsTabX2 = spellsTabX1 + 72;
	
	if (point_in_rectangle(mouse_x, mouse_y, inventoryTabX1, tabY1, inventoryTabX2, tabY2)) {
		selectedMenuTab = menuTabInventory;
	}
	if (point_in_rectangle(mouse_x, mouse_y, spellsTabX1, tabY1, spellsTabX2, tabY2)) {
		selectedMenuTab = menuTabSpells;
		instance_destroy(objItemParent);
	}
}
