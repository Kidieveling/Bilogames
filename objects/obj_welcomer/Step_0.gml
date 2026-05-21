/// @description Tour tick, face player during active dialogue, walk animation, depth sort.

#region Guided Tour

if (guided_tour_active) {
	GuidedIntro_TickWelcomer(id);
}

#endregion

#region Face Player During Dialogue

if (face_player_while_dialogue) {
	if (instance_exists(obj_dialogue) && obj_dialogue.active && instance_exists(obj_player)) {
		FaceTowardInstance(instance_find(obj_player, 0));
	} else {
		face_player_while_dialogue = false;
	}
}

#endregion

UpdateWelcomerAnimation();

depth = -y;
