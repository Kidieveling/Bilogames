/// @description Gather cooldown, respawn countdown, and auto-gather while player stays in range.

#region Cooldown

if (gather_cooldown > 0) {
    gather_cooldown -= 1
}

#endregion

#region Respawn

if (depleted && respawn_timer > 0) {
	respawn_timer -= 1
	if (respawn_timer <= 0) {
		RespawnResource()
	}
}

#endregion

#region Auto Gather

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

#endregion

depth = -y
