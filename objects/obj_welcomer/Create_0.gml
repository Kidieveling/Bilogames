event_inherited();
sprite_index = spr_welcome
visible = true

npc_name = "Welcomer"
npc_text = "Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk. Ask what you need to know before we speak of duty."
dialogue_text = npc_name + ": " + npc_text
image_speed = 0
image_index = 0
facing_dir = 0
face_player_while_dialogue = false

FaceTowardInstance = function(_target) {
	if (!instance_exists(_target)) {
		return
	}
	
	var dir = point_direction(x, y, _target.x, _target.y)
	var sector = floor(((dir + 22.5) mod 360) / 45)
	
	switch (sector) {
		case 0: facing_dir = 2; break // east
		case 1: facing_dir = 3; break // northeast
		case 2: facing_dir = 4; break // north
		case 3: facing_dir = 5; break // northwest
		case 4: facing_dir = 6; break // west
		case 5: facing_dir = 7; break // southwest
		case 6: facing_dir = 0; break // south
		case 7: facing_dir = 1; break // southeast
	}
	
	image_index = facing_dir
}

OpenDialogueMenu = function() {
	face_player_while_dialogue = true
	dialogue_text = GetWelcomerGreeting()
	npc_choices = BuildWelcomerChoices()
	Dialogue_PresentMenu(id, dialogue_text, npc_choices)
}

AcceptSecondChanceTrial = function() {
	GameState_StartSecondChanceTrial()
	Dialogue_ShowResponse(
		id,
		"Welcomer: Then it is on record. Your Second Chance Trial begins now. Sleep inside the walls. Work under supervision. Earn Marks from the trainers when you return with proof, not promises. Start with the Woodcutting Trainer and earn your Timber Mark."
	)
}

GetWelcomerGreeting = function() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		var remaining = GameState_GetBriefingRemainingCount()
		if (remaining == 6) {
			return "Welcomer: Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk. Before I assign you work, you should understand how you got here and what that costs this settlement."
		}
		if (remaining > 0) {
			return "Welcomer: You still have " + string(remaining) + " matter" + (remaining == 1 ? "" : "s") + " to hear. Ask. When you understand where you stand, you may choose the trial."
		}
		return "Welcomer: You have heard the essentials. If you are ready to be judged by finished work instead of a missing past, tell me you accept the Second Chance Trial."
	}
	
	if (Quest_Woodcutting_GetState() == 0) {
		return "Welcomer: Your Second Chance Trial is underway. Earn Marks from the trainers — witnessed proof that you can finish useful work. Start with the Timber Mark."
	}
	
	if (Quest_Woodcutting_GetState() == 1) {
		return "Welcomer: Still working toward your Timber Mark? Good. Hearthmere has no patience for half-finished duty. Neither do I."
	}
	
	if (GameState_IsWoodcuttingMarkApproved() && !GameState_IsWoodcuttingAcknowledged()) {
		return "Welcomer: The Woodcutting Trainer endorsed your timber work. Your first Mark is on record. That is more identity than you arrived with."
	}
	
	if (GameState_IsWoodcuttingMarkApproved()) {
		return "Welcomer: Timber Mark recorded. Next, prove you can pull ore from ground that would rather keep it. Speak with the Mining Trainer."
	}
	
	return npc_name + ": " + npc_text
}

BuildWelcomerChoices = function() {
	var choices = []
	var welcomer = id
	
	if (!GameState_IsSecondChanceTrialStarted()) {
		if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_WHAT_HAPPENED)) {
			array_push(choices, {
				text: "What happened to me?",
				welcomer: welcomer,
				action: function() {
					GameState_SetBriefingHeard(GAMESTATE_BRIEF_WHAT_HAPPENED)
					if (instance_exists(welcomer)) {
						Dialogue_ShowResponse(
							welcomer,
							"Welcomer: You were found outside the safe roads near the remains of a failed expedition route. Most of that party vanished from official history. You had no valid papers, no trade mark, and no witnesses Hearthmere will honor. You remember fragments — smoke, a broken gate, tools in mud, names called from the dark. We cannot tell if you were abandoned or saved. That is why you are here under watch, not welcome."
						)
					}
				}
			})
		}
		
		if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS)) {
			array_push(choices, {
				text: "What does Markless mean?",
				welcomer: welcomer,
				action: function() {
					GameState_SetBriefingHeard(GAMESTATE_BRIEF_MARKLESS)
					if (instance_exists(welcomer)) {
						Dialogue_ShowResponse(
							welcomer,
							"Welcomer: No civic record we can trust. No trade mark. No guild standing. No name the settlement can rely on yet. Not condemned. Not cleared. Unproven. The Markless are people Hearthmere has not decided to rely on."
						)
					}
				}
			})
		}
		
		if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_HEARTHMERE)) {
			array_push(choices, {
				text: "What is Hearthmere?",
				welcomer: welcomer,
				action: function() {
					GameState_SetBriefingHeard(GAMESTATE_BRIEF_HEARTHMERE)
					if (instance_exists(welcomer)) {
						Dialogue_ShowResponse(
							welcomer,
							"Welcomer: A guarded frontier settlement on the edge of lands touched by the Hollowing. Not a peaceful tutorial village — a practical place where walls need timber, tools break, guards need gear, and nobody has spare trust. Hearthmere keeps people who might be useful. It measures everyone else carefully."
						)
					}
				}
			})
		}
		
		if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_SPONSOR)) {
			array_push(choices, {
				text: "Who vouched for me?",
				welcomer: welcomer,
				action: function() {
					GameState_SetBriefingHeard(GAMESTATE_BRIEF_SPONSOR)
					if (instance_exists(welcomer)) {
						Dialogue_ShowResponse(
							welcomer,
							"Welcomer: Someone with enough weight to force your admission through the gate. In the records they are only the Sponsor. No name for you to spend yet. Naming them would start arguments I am not paid enough to referee. Who they are, and why they cared, is not yours to know until you earn Marks."
						)
					}
				}
			})
		}
		
		if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKS)) {
			array_push(choices, {
				text: "What is a Mark?",
				welcomer: welcomer,
				action: function() {
					GameState_SetBriefingHeard(GAMESTATE_BRIEF_MARKS)
					if (instance_exists(welcomer)) {
						Dialogue_ShowResponse(
							welcomer,
							"Welcomer: Witnessed proof — that you did real work, that someone saw it, that Hearthmere can point to it later. Timber, ore, forge, craft. Trainers endorse Marks when you return with results. Marks are how strangers become people the settlement can count on."
						)
					}
				}
			})
		}
		
		if (!GameState_HasBriefingHeard(GAMESTATE_BRIEF_TRIAL_INFO)) {
			array_push(choices, {
				text: "What is the Second Chance Trial?",
				welcomer: welcomer,
				action: function() {
					GameState_SetBriefingHeard(GAMESTATE_BRIEF_TRIAL_INFO)
					if (instance_exists(welcomer)) {
						Dialogue_ShowResponse(
							welcomer,
							"Welcomer: A supervised path back into trust. You may sleep inside the walls and speak with trainers, but you earn your place through useful work. No free access to dangerous routes, rare recipes, or sensitive records until you prove yourself. Accepting the trial is your choice. Asking questions is not."
						)
					}
				}
			})
		}
		
		if (GameState_IsWelcomerBriefingComplete()) {
			array_push(choices, {
				text: "I accept the Second Chance Trial.",
				welcomer: welcomer,
				action: function() {
					if (instance_exists(welcomer)) {
						with (welcomer) {
							AcceptSecondChanceTrial()
						}
					}
				}
			})
		}
	} else if (Quest_Woodcutting_GetState() == 0) {
		array_push(choices, {
			text: "Where should I start?",
			welcomer: welcomer,
			action: function() {
				if (instance_exists(welcomer)) {
					Dialogue_ShowResponse(
						welcomer,
						"Welcomer: Woodcutting Trainer. Earn the Timber Mark — five Normal Logs returned with your own hands. When trainers can vouch for you without a clerk following, Hearthmere listens."
					)
				}
			}
		})
	} else if (Quest_Woodcutting_GetState() == 1) {
		array_push(choices, {
			text: "I am on timber duty.",
			welcomer: welcomer,
			action: function() {
				if (instance_exists(welcomer)) {
					Dialogue_ShowResponse(
						welcomer,
						"Welcomer: Then finish it. Gather the Normal Logs and return them to the Woodcutting Trainer. Around here, half-finished work is clutter with confidence."
					)
				}
			}
		})
	} else if (GameState_IsWoodcuttingMarkApproved() && !GameState_IsWoodcuttingAcknowledged()) {
		array_push(choices, {
			text: "I finished timber duty.",
			welcomer: welcomer,
			action: function() {
				GameState_SetWoodcuttingAcknowledged(true)
				if (instance_exists(welcomer)) {
					Dialogue_ShowResponse(
						welcomer,
						"Welcomer: Timber Mark recorded. Wood keeps us standing. Ore keeps our tools from becoming expensive sticks. Speak with the Mining Trainer next."
					)
				}
			}
		})
	} else if (GameState_IsWoodcuttingMarkApproved()) {
		array_push(choices, {
			text: "What is next?",
			welcomer: welcomer,
			action: function() {
				if (instance_exists(welcomer)) {
					Dialogue_ShowResponse(
						welcomer,
						"Welcomer: Mining, then smelt, then craft. The Mining and Crafting trainers will direct you."
					)
				}
			}
		})
		
		array_push(choices, {
			text: "How is my trial going?",
			welcomer: welcomer,
			action: function() {
				if (instance_exists(welcomer)) {
					Dialogue_ShowResponse(
						welcomer,
						"Welcomer: One Mark earned. Were you worth saving? You answer that with finished work. Keep earning Marks."
					)
				}
			}
		})
	}
	
	array_push(choices, Dialogue_MakeGoodbyeChoice())
	
	return choices
}

npc_choices = BuildWelcomerChoices()

interact = function(_player) {
	Dialogue_InteractNpc(id, _player)
}
