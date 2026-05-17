sprite_index = spr_mining_trainer

npc_name = "Mining Trainer"
npc_text = "Want to learn about mining?"
dialogue_text = npc_name + ": " + npc_text

npc_choices = [
	{
		text: "Can you teach me?",
		action: function() {
			if (!HasItem(obj_controller.myItems, "Bronze Pickaxe")) {
				with (obj_controller) {
					AddItem(myItems, ["Bronze Pickaxe", spr_bronze_pickaxe, 1, Type.Tool, 5, obj_bronze_pickaxe])
				}

				with (obj_dialogue) {
					show("Mining Trainer: Take this axe. Start by trying to get some minerals from that rock.", [])
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
