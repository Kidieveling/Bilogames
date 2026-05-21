/// @description Second Chance Trial quest state (Timber Mark) and quest panel copy for obj_controller.

#macro QUEST_WOODCUTTING_ITEM "Normal Log"

#region Init And State

function Quest_Init() {
	if (!variable_global_exists("quest_woodcutting_state")) {
		global.quest_woodcutting_state = 0;
	}
	if (!variable_global_exists("quest_woodcutting_required_logs")) {
		global.quest_woodcutting_required_logs = 5;
	}
}

function Quest_GetPlayerInventory() {
	if (instance_exists(obj_controller)) {
		return obj_controller.myItems;
	}
	return undefined;
}

function Quest_Woodcutting_GetState() {
	return global.quest_woodcutting_state;
}

function Quest_Woodcutting_GetRequiredLogs() {
	return global.quest_woodcutting_required_logs;
}

function Quest_Woodcutting_Start() {
	if (global.quest_woodcutting_state == 0) {
		global.quest_woodcutting_state = 1;
	}
}

#endregion

#region Progress And Completion

function Quest_Woodcutting_GetProgress() {
	var inventory = Quest_GetPlayerInventory();
	if (inventory == undefined) {
		return 0;
	}
	return clamp(GetItemAmount(inventory, QUEST_WOODCUTTING_ITEM), 0, global.quest_woodcutting_required_logs);
}

function Quest_Woodcutting_CanComplete() {
	return global.quest_woodcutting_state == 1
		&& Quest_Woodcutting_GetProgress() >= global.quest_woodcutting_required_logs;
}

function Quest_Woodcutting_Complete() {
	if (!Quest_Woodcutting_CanComplete()) {
		return false;
	}
	
	var inventory = Quest_GetPlayerInventory();
	if (inventory == undefined) {
		return false;
	}
	if (!RemoveItem(inventory, QUEST_WOODCUTTING_ITEM, global.quest_woodcutting_required_logs)) {
		return false;
	}
	
	global.quest_woodcutting_state = 2;
	GameState_SetWoodcuttingMarkApproved(true);
	AddSkillXP("Woodcutting", 50);
	return true;
}

#endregion

#region Quest Panel Copy

function Quest_Woodcutting_GetQuestInfo() {
	var questState = global.quest_woodcutting_state;
	var questProgress = Quest_Woodcutting_GetProgress();
	var questRequired = global.quest_woodcutting_required_logs;
	var questProgressAmount = clamp(questProgress / max(1, questRequired), 0, 1);
	var questStatus = "Not Started";
	var questObjective = StoryOpening_GetCurrentObjective();
	var questReturnTo = StoryOpening_GetCurrentReturnTarget();
	var questRewards = "Timber Mark + 50 Woodcutting XP";
	
	if (GameState_IsSecondChanceTrialStarted() && questState == 0) {
		questObjective = StoryOpening_GetCurrentObjective();
		questReturnTo = "Woodcutting Trainer";
	}
	
	if (questState == 1) {
		questStatus = "Active";
		questReturnTo = "Woodcutting Trainer";
		
		if (questProgress >= questRequired) {
			questObjective = "Return the logs for the Timber Mark.";
		} else {
			questObjective = "Collect " + string(questRequired) + " Normal Logs for the Timber Mark.";
		}
	}
	
	if (questState == 2) {
		questStatus = "Complete";
		questProgress = questRequired;
		questProgressAmount = 1;
		questObjective = "Report to the Welcomer — Timber Mark earned.";
		questReturnTo = "Welcomer";
		questRewards = "Timber Mark recorded + 50 Woodcutting XP";
		
		if (GameState_IsWoodcuttingAcknowledged()) {
			questObjective = "Earn the Ore Mark: speak with the Mining Trainer.";
			questReturnTo = "Mining Trainer";
		}
	}
	
	return {
		title: "Second Chance Trial",
		status: questStatus,
		objective: questObjective,
		return_to: questReturnTo,
		rewards: questRewards,
		progress: questProgress,
		required: questRequired,
		progress_amount: questProgressAmount
	};
}

#endregion
