depth = 25

if (!variable_global_exists("woodcutting_level")) {
	global.woodcutting_level = 1
}
if (!variable_global_exists("woodcutting_xp")) {
	global.woodcutting_xp = 0
}

resource_name = "Resource"
resource_action = "Gather"
required_level = 1
required_tool_name = ""
item_name = "Normal Log"
item_sprite = spr_normal_log
item_amount = 1
item_type = Type.Consumable
item_price = 1
item_object = obj_normal_log
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
	
	if (required_tool_name != "" && !HasItem(obj_controller.myItems, required_tool_name)) {
		with (obj_dialogue) {
			notify("You need a " + other.required_tool_name + " to use this.", 90)
		}
		return
	}
	
	if (global.woodcutting_level < required_level) {
		with (obj_dialogue) {
			notify("You need woodcutting level " + string(other.required_level) + ".", 90)
		}
		return
	}
	
	with (obj_controller) {
		AddItem(myItems, [other.item_name, other.item_sprite, other.item_amount, other.item_type, other.item_price, other.item_object])
	}
	
	global.woodcutting_xp += xp_reward
	gather_cooldown = gather_cooldown_max
	
	with (obj_dialogue) {
		notify("You get " + string(other.item_amount) + " " + other.item_name + ".", 90)
	}
}
