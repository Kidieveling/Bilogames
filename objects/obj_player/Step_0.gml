if (instance_exists(obj_dialogue) && obj_dialogue.active) {
    exit
}

if (instance_exists(obj_dialogue) && obj_dialogue.input_cooldown > 0) {
    exit
}

// Read input every frame
var input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
var input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))

if (mouse_check_button_pressed(mb_right)) {
    if (instance_exists(obj_context_menu)) {
        with (obj_context_menu) {
            instance_destroy()
        }
    }

    var clicked = collision_point(mouse_x, mouse_y, obj_start_tree, false, true)

    if (clicked == noone) {
        clicked = collision_point(mouse_x, mouse_y, obj_shop_trade, false, true)
    }

    if (clicked != noone && variable_instance_exists(clicked, "get_context_options")) {
        var menu = instance_create_layer(0, 0, "Instances", obj_context_menu)
        menu.menu_x = device_mouse_x_to_gui(0)
        menu.menu_y = device_mouse_y_to_gui(0)
        menu.options = clicked.get_context_options(id)
    }
}

var tile_is_blocked = function(_center_x, _foot_y) {
    var left = _center_x - tile_size / 2
    var top = _foot_y - tile_size
    var right = _center_x + tile_size / 2 - 1
    var bottom = _foot_y - 1

    if (collision_rectangle(left, top, right, bottom, obj_tile_blocked, false, true) != noone) {
        return true
    }

    if (collision_rectangle(left, top, right, bottom, obj_shop_trade, false, true) != noone) {
        return true
    }

    return collision_rectangle(left, top, right, bottom, obj_start_obstacle, false, true) != noone
}

// Store latest held direction, including diagonals
if (input_x != 0 || input_y != 0) {
    buffer_x = input_x
    buffer_y = input_y
}

// Start a new tile move only when not already moving
if (!moving) {
    if (buffer_x != 0 || buffer_y != 0) {
        var next_x = x + buffer_x * tile_size
        var next_y = y + buffer_y * tile_size

        // Face the direction the player is trying to move
        // This still happens even if the tile is blocked
        if (buffer_x == 0 && buffer_y > 0) {
            facing_dir = 0 // south
        } else if (buffer_x < 0 && buffer_y > 0) {
            facing_dir = 1 // southwest
        } else if (buffer_x < 0 && buffer_y == 0) {
            facing_dir = 2 // west
        } else if (buffer_x > 0 && buffer_y < 0) {
            facing_dir = 3 // northeast
        } else if (buffer_x == 0 && buffer_y < 0) {
            facing_dir = 4 // north
        } else if (buffer_x < 0 && buffer_y < 0) {
            facing_dir = 5 // northwest
        } else if (buffer_x > 0 && buffer_y == 0) {
            facing_dir = 6 // east
        } else if (buffer_x > 0 && buffer_y > 0) {
            facing_dir = 7 // southeast
        }

        var blocked = false

        // Room bounds
        if (
            next_x < 0 ||
            next_x >= room_width ||
            next_y < tile_size ||
            next_y > room_height
        ) {
            blocked = true
        }

        // Destination blocked
        if (tile_is_blocked(next_x, next_y)) {
            blocked = true
        }

        // Prevent diagonal corner cutting
        if (buffer_x != 0 && buffer_y != 0) {
            var side_x = x + buffer_x * tile_size
            var side_y = y

            var vertical_x = x
            var vertical_y = y + buffer_y * tile_size

            if (tile_is_blocked(side_x, side_y)) {
                blocked = true
            }

            if (tile_is_blocked(vertical_x, vertical_y)) {
                blocked = true
            }
        }

        if (!blocked) {
            target_x = next_x
            target_y = next_y

            move_x = buffer_x
            move_y = buffer_y

            moving = true
        }

        // Clear buffer if no key is currently held
        if (input_x == 0 && input_y == 0) {
            buffer_x = 0
            buffer_y = 0
        }
    }
}

// Move toward target
if (moving) {
    var dist = point_distance(x, y, target_x, target_y)

    if (dist <= move_speed) {
        x = target_x
        y = target_y

        moving = false

        // If player released the keys, stop queued movement
        if (input_x == 0 && input_y == 0) {
            buffer_x = 0
            buffer_y = 0
        }

        image_index = facing_dir * walk_frames
    } else {
        var dir = point_direction(x, y, target_x, target_y)

        x += lengthdir_x(move_speed, dir)
        y += lengthdir_y(move_speed, dir)

        var walk_frame = floor(current_time / 100) mod walk_frames
        image_index = facing_dir * walk_frames + walk_frame
    }
} else {
    image_index = facing_dir * walk_frames
}
