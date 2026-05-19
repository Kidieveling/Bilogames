image_speed = 0

if (face_player_while_dialogue) {
	if (instance_exists(obj_dialogue) && obj_dialogue.active && instance_exists(obj_player)) {
		FaceTowardInstance(instance_find(obj_player, 0))
	} else {
		face_player_while_dialogue = false
	}
}

image_index = facing_dir
depth = -y
