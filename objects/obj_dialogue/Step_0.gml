/// @description Dialogue input: typewriter skip, beat advance, choice confirm, dismiss.
/// Typing, choice selection, and line advance are mutually exclusive each frame.

#region Timers

if (input_cooldown > 0) {
	input_cooldown -= 1;
}
if (notice_timer > 0) {
	notice_timer -= 1;
}

#endregion

#region Presentation Ticks

if (active) {
	Dialogue_TickTypewriter();
}

if (conv_active) {
	Conversation_TickPause();
}

#endregion

#region Escape Handling

if (keyboard_check_pressed(vk_escape)) {
	if (instance_exists(obj_controller) && obj_controller.menu_open) {
		obj_controller.CloseContextMenu();
	}
	else if (active) {
		hide();
	}
	else if (notice_timer > 0) {
		notice_text = "";
		notice_timer = 0;
	}
	else if (prompt_active) {
		clear_prompt();
	}
}

#endregion

if (!active) {
	exit;
}

#region Input State Machine

var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
var layout = ComputeDialogueLayout();
var confirm_e = keyboard_check_pressed(ord("E"));
var confirm_advance = confirm_e || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);

// Still revealing — E or a panel click snaps the line; choices stay hidden until text_finished.
if (!text_finished) {
	if (layout.valid && point_in_rectangle(mouse_gui_x, mouse_gui_y, layout.box_x1, layout.box_y1, layout.box_x2, layout.box_y2)) {
		if (mouse_check_button_pressed(mb_left)) {
			confirm_e = true;
		}
	}
	
	if (confirm_e) {
		Dialogue_FinishTypewriter();
		input_cooldown = 4;
	}
	exit;
}

// Menu is up — E picks the highlight; paced line advance is suppressed for this frame.
if (choices_visible) {
	Dialogue_HandleChoiceInput(layout, mouse_gui_x, mouse_gui_y, confirm_e);
	exit;
}

// Welcomer-style beats: Space/Enter can advance a line or skip a PAUSE beat once copy is done.
if (conv_active) {
	if (Conversation_WantsAdvanceInput() && confirm_advance) {
		Conversation_TryAdvance();
		input_cooldown = 4;
	}
	exit;
}

// Trainer show() with no menu rows — E dismisses after the typed line is complete.
if (array_length(choices) <= 0 && confirm_e) {
	hide();
	input_cooldown = 6;
}

#endregion
