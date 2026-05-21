/// @description Story progression globals, Welcomer briefing/trial flags, shared movement tick,
/// and skill/RNG bootstrap. Called from obj_controller Create; rm_init still hard-resets skills on boot.

#region Briefing Topic Macros

#macro GAMESTATE_BRIEF_WHAT_HAPPENED "what_happened"
#macro GAMESTATE_BRIEF_MARKLESS "markless"
#macro GAMESTATE_BRIEF_HEARTHMERE "hearthmere"
#macro GAMESTATE_BRIEF_SPONSOR "sponsor"
#macro GAMESTATE_BRIEF_MARKS "marks"
#macro GAMESTATE_BRIEF_TRIAL_INFO "trial_info"

#endregion

#region Movement Tick

/// Logic steps on movement ticks; visual lerp still runs every frame between tile centers.
#macro MOVEMENT_TICK_LENGTH 11

function MovementTick_Init() {
	if (!variable_global_exists("movement_tick")) {
		global.movement_tick = 0;
	}
	if (!variable_global_exists("movement_tick_length")) {
		global.movement_tick_length = MOVEMENT_TICK_LENGTH;
	}
}

function MovementTick_Advance() {
	if (!variable_global_exists("movement_tick")) {
		MovementTick_Init();
	}
	global.movement_tick += 1;
}

function MovementTick_Get() {
	if (!variable_global_exists("movement_tick")) {
		MovementTick_Init();
	}
	return global.movement_tick;
}

#endregion

#region Bootstrap

function GameState_Init() {
	MovementTick_Init();
	GameState_InitSkillsAndRng();
	
	// variable_global_exists guards keep flags across room transitions; rm_init overwrites skills on a cold boot.
	if (!variable_global_exists("story_opening_seen")) {
		global.story_opening_seen = false;
	}
	if (!variable_global_exists("story_opening_prompt_enabled")) {
		global.story_opening_prompt_enabled = true;
	}
	if (!variable_global_exists("welcomer_brief_what_happened")) {
		global.welcomer_brief_what_happened = false;
	}
	if (!variable_global_exists("welcomer_brief_markless")) {
		global.welcomer_brief_markless = false;
	}
	if (!variable_global_exists("welcomer_brief_hearthmere")) {
		global.welcomer_brief_hearthmere = false;
	}
	if (!variable_global_exists("welcomer_brief_sponsor")) {
		global.welcomer_brief_sponsor = false;
	}
	if (!variable_global_exists("welcomer_brief_marks")) {
		global.welcomer_brief_marks = false;
	}
	if (!variable_global_exists("welcomer_brief_trial_info")) {
		global.welcomer_brief_trial_info = false;
	}
	if (!variable_global_exists("welcomer_approval_started")) {
		global.welcomer_approval_started = false;
	}
	if (!variable_global_exists("welcomer_woodcutting_approved")) {
		global.welcomer_woodcutting_approved = false;
	}
	if (!variable_global_exists("welcomer_woodcutting_acknowledged")) {
		global.welcomer_woodcutting_acknowledged = false;
	}
	if (!variable_global_exists("welcomer_intro_complete")) {
		global.welcomer_intro_complete = false;
	}
	if (!variable_global_exists("welcomer_guided_tour_complete")) {
		global.welcomer_guided_tour_complete = false;
	}
	
	Quest_Init();
}

function GameState_InitSkillsAndRng() {
	if (!variable_global_exists("rng_seeded")) {
		randomize();
		global.rng_seeded = true;
	}
	if (!variable_global_exists("woodcutting_level")) {
		global.woodcutting_level = 1;
	}
	if (!variable_global_exists("woodcutting_xp")) {
		global.woodcutting_xp = 0;
	}
	if (!variable_global_exists("mining_level")) {
		global.mining_level = 1;
	}
	if (!variable_global_exists("mining_xp")) {
		global.mining_xp = 0;
	}
	if (!variable_global_exists("smelting_level")) {
		global.smelting_level = 1;
	}
	if (!variable_global_exists("smelting_xp")) {
		global.smelting_xp = 0;
	}
}

#endregion

#region Welcomer Flow

function GameState_IsWelcomerIntroComplete() {
	return variable_global_exists("welcomer_intro_complete") && global.welcomer_intro_complete;
}

function GameState_SetWelcomerIntroComplete(_complete = true) {
	global.welcomer_intro_complete = _complete;
}

function GameState_IsWelcomerGuidedTourComplete() {
	return variable_global_exists("welcomer_guided_tour_complete") && global.welcomer_guided_tour_complete;
}

function GameState_SetWelcomerGuidedTourComplete(_complete = true) {
	global.welcomer_guided_tour_complete = _complete;
}

function GameState_IsStoryPromptEnabled() {
	return variable_global_exists("story_opening_prompt_enabled") && global.story_opening_prompt_enabled;
}

#endregion

#region Welcomer Briefing

function GameState_HasBriefingHeard(_topic) {
	switch (_topic) {
		case GAMESTATE_BRIEF_WHAT_HAPPENED:
			return variable_global_exists("welcomer_brief_what_happened") && global.welcomer_brief_what_happened;
		case GAMESTATE_BRIEF_MARKLESS:
			return variable_global_exists("welcomer_brief_markless") && global.welcomer_brief_markless;
		case GAMESTATE_BRIEF_HEARTHMERE:
			return variable_global_exists("welcomer_brief_hearthmere") && global.welcomer_brief_hearthmere;
		case GAMESTATE_BRIEF_SPONSOR:
			return variable_global_exists("welcomer_brief_sponsor") && global.welcomer_brief_sponsor;
		case GAMESTATE_BRIEF_MARKS:
			return variable_global_exists("welcomer_brief_marks") && global.welcomer_brief_marks;
		case GAMESTATE_BRIEF_TRIAL_INFO:
			return variable_global_exists("welcomer_brief_trial_info") && global.welcomer_brief_trial_info;
	}
	return false;
}

function GameState_SetBriefingHeard(_topic, _heard = true) {
	switch (_topic) {
		case GAMESTATE_BRIEF_WHAT_HAPPENED: global.welcomer_brief_what_happened = _heard; break;
		case GAMESTATE_BRIEF_MARKLESS: global.welcomer_brief_markless = _heard; break;
		case GAMESTATE_BRIEF_HEARTHMERE: global.welcomer_brief_hearthmere = _heard; break;
		case GAMESTATE_BRIEF_SPONSOR: global.welcomer_brief_sponsor = _heard; break;
		case GAMESTATE_BRIEF_MARKS: global.welcomer_brief_marks = _heard; break;
		case GAMESTATE_BRIEF_TRIAL_INFO: global.welcomer_brief_trial_info = _heard; break;
	}
}

function GameState_IsWelcomerBriefingComplete() {
	return GameState_HasBriefingHeard(GAMESTATE_BRIEF_WHAT_HAPPENED)
		&& GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS)
		&& GameState_HasBriefingHeard(GAMESTATE_BRIEF_HEARTHMERE)
		&& GameState_HasBriefingHeard(GAMESTATE_BRIEF_SPONSOR)
		&& GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKS)
		&& GameState_HasBriefingHeard(GAMESTATE_BRIEF_TRIAL_INFO);
}

function GameState_GetBriefingRemainingCount() {
	var remaining = 0;
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_WHAT_HAPPENED)) remaining += 1;
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS)) remaining += 1;
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_HEARTHMERE)) remaining += 1;
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_SPONSOR)) remaining += 1;
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKS)) remaining += 1;
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_TRIAL_INFO)) remaining += 1;
	return remaining;
}

#endregion

#region Second Chance Trial

function GameState_IsSecondChanceTrialStarted() {
	return variable_global_exists("welcomer_approval_started") && global.welcomer_approval_started;
}

function GameState_StartSecondChanceTrial() {
	global.welcomer_approval_started = true;
}

function GameState_IsWoodcuttingMarkApproved() {
	return variable_global_exists("welcomer_woodcutting_approved") && global.welcomer_woodcutting_approved;
}

function GameState_IsWoodcuttingAcknowledged() {
	return variable_global_exists("welcomer_woodcutting_acknowledged") && global.welcomer_woodcutting_acknowledged;
}

function GameState_SetWoodcuttingAcknowledged(_acknowledged = true) {
	global.welcomer_woodcutting_acknowledged = _acknowledged;
}

function GameState_SetWoodcuttingMarkApproved(_approved = true) {
	global.welcomer_woodcutting_approved = _approved;
}

#endregion
