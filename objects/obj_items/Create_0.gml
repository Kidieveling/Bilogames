/// @description Master Item Object

// All Item Properties
enum Item{
    Name,
    Sprite,
    Amount,
    Type,
    Price,
    Object,
    Height
}

enum Type{
    Tool,
    Weapon,
    Armor,
    Consumable
}

enum Ailment{
    Poison,
    Confused,
    Drunk
}

enum SortType{
    Name,
    Amount,
    Type,
    Price,
    Height
}





///Master Item List
///
///0 (Name)
///1 (Sprite)
///2 (Amount)
///3 (Type)
///4 (Price)
///5 (Object)
/// 

global.Allitems = ds_grid_create(0, Item.Height)

AddItemToMasterList(["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe])