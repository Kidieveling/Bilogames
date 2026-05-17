if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
	draw_set_alpha(0.45);
	draw_set_color(c_yellow);
	draw_self();
	draw_set_alpha(1);
	draw_set_color(c_white);
	exit;
}
draw_self();
