// Read input every frame
var input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
var input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))

var tile_is_blocked = function(_center_x, _foot_y) {
    return false
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
