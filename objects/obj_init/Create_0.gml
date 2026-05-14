window_set_fullscreen(true);

global.tile_size = 32;

global.inventory_open = false;

global.inventory_cols = 5;
global.inventory_rows = 4;
global.inventory_slots = global.inventory_cols * global.inventory_rows;

global.inventory = array_create(global.inventory_slots, noone);

global.inventory[0] = {
    name: "Potion",
    sprite: spr_tile_floor,
    amount: 3
};

global.inventory[1] = {
    name: "Key",
    sprite: spr_tile_blocked,
    amount: 1
};

room_goto(rm_tutorial);
