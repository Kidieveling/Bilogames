window_set_fullscreen(true);

if (!variable_global_exists("rng_seeded")) {
	randomize();
	global.rng_seeded = true;
}

global.tile_size = 32;

global.woodcutting_level = 1;
global.woodcutting_xp = 0;
global.mining_level = 1;
global.mining_xp = 0;
global.smelting_level = 1;
global.smelting_xp = 0;

if (!instance_exists(obj_dialogue)) {
    instance_create_layer(0, 0, "Instances", obj_dialogue);
}

room_goto(rm_tutorial);
