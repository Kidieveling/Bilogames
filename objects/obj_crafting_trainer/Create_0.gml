is_npc = true

if (!variable_global_exists("welcomer_approval_started")) {
	global.welcomer_approval_started = false
}

npc_name = "Crafting Trainer"
npc_text = "Crafting comes after approval starts. The Welcomer likes things in order. Annoying, but useful."
dialogue_text = npc_name + ": " + npc_text

npc_choices = [
	{
		text: "Can you teach me?",
		action: function() {
			if (!global.welcomer_approval_started) {
				with (obj_dialogue) {
					show("Crafting Trainer: Start with the Welcomer. They decide who gets approved for skill work, tools, and settlement responsibility. I organize materials, not second chances.", [])
				}
			} else if (!HasItem(obj_controller.myItems, "Normal Log")) {
				with (obj_dialogue) {
					show("Crafting Trainer: You need to gather some Normal Logs", [])
				}
			} else if (!HasItem(obj_controller.myItems, "Copper Ore")) {
				with (obj_dialogue) {
					show("Crafting Trainer: You need to gather some Copper Ore", [])
				}
			} else if (!HasItem(obj_controller.myItems, "Knife")) {
				with (obj_controller) {
					AddItem(myItems, ["Knife", spr_knife, 1, Type.Tool, 5, obj_knife])
				}
				with (obj_dialogue) {
					show("Crafting Trainer: Good. You brought the materials. Take this knife. Work a log, then take your ore to the furnace. We do things in order here.", [])
				}
			} else {
				with (obj_dialogue) {
					show("Use your knife on a log and use your ore on a furnace", [])
				}
			}
		}
	},
	{
		text: "Goodbye.",
		action: function() {
			with (obj_dialogue) {
				hide()
			}
		}
	}
]

interact = function(_player) {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue)
	}
	
	with (obj_dialogue) {
		show(other.dialogue_text, other.npc_choices)
	}
}
