/// @description Dialogue input

if (input_cooldown > 0) {
	input_cooldown -= 1;
}
if (notice_timer > 0) {
	notice_timer -= 1;
}

if (conv_active) {
	Conversation_TickTypewriter();
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
var confirm_advance = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);
var layout = ComputeDialogueLayout();

if (layout.valid && point_in_rectangle(mouse_gui_x, mouse_gui_y, layout.box_x1, layout.box_y1, layout.box_x2, layout.box_y2)) {
	if (mouse_check_button_pressed(mb_left)) {
		confirm_advance = true;
	}
}

if (conv_active) {
	if (Conversation_WantsAdvanceInput() && confirm_advance) {
		Conversation_TryAdvance();
		input_cooldown = 4;
	}
	
	if (Conversation_WantsChoiceInput()) {
		if (keyboard_check_pressed(ord("W"))) {
			choice_index -= 1;
		}
		if (keyboard_check_pressed(ord("S"))) {
			choice_index += 1;
		}
		
		if (array_length(choices) > 0) {
			choice_index = clamp(choice_index, 0, array_length(choices) - 1);
		}
		
		var confirm_choice = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter);
		
		if (layout.valid && array_length(layout.choice_rects) > 0) {
			var hovered_choice = -1;
			for (var i = 0; i < array_length(layout.choice_rects); ++i) {
				var row = layout.choice_rects[i];
				if (point_in_rectangle(mouse_gui_x, mouse_gui_y, row.x1, row.y1, row.x2, row.y2)) {
					hovered_choice = i;
				}
			}
			
			if (hovered_choice >= 0) {
				choice_index = hovered_choice;
				if (mouse_check_button_pressed(mb_left)) {
					confirm_choice = true;
				}
			}
		}
		
		if (confirm_choice) {
			ActivateChoice(choice_index);
			input_cooldown = 6;
		}
	}
	
	exit;
}

// Legacy menu mode
if (keyboard_check_pressed(ord("W"))) {
	choice_index -= 1;
}
if (keyboard_check_pressed(ord("S"))) {
	choice_index += 1;
}

if (array_length(choices) > 0) {
	choice_index = clamp(choice_index, 0, array_length(choices) - 1);
}

var confirm_choice = keyboard_check_pressed(ord("E"));

if (layout.valid && array_length(layout.choice_rects) > 0) {
	var mouse_gui_x = device_mouse_x_to_gui(0);
	var mouse_gui_y = device_mouse_y_to_gui(0);
	var hovered_choice = -1;
	
	for (var j = 0; j < array_length(layout.choice_rects); ++j) {
		var row_legacy = layout.choice_rects[j];
		if (point_in_rectangle(mouse_gui_x, mouse_gui_y, row_legacy.x1, row_legacy.y1, row_legacy.x2, row_legacy.y2)) {
			hovered_choice = j;
		}
	}
	
	if (hovered_choice >= 0) {
		choice_index = hovered_choice;
		if (mouse_check_button_pressed(mb_left)) {
			confirm_choice = true;
		}
	}
}

if (confirm_choice) {
	if (array_length(choices) > 0) {
		ActivateChoice(choice_index);
	} else {
		hide();
	}
}
