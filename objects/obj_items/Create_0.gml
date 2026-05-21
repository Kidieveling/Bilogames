/// @description Singleton master item catalog. Enums here; item rows in ItemsCatalog script.

if (instance_number(obj_items) > 1) {
	instance_destroy();
	exit;
}

#region Item Enums

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
	Resource,
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

#endregion

ItemsCatalog_Bootstrap();
