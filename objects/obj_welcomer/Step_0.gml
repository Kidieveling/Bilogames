if (guided_tour_active) {
	GuidedIntro_TickWelcomer(id);
}

if (face_player_while_dialogue) {
	if (instance_exists(obj_dialogue) && obj_dialogue.active && instance_exists(obj_player)) {
		FaceTowardInstance(instance_find(obj_player, 0));
	} else {
		face_player_while_dialogue = false;
	}
}

UpdateWelcomerAnimation();

depth = -y;
