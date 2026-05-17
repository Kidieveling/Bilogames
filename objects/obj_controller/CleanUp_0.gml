/// @description Release controller-owned data

if (ds_exists(myItems, ds_type_grid)) {
	ds_grid_destroy(myItems);
	myItems = -1;
}

if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
	instance_destroy(currentItem);
}

with (objItemParent) {
	if (isInMenu) {
		instance_destroy();
	}
}
