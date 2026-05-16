var option_count = array_length(options)
var menu_height = padding * 2 + option_count * option_height

draw_set_color(c_black)
draw_rectangle(menu_x, menu_y, menu_x + menu_width, menu_y + menu_height, false)

draw_set_color(c_white)
draw_rectangle(menu_x, menu_y, menu_x + menu_width, menu_y + menu_height, true)

var mouse_gui_x = device_mouse_x_to_gui(0)
var mouse_gui_y = device_mouse_y_to_gui(0)

for (var i = 0; i < option_count; i++) {
    var option_y = menu_y + padding + i * option_height
    var hovered =
        mouse_gui_x >= menu_x &&
        mouse_gui_x <= menu_x + menu_width &&
        mouse_gui_y >= option_y &&
        mouse_gui_y <= option_y + option_height

    if (hovered) {
        draw_set_color(c_dkgray)
        draw_rectangle(menu_x + 2, option_y, menu_x + menu_width - 2, option_y + option_height, false)
    }

    var option_text = options[i]

    if (is_struct(options[i])) {
        option_text = options[i].text
    }

    draw_set_color(c_white)
    draw_text(menu_x + padding, option_y + 4, option_text)
}
