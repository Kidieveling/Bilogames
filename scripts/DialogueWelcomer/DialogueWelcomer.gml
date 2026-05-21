/// @description Welcomer flow orchestration: tour vs briefing vs trial session; delegates copy to DialogueWelcomerData.

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

function DialogueWelcomer_BeginSession(_welcomer) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	if (GuidedIntro_IsTourActive(_welcomer)) {
		return;
	}
	
	if (GameState_IsSecondChanceTrialStarted()) {
		DialogueConversation_Start(_welcomer, DialogueWelcomer_BuildTrialSession(_welcomer));
	} else if (!GameState_IsWelcomerGuidedTourComplete()) {
		GuidedIntro_StartWelcomerTour(_welcomer);
	} else {
		DialogueWelcomer_StartPostTourBriefing(_welcomer);
	}
}

function DialogueWelcomer_StartPostTourBriefing(_welcomer) {
	if (GameState_IsWelcomerBriefingComplete()) {
		DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_TRIAL_DECISION, false);
	} else if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS)) {
		DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_MARKLESS, false);
	} else {
		DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_CATCHUP, false);
	}
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
	if (_node_id == DIALOGUE_WELCOMER_NODE_CATCHUP) {
		// Catch-up node surfaces any briefing topic not yet heard, not only branches tied to this node id.
		return !GameState_HasBriefingHeard(_branch.topic);
	}
	if (_branch.node != _node_id) {
		return false;
	}
	return !DialogueWelcomer_HasAskedBranch(_welcomer, _branch.id);
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
		// self.* on the choice struct — GML closures need explicit fields, not other/id from the builder scope.
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
		if (GameState_IsWelcomerBriefingComplete() && !GameState_IsSecondChanceTrialStarted()) {
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
	
	if (_node_id == DIALOGUE_WELCOMER_NODE_CATCHUP && GameState_IsWelcomerBriefingComplete()) {
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
	var beats = DialogueWelcomer_BuildIntroBranchBeats(_branch_id);
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
		if (GameState_IsWelcomerBriefingComplete()) {
			DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_TRIAL_DECISION, false);
		} else {
			DialogueWelcomer_PlayIntroNode(_welcomer, DIALOGUE_WELCOMER_NODE_CATCHUP, false);
		}
		return;
	}
	
	DialogueWelcomer_StartPostTourBriefing(_welcomer);
}

#endregion

#region Legacy Topic Menu

function DialogueWelcomer_BuildIntroBranchBeats(_branch_id) {
	return DialogueWelcomerData_GetBranchBeats(_branch_id);
}

function DialogueWelcomer_PlayTopic(_welcomer, _topic_id) {
	var branch_id = "";
	switch (_topic_id) {
		case DIALOGUE_WELCOMER_TOPIC_WHAT: branch_id = "what_happened"; break;
		case DIALOGUE_WELCOMER_TOPIC_MARKLESS: branch_id = "what_markless"; break;
		case DIALOGUE_WELCOMER_TOPIC_HEARTHMERE: branch_id = "what_is_hearthmere"; break;
		case DIALOGUE_WELCOMER_TOPIC_SPONSOR: branch_id = "who_decided"; break;
		case DIALOGUE_WELCOMER_TOPIC_MARKS: branch_id = "what_is_mark"; break;
		case DIALOGUE_WELCOMER_TOPIC_TRIAL: branch_id = "what_is_trial"; break;
	}
	if (branch_id == "") {
		return;
	}
	var return_node = GameState_IsWelcomerBriefingComplete()
		? DIALOGUE_WELCOMER_NODE_TRIAL_DECISION
		: DIALOGUE_WELCOMER_NODE_CATCHUP;
	DialogueWelcomer_PlayIntroBranch(_welcomer, branch_id, return_node);
}

function DialogueWelcomer_IsTopicHeard(_topic_id) {
	switch (_topic_id) {
		case DIALOGUE_WELCOMER_TOPIC_WHAT: return GameState_HasBriefingHeard(GAMESTATE_BRIEF_WHAT_HAPPENED);
		case DIALOGUE_WELCOMER_TOPIC_MARKLESS: return GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS);
		case DIALOGUE_WELCOMER_TOPIC_HEARTHMERE: return GameState_HasBriefingHeard(GAMESTATE_BRIEF_HEARTHMERE);
		case DIALOGUE_WELCOMER_TOPIC_SPONSOR: return GameState_HasBriefingHeard(GAMESTATE_BRIEF_SPONSOR);
		case DIALOGUE_WELCOMER_TOPIC_MARKS: return GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKS);
		case DIALOGUE_WELCOMER_TOPIC_TRIAL: return GameState_HasBriefingHeard(GAMESTATE_BRIEF_TRIAL_INFO);
	}
	return true;
}

function DialogueWelcomer_GetTopicChoiceLabel(_topic_id) {
	switch (_topic_id) {
		case DIALOGUE_WELCOMER_TOPIC_WHAT: return "What happened to me?";
		case DIALOGUE_WELCOMER_TOPIC_MARKLESS: return "What does Markless mean?";
		case DIALOGUE_WELCOMER_TOPIC_HEARTHMERE: return "What is Hearthmere?";
		case DIALOGUE_WELCOMER_TOPIC_SPONSOR: return "Who vouched for me?";
		case DIALOGUE_WELCOMER_TOPIC_MARKS: return "What is a Mark?";
		case DIALOGUE_WELCOMER_TOPIC_TRIAL: return "What is the Second Chance Trial?";
	}
	return "Ask something.";
}

#endregion

#region Trial Session

function DialogueWelcomer_BuildTrialSession(_welcomer) {
	var w = DIALOGUE_WELCOMER_NAME;
	var beats = [];
	
	if (Quest_Woodcutting_GetState() == 0) {
		array_push(beats, DialogueBeat_Line(w, "Your Second Chance Trial is underway.", 16));
		array_push(beats, DialogueBeat_Pause(12));
		array_push(beats, DialogueBeat_Line(w, "Earn Marks from the trainers — witnessed proof that you can finish useful work. Start with the Timber Mark.", 20));
	} else if (Quest_Woodcutting_GetState() == 1) {
		array_push(beats, DialogueBeat_Line(w, "Still working toward your Timber Mark?", 14));
		array_push(beats, DialogueBeat_Pause(10));
		array_push(beats, DialogueBeat_Line(w, "Good. Hearthmere has no patience for half-finished duty. Neither do I.", 18));
	} else if (GameState_IsWoodcuttingMarkApproved() && !GameState_IsWoodcuttingAcknowledged()) {
		array_push(beats, DialogueBeat_Line(w, "The Woodcutting Trainer endorsed your timber work.", 16));
		array_push(beats, DialogueBeat_Pause(12));
		array_push(beats, DialogueBeat_Line(w, "Your first Mark is on record. That is more identity than you arrived with.", 20));
	} else if (GameState_IsWoodcuttingMarkApproved()) {
		array_push(beats, DialogueBeat_Line(w, "Timber Mark recorded.", 14));
		array_push(beats, DialogueBeat_Pause(10));
		array_push(beats, DialogueBeat_Line(w, "Next, prove you can pull ore from ground that would rather keep it. Speak with the Mining Trainer.", 22));
	} else {
		array_push(beats, DialogueBeat_Line(w, "Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk.", 18));
	}
	
	array_push(beats, DialogueBeat_Pause(14));
	array_push(beats, DialogueBeat_Choices("", DialogueWelcomer_BuildTrialChoices(_welcomer)));
	return beats;
}

function DialogueWelcomer_BuildTrialChoices(_welcomer) {
	var choices = [];
	
	if (Quest_Woodcutting_GetState() == 0) {
		array_push(choices, {
			text: "Where should I start?",
			welcomer: _welcomer,
			reply: "start",
			action: function() {
				DialogueWelcomer_PlayTrialReply(self.welcomer, self.reply);
			}
		});
	} else if (Quest_Woodcutting_GetState() == 1) {
		array_push(choices, {
			text: "I am on timber duty.",
			welcomer: _welcomer,
			reply: "timber_duty",
			action: function() {
				DialogueWelcomer_PlayTrialReply(self.welcomer, self.reply);
			}
		});
	} else if (GameState_IsWoodcuttingMarkApproved() && !GameState_IsWoodcuttingAcknowledged()) {
		array_push(choices, {
			text: "I finished timber duty.",
			welcomer: _welcomer,
			reply: "timber_done",
			action: function() {
				GameState_SetWoodcuttingAcknowledged(true);
				DialogueWelcomer_PlayTrialReply(self.welcomer, self.reply);
			}
		});
	} else if (GameState_IsWoodcuttingMarkApproved()) {
		array_push(choices, {
			text: "What is next?",
			welcomer: _welcomer,
			reply: "next",
			action: function() {
				DialogueWelcomer_PlayTrialReply(self.welcomer, self.reply);
			}
		});
		array_push(choices, {
			text: "How is my trial going?",
			welcomer: _welcomer,
			reply: "progress",
			action: function() {
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
	return [
		DialogueBeat_Action(function() {
			GameState_StartSecondChanceTrial();
			GameState_SetWelcomerIntroComplete(true);
		}),
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, "Then it is on record.", 16),
		DialogueBeat_Pause(14),
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, "Your Second Chance Trial begins now.", 16),
		DialogueBeat_Pause(12),
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, "Sleep inside the walls. Work under supervision.", 16),
		DialogueBeat_Pause(12),
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, "Earn Marks from the trainers when you return with proof, not promises.", 20),
		DialogueBeat_Pause(14),
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, "Start with the Woodcutting Trainer and earn your Timber Mark.", 22),
		DialogueBeat_Pause(18),
		DialogueBeat_Choices("", [Dialogue_MakeGoodbyeChoice()])
	];
}

#endregion
