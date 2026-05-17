// Read input every frame
var dialogue_blocking_input = false
if (instance_exists(obj_dialogue)) {
    dialogue_blocking_input = obj_dialogue.active || obj_dialogue.input_cooldown > 0
}

var input_x = 0
var input_y = 0

if (!dialogue_blocking_input) {
    input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
    input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))
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
        } else if (buffer_x > 0 && buffer_y > 0) {
            facing_dir = 1 // southeast
        } else if (buffer_x > 0 && buffer_y == 0) {
            facing_dir = 2 // east
        } else if (buffer_x > 0 && buffer_y < 0) {
            facing_dir = 3 // northeast
        } else if (buffer_x == 0 && buffer_y < 0) {
            facing_dir = 4 // north
        } else if (buffer_x < 0 && buffer_y < 0) {
            facing_dir = 5 // northwest
        } else if (buffer_x < 0 && buffer_y == 0) {
            facing_dir = 6 // west
        } else if (buffer_x < 0 && buffer_y > 0) {
            facing_dir = 7 // southwest

        } else if (buffer_x > 0 && buffer_y > 0) {
            facing_dir = 1 // southeast
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

        image_index = facing_dir
    } else {
        var dir = point_direction(x, y, target_x, target_y)

        x += lengthdir_x(move_speed, dir)
        y += lengthdir_y(move_speed, dir)

        image_index = facing_dir
    }
} else {
    image_index = facing_dir
}

var npc = instance_nearest(x, y, obj_npc);
if (npc != noone) {
    if (!dialogue_blocking_input && point_distance(x, y, npc.x, npc.y) <= tile_size && keyboard_check_pressed(ord("E"))) {
        pending_dialogue_npc = npc;
    }
}

if (!dialogue_blocking_input && !moving && pending_dialogue_npc != noone) {
    if (instance_exists(pending_dialogue_npc)) {
        if (point_distance(x, y, pending_dialogue_npc.x, pending_dialogue_npc.y) <= tile_size) {
            with (pending_dialogue_npc) {
                interact(other);
            }
        }
    }
    
    pending_dialogue_npc = noone;
}

if (instance_exists(obj_dialogue) && !obj_dialogue.active) {
    var prompt_npc = instance_nearest(x, y, obj_npc);
    
    if (prompt_npc != noone && point_distance(x, y, prompt_npc.x, prompt_npc.y) <= tile_size) {
        with (obj_dialogue) {
            prompt("[E] Talk to " + prompt_npc.npc_name);
        }
    }
    else {
        with (obj_dialogue) {
            clear_prompt();
        }
    }
}
