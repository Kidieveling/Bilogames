/// @description Dialogue input

if (input_cooldown > 0) {
	input_cooldown -= 1;
}
if (notice_timer > 0) {
	notice_timer -= 1;
}

if (active) {
	Dialogue_TickTypewriter();
}

if (conv_active) {
	Conversation_TickPause();
}

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

if (!active) {
	exit;
}

var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
var layout = ComputeDialogueLayout();
var confirm_e = keyboard_check_pressed(ord("E"));
var confirm_advance = confirm_e || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);

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

// Text finished — full line stays visible; choices appear when applicable
if (choices_visible) {
	Dialogue_HandleChoiceInput(layout, mouse_gui_x, mouse_gui_y, confirm_e);
	exit;
}

if (conv_active) {
	if (Conversation_WantsAdvanceInput() && confirm_advance) {
		Conversation_TryAdvance();
		input_cooldown = 4;
	}
	exit;
}

// Legacy: no choices — E dismisses after the line is shown
if (array_length(choices) <= 0 && confirm_e) {
	hide();
	input_cooldown = 6;
}
