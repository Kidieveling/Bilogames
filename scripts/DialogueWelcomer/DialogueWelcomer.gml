/// @description Welcomer dialogue director: nodes, branches, trial menu. Copy → DialogueWelcomerData; flags → WelcomerProgress.

#region Topic And Node Macros

#macro DIALOGUE_WELCOMER_NAME "Welcomer"
#macro DIALOGUE_WELCOMER_TOPIC_WHAT "what_happened"
#macro DIALOGUE_WELCOMER_TOPIC_MARKLESS "markless"
#macro DIALOGUE_WELCOMER_TOPIC_HEARTHMERE "hearthmere"
#macro DIALOGUE_WELCOMER_TOPIC_SPONSOR "sponsor"
#macro DIALOGUE_WELCOMER_TOPIC_MARKS "marks"
#macro DIALOGUE_WELCOMER_TOPIC_TRIAL "trial_info"

#macro DIALOGUE_WELCOMER_NODE_ARRIVAL "arrival"
#macro DIALOGUE_WELCOMER_NODE_GATE "gate"
#macro DIALOGUE_WELCOMER_NODE_TRAINERS "trainers"
#macro DIALOGUE_WELCOMER_NODE_WORKYARD "workyard"
#macro DIALOGUE_WELCOMER_NODE_MARKLESS "markless"
#macro DIALOGUE_WELCOMER_NODE_TRIAL "trial"
#macro DIALOGUE_WELCOMER_NODE_CATCHUP "catchup"
#macro DIALOGUE_WELCOMER_NODE_TRIAL_DECISION "trial_decision"

#endregion

#region Session Entry

/// Public entry from obj_welcomer OpenDialogueMenu — routes tour, trial session, or briefing nodes.
function DialogueWelcomer_Open(_welcomer) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	if (GuidedIntro_IsTourActive(_welcomer)) {
		return;
	}
	if (!GameState_IsSecondChanceTrialStarted() && !GameState_IsWelcomerGuidedTourComplete()) {
		GuidedIntro_StartWelcomerTour(_welcomer);
		return;
	}
	with (_welcomer) {
		face_player_while_dialogue = true;
	}
	if (WelcomerProgress_ShouldRunTrialSession()) {
		DialogueConversation_Start(_welcomer, DialogueWelcomer_BuildTrialSession(_welcomer));
	} else {
		DialogueWelcomer_StartPostTourBriefing(_welcomer);
	}
}

function DialogueWelcomer_AcceptSecondChanceTrial(_welcomer) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	if (GuidedIntro_IsTourActive(_welcomer)) {
		GuidedIntro_EndTour(_welcomer);
	}
	DialogueConversation_Start(_welcomer, DialogueWelcomer_AcceptTrialBeats(_welcomer));
}

function DialogueWelcomer_StartPostTourBriefing(_welcomer) {
	DialogueWelcomer_PlayIntroNode(_welcomer, WelcomerProgress_GetPostTourIntroNode(), false);
}

#endregion

#region Data Delegates

function DialogueWelcomer_GetIntroNodePrompt(_node_id) {
	return DialogueWelcomerData_GetIntroNodePrompt(_node_id);
}

function DialogueWelcomer_GetBranchCatalog() {
	return DialogueWelcomerData_GetBranchCatalog();
}

function DialogueWelcomer_GetBranchTopicKey(_branch_id) {
	var catalog = DialogueWelcomer_GetBranchCatalog();
	for (var i = 0; i < array_length(catalog); i++) {
		if (catalog[i].id == _branch_id) {
			return catalog[i].topic;
		}
	}
	return "";
}

function DialogueWelcomer_HasAskedBranch(_welcomer, _branch_id) {
	if (!instance_exists(_welcomer) || !variable_instance_exists(_welcomer, "intro_branches_asked")) {
		return false;
	}
	for (var i = 0; i < array_length(_welcomer.intro_branches_asked); i++) {
		if (_welcomer.intro_branches_asked[i] == _branch_id) {
			return true;
		}
	}
	return false;
}

function DialogueWelcomer_MarkBranchAsked(_welcomer, _branch_id) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	if (!variable_instance_exists(_welcomer, "intro_branches_asked")) {
		_welcomer.intro_branches_asked = [];
	}
	if (DialogueWelcomer_HasAskedBranch(_welcomer, _branch_id)) {
		return;
	}
	array_push(_welcomer.intro_branches_asked, _branch_id);
}

#endregion

#region Branch Availability

function DialogueWelcomer_IsBranchAvailable(_branch, _node_id, _welcomer) {
	return WelcomerProgress_IsBranchAvailable(_branch, _node_id, _welcomer);
}

function DialogueWelcomer_NodeHasOpenBranches(_welcomer, _node_id) {
	var catalog = DialogueWelcomer_GetBranchCatalog();
	for (var i = 0; i < array_length(catalog); i++) {
		if (DialogueWelcomer_IsBranchAvailable(catalog[i], _node_id, _welcomer)) {
			return true;
		}
	}
	return false;
}

#endregion

#region Intro Node Choices

function DialogueWelcomer_BuildIntroNodeChoices(_welcomer, _node_id) {
	var choices = [];
	var catalog = DialogueWelcomer_GetBranchCatalog();
	
	for (var i = 0; i < array_length(catalog); i++) {
		if (array_length(choices) >= DIALOGUE_MAX_CHOICES - 1) {
			break;
		}
		var branch = catalog[i];
		if (!DialogueWelcomer_IsBranchAvailable(branch, _node_id, _welcomer)) {
			continue;
		}
		array_push(choices, {
			text: branch.text,
			welcomer: _welcomer,
			branch_id: branch.id,
			return_node: _node_id,
			action: function() {
				DialogueWelcomer_PlayIntroBranch(self.welcomer, self.branch_id, self.return_node);
			}
		});
	}
	
	if (_node_id == DIALOGUE_WELCOMER_NODE_TRIAL_DECISION) {
		if (WelcomerProgress_CanOfferTrialAcceptance()) {
			array_push(choices, {
				text: "I accept the Second Chance Trial.",
				welcomer: _welcomer,
				action: function() {
					if (instance_exists(self.welcomer)) {
						DialogueConversation_Start(self.welcomer, DialogueWelcomer_AcceptTrialBeats(self.welcomer));
					}
				}
			});
			array_push(choices, {
				text: "I need to ask more first.",
				welcomer: _welcomer,
				node_id: DIALOGUE_WELCOMER_NODE_CATCHUP,
				action: function() {
					DialogueWelcomer_PlayIntroNode(self.welcomer, self.node_id, false);
				}
			});
		}
	} else if (!DialogueWelcomer_NodeHasOpenBranches(_welcomer, _node_id)) {
		array_push(choices, {
			text: "Continue.",
			welcomer: _welcomer,
			return_node: _node_id,
			action: function() {
				DialogueWelcomer_OnIntroNodeContinue(self.welcomer, self.return_node);
			}
		});
	}
	
	if (_node_id == DIALOGUE_WELCOMER_NODE_CATCHUP && WelcomerProgress_CanOfferTrialAcceptance()) {
		array_push(choices, {
			text: "I accept the Second Chance Trial.",
			welcomer: _welcomer,
			action: function() {
				if (instance_exists(self.welcomer)) {
					DialogueConversation_Start(self.welcomer, DialogueWelcomer_AcceptTrialBeats(self.welcomer));
				}
			}
		});
	}
	
	if (!GuidedIntro_IsTourActive(_welcomer)
		|| _node_id == DIALOGUE_WELCOMER_NODE_TRIAL_DECISION
		|| _node_id == DIALOGUE_WELCOMER_NODE_CATCHUP) {
		array_push(choices, Dialogue_MakeGoodbyeChoice());
	}
	return choices;
}

#endregion

#region Intro Nodes And Branches

function DialogueWelcomer_PlayIntroNode(_welcomer, _node_id, _during_tour = false) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	
	_welcomer.intro_dialogue_node = _node_id;
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		SetActiveSpeaker(_welcomer);
		player_movement_locked = _during_tour || _node_id == DIALOGUE_WELCOMER_NODE_TRIAL_DECISION;
	}
	
	var beats = [
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, DialogueWelcomerData_GetIntroNodePrompt(_node_id), 18),
		DialogueBeat_Choices("", DialogueWelcomer_BuildIntroNodeChoices(_welcomer, _node_id))
	];
	if (_node_id == DIALOGUE_WELCOMER_NODE_MARKLESS) {
		array_insert(beats, 0, {
			type: DIALOGUE_BEAT_ACTION,
			brief_topic: GAMESTATE_BRIEF_MARKLESS,
			fn: function() {
				GameState_SetBriefingHeard(self.brief_topic);
			}
		});
	}
	DialogueConversation_Start(_welcomer, beats);
	
	if (_during_tour && GuidedIntro_IsTourActive(_welcomer)) {
		_welcomer.guided_phase = "intro_node";
		_welcomer.guided_line_started = true;
	}
}

function DialogueWelcomer_PlayIntroBranch(_welcomer, _branch_id, _return_node) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	
	_welcomer.intro_dialogue_node = _return_node;
	var beats = DialogueWelcomerData_GetBranchBeats(_branch_id);
	var gs_key = DialogueWelcomer_GetBranchTopicKey(_branch_id);
	array_insert(beats, 0, {
		type: DIALOGUE_BEAT_ACTION,
		welcomer: _welcomer,
		branch_id: _branch_id,
		topic_key: gs_key,
		fn: function() {
			DialogueWelcomer_MarkBranchAsked(self.welcomer, self.branch_id);
			if (self.topic_key != "") {
				GameState_SetBriefingHeard(self.topic_key);
			}
		}
	});
	array_push(beats, DialogueBeat_Choices("", DialogueWelcomer_BuildIntroNodeChoices(_welcomer, _return_node)));
	DialogueConversation_Start(_welcomer, beats);
	
	if (GuidedIntro_IsTourActive(_welcomer)) {
		_welcomer.guided_phase = "intro_node";
		_welcomer.guided_line_started = true;
	}
}

function DialogueWelcomer_OnIntroNodeContinue(_welcomer, _node_id) {
	if (instance_exists(obj_dialogue)) {
		with (obj_dialogue) {
			hide();
		}
	}
	
	if (GuidedIntro_IsTourActive(_welcomer)) {
		GuidedIntro_AdvanceStepIndex(_welcomer);
		return;
	}
	
	if (_node_id == DIALOGUE_WELCOMER_NODE_TRIAL || _node_id == DIALOGUE_WELCOMER_NODE_CATCHUP) {
		if (WelcomerProgress_IsBriefingComplete()) {
			DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_TRIAL_DECISION, false);
		} else {
			DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_CATCHUP, false);
		}
		return;
	}
	
	DialogueWelcomer_StartPostTourBriefing(_welcomer);
}

#endregion

#region Trial Session

function DialogueWelcomer_BuildTrialSession(_welcomer) {
	var beats = DialogueWelcomerData_GetTrialSessionBeats(WelcomerProgress_GetTrialPhase());
	array_push(beats, DialogueBeat_Pause(14));
	array_push(beats, DialogueBeat_Choices("", DialogueWelcomer_BuildTrialChoices(_welcomer)));
	return beats;
}

function DialogueWelcomer_BuildTrialChoices(_welcomer) {
	var choices = [];
	var menu = WelcomerProgress_GetTrialChoiceMenu();
	for (var i = 0; i < array_length(menu); i++) {
		var row = menu[i];
		array_push(choices, {
			text: row.text,
			welcomer: _welcomer,
			reply: row.reply_id,
			acknowledge_timber: variable_struct_exists(row, "acknowledge_timber") && row.acknowledge_timber,
			action: function() {
				if (self.acknowledge_timber) {
					WelcomerProgress_OnTimberMarkAcknowledged();
				}
				DialogueWelcomer_PlayTrialReply(self.welcomer, self.reply);
			}
		});
	}
	array_push(choices, Dialogue_MakeGoodbyeChoice());
	return choices;
}

function DialogueWelcomer_PlayTrialReply(_welcomer, _reply_id) {
	var beats = DialogueWelcomerData_GetTrialReplyBeats(_reply_id);
	var tail = [
		DialogueBeat_Pause(14),
		DialogueBeat_Choices("", DialogueWelcomer_BuildTrialChoices(_welcomer))
	];
	DialogueConversation_Start(_welcomer, array_concat(beats, tail));
}

function DialogueWelcomer_AcceptTrialBeats(_welcomer) {
	return array_concat(
		[DialogueBeat_Action(function() { WelcomerProgress_OnTrialAccepted(); })],
		DialogueWelcomerData_GetAcceptTrialBeats(),
		[DialogueBeat_Choices("", [Dialogue_MakeGoodbyeChoice()])]
	);
}

#endregion
