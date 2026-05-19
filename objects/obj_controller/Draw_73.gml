/// @description Draw custom cursor above the fixed UI

if (menu_open && array_length(menu_actions) > 0) {
	var rect = GetContextMenuRect();
	var mx = rect.x;
	var my = rect.y;
	var menuW = rect.w;
	var optionH = rect.option_h;
	var menuH = rect.h;
	draw_set_alpha(0.95);
	draw_set_color(c_yellow);
	draw_rectangle(mx - 4, my - 4, mx + menuW + 4, my + menuH + 4, false);
	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_rectangle(mx, my, mx + menuW, my + menuH, false);
	draw_set_color(c_white);
	draw_rectangle(mx, my, mx + menuW, my + menuH, true);
	draw_set_font(fntSmaller);
	var hoveredOption = -1;
	if (point_in_rectangle(mouse_x, mouse_y, mx, my, mx + menuW, my + menuH)) {
		hoveredOption = floor((mouse_y - my) / optionH);
	}
	for (var i = 0; i < array_length(menu_actions); i++) {
		var y1 = my + i * optionH;
		if (i == hoveredOption) {
			draw_set_alpha(0.35);
			draw_set_color(c_yellow);
			draw_rectangle(mx + 1, y1 + 1, mx + menuW - 1, y1 + optionH - 1, false);
			draw_set_alpha(1);
		}
		draw_set_color(c_white);
		draw_text(mx + 8, y1 + 4, menu_actions[i].label);
	}
}

draw_set_alpha(1);
if (!(instance_exists(obj_dialogue) && (obj_dialogue.active || obj_dialogue.prompt_active || obj_dialogue.notice_timer > 0))) {
	draw_sprite(spr_cursor, 0, mouse_x + sprite_get_xoffset(spr_cursor), mouse_y + sprite_get_yoffset(spr_cursor));
}
