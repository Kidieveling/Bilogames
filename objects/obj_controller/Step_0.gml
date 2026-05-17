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
		instance_destroy(objItemParent);
	}
	if (point_in_rectangle(mouse_x, mouse_y, questsTabX1, tabY1, questsTabX2, tabY2)) {
		selectedMenuTab = menuTabQuests;
		instance_destroy(objItemParent);
	}
}
