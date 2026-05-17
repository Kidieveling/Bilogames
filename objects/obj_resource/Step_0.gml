if (gather_cooldown > 0) {
    gather_cooldown -= 1
}

if (depleted && respawn_timer > 0) {
	respawn_timer -= 1
	if (respawn_timer <= 0) {
		RespawnResource()
	}
}

if (gathering_active) {
	if (!instance_exists(gathering_player) || !obj_controller.IsInInteractionRange(gathering_player, id, 1)) {
		StopGathering()
		with (obj_dialogue) {
			notify("You stop gathering.", 60)
		}
	} else if (gather_cooldown <= 0) {
		TryGatherAttempt()
	}
}

depth = -y
