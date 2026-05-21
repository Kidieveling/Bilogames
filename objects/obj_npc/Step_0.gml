/// @description Hold facing during dialogue; depth sort with world objects.

image_speed = 0

#region Face Player During Dialogue

if (face_player_while_dialogue) {
	if (instance_exists(obj_dialogue) && obj_dialogue.active && instance_exists(obj_player)) {
		FaceTowardInstance(instance_find(obj_player, 0))
	} else {
		face_player_while_dialogue = false
	}
}

#endregion

image_index = facing_dir
depth = -y
