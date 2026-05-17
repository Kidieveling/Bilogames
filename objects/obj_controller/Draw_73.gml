/// @description Draw custom cursor above the fixed UI

draw_set_alpha(1);
draw_sprite(spr_cursor, 0, mouse_x + sprite_get_xoffset(spr_cursor), mouse_y + sprite_get_yoffset(spr_cursor));
