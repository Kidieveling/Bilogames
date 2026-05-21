/// @description Welcomer copy only: node prompts, branch catalog, beat tables, trial replies (no flow logic).

#region Intro Node Prompts

function DialogueWelcomerData_GetIntroNodePrompt(_node_id) {

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
			if (WelcomerProgress_CatchupHasBriefingGaps()) {
				return "You still have gaps in what you were told. Ask while I have the patience.";
			}
			return "You have heard the essentials. If you are ready to be judged by finished work instead of a missing past, say so.";
		case DIALOGUE_WELCOMER_NODE_TRIAL_DECISION:
			return "You have heard the essentials. If you are ready to be judged by finished work instead of a missing past, tell me when you accept the Second Chance Trial.";
	}
	return "Speak.";
}

#endregion

#region Branch Catalog

function DialogueWelcomerData_GetBranchCatalog() {
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

#endregion

#region Branch Beat Tables

function DialogueWelcomerData_GetBranchBeats(_branch_id) {
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

#endregion

#region Trial Session Copy

function DialogueWelcomerData_GetTrialSessionBeats(_phase) {
	var w = DIALOGUE_WELCOMER_NAME;
	var beats = [];
	switch (_phase) {
		case "not_started":
			array_push(beats, DialogueBeat_Line(w, "Your Second Chance Trial is underway.", 16));
			array_push(beats, DialogueBeat_Pause(12));
			array_push(beats, DialogueBeat_Line(w, "Earn Marks from the trainers — witnessed proof that you can finish useful work. Start with the Timber Mark.", 20));
			break;
		case "timber_active":
			array_push(beats, DialogueBeat_Line(w, "Still working toward your Timber Mark?", 14));
			array_push(beats, DialogueBeat_Pause(10));
			array_push(beats, DialogueBeat_Line(w, "Good. Hearthmere has no patience for half-finished duty. Neither do I.", 18));
			break;
		case "timber_pending_ack":
			array_push(beats, DialogueBeat_Line(w, "The Woodcutting Trainer endorsed your timber work.", 16));
			array_push(beats, DialogueBeat_Pause(12));
			array_push(beats, DialogueBeat_Line(w, "Your first Mark is on record. That is more identity than you arrived with.", 20));
			break;
		case "timber_complete":
			array_push(beats, DialogueBeat_Line(w, "Timber Mark recorded.", 14));
			array_push(beats, DialogueBeat_Pause(10));
			array_push(beats, DialogueBeat_Line(w, "Next, prove you can pull ore from ground that would rather keep it. Speak with the Mining Trainer.", 22));
			break;
		default:
			array_push(beats, DialogueBeat_Line(w, "Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk.", 18));
			break;
	}
	return beats;
}

function DialogueWelcomerData_GetAcceptTrialBeats() {
	var w = DIALOGUE_WELCOMER_NAME;
	return [
		DialogueBeat_Line(w, "Then it is on record.", 16),
		DialogueBeat_Pause(14),
		DialogueBeat_Line(w, "Your Second Chance Trial begins now.", 16),
		DialogueBeat_Pause(12),
		DialogueBeat_Line(w, "Sleep inside the walls. Work under supervision.", 16),
		DialogueBeat_Pause(12),
		DialogueBeat_Line(w, "Earn Marks from the trainers when you return with proof, not promises.", 20),
		DialogueBeat_Pause(14),
		DialogueBeat_Line(w, "Start with the Woodcutting Trainer and earn your Timber Mark.", 22),
		DialogueBeat_Pause(18)
	];
}

#endregion

#region Trial Reply Beats

function DialogueWelcomerData_GetTrialReplyBeats(_reply_id) {
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
	return beats;
}

#endregion
