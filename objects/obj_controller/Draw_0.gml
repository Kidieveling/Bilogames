/// @description Draw The Menu
draw_self();

if (menu_open) {
    draw_set_color(c_black);
    draw_set_alpha(0.75);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(32, 32, "Menu");
}
