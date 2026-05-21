/// @description NPC sprite, hover tint, and name label (skipped for placeholder "UPDATE" names).

#region Sprite

var hovered = point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)

if (hovered) {
	draw_set_alpha(0.45);
	draw_set_color(c_yellow);
	draw_self();
	draw_set_alpha(1);
	draw_set_color(c_white);
} else {
	draw_self();
}

#endregion

#region Name Label

if (variable_instance_exists(id, "npc_name") && npc_name != "" && npc_name != "UPDATE") {
	draw_set_font(fntSmaller);
	
	var name_text = string(npc_name);
	var name_x = x - (string_width(name_text) / 2);
	var name_y = bbox_top - 18;
	
	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_text(name_x + 1, name_y + 1, name_text);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(name_x, name_y, name_text);
}

#endregion

draw_set_alpha(1);
draw_set_color(c_white);
