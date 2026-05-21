/// @description Woodcutting trainer instance: identity + menu entry only (dialogue in DialogueWoodcuttingTrainer).

function TrainerWoodcutting_Register(_inst) {
	with (_inst) {
		npc_name = DIALOGUE_WOODCUTTING_TRAINER_NAME;
		npc_text = "Timber work is the first real test around here. If the Welcomer has you on the trial list, I can put an axe in your hands.";
		dialogue_text = npc_name + ": " + npc_text;
		
		OpenDialogueMenu = function() {
			DialogueWoodcuttingTrainer_Open(id);
		};
		
		interact = function(_player) {
			Dialogue_InteractNpc(id, _player);
		};
	}
}
