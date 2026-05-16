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
    name: "Bronze Axe",
    sprite: spr_bronze_axe,
    amount: 1
};

room_goto(rm_tutorial);
