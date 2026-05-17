sprite_index = spr_welcome

if (!variable_global_exists("welcomer_approval_started")) {
	global.welcomer_approval_started = false
}
if (!variable_global_exists("welcomer_woodcutting_approved")) {
	global.welcomer_woodcutting_approved = false
}
if (!variable_global_exists("quest_woodcutting_state")) {
	global.quest_woodcutting_state = 0
}

npc_name = "Welcomer"
npc_text = "Easy now. You are inside the settlement, which means someone important decided you were worth the risk."
dialogue_text = npc_name + ": " + npc_text

npc_choices = [
	{
		text: "What happens now?",
		action: function() {
			global.welcomer_approval_started = true
			
			with (obj_dialogue) {
				show(
					"Welcomer: You earn approval from the trainers. Each one watches a different kind of work: timber, ore, tools, and whatever else keeps this place standing. Get their approval, then come back when the settlement has reason to trust you.",
					[]
				)
			}
		}
	},
	{
		text: "How do I earn approval?",
		action: function() {
			if (!global.welcomer_approval_started) {
				global.welcomer_approval_started = true
			}
			
			with (obj_dialogue) {
				show(
					"Welcomer: Speak with each trainer and complete the work they give you. You do not need my approval for every log or rock. You need their marks showing you can be useful without needing someone to stand over you with a clipboard.",
					[]
				)
			}
		}
	},
	{
		text: "Where should I start?",
		action: function() {
			global.welcomer_approval_started = true
			
			with (obj_dialogue) {
				show(
					"Welcomer: Start with the woodcutting trainer. Timber teaches the basic rhythm: get a tool, gather materials, finish the task, earn a mark. After that, mining and crafting will make more sense. Slightly more sense. Do not get ambitious.",
					[]
				)
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
