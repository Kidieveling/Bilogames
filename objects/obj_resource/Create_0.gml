depth = -y

if (!variable_global_exists("woodcutting_level")) {
	global.woodcutting_level = 1
}
if (!variable_global_exists("woodcutting_xp")) {
	global.woodcutting_xp = 0
}
if (!variable_global_exists("mining_level")) {
	global.mining_level = 1
}
if (!variable_global_exists("mining_xp")) {
	global.mining_xp = 0
}
if (!variable_global_exists("smelting_level")) {
	global.smelting_level = 1
}
if (!variable_global_exists("smelting_xp")) {
	global.smelting_xp = 0
}

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

interact = function(_player) {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue)
	}
	
	if (gather_cooldown > 0) {
		return
	}
	
	if (resource_skill == "" || item_name == "" || item_sprite == -1 || item_object == noone) {
		with (obj_dialogue) {
			notify("UPDATE: This resource needs creation code.", 90)
		}
		return
	}
	
	if (!SkillExists(resource_skill)) {
		with (obj_dialogue) {
			notify("UPDATE: This resource needs a valid skill.", 90)
		}
		return
	}
	
	if (required_tool_name != "" && !HasItem(obj_controller.myItems, required_tool_name)) {
		with (obj_dialogue) {
			notify("You need a " + other.required_tool_name + " to use this.", 90)
		}
		return
	}
	
	var skill_level = GetSkillLevel(resource_skill)
	
	if (skill_level < required_level) {
		with (obj_dialogue) {
			notify("You need " + other.resource_skill + " level " + string(other.required_level) + ".", 90)
		}
		return
	}
	
	if (required_resource_name != "" && GetItemAmount(obj_controller.myItems, required_resource_name) < required_resource_amount) {
		with (obj_dialogue) {
			notify("You need " + string(other.required_resource_amount) + " " + other.required_resource_name + " to use this.", 90)
		}
		return
	}
	
	var item_added = AddItem(obj_controller.myItems, [item_name, item_sprite, item_amount, item_type, item_price, item_object])
	
	if (!item_added) {
		with (obj_dialogue) {
			notify("Your inventory is full.", 90)
		}
		return
	}
	
	if (required_resource_name != "") {
		RemoveItem(obj_controller.myItems, required_resource_name, required_resource_amount)
	}
	
	var leveled_up = AddSkillXP(resource_skill, xp_reward)
	
	gather_cooldown = gather_cooldown_max
	
	with (obj_dialogue) {
		var xp_text = " +" + string(other.xp_reward) + " " + other.resource_skill + " XP."
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
}
