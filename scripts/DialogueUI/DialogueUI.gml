/// @description Bottom-center cinematic dialogue panel layout helpers

#macro DIALOGUEUI_WIDTH_FACTOR 0.70
#macro DIALOGUEUI_MIN_HEIGHT 150
#macro DIALOGUEUI_MAX_HEIGHT_FACTOR 0.24
#macro DIALOGUEUI_BOTTOM_MARGIN 32
#macro DIALOGUEUI_PADDING 18
#macro DIALOGUEUI_LINE_GAP 18
#macro DIALOGUEUI_NAME_GAP 24
#macro DIALOGUEUI_CHOICE_ROW_HEIGHT 24
#macro DIALOGUEUI_CHOICE_TOP_GAP 8

/// @param {Real} _height Optional panel height in GUI pixels (clamped to min/max)
/// @returns {Struct} { x1, y1, x2, y2, w, h, padding }
function DialogueUI_GetPanelRect(_height = undefined) {
	var gui_w = display_get_gui_width();
	var gui_h = display_get_gui_height();
	var box_w = gui_w * DIALOGUEUI_WIDTH_FACTOR;
	var box_h = DIALOGUEUI_MIN_HEIGHT;
	
	if (!is_undefined(_height)) {
		box_h = _height;
	}
	
	var max_h = gui_h * DIALOGUEUI_MAX_HEIGHT_FACTOR;
	box_h = clamp(box_h, DIALOGUEUI_MIN_HEIGHT, max_h);
	
	var box_x = (gui_w - box_w) * 0.5;
	var box_y = gui_h - box_h - DIALOGUEUI_BOTTOM_MARGIN;
	
	return {
		x1: box_x,
		y1: box_y,
		x2: box_x + box_w,
		y2: box_y + box_h,
		w: box_w,
		h: box_h,
		padding: DIALOGUEUI_PADDING
	};
}

/// @param {String} _line Full line, often "Speaker: body"
/// @returns {Struct} { speaker, body }
function DialogueUI_ParseFormattedLine(_line) {
	var sep = string_pos(":", _line);
	if (sep > 1 && sep <= 48) {
		var body = string_copy(_line, sep + 1, string_length(_line) - sep);
		if (string_length(body) > 0 && string_char_at(body, 1) == " ") {
			body = string_copy(body, 2, string_length(body) - 1);
		}
		return {
			speaker: string_copy(_line, 1, sep - 1),
			body: body
		};
	}
	return { speaker: "", body: _line };
}

/// @param {Id.Instance} _speaker
/// @returns {String}
function DialogueUI_GetSpeakerName(_speaker) {
	if (!instance_exists(_speaker)) {
		return "";
	}
	if (variable_instance_exists(_speaker, "npc_name") && _speaker.npc_name != "") {
		return _speaker.npc_name;
	}
	return "";
}
