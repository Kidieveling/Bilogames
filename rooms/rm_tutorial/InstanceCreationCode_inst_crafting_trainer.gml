sprite_index = spr_crafting_trainer

npc_name = "Crafting Trainer"
npc_text = "Want to learn about crafting?"
dialogue_text = npc_name + ": " + npc_text

npc_choices = [
	{
		text: "Can you teach me?",
		action: function() {
			if (!HasItem(obj_controller.myItems, "Copper Ore")) {
				with (obj_dialogue) {
					show("Crafting Trainer: You need to gather some Copper Ore", [])
				}
			} else if (!HasItem(obj_controller.myItems, "Normal Log")) {
				with (obj_dialogue) {
					show("Crafting Trainer: You need to gather some Normal Logs", [])
				}
			} else {
				with (obj_dialogue) {
					show("Mining Trainer: You already have a Pickaxe.", [])
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
