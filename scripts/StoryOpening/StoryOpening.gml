/// @description HUD objective/return-target strings from GameState + quest progress (Welcomer intro pillar).

#region Delegates

function StoryOpening_InitGlobals() {
	GameState_Init();
}

function StoryOpening_IsWelcomerBriefingComplete() {
	return GameState_IsWelcomerBriefingComplete();
}

function StoryOpening_IsSecondChanceTrialStarted() {
	return GameState_IsSecondChanceTrialStarted();
}

#endregion

#region Objective Text

function StoryOpening_GetCurrentObjective() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		if (GameState_IsWelcomerBriefingComplete()) {
			return "Accept the Second Chance Trial with the Welcomer.";
		}
		return "Learn your standing — speak with the Welcomer at Hearthmere.";
	}
	
	var woodcuttingState = Quest_Woodcutting_GetState();
	if (woodcuttingState == 0) {
		return "Earn the Timber Mark: speak with the Woodcutting Trainer.";
	}
	if (woodcuttingState == 1) {
		return "Earn the Timber Mark: return 5 Normal Logs to the Woodcutting Trainer.";
	}
	
	if (GameState_IsWoodcuttingAcknowledged()) {
		return "Earn the Ore Mark: gather copper, then smelt and craft.";
	}
	
	return "Continue the Second Chance Trial — earn Marks through useful work.";
}

function StoryOpening_GetCurrentReturnTarget() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		return "Welcomer";
	}
	
	var woodcuttingState = Quest_Woodcutting_GetState();
	if (woodcuttingState == 0 || woodcuttingState == 1) {
		return "Woodcutting Trainer";
	}
	if (woodcuttingState == 2) {
		if (GameState_IsWoodcuttingAcknowledged()) {
			return "Mining Trainer";
		}
		return "Welcomer";
	}
	
	return "Welcomer";
}

#endregion

#region World Prompt

function StoryOpening_GetPromptText() {
	if (!GameState_IsStoryPromptEnabled()) {
		return "";
	}
	if (GameState_IsSecondChanceTrialStarted()) {
		return "";
	}
	if (GameState_IsWelcomerBriefingComplete()) {
		return "Accept the Second Chance Trial at the Welcomer";
	}
	return "Speak with the Welcomer";
}

#endregion
