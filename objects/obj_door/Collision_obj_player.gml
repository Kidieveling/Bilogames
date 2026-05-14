var tile_size = 32;

// Player tile, using the player's foot position
var player_col = floor(other.x / tile_size);
var player_row = floor((other.y - tile_size) / tile_size);

// Door tile
var door_col = floor(x / tile_size);
var door_row = floor(y / tile_size);

if (player_col == door_col && player_row == door_row) {
    global.spawn_x = target_x;
    global.spawn_y = target_y;

    room_goto(target_room);
}

