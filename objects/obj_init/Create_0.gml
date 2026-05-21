/// @description Boot room: fullscreen, tile size, fresh skill globals, then tutorial.

#region Display And RNG

window_set_fullscreen(true);

if (!variable_global_exists("rng_seeded")) {
	randomize();
	global.rng_seeded = true;
}

#endregion

#region Skills And Tile Size

global.tile_size = 32;

// Unconditional reset — GameState_InitSkillsAndRng only fills missing globals on later rooms.
global.woodcutting_level = 1;
global.woodcutting_xp = 0;
global.mining_level = 1;
global.mining_xp = 0;
global.smelting_level = 1;
global.smelting_xp = 0;

#endregion

#region Persistent Instances

if (!instance_exists(obj_dialogue)) {
    instance_create_layer(0, 0, "Instances", obj_dialogue);
}

if (!instance_exists(obj_debug_overlay)) {
	instance_create_layer(0, 0, "Instances", obj_debug_overlay);
}

#endregion

room_goto(rm_tutorial);
