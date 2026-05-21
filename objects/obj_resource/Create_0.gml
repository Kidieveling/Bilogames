/// @description Data-driven gather nodes: room creation code sets fields; children inherit this loop.
/// Woodcutting/Mining auto-repeat while in range; Smelting is one-shot per interact.

depth = -y

#region Creation Code Defaults

resource_name = "UPDATE Resource"
resource_action = "Gather"
resource_skill = ""
required_level = 1
required_tool_name = ""
required_resource_name = ""
required_resource_amount = 1
item_name = ""
item_sprite = -1
item_amount = 1
item_type = Type.Resource
item_price = 0
item_object = noone
xp_reward = 0

gather_cooldown = 0
gather_cooldown_max = 30
gathering_active = false
gathering_player = noone
resource_amount_min = 3
resource_amount_max = 6
resource_amount_available = irandom_range(resource_amount_min, resource_amount_max)
success_chance = 75
depleted = false
depleted_sprite = spr_resource
active_sprite = -1
active_resource_action = ""
respawn_timer = 0
respawn_time_min = 600
respawn_time_max = 900

#endregion

#region Gather State

CanAutoGather = function() {
	return resource_skill == "Woodcutting" || resource_skill == "Mining"
}

StopGathering = function() {
	gathering_active = false
	gathering_player = noone
}

#endregion

#region Requirements

CanUseResource = function() {
	if (depleted) {
		with (obj_dialogue) {
			notify(other.resource_name + " is depleted.", 90)
		}
		return false
	}
	
	if (resource_skill == "" || item_name == "" || item_sprite == -1 || item_object == noone) {
		with (obj_dialogue) {
			notify("UPDATE: This resource needs creation code.", 90)
		}
		return false
	}
	
	if (!SkillExists(resource_skill)) {
		with (obj_dialogue) {
			notify("UPDATE: This resource needs a valid skill.", 90)
		}
		return false
	}
	
	if (required_tool_name != "" && !HasItem(obj_controller.myItems, required_tool_name)) {
		with (obj_dialogue) {
			notify("You need a " + other.required_tool_name + " to use this.", 90)
		}
		return false
	}
	
	var skill_level = GetSkillLevel(resource_skill)
	if (skill_level < required_level) {
		with (obj_dialogue) {
			notify("You need " + other.resource_skill + " level " + string(other.required_level) + ".", 90)
		}
		return false
	}
	
	if (required_resource_name != "" && GetItemAmount(obj_controller.myItems, required_resource_name) < required_resource_amount) {
		with (obj_dialogue) {
			notify("You need " + string(other.required_resource_amount) + " " + other.required_resource_name + " to use this.", 90)
		}
		return false
	}
	
	return true
}

#endregion

#region Depletion And Respawn

DepleteResource = function() {
	if (active_sprite == -1) {
		active_sprite = sprite_index
	}
	if (active_resource_action == "") {
		active_resource_action = resource_action
	}
	
	depleted = true
	StopGathering()
	sprite_index = depleted_sprite
	resource_action = "Inspect"
	respawn_timer = irandom_range(respawn_time_min, respawn_time_max)
	with (obj_dialogue) {
		notify(other.resource_name + " is depleted.", 120)
	}
}

RespawnResource = function() {
	depleted = false
	resource_amount_available = irandom_range(resource_amount_min, resource_amount_max)
	respawn_timer = 0
	
	if (active_sprite != -1) {
		sprite_index = active_sprite
	}
	if (active_resource_action != "") {
		resource_action = active_resource_action
	}
}

#endregion

#region Gather Attempt

TryGatherAttempt = function() {
	if (!CanUseResource()) {
		StopGathering()
		return false
	}
	
	gather_cooldown = gather_cooldown_max
	
	// Miss still consumes the swing timer so auto-gather pacing stays steady.
	if (CanAutoGather() && irandom(99) >= success_chance) {
		with (obj_dialogue) {
			notify("You swing at the " + other.resource_name + " but get nothing.", 60)
		}
		return true
	}
	
	var item_added = Inventory_GrantItem(obj_controller.myItems, item_name, item_amount)
	if (!item_added) {
		with (obj_dialogue) {
			notify("Your inventory is full.", 90)
		}
		StopGathering()
		return false
	}
	
	if (required_resource_name != "") {
		RemoveItem(obj_controller.myItems, required_resource_name, required_resource_amount)
	}
	
	var leveled_up = AddSkillXP(resource_skill, xp_reward)
	
	if (CanAutoGather()) {
		resource_amount_available -= item_amount
	}
	
	with (obj_dialogue) {
		var xp_text = " +" + string(other.xp_reward) + " " + other.resource_skill + " XP.";
		if (other.required_resource_name != "") {
			if (leveled_up) {
				notify("You smelt " + other.required_resource_name + " into " + other.item_name + "." + xp_text + " Level up!", 120)
			} else {
				notify("You smelt " + other.required_resource_name + " into " + other.item_name + "." + xp_text, 90)
			}
		} else {
			if (leveled_up) {
				notify("You get " + string(other.item_amount) + " " + other.item_name + "." + xp_text + " Level up!", 120)
			} else {
				notify("You get " + string(other.item_amount) + " " + other.item_name + "." + xp_text, 90)
			}
		}
	}
	
	if (CanAutoGather() && resource_amount_available <= 0) {
		DepleteResource()
	}
	
	return true
}

#endregion

#region Interact Entry

interact = function(_player) {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue)
	}
	
	if (gather_cooldown > 0) {
		return
	}
	
	if (!CanUseResource()) {
		return
	}
	
	if (CanAutoGather()) {
		gathering_active = true
		gathering_player = _player
		TryGatherAttempt()
		return
	}
	
	TryGatherAttempt()
}

#endregion
