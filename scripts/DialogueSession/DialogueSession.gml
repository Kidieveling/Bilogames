/// @description Legacy show/prompt/notice API and session lifecycle on obj_dialogue.

function DialogueSession_Register(_inst) {
	with (_inst) {
		
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
	}
}
