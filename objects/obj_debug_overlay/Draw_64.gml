/// @description Debug overlay (FPS, frame time, animated heartbeat)

if (!enabled) {
	exit;
}

var panel_x = 8;
var panel_y = 8;
var panel_w = 210;
var panel_h = 118;
var line_h = 14;
var text_x = panel_x + 6;
var text_y = panel_y + 6;

draw_set_alpha(0.8);
draw_set_color(c_black);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
draw_set_alpha(1);

if (spike_flash > 0) {
	draw_set_alpha(0.35);
	draw_set_color(c_red);
	draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
	draw_set_alpha(1);
}

draw_set_font(fntSmaller);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var fps_color = c_lime;
if (fps_display < 55) {
	fps_color = c_yellow;
}
if (fps_display < 30) {
	fps_color = c_red;
}

var ms_color = c_white;
if (frame_ms_display > 20) {
	ms_color = c_yellow;
}
if (frame_ms_display > 50) {
	ms_color = c_red;
}

draw_set_color(fps_color);
draw_text(text_x, text_y, "FPS: " + string(floor(fps_display)));
text_y += line_h;

draw_set_color(ms_color);
draw_text(text_x, text_y, "Frame: " + string_format(frame_ms_display, 1, 1) + " ms");
text_y += line_h;

draw_set_color(frame_ms_max > 33 ? c_red : c_ltgray);
draw_text(text_x, text_y, "Spike max: " + string_format(frame_ms_max, 1, 1) + " ms / 1s");
text_y += line_h;

draw_set_color(c_white);
var menu_item_count = instance_number(objItemParent);
draw_text(text_x, text_y, "Inst: " + string(instance_number(all)) + "  MenuItems: " + string(menu_item_count));
text_y += line_h;

draw_set_color(c_ltgray);
draw_text(text_x, text_y, "F3 hide  |  red flash = hitch");

var anim_x = panel_x + panel_w - 36;
var anim_y = panel_y + panel_h - 40;
draw_sprite(spr_player, floor(anim_frame), anim_x, anim_y);

var pulse = 0.5 + 0.5 * sin(degtorad(pulse_timer * 12));
draw_set_color(make_color_rgb(255, 50 + 205 * pulse, 50 + 205 * (1 - pulse)));
draw_circle(anim_x - 14, anim_y + 18, 4 + 2 * pulse, false);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
