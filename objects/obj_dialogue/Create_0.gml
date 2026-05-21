/// @description Persistent dialogue controller: instance state, legacy menus, prompts/notices.
/// Typewriter, paced beats, layout, and input are bound from Dialogue* scripts on Create.

#region Instance State

active = false;
active_speaker = noone;
conversation_speaker = noone;
text = "";
choices = [];
choice_index = 0;
input_cooldown = 0;

prompt_active = false;
prompt_text = "";
notice_text = "";
notice_timer = 0;

anchor_to_speaker = false;
player_movement_locked = false;

// full_text stays on screen after typing; display_text is only the revealed prefix.
display_text = "";
full_text = "";
typewriter_index = 0;
typewriter_speed = 1;
typewriter_timer = 0;
text_finished = false;
choices_visible = false;

conv_active = false;
conv_beats = [];
conv_beat_index = 0;
conv_beat_type = "";
conv_pause_timer = 0;
conv_line_pause_after = 0;
conv_line_pause_active = false;
panel_speaker_name = "";
dialogue_dim_background = false; // paced conversations only — keeps world visible, not a full-screen block

#endregion

#region Legacy Menu API

SetActiveSpeaker = function(_speaker) {
	active_speaker = _speaker;
	conversation_speaker = _speaker;
	anchor_to_speaker = instance_exists(_speaker);
};

show = function(_text, _choices) {
	EndConversation();
	player_movement_locked = false;
	prompt_active = false;
	prompt_text = "";
	notice_timer = 0;
	
	choices = _choices;
	choice_index = 0;
	active = true;
	conv_active = false;
	dialogue_dim_background = false;
	
	panel_speaker_name = DialogueUI_GetSpeakerName(GetActiveSpeaker());
	var parsed = DialogueUI_ParseFormattedLine(_text);
	if (panel_speaker_name == "") {
		panel_speaker_name = parsed.speaker;
	}
	
	var bodyText = _text;
	if (parsed.speaker != "") {
		bodyText = parsed.body;
	}
	
	Dialogue_ResetTypewriter(bodyText);
};

#endregion

#region World Prompts And Notices

// Bottom panel doubles as a world hint bar whenever no conversation owns it.

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

// Timed notices win over hover prompts so gather/depletion feedback is never masked.
notify = function(_text, _duration) {
	if (!active) {
		prompt_active = false;
		prompt_text = "";
		notice_text = _text;
		notice_timer = _duration;
	}
};

#endregion

#region Session Control

hide = function() {
	active = false;
	EndConversation();
	dialogue_dim_background = false;
	panel_speaker_name = "";
	SetActiveSpeaker(noone);
	player_movement_locked = false;
	choices = [];
	choice_index = 0;
	input_cooldown = 12; // prevents the same confirm from closing and immediately reopening talk
	with (obj_player) {
		npc_talk_cooldown = 18;
	}
};

Dialogue_PlayerMovementLocked = function() {
	if (!active) {
		return false;
	}
	return player_movement_locked || choices_visible;
};

GetActiveSpeaker = function() {
	if (instance_exists(active_speaker)) {
		return active_speaker;
	}
	if (instance_exists(conversation_speaker)) {
		return conversation_speaker;
	}
	return noone;
};

#endregion

#region Script Bindings

DialogueTypewriter_Register(id);
DialogueConversation_Register(id);
DialogueLayout_Register(id);
DialogueInput_Register(id);

#endregion
