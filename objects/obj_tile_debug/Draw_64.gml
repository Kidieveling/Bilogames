var tile_size = 32;

var tile_col = floor(mouse_x / tile_size);
var tile_row = floor(mouse_y / tile_size);

var spawn_x = tile_col * tile_size + tile_size / 2;
var spawn_y = tile_row * tile_size + tile_size;

draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(12, 12, 228, 58, false);
draw_set_alpha(1);

draw_set_color(c_white);
draw_text(20, 24, "target_x = " + string(spawn_x) + "; target_y = " + string(spawn_y) + ";");
