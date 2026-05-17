/// @description Control Menu

if (keyboard_check_pressed(ord("I"))) {
	if (isShowingMenu == true) {
		isShowingMenu = false;
		instance_destroy(objItemParent);
	}
	else {
		isShowingMenu = true;
		SortInventory(myItems, sortType);
	}
}

window_set_cursor(cr_none);


