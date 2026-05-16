window_set_fullscreen(true);

global.tile_size = 32;

global.inventory_open = false;
global.woodcutting_level = 1;
global.woodcutting_xp = 0;

global.inventory_cols = 5;
global.inventory_rows = 4;
global.inventory_slots = global.inventory_cols * global.inventory_rows;

global.inventory = array_create(global.inventory_slots, noone);

global.inventory[0] = {
    item_id: Item.POTION,
    name: global.item_get_name(Item.POTION),
    sprite: global.item_get_sprite(Item.POTION),
    amount: 3
};

global.inventory[1] = {
    item_id: Item.KEY,
    name: global.item_get_name(Item.KEY),
    sprite: global.item_get_sprite(Item.KEY),
    amount: 1
};

global.inventory[2] = {
    item_id: Item.BRONZE_AXE,
    name: global.item_get_name(Item.BRONZE_AXE),
    sprite: global.item_get_sprite(Item.BRONZE_AXE),
    amount: 1,
    type: global.item_get_type(Item.BRONZE_AXE)
};

room_goto(rm_tutorial);
