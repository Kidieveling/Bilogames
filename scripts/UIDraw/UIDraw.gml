/// @description Reusable UI rectangles and choice rows (GUI and room draw). Restores alpha/color after each call.

#macro UI_DIALOGUE_PANEL_FILL make_color_rgb(12, 12, 16)
#macro UI_DIALOGUE_PANEL_BORDER make_color_rgb(90, 90, 98)
#macro UI_PANEL_BORDER_NEUTRAL make_color_rgb(90, 90, 98)

/// @description Reset common draw state after panel primitives.
function UI_ResetDrawState() {
	draw_set_alpha(1);
	draw_set_color(c_white);
}

/// @description Filled axis-aligned rectangle.
function UI_DrawPanel(_x1, _y1, _x2, _y2, _color = c_black, _alpha = 1) {
	draw_set_alpha(_alpha);
	draw_set_color(_color);
	draw_rectangle(_x1, _y1, _x2, _y2, false);
	UI_ResetDrawState();
}

/// @description Fill plus outline; optional outer glow rectangle (context menus, highlights).
function UI_DrawBorderedPanel(_x1, _y1, _x2, _y2, _fill_col = c_black, _fill_alpha = 0.9, _border_col = c_white, _border_alpha = 1, _outer_glow_col = undefined, _outer_pad = 4, _outer_alpha = 0.95) {
	if (!is_undefined(_outer_glow_col)) {
		draw_set_alpha(_outer_alpha);
		draw_set_color(_outer_glow_col);
		draw_rectangle(_x1 - _outer_pad, _y1 - _outer_pad, _x2 + _outer_pad, _y2 + _outer_pad, false);
	}
	UI_DrawPanel(_x1, _y1, _x2, _y2, _fill_col, _fill_alpha);
	if (_border_alpha > 0) {
		draw_set_alpha(_border_alpha);
		draw_set_color(_border_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
	}
	UI_ResetDrawState();
}

/// @description Full-screen dim behind modal dialogue (GUI space).
function UI_DrawDimScreen(_alpha = 0.15, _color = c_black) {
	UI_DrawPanel(0, 0, display_get_gui_width(), display_get_gui_height(), _color, _alpha);
}

/// @description Highlight one row (choice hover/selection).
function UI_DrawRowHighlight(_x1, _y1, _x2, _y2, _color, _alpha, _pad_x = 0, _pad_y = 0) {
	UI_DrawPanel(_x1 - _pad_x, _y1 - _pad_y, _x2 + _pad_x, _y2 + _pad_y, _color, _alpha);
}

/// @description Choice/menu rows. _items: strings or structs with .text; _rects[i] optional {x1,y1,x2,y2}.
/// @param {Struct} [_opts] highlight_color, highlight_alpha, highlight_pad_x/y, prefix_selected, prefix_normal, text_selected_col, text_normal_col, text_x_offset, text_y_offset
function UI_DrawChoiceList(_rects, _items, _highlight_index, _opts = undefined) {
	var highlight_col = make_color_rgb(70, 72, 88);
	var highlight_alpha = 0.22;
	var highlight_pad_x = 4;
	var highlight_pad_y = 2;
	var prefix_sel = "> ";
	var prefix_norm = "  ";
	var text_sel_col = c_white;
	var text_norm_col = make_color_rgb(210, 210, 215);
	var text_x_off = 0;
	var text_y_off = 0;
	
	if (is_struct(_opts)) {
		if (variable_struct_exists(_opts, "highlight_color")) highlight_col = _opts.highlight_color;
		if (variable_struct_exists(_opts, "highlight_alpha")) highlight_alpha = _opts.highlight_alpha;
		if (variable_struct_exists(_opts, "highlight_pad_x")) highlight_pad_x = _opts.highlight_pad_x;
		if (variable_struct_exists(_opts, "highlight_pad_y")) highlight_pad_y = _opts.highlight_pad_y;
		if (variable_struct_exists(_opts, "prefix_selected")) prefix_sel = _opts.prefix_selected;
		if (variable_struct_exists(_opts, "prefix_normal")) prefix_norm = _opts.prefix_normal;
		if (variable_struct_exists(_opts, "text_selected_col")) text_sel_col = _opts.text_selected_col;
		if (variable_struct_exists(_opts, "text_normal_col")) text_norm_col = _opts.text_normal_col;
		if (variable_struct_exists(_opts, "text_x_offset")) text_x_off = _opts.text_x_offset;
		if (variable_struct_exists(_opts, "text_y_offset")) text_y_off = _opts.text_y_offset;
	}
	
	for (var i = 0; i < array_length(_items); i++) {
		var label = _items[i];
		if (is_struct(label) && variable_struct_exists(label, "text")) {
			label = label.text;
		}
		var is_highlight = (i == _highlight_index);
		var row = undefined;
		if (i < array_length(_rects)) {
			row = _rects[i];
		}
		if (is_highlight && is_struct(row)) {
			UI_DrawRowHighlight(row.x1, row.y1, row.x2, row.y2, highlight_col, highlight_alpha, highlight_pad_x, highlight_pad_y);
		}
		var draw_x = is_struct(row) ? row.x1 + text_x_off : text_x_off;
		var draw_y = is_struct(row) ? row.y1 + text_y_off : text_y_off;
		if (!is_struct(row) && is_struct(_opts) && variable_struct_exists(_opts, "base_x")) {
			draw_x = _opts.base_x + text_x_off;
			draw_y = _opts.base_y + i * _opts.row_h + text_y_off;
		}
		draw_set_color(is_highlight ? text_sel_col : text_norm_col);
		draw_text(draw_x, draw_y, (is_highlight ? prefix_sel : prefix_norm) + label);
	}
	UI_ResetDrawState();
}
