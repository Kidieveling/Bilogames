/// @description Story opening helpers for the Markless / Second Chance Trial intro

function StoryOpening_InitGlobals() {
	if (!variable_global_exists("story_opening_seen")) {
		global.story_opening_seen = false;
	}
	if (!variable_global_exists("story_opening_prompt_enabled")) {
		global.story_opening_prompt_enabled = true;
	}
}

function StoryOpening_IsSecondChanceTrialStarted() {
	return variable_global_exists("welcomer_approval_started") && global.welcomer_approval_started;
}

function StoryOpening_GetCurrentObjective() {
	if (!StoryOpening_IsSecondChanceTrialStarted()) {
		return "Speak with the Welcomer.";
	}
	
	if (variable_global_exists("quest_woodcutting_state")) {
		if (global.quest_woodcutting_state == 0) {
			return "Earn the Timber Mark: speak with the Woodcutting Trainer.";
		}
		if (global.quest_woodcutting_state == 1) {
			return "Earn the Timber Mark: complete the Woodcutting Trainer's task.";
		}
	}
	
	return "Continue the Second Chance Trial.";
}

function StoryOpening_GetCurrentReturnTarget() {
	if (!StoryOpening_IsSecondChanceTrialStarted()) {
		return "Welcomer";
	}
	
	if (variable_global_exists("quest_woodcutting_state")) {
		if (global.quest_woodcutting_state == 0 || global.quest_woodcutting_state == 1) {
			return "Woodcutting Trainer";
		}
		if (global.quest_woodcutting_state == 2) {
			return "Welcomer";
		}
	}
	
	return "Welcomer";
}

function StoryOpening_GetPromptText() {
	if (!variable_global_exists("story_opening_prompt_enabled")) {
		return "";
	}
	if (!global.story_opening_prompt_enabled) {
		return "";
	}
	if (StoryOpening_IsSecondChanceTrialStarted()) {
		return "";
	}
	return "Speak with the Welcomer";
}
