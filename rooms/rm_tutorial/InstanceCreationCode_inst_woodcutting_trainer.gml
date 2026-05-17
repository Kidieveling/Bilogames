sprite_index = spr_woodcutting_trainer

if (!variable_global_exists("welcomer_approval_started")) {
	global.welcomer_approval_started = false
}
if (!variable_global_exists("welcomer_woodcutting_approved")) {
	global.welcomer_woodcutting_approved = false
}
if (!variable_global_exists("quest_woodcutting_state")) {
	global.quest_woodcutting_state = 0
}

npc_name = "Woodcutting Trainer"
npc_text = "Need timber work? I can help, once the Welcomer has you cleared for approval tasks."
dialogue_text = npc_name + ": " + npc_text

GetWoodcuttingGreeting = function() {
	if (!global.welcomer_approval_started) {
		return "Woodcutting Trainer: Timber work starts after the Welcomer clears you for approval tasks."
	}
	if (global.quest_woodcutting_state == 0) {
		return "Woodcutting Trainer: Cleared by the Welcomer, then? Good. I have timber work ready."
	}
	if (global.quest_woodcutting_state == 1 && obj_controller.CanCompleteWoodcuttingQuest()) {
		return "Woodcutting Trainer: That looks like enough timber. Let me count it before you start naming the logs."
	}
	if (global.quest_woodcutting_state == 1) {
		var current_logs = obj_controller.GetWoodcuttingQuestProgress()
		return "Woodcutting Trainer: You are on timber duty. Normal Logs collected: " + string(current_logs) + " / " + string(global.quest_woodcutting_required_logs) + "."
	}
	return "Woodcutting Trainer: Timber duty is approved. The Welcomer will want to hear you are making progress."
}

StartTimberDuty = function() {
	if (!global.welcomer_approval_started) {
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: Start with the Welcomer. They decide who is cleared for approval work. Once your name is on that list, I can give you a tool and a task.",
				[]
			)
		}
		return
	}
	
	var gave_axe = !HasItem(obj_controller.myItems, "Bronze Axe")
	with (obj_controller) {
		StartWoodcuttingQuest()
		if (!HasItem(myItems, "Bronze Axe")) {
			AddItem(myItems, ["Bronze Axe", spr_bronze_axe, 1, Type.Tool, 5, obj_bronze_axe])
		}
	}
	
	if (gave_axe) {
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: First approval task: collect 5 Normal Logs. The settlement needs repairs, handles, cookfires, and fewer people pretending wood appears by wishing. Take this Bronze Axe. Keep your swing steady.",
				[]
			)
		}
	} else {
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: You already have an axe, so that saves us both a speech. First approval task: collect 5 Normal Logs and bring them back here.",
				[]
			)
		}
	}
}

CheckTimberDuty = function() {
	if (obj_controller.CanCompleteWoodcuttingQuest()) {
		with (obj_controller) {
			CompleteWoodcuttingQuest()
		}
		
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: Good. Five clean logs. I will mark your timber duty approved for the Welcomer. That is how trust starts around here: useful work, finished properly.",
				[]
			)
		}
	} else {
		var current_logs = obj_controller.GetWoodcuttingQuestProgress()
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: You are still on timber duty. Bring me 5 Normal Logs. You have " + string(current_logs) + " counted so far. The trees are not running away, which is more than I can say for some recruits.",
				[]
			)
		}
	}
}

ExplainWoodcutting = function() {
	if (!global.welcomer_approval_started) {
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: Ask the Welcomer first. They decide where every new approval case starts. I can explain timber once you are officially on the list.",
				[]
			)
		}
	} else {
		with (obj_dialogue) {
			show(
				"Woodcutting Trainer: Because wood touches everything. Tool handles, bows, fires, repairs, crates, fences. Learn to gather it well and the rest of the settlement gets easier to build.",
				[]
			)
		}
	}
}

BuildWoodcuttingChoices = function() {
	var choices = []
	var trainer = id
	
	if (!global.welcomer_approval_started) {
		array_push(choices, {
			text: "Where do I start?",
			action: function() {
				with (obj_dialogue) {
					show(
						"Woodcutting Trainer: With the Welcomer. They are the decider for new approval cases. Speak with them first, then come back when you are cleared for work.",
						[]
					)
				}
			}
		})
	} else if (global.quest_woodcutting_state == 0) {
		array_push(choices, {
			text: "Start timber duty.",
			trainer: trainer,
			action: function() {
				if (instance_exists(trainer)) {
					with (trainer) {
						StartTimberDuty()
					}
				}
			}
		})
	} else if (global.quest_woodcutting_state == 1) {
		if (obj_controller.CanCompleteWoodcuttingQuest()) {
			array_push(choices, {
				text: "Turn in the Normal Logs.",
				trainer: trainer,
				action: function() {
					if (instance_exists(trainer)) {
						with (trainer) {
							CheckTimberDuty()
						}
					}
				}
			})
		} else {
			array_push(choices, {
				text: "Ask about timber duty.",
				trainer: trainer,
				action: function() {
					if (instance_exists(trainer)) {
						with (trainer) {
							CheckTimberDuty()
						}
					}
				}
			})
		}
	} else {
		array_push(choices, {
			text: "Timber duty is complete.",
			action: function() {
				with (obj_dialogue) {
					show(
						"Woodcutting Trainer: It is. Check in with the Welcomer when you want to see where your approval stands. I only handle the tree-shaped part of your future.",
						[]
					)
				}
			}
		})
	}
	
	array_push(choices, {
		text: "Why wood first?",
		trainer: trainer,
		action: function() {
			if (instance_exists(trainer)) {
				with (trainer) {
					ExplainWoodcutting()
				}
			}
		}
	})
	
	array_push(choices, {
		text: "Goodbye.",
		action: function() {
			with (obj_dialogue) {
				hide()
			}
		}
	})
	
	return choices
}

npc_choices = BuildWoodcuttingChoices()

interact = function(_player) {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue)
	}
	
	dialogue_text = GetWoodcuttingGreeting()
	npc_choices = BuildWoodcuttingChoices()
	
	with (obj_dialogue) {
		show(other.dialogue_text, other.npc_choices)
	}
}
