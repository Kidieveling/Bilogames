sprite_index = spr_magic_trainer

npc_name = "Magic Trainer"
npc_text = "Want to learn about Magic?"
dialogue_text = npc_name + ": " + npc_text

npc_choices = [
	{
		text: "Can you teach me?",
		action: function() {
			if (!HasItem(obj_controller.myItems, "Simple Staff")) {
				with (obj_controller) {
					AddItem(myItems, ["Simple Staff", spr_simple_staff, 1, Type.Weapon, 5, obj_simple_staff])
				}

				with (obj_dialogue) {
					show("Magic Trainer: Take this Staff and defeat a few enemies", [])
				}
			} else {
				with (obj_dialogue) {
					show("Magic Trainer: You already have a staff now go practice.", [])
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
