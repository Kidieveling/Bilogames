/// @description Dialogue state and helpers

active = false;
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
	if (!active) {
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
	if (!active && !prompt_active) {
		notice_text = _text;
		notice_timer = _duration;
	}
};

hide = function() {
	active = false;
	text = "";
	choices = [];
	choice_index = 0;
	input_cooldown = 2;
};
