if (input_cooldown > 0) {
    input_cooldown -= 1
}

if (active) {
    if (array_length(choices) > 0) {
        if (keyboard_check_pressed(ord("W"))) {
            choice_index -= 1
        }

        if (keyboard_check_pressed(ord("S"))) {
            choice_index += 1
        }

        choice_index = clamp(choice_index, 0, array_length(choices) - 1);

        if (keyboard_check_pressed(ord("E"))) {
            var choice = choices[choice_index]

            if (is_struct(choice) && variable_struct_exists(choice, "action")) {
                choice.action()
            } else {
                hide()
            }
        }
    } else {
        if (keyboard_check_pressed(ord("E"))) {
            hide()
        }
    }
}
