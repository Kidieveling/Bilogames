if (id == instance_find(obj_shop, 0)) {
    var tile_size = 32;

    var player_col = floor(obj_player.x / tile_size);
    var player_row = floor((obj_player.y - tile_size) / tile_size);

    var check_x = player_col * tile_size + tile_size / 2;
    var check_y = player_row * tile_size + tile_size / 2;

    var on_shop_tile = instance_position(check_x, check_y, obj_shop) != noone;

    layer_set_visible("Shop_outside", !on_shop_tile);
    layer_set_visible("Shop_inside", on_shop_tile);
}
