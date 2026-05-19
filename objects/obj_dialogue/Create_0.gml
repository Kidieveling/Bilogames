/// @description Dialogue state and helpers

active = false;
conversation_speaker = noone;
text = "";
choices = [];
choice_index = 0;
input_cooldown = 0;
prompt_active = false;
prompt_text = "";
notice_text = "";
notice_timer = 0;

show = function(_text, _choices) {
	text = _text;
	prompt_active = false;
	prompt_text = "";
	notice_timer = 0;
	
	if (array_length(_choices) == 0) {
		choices = [
			{
				text: "OK",
				action: function() {
					with (obj_dialogue) {
						hide();
					}
				}
			}
		];
	} else {
		choices = _choices;
	}
	
	choice_index = 0;
	active = true;
};

prompt = function(_text) {
	if (!active && notice_timer <= 0) {
		prompt_text = _text;
		prompt_active = true;
	}
};

clear_prompt = function() {
	if (!active) {
		prompt_text = "";
		prompt_active = false;
	}
};

notify = function(_text, _duration) {
	if (!active) {
		prompt_active = false;
		prompt_text = "";
		notice_text = _text;
		notice_timer = _duration;
	}
};

hide = function() {
	active = false;
	conversation_speaker = noone;
	text = "";
	choices = [];
	choice_index = 0;
	input_cooldown = 12;
	with (obj_player) {
		npc_talk_cooldown = 18;
	}
};

ComputeDialogueLayout = function() {
	var layout = {
		valid: false,
		box_x1: 0,
		box_y1: 0,
		box_x2: 0,
		box_y2: 0,
		choice_rects: []
	};
	
	if (!active) {
		return layout;
	}
	
	var screenWidth = display_get_gui_width();
	var screenHeight = display_get_gui_height();
	var paddingX = 24;
	var paddingY = 18;
	var lineGap = 18;
	var maxBoxWidth = min(560, screenWidth - 64);
	
	draw_set_font(fntSmaller);
	
	var contentWidth = min(string_width(text), maxBoxWidth - paddingX * 2);
	for (var c = 0; c < array_length(choices); ++c) {
		var measuredChoice = choices[c];
		if (is_struct(measuredChoice)) {
			measuredChoice = measuredChoice.text;
		}
		contentWidth = max(contentWidth, string_width("> " + string(measuredChoice)));
	}
	
	var boxWidth = clamp(contentWidth + paddingX * 2, 180, maxBoxWidth);
	var textWidth = boxWidth - paddingX * 2;
	var textLines = max(1, ceil(string_width(text) / max(1, textWidth)));
	var contentHeight = textLines * lineGap + 36 + array_length(choices) * 24;
	var boxHeight = contentHeight + paddingY * 2;
	var skillBarTop = screenHeight - sprite_get_height(spr_skillBar) - 12;
	
	layout.valid = true;
	layout.box_x1 = 32;
	layout.box_y1 = skillBarTop - boxHeight - 12;
	layout.box_x2 = layout.box_x1 + boxWidth;
	layout.box_y2 = layout.box_y1 + boxHeight;
	
	var textX = layout.box_x1 + paddingX;
	var textY = layout.box_y1 + paddingY;
	var choicesY = textY + textLines * lineGap + 36;
	var choiceRowHeight = 24;
	
	for (var i = 0; i < array_length(choices); ++i) {
		array_push(layout.choice_rects, {
			x1: textX,
			y1: choicesY + i * choiceRowHeight,
			x2: layout.box_x2 - paddingX,
			y2: choicesY + (i + 1) * choiceRowHeight - 2
		});
	}
	
	return layout;
};

ActivateChoice = function(_index) {
	if (_index < 0 || _index >= array_length(choices)) {
		return;
	}
	
	choice_index = _index;
	var choice = choices[_index];
	
	if (is_struct(choice) && variable_struct_exists(choice, "action")) {
		var _action = choice.action;
		_action();
	} else {
		hide();
	}
};

IsMouseOverDialogueGui = function(_mx, _my) {
	if (!active) {
		return false;
	}
	
	var layout = ComputeDialogueLayout();
	if (!layout.valid) {
		return false;
	}
	
	return point_in_rectangle(_mx, _my, layout.box_x1, layout.box_y1, layout.box_x2, layout.box_y2);
};
