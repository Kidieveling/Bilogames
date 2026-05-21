/// @description Thin API over obj_dialogue: ensure instance, set speaker, menus, paced conversations, NPC interact.

#region Instance Access

function Dialogue_EnsureInstance() {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue);
	}
}

function Dialogue_GetSpeaker() {
	if (!instance_exists(obj_dialogue)) {
		return noone;
	}
	
	var speaker = obj_dialogue.conversation_speaker;
	if (!instance_exists(speaker)) {
		return noone;
	}
	return speaker;
}

function Dialogue_SetSpeaker(_speaker) {
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		SetActiveSpeaker(_speaker);
	}
}

#endregion

#region Menus And Conversations

function Dialogue_PresentMenu(_speaker, _text, _choices) {
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		SetActiveSpeaker(_speaker);
		show(_text, _choices);
	}
}

function Dialogue_StartConversation(_speaker, _beats) {
	Dialogue_SetSpeaker(_speaker);
	DialogueConversation_Start(_speaker, _beats);
}

function Dialogue_OpenMenu(_speaker) {
	if (!instance_exists(_speaker)) {
		return;
	}
	
	Dialogue_SetSpeaker(_speaker);
	with (_speaker) {
		OpenDialogueMenu();
	}
}

#endregion

#region Responses And Close

function Dialogue_ShowResponse(_speaker, _text, _okText = "OK") {
	if (!instance_exists(_speaker)) {
		Dialogue_Close();
		return;
	}
	
	var speaker = _speaker;
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		SetActiveSpeaker(speaker);
		player_movement_locked = true;
		show(_text, [
			{
				text: _okText,
				action: function() {
					Dialogue_OpenMenu(Dialogue_GetSpeaker());
				}
			}
		]);
	}
}

function Dialogue_Close() {
	if (!instance_exists(obj_dialogue)) {
		return;
	}
	
	with (obj_dialogue) {
		SetActiveSpeaker(noone);
		hide();
	}
}

function Dialogue_MakeGoodbyeChoice() {
	return {
		text: "Goodbye.",
		action: function() {
			Dialogue_Close();
		}
	};
}

#endregion

#region NPC Interact

function Dialogue_InteractNpc(_speaker, _player) {
	if (!instance_exists(_speaker)) {
		return;
	}
	
	Dialogue_EnsureInstance();
	with (_speaker) {
		if (instance_exists(_player) && variable_instance_exists(id, "FaceTowardInstance")) {
			FaceTowardInstance(_player);
		} else if (instance_exists(obj_player) && variable_instance_exists(id, "FaceTowardInstance")) {
			FaceTowardInstance(instance_find(obj_player, 0));
		}
		
		if (variable_instance_exists(id, "face_player_while_dialogue")) {
			face_player_while_dialogue = true;
		}
	}
	
	Dialogue_OpenMenu(_speaker);
}

#endregion
