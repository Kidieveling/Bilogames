event_inherited();

npc_name = "Mining Trainer"
npc_text = "Ore work is approval work. If the Welcomer has your name on the trial list, we can talk about the Ore Mark."
dialogue_text = npc_name + ": " + npc_text

OpenDialogueMenu = function() {
	dialogue_text = GetMiningGreeting()
	npc_choices = BuildMiningChoices()
	Dialogue_PresentMenu(id, dialogue_text, npc_choices)
}

GetMiningGreeting = function() {
	return npc_name + ": " + npc_text
}

TeachMining = function() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		Dialogue_ShowResponse(
			id,
			"Mining Trainer: Start with the Welcomer. They decide who gets a Second Chance Trial. I teach mining, not paperwork — and I am grateful for that every morning."
		)
		return
	}
	
	if (!HasItem(obj_controller.myItems, "Bronze Pickaxe")) {
		Inventory_GrantItem(undefined, "Bronze Pickaxe")
		
		Dialogue_ShowResponse(
			id,
			"Mining Trainer: Good. Timber proved you can finish simple labor. Ore proves you can handle risk. Take this pickaxe. Copper first — tools, hinges, nails, what the forge eats. Swing clean, watch your footing, and do not argue with rocks. They always win eventually."
		)
	} else {
		Dialogue_ShowResponse(
			id,
			"Mining Trainer: You already have a pickaxe. Get copper ore back here with your own hands. Useful ore is how Hearthmere stops doubting you."
		)
	}
}

ExplainMiningOrder = function() {
	Dialogue_ShowResponse(
		id,
		"Mining Trainer: Because wood keeps the walls standing and ore keeps what is inside them from falling apart. Timber Mark first. Ore Mark next. That is the order the Welcomer likes, and the order that keeps recruits alive."
	)
}

BuildMiningChoices = function() {
	var choices = []
	var trainer = id
	
	array_push(choices, {
		text: "Can you teach me?",
		trainer: trainer,
		action: function() {
			if (instance_exists(trainer)) {
				with (trainer) {
					TeachMining()
				}
			}
		}
	})
	
	array_push(choices, {
		text: "Why mining after wood?",
		trainer: trainer,
		action: function() {
			if (instance_exists(trainer)) {
				with (trainer) {
					ExplainMiningOrder()
				}
			}
		}
	})
	
	array_push(choices, Dialogue_MakeGoodbyeChoice())
	
	return choices
}

npc_choices = BuildMiningChoices()

interact = function(_player) {
	Dialogue_InteractNpc(id, _player)
}
