if (keyboard_check_pressed(ord("I"))) {
    global.inventory_open = !global.inventory_open;
}

if (global.inventory_open) {
    if (keyboard_check_pressed(vk_right)) {
        selected_slot += 1;
    }

    if (keyboard_check_pressed(vk_left)) {
        selected_slot -= 1;
    }

    if (keyboard_check_pressed(vk_down)) {
        selected_slot += global.inventory_cols;
    }

    if (keyboard_check_pressed(vk_up)) {
        selected_slot -= global.inventory_cols;
    }

    selected_slot = clamp(selected_slot, 0, global.inventory_slots - 1);
}
