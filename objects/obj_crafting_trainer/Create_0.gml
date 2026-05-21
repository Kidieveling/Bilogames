/// @description Crafting/smelting trial trainer (inherits obj_npc).

event_inherited();

npc_name = "Crafting Trainer"
npc_text = "Gathering is not enough here. Raw logs and ore have to become something the settlement can stock. The Welcomer sends people to me when they are ready for that step."
dialogue_text = npc_name + ": " + npc_text

#region Menu

OpenDialogueMenu = function() {
	dialogue_text = GetCraftingGreeting()
	npc_choices = BuildCraftingChoices()
	Dialogue_PresentMenu(id, dialogue_text, npc_choices)
}

GetCraftingGreeting = function() {
	return npc_name + ": " + npc_text
}

#endregion

#region Training

// Gates on trial flag plus inventory proof — mirrors gather → smelt → craft loop in the yard.
TeachCrafting = function() {
	if (!GameState_IsSecondChanceTrialStarted()) {
		Dialogue_ShowResponse(
			id,
			"Crafting Trainer: Start with the Welcomer. They run the Second Chance Trial. I organize materials and recipes — not intake, and thank the walls for that."
		)
		return
	}
	
	if (!HasItem(obj_controller.myItems, "Normal Log")) {
		Dialogue_ShowResponse(
			id,
			"Crafting Trainer: Bring Normal Logs first. Timber Mark work — the Woodcutting Trainer should have set you on that. Hearthmere needs raw stock before it needs finished goods."
		)
		return
	}
	
	if (!HasItem(obj_controller.myItems, "Copper Ore")) {
		Dialogue_ShowResponse(
			id,
			"Crafting Trainer: You need Copper Ore from the Mining Trainer. Ore Mark work. Smelting turns effort into something stable. We do not skip steps in a settlement that counts every bar."
		)
		return
	}
	
	if (!HasItem(obj_controller.myItems, "Knife")) {
		Inventory_GrantItem(undefined, "Knife")
		
		Dialogue_ShowResponse(
			id,
			"Crafting Trainer: Good. You brought the raw materials. Take this knife. Work a log, then take your ore to the furnace and smelt a bar. That is the loop — gather, refine, craft. Turn borderland risk into gear someone can trust."
		)
		return
	}
	
	Dialogue_ShowResponse(
		id,
		"Crafting Trainer: Use your knife on a log. Smelt your ore at the furnace. Return with proof, not enthusiasm. The Craft Mark is for people who make value, not piles."
	)
}

ExplainCrafting = function() {
	Dialogue_ShowResponse(
		id,
		"Crafting Trainer: Because Hearthmere does not survive on piles of ore in a yard. It survives on hinges, blades, repairs, and tools that hold. Smelting bridges effort and usefulness. Crafting proves you can create what others depend on."
	)
}

BuildCraftingChoices = function() {
	var choices = []
	var trainer = id
	
	array_push(choices, {
		text: "Can you teach me?",
		trainer: trainer,
		action: function() {
			if (instance_exists(self.trainer)) {
				with (self.trainer) {
					TeachCrafting()
				}
			}
		}
	})
	
	array_push(choices, {
		text: "Why smelt and craft?",
		trainer: trainer,
		action: function() {
			if (instance_exists(self.trainer)) {
				with (self.trainer) {
					ExplainCrafting()
				}
			}
		}
	})
	
	array_push(choices, Dialogue_MakeGoodbyeChoice())
	
	return choices
}

#endregion

npc_choices = BuildCraftingChoices()

interact = function(_player) {
	Dialogue_InteractNpc(id, _player)
}
