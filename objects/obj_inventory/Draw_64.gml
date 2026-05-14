if (global.inventory_open) {
    var slot_size = 32;
    var gap = 3;

    var start_x = 1080;
    var start_y = 500;

    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_rectangle(
        start_x - 16,
        start_y - 48,
        start_x + global.inventory_cols * (slot_size + gap),
        start_y + global.inventory_rows * (slot_size + gap),
        false
    );
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(start_x, start_y - 32, "Inventory");

    for (var i = 0; i < global.inventory_slots; i++) {
        var col = i mod global.inventory_cols;
        var row = i div global.inventory_cols;

        var xx = start_x + col * (slot_size + gap);
        var yy = start_y + row * (slot_size + gap);

        // Slot box
        if (i == selected_slot) {
            draw_set_color(c_yellow);
        } else {
            draw_set_color(c_white);
        }

        draw_rectangle(xx, yy, xx + slot_size, yy + slot_size, false);

        // Item inside slot
        var item = global.inventory[i];

        if (item != noone) {
            draw_sprite(item.sprite, 0, xx + slot_size / 2, yy + slot_size / 2);

            if (item.amount > 1) {
                draw_set_color(c_white);
                draw_text(xx + slot_size - 16, yy + slot_size - 18, string(item.amount));
            }
        }
    }
}
