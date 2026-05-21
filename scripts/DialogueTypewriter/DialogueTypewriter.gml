/// @description Typewriter reveal and choice visibility; bound on obj_dialogue Create.

function DialogueTypewriter_Register(_inst) {
	with (_inst) {
		
		#region Typewriter
		
		Dialogue_ResetTypewriter = function(_full_text) {
			full_text = _full_text;
			text = _full_text;
			display_text = "";
			typewriter_index = 0;
			typewriter_timer = 0;
			text_finished = (string_length(_full_text) <= 0);
			
			// ACTION/PAUSE beats have no body copy — skip the typewriter entirely.
			if (text_finished) {
				display_text = _full_text;
				typewriter_index = string_length(_full_text);
			}
			
			Dialogue_UpdateChoicesVisibility();
		};
		
		Dialogue_UpdateChoicesVisibility = function() {
			if (!text_finished || array_length(choices) <= 0) {
				choices_visible = false;
				return;
			}
			if (conv_active && conv_beat_type == DIALOGUE_BEAT_LINE) {
				choices_visible = false;
				return;
			}
			choices_visible = true;
		};
		
		// After a LINE beat finishes typing, merge an immediate empty-prompt CHOICES beat in-place (keep full_text).
		Dialogue_OnLineTypewriterComplete = function() {
			if (!conv_active || conv_beat_type != DIALOGUE_BEAT_LINE) {
				Dialogue_UpdateChoicesVisibility();
				return;
			}
			var next_index = conv_beat_index + 1;
			if (next_index < array_length(conv_beats)) {
				var next_beat = conv_beats[next_index];
				if (next_beat.type == DIALOGUE_BEAT_CHOICES && string_length(next_beat.prompt) <= 0) {
					conv_beat_index = next_index;
					conv_beat_type = DIALOGUE_BEAT_CHOICES;
					choices = next_beat.choices;
					choice_index = 0;
					text_finished = true;
					display_text = full_text;
					choices_visible = array_length(choices) > 0;
					return;
				}
			}
			Dialogue_UpdateChoicesVisibility();
		};
		
		Dialogue_TickTypewriter = function() {
			if (!active || text_finished || string_length(full_text) <= 0) {
				return;
			}
			
			typewriter_timer += 1;
			if (typewriter_timer < typewriter_speed) {
				return;
			}
			
			typewriter_timer = 0;
			typewriter_index = min(string_length(full_text), typewriter_index + DIALOGUE_TYPEWRITER_CHARS_PER_FRAME);
			display_text = string_copy(full_text, 1, typewriter_index);
			
			if (typewriter_index >= string_length(full_text)) {
				text_finished = true;
				display_text = full_text;
				Dialogue_OnLineTypewriterComplete();
			}
		};
		
		Dialogue_FinishTypewriter = function() {
			if (text_finished) {
				return;
			}
			
			typewriter_index = string_length(full_text);
			display_text = full_text;
			text_finished = true;
			Dialogue_OnLineTypewriterComplete();
		};
		
		Dialogue_ResetPresentationState = function() {
			display_text = "";
			full_text = "";
			text = "";
			typewriter_index = 0;
			typewriter_timer = 0;
			text_finished = false;
			choices_visible = false;
		};
		
		Dialogue_GetBodyTextForLayout = function() {
			if (!active) {
				return "";
			}
			
			if (text_finished) {
				return full_text;
			}
			
			return display_text;
		};
		
		#endregion
	}
}
