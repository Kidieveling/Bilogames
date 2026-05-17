sprite_index = spr_mining_trainer

if (!variable_global_exists("welcomer_approval_started")) {
	global.welcomer_approval_started = false
}

npc_name = "Mining Trainer"
npc_text = "Mining work is approval work. If the Welcomer has your name, we can talk."
dialogue_text = npc_name + ": " + npc_text

npc_choices = [
	{
		text: "Can you teach me?",
		action: function() {
			if (!global.welcomer_approval_started) {
				with (obj_dialogue) {
					show("Mining Trainer: Start with the Welcomer. They decide who gets approved for settlement work. I teach mining, not paperwork, and I am grateful for that every morning.", [])
				}
			} else if (!HasItem(obj_controller.myItems, "Bronze Pickaxe")) {
				with (obj_controller) {
					AddItem(myItems, ["Bronze Pickaxe", spr_bronze_pickaxe, 1, Type.Tool, 5, obj_bronze_pickaxe])
				}

				with (obj_dialogue) {
					show("Mining Trainer: Good. The Welcomer has you moving through approval work. Take this pickaxe and start with Copper Ore. Swing clean, watch your footing, and do not argue with rocks. They always win eventually.", [])
				}
			} else {
				with (obj_dialogue) {
					show("Mining Trainer: You already have a pickaxe. Copper first. Bring useful ore, and the Welcomer will have one less reason to doubt you.", [])
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
