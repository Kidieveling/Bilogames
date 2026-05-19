event_inherited();

npc_name = "Woodcutting Trainer"
npc_text = "Timber work is the first real test around here. If the Welcomer has you on the trial list, I can put an axe in your hands."
dialogue_text = npc_name + ": " + npc_text

OpenDialogueMenu = function() {
	dialogue_text = GetWoodcuttingGreeting()
	npc_choices = BuildWoodcuttingChoices()
	Dialogue_PresentMenu(id, dialogue_text, npc_choices)
}

GetWoodcuttingGreeting = function() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		return "Woodcutting Trainer: The Welcomer runs intake. Until your Second Chance Trial is official, I cannot hand out tools or Marks. Go speak with them first."
	}
	if (Quest_Woodcutting_GetState() == 0) {
		return "Woodcutting Trainer: On the trial list, then. Good. Hearthmere needs timber — repairs, handles, fires, barricades. I can start you toward the Timber Mark."
	}
	if (Quest_Woodcutting_GetState() == 1 && Quest_Woodcutting_CanComplete()) {
		return "Woodcutting Trainer: That looks like enough timber. Let me count it before you start naming the logs."
	}
	if (Quest_Woodcutting_GetState() == 1) {
		var current_logs = Quest_Woodcutting_GetProgress()
		return "Woodcutting Trainer: You are on timber duty. Normal Logs collected: " + string(current_logs) + " / " + string(Quest_Woodcutting_GetRequiredLogs()) + "."
	}
	return "Woodcutting Trainer: Timber Mark earned. The Welcomer keeps the records. I keep the trees from becoming a crisis."
}

StartTimberDuty = function() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: Start with the Welcomer. They decide who is on the Second Chance Trial. Once your name is on that list, I can give you a tool and timber duty."
		)
		return
	}
	
	var had_axe = HasItem(obj_controller.myItems, "Bronze Axe")
	Quest_Woodcutting_Start()
	var gave_axe = !had_axe && Inventory_GrantItem(undefined, "Bronze Axe")
	
	if (gave_axe) {
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: Timber Mark duty: collect 5 Normal Logs and bring them here. Hearthmere burns through wood faster than newcomers think. Take this Bronze Axe. Steady swings. Come back with proof, not excuses."
		)
	} else {
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: You already have an axe, so that saves us both a speech. First approval task: collect 5 Normal Logs and bring them back here."
		)
	}
}

CheckTimberDuty = function() {
	if (Quest_Woodcutting_CanComplete()) {
		Quest_Woodcutting_Complete()
		
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: Five clean logs. I will endorse your Timber Mark for the Welcomer. That is how it works here — witnessed work, finished properly. The settlement can use you."
		)
	} else {
		var current_logs = Quest_Woodcutting_GetProgress()
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: You are still on timber duty. Bring me 5 Normal Logs. You have " + string(current_logs) + " counted so far. The trees are not running away, which is more than I can say for some recruits."
		)
	}
}

ExplainWoodcutting = function() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: Ask the Welcomer first. They decide where every new approval case starts. I can explain timber once you are officially on the list."
		)
	} else {
		Dialogue_ShowResponse(
			id,
			"Woodcutting Trainer: Because wood touches everything in a place like this. Handles, bows, fires, repairs, crates, fences. Timber is the first way we see whether someone finishes what they start."
		)
	}
}

BuildWoodcuttingChoices = function() {
	var choices = []
	var trainer = id
	
	if (!GameState_IsSecondChanceTrialStarted()) {
		array_push(choices, {
			text: "Where do I start?",
			trainer: trainer,
			action: function() {
				if (instance_exists(trainer)) {
					Dialogue_ShowResponse(
						trainer,
						"Woodcutting Trainer: With the Welcomer. They are the decider for new approval cases. Speak with them first, then come back when you are cleared for work."
					)
				}
			}
		})
	} else if (Quest_Woodcutting_GetState() == 0) {
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
	} else if (Quest_Woodcutting_GetState() == 1) {
		if (Quest_Woodcutting_CanComplete()) {
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
			trainer: trainer,
			action: function() {
				if (instance_exists(trainer)) {
					Dialogue_ShowResponse(
						trainer,
						"Woodcutting Trainer: It is. Check in with the Welcomer when you want to see where your approval stands. I only handle the tree-shaped part of your future."
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
	
	array_push(choices, Dialogue_MakeGoodbyeChoice())
	
	return choices
}

npc_choices = BuildWoodcuttingChoices()

interact = function(_player) {
	Dialogue_InteractNpc(id, _player)
}
