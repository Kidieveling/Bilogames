tile_size = 32
move_speed = 3

moving = false
target_x = x
target_y = y

move_x = 0
move_y = 0

buffer_x = 0
buffer_y = 0
pending_dialogue_npc = noone
pending_resource = noone

facing_dir = 0
walk_frames = 1

image_speed = 0
depth = 0

x = (floor(x / tile_size) * tile_size) + tile_size / 2
y = (floor(y / tile_size) * tile_size) + tile_size

target_x = x
target_y = y

if (variable_global_exists("spawn_x")) {
    x = global.spawn_x;
    y = global.spawn_y;
}

