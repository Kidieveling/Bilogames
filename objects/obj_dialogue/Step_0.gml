/// @description Dialogue input

if (input_cooldown > 0) {
	input_cooldown -= 1;
}
if (notice_timer > 0) {
	notice_timer -= 1;
}

if (active) {
	if (keyboard_check_pressed(ord("W"))) {
		choice_index -= 1;
	}
	if (keyboard_check_pressed(ord("S"))) {
		choice_index += 1;
	}
	
	if (array_length(choices) > 0) {
		choice_index = clamp(choice_index, 0, array_length(choices) - 1);
	}
	
	if (keyboard_check_pressed(ord("E"))) {
		if (array_length(choices) > 0) {
			var choice = choices[choice_index];
			
			if (is_struct(choice) && variable_struct_exists(choice, "action")) {
				choice.action();
			} else {
				hide();
			}
		} else {
			hide();
		}
	}
}
