/// @description Tear down inventory DS grid and menu-layer item previews on room end.

#region Inventory Grid

if (ds_exists(myItems, ds_type_grid)) {
	ds_grid_destroy(myItems);
	myItems = -1;
}

#endregion

#region Menu Preview Instances

if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
	instance_destroy(currentItem);
}

with (objItemParent) {
	if (isInMenu) {
		instance_destroy();
	}
}

#endregion
