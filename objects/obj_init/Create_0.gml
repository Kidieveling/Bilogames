window_set_fullscreen(true);

global.tile_size = 32;

global.woodcutting_level = 1;
global.woodcutting_xp = 0;

if (!instance_exists(obj_dialogue)) {
    instance_create_layer(0, 0, "Instances", obj_dialogue);
}

room_goto(rm_tutorial);
