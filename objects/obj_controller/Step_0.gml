/// @description Control Menu

if (keyboard_check_pressed(ord("M"))) {
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

//Sort
if (isShowingMenu) {
	if (keyboard_check_pressed(ord("S"))) {
		++sortType;
		if (sortType >= SortType.Height) {
			sortType = 0;
		}
		SortInventory(myItems, sortType);
	}
}
