/// @description Release master item data

if (variable_global_exists("AllItems") && ds_exists(global.AllItems, ds_type_grid)) {
	ds_grid_destroy(global.AllItems);
	global.AllItems = -1;
}
