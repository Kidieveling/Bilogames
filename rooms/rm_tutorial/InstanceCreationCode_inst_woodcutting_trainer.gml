npc_name = "Woodcutting Trainer"
npc_text = "Want to learn about woodcutting?"
dialogue_text = npc_name + ": " + npc_text
x -= 16
npc_choices = [
	{
		text: "Can you teach me?",
		action: function() {
			if (!HasItem(obj_controller.myItems, "Bronze Axe")) {
				with (obj_controller) {
					AddItem(myItems, ["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe])
				}

				with (obj_dialogue) {
					show("Woodcutting Trainer: Take this axe. Start by trying to chop down a Normal Tree.", [])
				}
			} else {
				with (obj_dialogue) {
					show("Woodcutting Trainer: You already have an axe.", [])
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
