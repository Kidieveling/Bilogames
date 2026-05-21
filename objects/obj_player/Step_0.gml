/// @description Player frame order: intent (click/path) before displacement; interact after tile land.

#region Cooldowns And Global Ticks

if (npc_talk_cooldown > 0) {
	npc_talk_cooldown -= 1;
}

MovementTick_Advance();

#endregion

#region Input And Movement

// A new click path should win over an in-flight step — handle input before integrating position.
StepMovement_HandleKeyboardBuffer();
StepInteraction();

// Dialogue choice mode must not leave a walk queued under the panel.
if (IsDialogueBlockingInput()) {
	CancelActiveMovement();
}

StepMovement();

if (walk_anim_hold > 0) {
	walk_anim_hold -= 1;
}

#endregion

#region Post-Move Interaction And Presentation

// Talk/gather intents from pathing only commit once the avatar is on the destination tile.
StepInteraction_ResolvePending();

// Prompts and walk frames read final x/y for this frame, not a mid-lerp position.
StepInteraction_PromptsAndAnimation();

depth = -y;

#endregion
