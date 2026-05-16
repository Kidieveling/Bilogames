if (active) {
    var screen_h = display_get_gui_height()

    var box_width = 560
    var box_height = 180

    var box_x1 = 32
    var box_y1 = screen_h - box_height - 32
    var box_x2 = box_x1 + box_width
    var box_y2 = box_y1 + box_height

    draw_set_color(c_black)
    draw_rectangle(box_x1, box_y1, box_x2, box_y2, false)

    draw_set_color(c_white)
    draw_rectangle(box_x1, box_y1, box_x2, box_y2, true)

    var text_x = box_x1 + 24
    var text_y = box_y1 + 20
    var text_width = box_width - 48
    var line_gap = 18

    draw_set_color(c_white)
    draw_text_ext(text_x, text_y, text, line_gap, text_width)

    var choices_y = text_y + 72

    for (var i = 0; i < array_length(choices); i++) {
        var prefix = "  "
        
        if (i == choice_index) {
            prefix = "> "
        }

        var choice_text = choices[i]

        if (is_struct(choices[i])) {
            choice_text = choices[i].text
        }

        draw_text(text_x, choices_y + i * 24, prefix + choice_text)
    }
}
