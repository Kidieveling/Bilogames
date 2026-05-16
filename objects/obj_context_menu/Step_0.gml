if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right)) {
    instance_destroy()
    exit
}

if (mouse_check_button_pressed(mb_left)) {
    var mouse_gui_x = device_mouse_x_to_gui(0)
    var mouse_gui_y = device_mouse_y_to_gui(0)
    var menu_height = padding * 2 + array_length(options) * option_height

    var inside_menu =
        mouse_gui_x >= menu_x &&
        mouse_gui_x <= menu_x + menu_width &&
        mouse_gui_y >= menu_y &&
        mouse_gui_y <= menu_y + menu_height

    if (!inside_menu) {
        instance_destroy()
        exit
    }

    var option_index = (mouse_gui_y - menu_y - padding) div option_height

    if (option_index >= 0 && option_index < array_length(options)) {
        var option = options[option_index]

        if (is_struct(option) && variable_struct_exists(option, "action")) {
            var action = option.action
            instance_destroy()
            action()
        } else {
            instance_destroy()
        }
    }
}
