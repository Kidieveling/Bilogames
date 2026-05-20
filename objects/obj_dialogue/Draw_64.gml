/// @description Draw dialogue, prompts, and notices (Draw GUI)

draw_set_font(fntSmaller);

if (active) {
	var layout = ComputeDialogueLayout();
	DrawDialogueLayout(layout);
} else if (prompt_active || notice_timer > 0) {
	var displayText = notice_timer > 0 ? notice_text : prompt_text;
	var panel = DialogueUI_GetPanelRect(72);
	var padding = DIALOGUEUI_PADDING;
	var textWidth = panel.w - padding * 2;
	
	draw_set_alpha(0.88);
	draw_set_color(make_color_rgb(12, 12, 16));
	draw_rectangle(panel.x1, panel.y1, panel.x2, panel.y2, false);
	draw_set_alpha(1);
	draw_set_color(make_color_rgb(90, 90, 98));
	draw_rectangle(panel.x1, panel.y1, panel.x2, panel.y2, true);
	draw_set_color(c_white);
	draw_text_ext(panel.x1 + padding, panel.y1 + padding, displayText, DIALOGUEUI_LINE_GAP, textWidth);
}

draw_set_alpha(1);
var cursor_gui_x = device_mouse_x_to_gui(0);
var cursor_gui_y = device_mouse_y_to_gui(0);
draw_sprite(spr_cursor, 0, cursor_gui_x + sprite_get_xoffset(spr_cursor), cursor_gui_y + sprite_get_yoffset(spr_cursor));
