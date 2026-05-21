/// @description Master item list rows for global.AllItems (called once from obj_items Create).

function ItemsCatalog_Bootstrap() {
	global.AllItems = ds_grid_create(0, Item.Height);
	AddItemToMasterList(["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe]);
	AddItemToMasterList(["Simple Staff", spr_simple_staff, 1, Type.Weapon, 10, obj_simple_staff]);
	AddItemToMasterList(["Normal Log", spr_normal_log, 1, Type.Resource, 1, obj_normal_log]);
	AddItemToMasterList(["Bronze Pickaxe", spr_bronze_pickaxe, 1, Type.Tool, 5, obj_bronze_pickaxe]);
	AddItemToMasterList(["Copper Ore", spr_copper_ore, 1, Type.Resource, 1, obj_copper_ore]);
	AddItemToMasterList(["Knife", spr_knife, 1, Type.Tool, 5, obj_knife]);
	AddItemToMasterList(["Copper Bar", spr_copper_bar, 1, Type.Resource, 1, obj_copper_bar]);
}
