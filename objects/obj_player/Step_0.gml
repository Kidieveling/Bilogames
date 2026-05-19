if (npc_talk_cooldown > 0) {
	npc_talk_cooldown -= 1
}

MovementTick_Advance()

StepMovement_HandleKeyboardBuffer()
StepInteraction()

if (IsDialogueBlockingInput()) {
	CancelActiveMovement()
}

StepMovement()

if (walk_anim_hold > 0) {
	walk_anim_hold -= 1
}

StepInteraction_ResolvePending()
StepInteraction_PromptsAndAnimation()

depth = -y
