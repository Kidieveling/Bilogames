/// @description Draw custom cursor above all normal draw events

draw_set_alpha(1);
draw_sprite(spr_cursor, 0, mouse_x, mouse_y);
