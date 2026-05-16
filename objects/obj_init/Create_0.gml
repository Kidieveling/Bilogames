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
    name: "Potion",
    sprite: spr_tile_floor,
    amount: 3
};

global.inventory[1] = {
    name: "Key",
    sprite: spr_tile_blocked,
    amount: 1
};

global.inventory[2] = {
    name: "Bronze axe",
    sprite: spr_item_bronze_axe,
    amount: 1,
    type: "tool"
};

if (!instance_exists(obj_dialogue)) {
    instance_create_layer(0, 0, "Instances", obj_dialogue);
}

room_goto(rm_tutorial);
