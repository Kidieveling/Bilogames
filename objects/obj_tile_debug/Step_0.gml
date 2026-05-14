if (mouse_check_button_pressed(mb_left)) {
    var tile_size = 32;

    var tile_col = floor(mouse_x / tile_size);
    var tile_row = floor(mouse_y / tile_size);

    var spawn_x = tile_col * tile_size + tile_size / 2;
    var spawn_y = tile_row * tile_size + tile_size;

    show_debug_message(
        "target_x = " + string(spawn_x) + ";" +
        " target_y = " + string(spawn_y) + ";"
    );
}
