/// @description Draw GUI: dialogue panel, world prompts/notices, software cursor.
/// Panel geometry lives in ComputeDialogueLayout / ComputePromptLayout only.

draw_set_font(fntSmaller);

#region Dialogue Panel

if (active) {
	var layout = ComputeDialogueLayout();
	DrawDialogueLayout(layout);
}

#endregion

#region Prompts And Notices

else if (prompt_active || notice_timer > 0) {
	var promptText = notice_timer > 0 ? notice_text : prompt_text;
	var layout = ComputePromptLayout(promptText);
	DrawDialogueLayout(layout);
}

#endregion

#region Cursor

draw_set_alpha(1);
var cursor_gui_x = device_mouse_x_to_gui(0);
var cursor_gui_y = device_mouse_y_to_gui(0);
draw_sprite(spr_cursor, 0, cursor_gui_x + sprite_get_xoffset(spr_cursor), cursor_gui_y + sprite_get_yoffset(spr_cursor));

#endregion
