/// @description Draw player and interaction prompt

draw_self();

if (instance_exists(obj_dialogue) && obj_dialogue.active) {
	exit;
}

var npc = instance_nearest(x, y, obj_npc);
if (npc != noone) {
	if (point_distance(x, y, npc.x, npc.y) <= tile_size) {
		draw_set_font(fntSmaller);
		draw_set_color(c_white);
		draw_text(x - 48, y - 48, "Press E to talk to " + npc.npc_name);
	}
}
