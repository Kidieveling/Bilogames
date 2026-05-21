/// @description Draw End: world-space context menu and custom cursor above the menu HUD.
/// Dialogue uses its own GUI cursor, so we skip spr_cursor while a panel or notice is up.

#region Context Menu

if (menu_open && array_length(menu_actions) > 0) {
	var rect = GetContextMenuRect();
	var mx = rect.x;
	var my = rect.y;
	var menuW = rect.w;
	var optionH = rect.option_h;
	var menuH = rect.h;
	UI_DrawBorderedPanel(mx, my, mx + menuW, my + menuH, c_black, 1, c_white, 1, c_yellow, 4, 0.95);
	draw_set_font(fntSmaller);
	var hoveredOption = -1;
	if (point_in_rectangle(mouse_x, mouse_y, mx, my, mx + menuW, my + menuH)) {
		hoveredOption = floor((mouse_y - my) / optionH);
	}
	var menu_labels = [];
	var menu_rects = [];
	for (var i = 0; i < array_length(menu_actions); i++) {
		var y1 = my + i * optionH;
		array_push(menu_labels, menu_actions[i].label);
		array_push(menu_rects, {
			x1: mx + 1,
			y1: y1 + 1,
			x2: mx + menuW - 1,
			y2: y1 + optionH - 1
		});
	}
	UI_DrawChoiceList(menu_rects, menu_labels, hoveredOption, {
		highlight_color: c_yellow,
		highlight_alpha: 0.35,
		highlight_pad_x: 0,
		highlight_pad_y: 0,
		prefix_selected: "",
		prefix_normal: "",
		text_selected_col: c_white,
		text_normal_col: c_white,
		text_x_offset: 8,
		text_y_offset: 4
	});
}

#endregion

#region Cursor

draw_set_alpha(1);
if (!(instance_exists(obj_dialogue) && (obj_dialogue.active || obj_dialogue.prompt_active || obj_dialogue.notice_timer > 0))) {
	draw_sprite(spr_cursor, 0, mouse_x + sprite_get_xoffset(spr_cursor), mouse_y + sprite_get_yoffset(spr_cursor));
}

#endregion
