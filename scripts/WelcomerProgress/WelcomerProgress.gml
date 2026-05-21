/// @description Welcomer progression adapter: reads GameState + Quest, exposes flow decisions.
/// No dialogue copy and no beat building — DialogueWelcomer + DialogueWelcomerData use this layer.

#region Session Routing

function WelcomerProgress_ShouldRunTrialSession() {
	return GameState_IsSecondChanceTrialStarted();
}

function WelcomerProgress_ShouldStartGuidedTour() {
	return !GameState_IsWelcomerGuidedTourComplete();
}

function WelcomerProgress_GetPostTourIntroNode() {
	if (GameState_IsWelcomerBriefingComplete()) {
		return DIALOGUE_WELCOMER_NODE_TRIAL_DECISION;
	}
	if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS)) {
		return DIALOGUE_WELCOMER_NODE_MARKLESS;
	}
	return DIALOGUE_WELCOMER_NODE_CATCHUP;
}

function WelcomerProgress_GetReturnNodeAfterBranch() {
	return GameState_IsWelcomerBriefingComplete()
		? DIALOGUE_WELCOMER_NODE_TRIAL_DECISION
		: DIALOGUE_WELCOMER_NODE_CATCHUP;
}

function WelcomerProgress_IsBriefingComplete() {
	return GameState_IsWelcomerBriefingComplete();
}

function WelcomerProgress_CanOfferTrialAcceptance() {
	return WelcomerProgress_IsBriefingComplete() && !GameState_IsSecondChanceTrialStarted();
}

function WelcomerProgress_CatchupHasBriefingGaps() {
	return GameState_GetBriefingRemainingCount() > 0;
}

#endregion

#region Briefing Branches

function WelcomerProgress_IsBranchTopicHeard(_topic_key) {
	return GameState_HasBriefingHeard(_topic_key);
}

function WelcomerProgress_IsBranchAvailable(_branch, _node_id, _welcomer) {
	if (_node_id == DIALOGUE_WELCOMER_NODE_CATCHUP) {
		return !WelcomerProgress_IsBranchTopicHeard(_branch.topic);
	}
	if (_branch.node != _node_id) {
		return false;
	}
	return !DialogueWelcomer_HasAskedBranch(_welcomer, _branch.id);
}

function WelcomerProgress_OnTrialAccepted() {
	GameState_StartSecondChanceTrial();
	GameState_SetWelcomerIntroComplete(true);
}

function WelcomerProgress_OnTimberMarkAcknowledged() {
	GameState_SetWoodcuttingAcknowledged(true);
}

#endregion

#region Trial Phase

function WelcomerProgress_GetTrialPhase() {
	if (Quest_Woodcutting_GetState() == 0) {
		return "not_started";
	}
	if (Quest_Woodcutting_GetState() == 1) {
		return "timber_active";
	}
	if (GameState_IsWoodcuttingMarkApproved() && !GameState_IsWoodcuttingAcknowledged()) {
		return "timber_pending_ack";
	}
	if (GameState_IsWoodcuttingMarkApproved()) {
		return "timber_complete";
	}
	return "idle";
}

/// Menu rows for the post-trial Welcomer session. reply_id maps to DialogueWelcomerData trial replies.
function WelcomerProgress_GetTrialChoiceMenu() {
	var menu = [];
	var phase = WelcomerProgress_GetTrialPhase();
	switch (phase) {
		case "not_started":
			array_push(menu, { text: "Where should I start?", reply_id: "start" });
			break;
		case "timber_active":
			array_push(menu, { text: "I am on timber duty.", reply_id: "timber_duty" });
			break;
		case "timber_pending_ack":
			array_push(menu, { text: "I finished timber duty.", reply_id: "timber_done", acknowledge_timber: true });
			break;
		case "timber_complete":
			array_push(menu, { text: "What is next?", reply_id: "next" });
			array_push(menu, { text: "How is my trial going?", reply_id: "progress" });
			break;
	}
	return menu;
}

#endregion
