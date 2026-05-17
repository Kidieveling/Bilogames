/// @description Draw custom cursor above all GUI

draw_set_alpha(1);
draw_sprite(spr_cursor, 0, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
