is_npc = true
sprite_index = spr_welcome
visible = true

if (!variable_global_exists("welcomer_approval_started")) {
	global.welcomer_approval_started = false
}
if (!variable_global_exists("welcomer_woodcutting_approved")) {
	global.welcomer_woodcutting_approved = false
}
if (!variable_global_exists("welcomer_woodcutting_acknowledged")) {
	global.welcomer_woodcutting_acknowledged = false
}
if (!variable_global_exists("quest_woodcutting_state")) {
	global.quest_woodcutting_state = 0
}

npc_name = "Welcomer"
npc_text = "Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk. For now, you are Markless: not condemned, not cleared."
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

GetWelcomerGreeting = function() {
	if (!global.welcomer_approval_started) {
		return "Welcomer: Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk. For now, you are Markless: not condemned, not cleared."
	}
	
	if (global.quest_woodcutting_state == 0) {
		return "Welcomer: Your Second Chance Trial is open. Start with the Timber Mark so the trainers can see you finish something useful."
	}
	
	if (global.quest_woodcutting_state == 1) {
		return "Welcomer: Still working toward your Timber Mark? Good. Simple work reveals complicated people."
	}
	
	if (global.welcomer_woodcutting_approved && !global.welcomer_woodcutting_acknowledged) {
		return "Welcomer: The Woodcutting Trainer approved your Timber Mark. That is your first real mark here."
	}
	
	if (global.welcomer_woodcutting_approved) {
		return "Welcomer: Timber Mark recorded. Next, prove you can pull useful metal out of stubborn ground."
	}
	
	return npc_name + ": " + npc_text
}

BuildWelcomerChoices = function() {
	var choices = []
	
	if (!global.welcomer_approval_started) {
		array_push(choices, {
			text: "What does Markless mean?",
			action: function() {
				global.welcomer_approval_started = true
				
				with (obj_dialogue) {
					show(
						"Welcomer: It means no record we can trust, no trade mark we can honor, and no standing inside these walls. Not guilty. Not safe. Unproven.",
						[]
					)
				}
			}
		})
		
		array_push(choices, {
			text: "What happens now?",
			action: function() {
				global.welcomer_approval_started = true
				
				with (obj_dialogue) {
					show(
						"Welcomer: You are on a Second Chance Trial. Earn Marks from the trainers, finish useful work, and give Hearthmere reasons to keep trusting the risk.",
						[]
					)
				}
			}
		})
		
		array_push(choices, {
			text: "Who vouched for me?",
			action: function() {
				global.welcomer_approval_started = true
				
				with (obj_dialogue) {
					show(
						"Welcomer: Someone with enough weight to get you through the gate, and enough sense not to ask for more than that. Their name is not yours to spend yet.",
						[]
					)
				}
			}
		})
		
		array_push(choices, {
			text: "Where should I start?",
			action: function() {
				global.welcomer_approval_started = true
				
				with (obj_dialogue) {
					show(
						"Welcomer: Start with the Woodcutting Trainer. Timber teaches the rhythm: take a tool, gather what is needed, return with proof, earn your first Mark.",
						[]
					)
				}
			}
		})
	} else if (global.quest_woodcutting_state == 0) {
		array_push(choices, {
			text: "Where should I start?",
			action: function() {
				with (obj_dialogue) {
					show(
						"Welcomer: Woodcutting first. Speak with the Woodcutting Trainer, take the work seriously, and bring back proof that you can earn the Timber Mark.",
						[]
					)
				}
			}
		})
	} else if (global.quest_woodcutting_state == 1) {
		array_push(choices, {
			text: "I am on timber duty.",
			action: function() {
				with (obj_dialogue) {
					show(
						"Welcomer: Then finish it. Gather the Normal Logs and return them to the Woodcutting Trainer. Around here, half-finished work is just clutter with confidence.",
						[]
					)
				}
			}
		})
	} else if (global.welcomer_woodcutting_approved && !global.welcomer_woodcutting_acknowledged) {
		array_push(choices, {
			text: "I finished timber duty.",
			action: function() {
				global.welcomer_woodcutting_acknowledged = true
				
				with (obj_dialogue) {
					show(
						"Welcomer: I heard. Timber Mark recorded. Next, speak with the Mining Trainer. Wood keeps us standing, but ore keeps our tools from becoming expensive sticks.",
						[]
					)
				}
			}
		})
	} else if (global.welcomer_woodcutting_approved) {
		array_push(choices, {
			text: "What is next?",
			action: function() {
				with (obj_dialogue) {
					show(
						"Welcomer: Mining. Speak with the Mining Trainer and start learning Copper Ore. It is louder than woodcutting, but usually less splintery.",
						[]
					)
				}
			}
		})
		
		array_push(choices, {
			text: "How is my approval going?",
			action: function() {
				with (obj_dialogue) {
					show(
						"Welcomer: Timber Mark is complete. That is one mark. Keep earning them and people here will stop calling you new. Eventually.",
						[]
					)
				}
			}
		})
	}
	
	array_push(choices, {
		text: "Goodbye.",
		action: function() {
			with (obj_dialogue) {
				hide()
			}
		}
	})
	
	return choices
}

npc_choices = BuildWelcomerChoices()

interact = function(_player) {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue)
	}
	
	if (instance_exists(_player)) {
		FaceTowardInstance(_player)
	} else if (instance_exists(obj_player)) {
		FaceTowardInstance(instance_find(obj_player, 0))
	}
	face_player_while_dialogue = true
	dialogue_text = GetWelcomerGreeting()
	npc_choices = BuildWelcomerChoices()
	
	with (obj_dialogue) {
		show(other.dialogue_text, other.npc_choices)
	}
}
