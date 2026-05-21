/// @description Middle-click release: swap two inventory grid rows after drag ends.

#region Grid Swap

if (currentItemSlot != undefined && draggedItemSlot != undefined) {
	var tempGrid = ds_grid_create(1, Item.Height);
	ds_grid_set_grid_region(tempGrid, myItems, currentItemSlot, 0, currentItemSlot, Item.Height - 1, 0, 0);
	ds_grid_set_grid_region(myItems, myItems, draggedItemSlot, 0, draggedItemSlot, Item.Height - 1, currentItemSlot, 0);
	ds_grid_set_grid_region(myItems, tempGrid, 0, 0, 0, Item.Height - 1, draggedItemSlot, 0);
	ds_grid_destroy(tempGrid);
}

#endregion
