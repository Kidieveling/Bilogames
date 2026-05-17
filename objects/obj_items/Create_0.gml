/// @description Master Item Object

//All Item Properties
enum Item {
	Name,
	Sprite,
	Amount,
	Type,
	Price,
	Object,
	Height
}

enum Type {
	Weapon,
	Armor,
	Tool,
	Consumable
}

enum Ailment {
	Poison,
	Confused,
	Drunk
}

enum SortType {
	Name,
	Amount,
	Type,
	Price,
	Height
}




///Master item list
///             0   1
///0 (Name)  
///1 (Sprite) 
///2 (Amount)
///3 (Type)
///4 (Price)
///5 (Object)

global.AllItems = ds_grid_create(0, Item.Height)


AddItemToMasterList(["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe])
AddItemToMasterList(["Simple Staff", spr_simple_staff, 1 , Type.Weapon, 10, obj_simple_staff])






