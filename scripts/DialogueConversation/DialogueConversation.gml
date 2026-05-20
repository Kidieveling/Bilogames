/// @description Paced dialogue beat builders and session API (runner lives on obj_dialogue)

#macro DIALOGUE_BEAT_LINE "line"
#macro DIALOGUE_BEAT_PAUSE "pause"
#macro DIALOGUE_BEAT_CHOICES "choices"
#macro DIALOGUE_BEAT_ACTION "action"

#macro DIALOGUE_MAX_CHOICES 4
#macro DIALOGUE_TYPEWRITER_CHARS_PER_FRAME 2

/// @param {String} _speaker_name Display name prefix (e.g. "Welcomer")
/// @param {String} _text Line body without prefix
/// @param {Real} _pause_after Frames to hold line after player advances (0 = immediate next beat)
function DialogueBeat_Line(_speaker_name, _text, _pause_after = 0) {
	return {
		type: DIALOGUE_BEAT_LINE,
		speaker: _speaker_name,
		text: _text,
		pause_after: _pause_after
	};
}

/// @param {Real} _frames Hold before auto-advancing (player can skip with confirm)
function DialogueBeat_Pause(_frames) {
	return {
		type: DIALOGUE_BEAT_PAUSE,
		frames: _frames
	};
}

/// @param {String} _prompt Optional line above choices (empty = choices only)
/// @param {Array} _choices [{ text, action }] — max DIALOGUE_MAX_CHOICES recommended
function DialogueBeat_Choices(_prompt, _choices) {
	return {
		type: DIALOGUE_BEAT_CHOICES,
		prompt: _prompt,
		choices: _choices
	};
}

/// @param {Function} _fn Runs immediately; use to set flags before next beats
function DialogueBeat_Action(_fn) {
	return {
		type: DIALOGUE_BEAT_ACTION,
		fn: _fn
	};
}

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
