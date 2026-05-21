/// @description Room end: destroy global.AllItems so the master catalog does not leak across runs.

#region Master List

if (variable_global_exists("AllItems") && ds_exists(global.AllItems, ds_type_grid)) {
	ds_grid_destroy(global.AllItems);
	global.AllItems = -1;
}

#endregion
