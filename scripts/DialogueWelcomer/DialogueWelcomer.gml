/// @description Welcomer paced conversation definitions (intro nodes + topic tracking)

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

function DialogueWelcomer_GetIntroNodePrompt(_node_id) {
	switch (_node_id) {
		case DIALOGUE_WELCOMER_NODE_ARRIVAL:
			return "Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk.";
		case DIALOGUE_WELCOMER_NODE_GATE:
			return "Ask what you must about these walls before we move on.";
		case DIALOGUE_WELCOMER_NODE_TRAINERS:
			return "The trainers watch work, not excuses. Ask if you need the picture.";
		case DIALOGUE_WELCOMER_NODE_WORKYARD:
			return "This yard eats timber, ore, and patience. Ask what you do not understand.";
		case DIALOGUE_WELCOMER_NODE_MARKLESS:
			return "You are Markless. Not condemned. Not cleared. Unproven.";
		case DIALOGUE_WELCOMER_NODE_TRIAL:
			return "Marks are how strangers become people Hearthmere can count on. The Second Chance Trial is how you earn that here.";
		case DIALOGUE_WELCOMER_NODE_CATCHUP:
			if (GameState_GetBriefingRemainingCount() > 0) {
				return "You still have gaps in what you were told. Ask while I have the patience.";
			}
			return "You have heard the essentials. If you are ready to be judged by finished work instead of a missing past, say so.";
		case DIALOGUE_WELCOMER_NODE_TRIAL_DECISION:
			return "You have heard the essentials. If you are ready to be judged by finished work instead of a missing past, tell me when you accept the Second Chance Trial.";
	}
	return "Speak.";
}

function DialogueWelcomer_GetBranchCatalog() {
	return [
		{ id: "worth_risk", node: DIALOGUE_WELCOMER_NODE_ARRIVAL, text: "Worth the risk?", topic: GAMESTATE_BRIEF_HEARTHMERE },
		{ id: "where_am_i", node: DIALOGUE_WELCOMER_NODE_ARRIVAL, text: "Where am I?", topic: GAMESTATE_BRIEF_HEARTHMERE },
		{ id: "who_decided", node: DIALOGUE_WELCOMER_NODE_ARRIVAL, text: "Who decided that?", topic: GAMESTATE_BRIEF_SPONSOR },
		{ id: "why_walls", node: DIALOGUE_WELCOMER_NODE_GATE, text: "Why such heavy walls?", topic: GAMESTATE_BRIEF_HEARTHMERE },
		{ id: "what_is_hearthmere", node: DIALOGUE_WELCOMER_NODE_GATE, text: "What is Hearthmere?", topic: GAMESTATE_BRIEF_HEARTHMERE },
		{ id: "who_runs_place", node: DIALOGUE_WELCOMER_NODE_GATE, text: "Who runs this place?", topic: GAMESTATE_BRIEF_HEARTHMERE },
		{ id: "what_are_trainers", node: DIALOGUE_WELCOMER_NODE_TRAINERS, text: "What do trainers do?", topic: GAMESTATE_BRIEF_MARKS },
		{ id: "what_is_mark_preview", node: DIALOGUE_WELCOMER_NODE_TRAINERS, text: "What is a Mark?", topic: GAMESTATE_BRIEF_MARKS },
		{ id: "what_is_mark", node: DIALOGUE_WELCOMER_NODE_WORKYARD, text: "What is a Mark?", topic: GAMESTATE_BRIEF_MARKS },
		{ id: "what_work_wanted", node: DIALOGUE_WELCOMER_NODE_WORKYARD, text: "What work do you want from me?", topic: GAMESTATE_BRIEF_TRIAL_INFO },
		{ id: "what_happened", node: DIALOGUE_WELCOMER_NODE_MARKLESS, text: "What happened to me?", topic: GAMESTATE_BRIEF_WHAT_HAPPENED },
		{ id: "what_markless", node: DIALOGUE_WELCOMER_NODE_MARKLESS, text: "What does Markless mean?", topic: GAMESTATE_BRIEF_MARKLESS },
		{ id: "am_prisoner", node: DIALOGUE_WELCOMER_NODE_MARKLESS, text: "Am I a prisoner?", topic: GAMESTATE_BRIEF_MARKLESS },
		{ id: "how_prove", node: DIALOGUE_WELCOMER_NODE_MARKLESS, text: "How do I prove myself?", topic: GAMESTATE_BRIEF_TRIAL_INFO },
		{ id: "what_is_trial", node: DIALOGUE_WELCOMER_NODE_TRIAL, text: "What is the Second Chance Trial?", topic: GAMESTATE_BRIEF_TRIAL_INFO },
		{ id: "what_if_refuse", node: DIALOGUE_WELCOMER_NODE_TRIAL, text: "What happens if I refuse?", topic: GAMESTATE_BRIEF_TRIAL_INFO },
		{ id: "who_vouched", node: DIALOGUE_WELCOMER_NODE_CATCHUP, text: "Who vouched for me?", topic: GAMESTATE_BRIEF_SPONSOR },
		{ id: "am_in_trouble", node: DIALOGUE_WELCOMER_NODE_CATCHUP, text: "Am I in trouble?", topic: GAMESTATE_BRIEF_MARKLESS }
	];
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

function DialogueWelcomer_IsBranchAvailable(_branch, _node_id, _welcomer) {
	if (_node_id == DIALOGUE_WELCOMER_NODE_CATCHUP) {
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
		DialogueBeat_Line(DIALOGUE_WELCOMER_NAME, DialogueWelcomer_GetIntroNodePrompt(_node_id), 18),
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

function DialogueWelcomer_BuildIntroBranchBeats(_branch_id) {
	var w = DIALOGUE_WELCOMER_NAME;
	switch (_branch_id) {
		case "worth_risk":
			return [
				DialogueBeat_Line(w, "Hearthmere does not open its gates because someone looks harmless. It opens them when someone useful has put their name behind the risk.", 20),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "That is what you are standing inside.", 14)
			];
		case "where_am_i":
			return [
				DialogueBeat_Line(w, "Hearthmere. Last guarded settlement before the roads stop behaving like roads.", 18),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "Practical walls, practical people, practical consequences.", 16)
			];
		case "who_decided":
			return [
				DialogueBeat_Line(w, "The record names them only as your Sponsor. That is all you are cleared to know.", 18),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "They had enough weight to force your admission through the gate.", 16)
			];
		case "why_walls":
			return [
				DialogueBeat_Line(w, "Because the Hollowing does not send polite warnings before it reaches a wall.", 18),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "These stones are arithmetic, not comfort.", 14)
			];
		case "what_is_hearthmere":
			return [
				DialogueBeat_Line(w, "A guarded frontier settlement on the edge of lands touched by the Hollowing.", 18),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "Not a peaceful tutorial village — a place where walls need timber, tools break, and nobody has spare trust.", 22)
			];
		case "who_runs_place":
			return [
				DialogueBeat_Line(w, "Guards, clerks, trainers, and anyone with enough Marks to be listened to.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Hearthmere keeps people who might be useful. It measures everyone else carefully.", 18)
			];
		case "what_are_trainers":
			return [
				DialogueBeat_Line(w, "They teach a skill, watch you work, and endorse Marks when you return with proof.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Around here, a trainer's word is worth more than your promises.", 16)
			];
		case "what_is_mark_preview":
		case "what_is_mark":
			return [
				DialogueBeat_Line(w, "Witnessed proof — that you did real work, that someone saw it, that Hearthmere can point to it later.", 20),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "Timber, ore, forge, craft. Marks are how strangers become people the settlement can count on.", 20)
			];
		case "what_work_wanted":
			return [
				DialogueBeat_Line(w, "Useful work under supervision — the kind that keeps a frontier settlement standing.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "You will earn that through the Second Chance Trial, not by wandering where you please.", 18)
			];
		case "what_happened":
			return [
				DialogueBeat_Line(w, "You were found outside the safe roads near the remains of a failed expedition route.", 18),
				DialogueBeat_Pause(14),
				DialogueBeat_Line(w, "No valid papers, no trade mark, no witnesses Hearthmere will honor — only fragments you cannot fully trust.", 20),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "We cannot tell if you were abandoned or saved. That is why you are here under watch.", 18)
			];
		case "what_markless":
			return [
				DialogueBeat_Line(w, "No civic record we can trust. No trade mark. No guild standing.", 16),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Not condemned. Not cleared. Unproven — people Hearthmere has not decided to rely on yet.", 20)
			];
		case "am_prisoner":
		case "am_in_trouble":
			return [
				DialogueBeat_Line(w, "You are not in a cell. You are in a ledger with a question mark beside your name.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Sleep inside the walls, work under supervision, and do not test the guards' patience.", 18)
			];
		case "how_prove":
			return [
				DialogueBeat_Line(w, "Through the Second Chance Trial — finished work, witnessed by trainers, recorded as Marks.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Start with timber. Let Hearthmere see you return with results, not excuses.", 18)
			];
		case "what_is_trial":
			return [
				DialogueBeat_Line(w, "A supervised path back into trust.", 14),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "You earn Marks from trainers when you return with proof. No free access to dangerous routes until then.", 20)
			];
		case "what_if_refuse":
			return [
				DialogueBeat_Line(w, "Then you remain Markless, with fewer doors open and fewer people willing to speak plainly.", 20),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Hearthmere will not throw you out tonight. It will not invest in you either.", 18)
			];
		case "who_vouched":
			return [
				DialogueBeat_Line(w, "Your Sponsor — named only that in the records you are allowed to see.", 16),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Why they cared is not yours to know until you earn Marks.", 16)
			];
	}
	return [DialogueBeat_Line(w, "That is the shape of it. Ask again if something still will not settle.", 14)];
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
	var w = DIALOGUE_WELCOMER_NAME;
	var beats = [];
	
	switch (_reply_id) {
		case "start":
			beats = [
				DialogueBeat_Line(w, "Woodcutting Trainer.", 12),
				DialogueBeat_Pause(10),
				DialogueBeat_Line(w, "Earn the Timber Mark — five Normal Logs returned with your own hands.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "When trainers can vouch for you without a clerk following, Hearthmere listens.", 18)
			];
			break;
		case "timber_duty":
			beats = [
				DialogueBeat_Line(w, "Then finish it.", 12),
				DialogueBeat_Pause(10),
				DialogueBeat_Line(w, "Gather the Normal Logs and return them to the Woodcutting Trainer.", 16),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Around here, half-finished work is clutter with confidence.", 18)
			];
			break;
		case "timber_done":
			beats = [
				DialogueBeat_Line(w, "Timber Mark recorded.", 14),
				DialogueBeat_Pause(10),
				DialogueBeat_Line(w, "Wood keeps us standing. Ore keeps our tools from becoming expensive sticks.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Speak with the Mining Trainer next.", 16)
			];
			break;
		case "next":
			beats = [
				DialogueBeat_Line(w, "Mining, then smelt, then craft.", 14),
				DialogueBeat_Pause(10),
				DialogueBeat_Line(w, "The Mining and Crafting trainers will direct you.", 16)
			];
			break;
		case "progress":
			beats = [
				DialogueBeat_Line(w, "One Mark earned.", 12),
				DialogueBeat_Pause(10),
				DialogueBeat_Line(w, "Were you worth saving? You answer that with finished work.", 18),
				DialogueBeat_Pause(12),
				DialogueBeat_Line(w, "Keep earning Marks.", 14)
			];
			break;
	}
	
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
