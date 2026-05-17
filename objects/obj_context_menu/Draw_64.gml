if (!instance_exists(target)) exit;

var left = menu_x;
var top = menu_y;
var total_h = array_length(actions) * option_h;

draw_set_alpha(0.95);
draw_set_color(c_yellow);
draw_rectangle(left - 4, top - 4, left + width + 4, top + total_h + 4, false);
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(left, top, left + width, top + total_h, false);
draw_set_color(c_yellow);
draw_text(left + 8, top + 6, "MENU");

draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(left, top, left + width, top + total_h, true);

draw_set_font(fntSmaller);
for (var i = 0; i < array_length(actions); i++) {
	var y1 = top + i * option_h;
	if (i == hover_index) {
		draw_set_alpha(0.25);
		draw_set_color(c_white);
		draw_rectangle(left + 1, y1 + 1, left + width - 1, y1 + option_h - 1, false);
		draw_set_alpha(1);
	}
	draw_set_color(c_white);
	draw_text(left + 8, y1 + 4, actions[i].label);
}
