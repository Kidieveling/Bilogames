/// @description Draw custom cursor above the fixed UI

draw_set_alpha(1);
draw_sprite(spr_cursor, 0, mouse_x + sprite_get_xoffset(spr_cursor), mouse_y + sprite_get_yoffset(spr_cursor));

var dbg_npc = instance_position(mouse_x, mouse_y, obj_npc);
var dbg_res = instance_position(mouse_x, mouse_y, obj_resource);
draw_set_font(fntSmaller);
draw_set_color(c_yellow);
draw_text(20, 60, "room mouse " + string(floor(mouse_x)) + ", " + string(floor(mouse_y)));
draw_text(20, 76, "npc " + string(dbg_npc) + " res " + string(dbg_res));
draw_text(20, 92, "right " + string(variable_global_exists("debug_right_click") && global.debug_right_click));

if (variable_global_exists("hover_target") && instance_exists(global.hover_target)) {
	draw_set_alpha(0.35);
	draw_set_color(c_yellow);
	draw_rectangle(global.hover_target.bbox_left, global.hover_target.bbox_top, global.hover_target.bbox_right, global.hover_target.bbox_bottom, false);
	draw_set_alpha(1);
	draw_set_color(c_yellow);
	draw_text(global.hover_target.bbox_left, global.hover_target.bbox_top - 16, string(global.hover_target.object_index));
}
