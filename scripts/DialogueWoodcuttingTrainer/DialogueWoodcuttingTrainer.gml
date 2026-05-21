/// @description Woodcutting trainer dialogue: greeting, choices, quest responses. Quest state in Quest/GameState.

#macro DIALOGUE_WOODCUTTING_TRAINER_NAME "Woodcutting Trainer"

#region Entry

function DialogueWoodcuttingTrainer_Open(_trainer) {
	if (!instance_exists(_trainer)) {
		return;
	}
	var greeting = DialogueWoodcuttingTrainer_GetGreeting(_trainer);
	var choices = DialogueWoodcuttingTrainer_BuildChoices(_trainer);
	with (_trainer) {
		dialogue_text = greeting;
		npc_choices = choices;
	}
	Dialogue_PresentMenu(_trainer, greeting, choices);
}

#endregion

#region Greeting

function DialogueWoodcuttingTrainer_GetGreeting(_trainer) {
	if (!GameState_IsSecondChanceTrialStarted()) {
		return DIALOGUE_WOODCUTTING_TRAINER_NAME + ": The Welcomer runs intake. Until your Second Chance Trial is official, I cannot hand out tools or Marks. Go speak with them first.";
	}
	if (Quest_Woodcutting_GetState() == 0) {
		return DIALOGUE_WOODCUTTING_TRAINER_NAME + ": On the trial list, then. Good. Hearthmere needs timber — repairs, handles, fires, barricades. I can start you toward the Timber Mark.";
	}
	if (Quest_Woodcutting_GetState() == 1 && Quest_Woodcutting_CanComplete()) {
		return DIALOGUE_WOODCUTTING_TRAINER_NAME + ": That looks like enough timber. Let me count it before you start naming the logs.";
	}
	if (Quest_Woodcutting_GetState() == 1) {
		var current_logs = Quest_Woodcutting_GetProgress();
		return DIALOGUE_WOODCUTTING_TRAINER_NAME + ": You are on timber duty. Normal Logs collected: " + string(current_logs) + " / " + string(Quest_Woodcutting_GetRequiredLogs()) + ".";
	}
	return DIALOGUE_WOODCUTTING_TRAINER_NAME + ": Timber Mark earned. The Welcomer keeps the records. I keep the trees from becoming a crisis.";
}

#endregion

#region Quest Actions

function DialogueWoodcuttingTrainer_StartTimberDuty(_trainer) {
	if (!instance_exists(_trainer)) {
		return;
	}
	if (!GameState_IsSecondChanceTrialStarted()) {
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": Start with the Welcomer. They decide who is on the Second Chance Trial. Once your name is on that list, I can give you a tool and timber duty."
		);
		return;
	}
	var had_axe = HasItem(obj_controller.myItems, "Bronze Axe");
	Quest_Woodcutting_Start();
	var gave_axe = !had_axe && Inventory_GrantItem(undefined, "Bronze Axe");
	if (gave_axe) {
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": Timber Mark duty: collect 5 Normal Logs and bring them here. Hearthmere burns through wood faster than newcomers think. Take this Bronze Axe. Steady swings. Come back with proof, not excuses."
		);
	} else {
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": You already have an axe, so that saves us both a speech. First approval task: collect 5 Normal Logs and bring them back here."
		);
	}
}

function DialogueWoodcuttingTrainer_CheckTimberDuty(_trainer) {
	if (!instance_exists(_trainer)) {
		return;
	}
	if (Quest_Woodcutting_CanComplete()) {
		Quest_Woodcutting_Complete();
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": Five clean logs. I will endorse your Timber Mark for the Welcomer. That is how it works here — witnessed work, finished properly. The settlement can use you."
		);
	} else {
		var current_logs = Quest_Woodcutting_GetProgress();
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": You are still on timber duty. Bring me 5 Normal Logs. You have " + string(current_logs) + " counted so far. The trees are not running away, which is more than I can say for some recruits."
		);
	}
}

function DialogueWoodcuttingTrainer_ExplainWoodcutting(_trainer) {
	if (!instance_exists(_trainer)) {
		return;
	}
	if (!GameState_IsSecondChanceTrialStarted()) {
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": Ask the Welcomer first. They decide where every new approval case starts. I can explain timber once you are officially on the list."
		);
	} else {
		Dialogue_ShowResponse(
			_trainer,
			DIALOGUE_WOODCUTTING_TRAINER_NAME + ": Because wood touches everything in a place like this. Handles, bows, fires, repairs, crates, fences. Timber is the first way we see whether someone finishes what they start."
		);
	}
}

#endregion

#region Choices

function DialogueWoodcuttingTrainer_BuildChoices(_trainer) {
	var choices = [];
	if (!instance_exists(_trainer)) {
		return choices;
	}
	if (!GameState_IsSecondChanceTrialStarted()) {
		array_push(choices, {
			text: "Where do I start?",
			trainer: _trainer,
			action: function() {
				if (instance_exists(self.trainer)) {
					Dialogue_ShowResponse(
						self.trainer,
						DIALOGUE_WOODCUTTING_TRAINER_NAME + ": With the Welcomer. They are the decider for new approval cases. Speak with them first, then come back when you are cleared for work."
					);
				}
			}
		});
	} else if (Quest_Woodcutting_GetState() == 0) {
		array_push(choices, {
			text: "Start timber duty.",
			trainer: _trainer,
			action: function() {
				if (instance_exists(self.trainer)) {
					DialogueWoodcuttingTrainer_StartTimberDuty(self.trainer);
				}
			}
		});
	} else if (Quest_Woodcutting_GetState() == 1) {
		var label = Quest_Woodcutting_CanComplete() ? "Turn in the Normal Logs." : "Ask about timber duty.";
		array_push(choices, {
			text: label,
			trainer: _trainer,
			action: function() {
				if (instance_exists(self.trainer)) {
					DialogueWoodcuttingTrainer_CheckTimberDuty(self.trainer);
				}
			}
		});
	} else {
		array_push(choices, {
			text: "Timber duty is complete.",
			trainer: _trainer,
			action: function() {
				if (instance_exists(self.trainer)) {
					Dialogue_ShowResponse(
						self.trainer,
						DIALOGUE_WOODCUTTING_TRAINER_NAME + ": It is. Check in with the Welcomer when you want to see where your approval stands. I only handle the tree-shaped part of your future."
					);
				}
			}
		});
	}
	array_push(choices, {
		text: "Why wood first?",
		trainer: _trainer,
		action: function() {
			if (instance_exists(self.trainer)) {
				DialogueWoodcuttingTrainer_ExplainWoodcutting(self.trainer);
			}
		}
	});
	array_push(choices, Dialogue_MakeGoodbyeChoice());
	return choices;
}

#endregion
