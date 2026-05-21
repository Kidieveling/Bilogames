/// @description Paced dialogue beat structs and session entry points; runner state lives on obj_dialogue.

#region Beat Type Macros

#macro DIALOGUE_BEAT_LINE "line"
#macro DIALOGUE_BEAT_PAUSE "pause"
#macro DIALOGUE_BEAT_CHOICES "choices"
#macro DIALOGUE_BEAT_ACTION "action"

#macro DIALOGUE_MAX_CHOICES 4
#macro DIALOGUE_TYPEWRITER_CHARS_PER_FRAME 2

#endregion

#region Beat Builders

function DialogueBeat_Line(_speaker_name, _text, _pause_after = 0) {
	return {
		type: DIALOGUE_BEAT_LINE,
		speaker: _speaker_name,
		text: _text,
		pause_after: _pause_after
	};
}

function DialogueBeat_Pause(_frames) {
	return {
		type: DIALOGUE_BEAT_PAUSE,
		frames: _frames
	};
}

function DialogueBeat_Choices(_prompt, _choices) {
	return {
		type: DIALOGUE_BEAT_CHOICES,
		prompt: _prompt,
		choices: _choices
	};
}

function DialogueBeat_Action(_fn) {
	return {
		type: DIALOGUE_BEAT_ACTION,
		fn: _fn
	};
}

#endregion

#region Session API

function DialogueConversation_Start(_speaker, _beats) {
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		StartConversation(_speaker, _beats);
	}
}

function DialogueConversation_AppendBeats(_beats) {
	if (!instance_exists(obj_dialogue)) {
		return;
	}
	with (obj_dialogue) {
		AppendConversationBeats(_beats);
	}
}

function DialogueConversation_IsActive() {
	return instance_exists(obj_dialogue) && obj_dialogue.active && obj_dialogue.conv_active;
}

function DialogueConversation_FormatLine(_speaker_name, _text) {
	if (_speaker_name == "") {
		return _text;
	}
	return _speaker_name + ": " + _text;
}

#endregion

#region Instance Runner

function DialogueConversation_Register(_inst) {
	with (_inst) {
		
		StartConversation = function(_speaker, _beats) {
			if (array_length(_beats) <= 0) {
				return;
			}
			
			EndConversation();
			SetActiveSpeaker(_speaker);
			conv_beats = _beats;
			conv_beat_index = 0;
			conv_active = true;
			dialogue_dim_background = true;
			active = true;
			choices = [];
			choice_index = 0;
			prompt_active = false;
			prompt_text = "";
			notice_timer = 0;
			ApplyConversationBeat();
		};
		
		AppendConversationBeats = function(_beats) {
			for (var i = 0; i < array_length(_beats); i++) {
				array_push(conv_beats, _beats[i]);
			}
		};
		
		EndConversation = function() {
			conv_active = false;
			conv_beats = [];
			conv_beat_index = 0;
			conv_beat_type = "";
			conv_pause_timer = 0;
			conv_line_pause_after = 0;
			conv_line_pause_active = false;
			Dialogue_ResetPresentationState();
		};
		
		// LINE → optional hold → CHOICES/ACTION; ACTION runs inline so quest flags can fire between spoken lines.
		ApplyConversationBeat = function() {
			if (!conv_active) {
				return;
			}
			
			if (conv_beat_index >= array_length(conv_beats)) {
				hide();
				return;
			}
			
			var beat = conv_beats[conv_beat_index];
			conv_beat_type = beat.type;
			choices = [];
			choice_index = 0;
			conv_line_pause_active = false;
			conv_line_pause_after = 0;
			choices_visible = false;
			
			switch (beat.type) {
				case DIALOGUE_BEAT_LINE:
					panel_speaker_name = beat.speaker;
					Dialogue_ResetTypewriter(beat.text);
					conv_line_pause_after = beat.pause_after;
					break;
				
				case DIALOGUE_BEAT_PAUSE:
					Dialogue_ResetTypewriter("");
					break;
				
				case DIALOGUE_BEAT_CHOICES:
					choices = beat.choices;
					Dialogue_ResetTypewriter(beat.prompt);
					break;
				
				case DIALOGUE_BEAT_ACTION:
					Dialogue_ResetTypewriter("");
					if (variable_struct_exists(beat, "fn")) {
						method(beat, beat.fn)();
					}
					AdvanceConversationBeat();
					break;
			}
		};
		
		AdvanceConversationBeat = function() {
			conv_beat_index += 1;
			conv_line_pause_active = false;
			conv_pause_timer = 0;
			ApplyConversationBeat();
		};
		
		Conversation_IsLineComplete = function() {
			return text_finished;
		};
		
		Conversation_SkipTypewriter = function() {
			Dialogue_FinishTypewriter();
		};
		
		Conversation_TryAdvance = function() {
			if (!conv_active || !text_finished) {
				return false;
			}
			
			if (conv_beat_type == DIALOGUE_BEAT_CHOICES) {
				if (!choices_visible) {
					Dialogue_FinishTypewriter();
					return true;
				}
				return false;
			}
			
			if (conv_beat_type == DIALOGUE_BEAT_PAUSE) {
				conv_pause_timer = 0;
				AdvanceConversationBeat();
				return true;
			}
			
			if (conv_line_pause_active) {
				conv_line_pause_active = false;
				AdvanceConversationBeat();
				return true;
			}
			
			// pause_after needs two confirms: first starts the hold, second advances the beat index.
			if (conv_line_pause_after > 0) {
				conv_line_pause_active = true;
				conv_pause_timer = conv_line_pause_after;
				return true;
			}
			
			AdvanceConversationBeat();
			return true;
		};
		
		Conversation_TickPause = function() {
			if (!conv_active) {
				return;
			}
			
			if (conv_beat_type == DIALOGUE_BEAT_PAUSE && conv_pause_timer > 0) {
				conv_pause_timer -= 1;
				if (conv_pause_timer <= 0) {
					AdvanceConversationBeat();
				}
				return;
			}
			
			if (conv_line_pause_active && conv_pause_timer > 0) {
				conv_pause_timer -= 1;
				if (conv_pause_timer <= 0) {
					conv_line_pause_active = false;
					AdvanceConversationBeat();
				}
			}
		};
	}
}

#endregion
