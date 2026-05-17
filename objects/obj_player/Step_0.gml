// Read input every frame
var dialogue_blocking_input = false
if (instance_exists(obj_dialogue)) {
    dialogue_blocking_input = obj_dialogue.active || obj_dialogue.input_cooldown > 0
}

if (npc_talk_cooldown > 0) {
	npc_talk_cooldown -= 1
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

var clicked_target = noone
var hover_target = noone
if (instance_exists(obj_controller)) {
	hover_target = obj_controller.GetInteractTargetAtPoint(mouse_x, mouse_y)
}
global.hover_target = hover_target

if (!dialogue_blocking_input && (mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_left))) {
	clicked_target = hover_target
}

if (!dialogue_blocking_input && mouse_check_button_pressed(mb_right)) {
	global.debug_right_click = true;
	if (instance_exists(obj_controller)) {
		obj_controller.CloseContextMenu()
	}
	if (clicked_target != noone) {
		pending_context_target = clicked_target
		if (instance_exists(obj_controller)) {
			with (obj_controller) {
				OpenContextMenu(other.pending_context_target, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0))
			}
		}
	}
}

if (!dialogue_blocking_input && mouse_check_button_pressed(mb_left)) {
	var controller = instance_find(obj_controller, 0);
	if (instance_exists(controller) && controller.menu_open) {
		var clickX = mouse_x;
		var clickY = mouse_y;
		var rect = controller.GetContextMenuRect();
		var optionIndex = floor((clickY - rect.y) / rect.option_h);
		if (point_in_rectangle(clickX, clickY, rect.x, rect.y, rect.x + rect.w, rect.y + rect.h) && optionIndex >= 0 && optionIndex < array_length(controller.menu_actions)) {
			controller.ChooseContextMenuOption(id, optionIndex);
		} else {
			controller.CloseContextMenu();
		}
	} else {
		if (instance_exists(obj_context_menu)) {
			// let the menu handle it
		} else if (clicked_target != noone) {
			if (clicked_target.object_index == obj_npc) {
				if (npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, clicked_target, 1)) {
					with (clicked_target) {
						interact(other)
					}
				} else if (npc_talk_cooldown <= 0) {
					if (instance_exists(obj_controller)) {
						if (obj_controller.StartMoveToInteractTarget(id, clicked_target, 1)) {
							pending_click_target = clicked_target
							pending_click_action = "npc_talk"
							pending_click_action_label = "Talk-to"
							pending_click_move = true
						}
					}
				}
			} else if (clicked_target.object_index == obj_resource && !clicked_target.depleted) {
				if (obj_controller.IsInInteractionRange(id, clicked_target, 1)) {
					with (clicked_target) {
						interact(other)
					}
				} else {
					if (instance_exists(obj_controller)) {
						if (obj_controller.StartMoveToInteractTarget(id, clicked_target, 1)) {
							pending_click_target = clicked_target
							pending_click_action = "resource_use"
							pending_click_action_label = clicked_target.resource_action
							pending_click_move = true
						}
					}
				}
			}
		} else {
			if (instance_exists(obj_controller)) {
				obj_controller.StartMoveToPoint(id, mouse_x, mouse_y)
			}
		}
	}
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
        
        var next_tile_x = TileXFromPosition(next_x)
        var next_tile_y = TileYFromBottom(next_y)
        
        if (TileBlockedByObject(next_tile_x, next_tile_y, obj_npc)) {
            blocked = true
        }
        if (TileBlockedByObject(next_tile_x, next_tile_y, obj_resource)) {
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

if (!moving && pending_click_target != noone) {
	if (instance_exists(pending_click_target)) {
		if (obj_controller.IsInInteractionRange(id, pending_click_target, 1)) {
			var pending_action_done = false
			if (pending_click_action == "npc_talk" && npc_talk_cooldown <= 0) {
				with (pending_click_target) {
					interact(other)
				}
				pending_action_done = true
			} else if (pending_click_action == "resource_use") {
				with (pending_click_target) {
					interact(other)
				}
				pending_action_done = true
			}
			
			if (pending_action_done) {
				pending_click_target = noone
				pending_click_action = ""
				pending_click_move = false
				pending_click_action_label = ""
			}
        }
    } else {
        pending_click_target = noone
        pending_click_action = ""
        pending_click_move = false
        pending_click_action_label = ""
    }
}

if (instance_exists(obj_context_menu) && mouse_check_button_pressed(mb_left)) {
    if (point_in_rectangle(mouse_x, mouse_y, obj_context_menu.x, obj_context_menu.y, obj_context_menu.x + obj_context_menu.width, obj_context_menu.y + (array_length(obj_context_menu.actions) * obj_context_menu.option_h))) {
        // menu handles it
    }
}

var npc = instance_nearest(x, y, obj_npc);
var npc_in_range = npc != noone && obj_controller.IsInInteractionRange(id, npc, 1);
if (npc_in_range) {
    if (!dialogue_blocking_input && npc_talk_cooldown <= 0 && keyboard_check_pressed(ord("E"))) {
        pending_dialogue_npc = npc;
    }
}

var resource = instance_nearest(x, y, obj_resource);
var resource_in_range = resource != noone && obj_controller.IsInInteractionRange(id, resource, 1);
if (!npc_in_range && resource_in_range) {
    if (!dialogue_blocking_input && keyboard_check_pressed(ord("E"))) {
        pending_resource = resource;
    }
}

if (!dialogue_blocking_input && !moving && pending_dialogue_npc != noone) {
    if (instance_exists(pending_dialogue_npc)) {
        if (npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, pending_dialogue_npc, 1)) {
            with (pending_dialogue_npc) {
                interact(other);
            }
        }
    }
    
    pending_dialogue_npc = noone;
}

if (!dialogue_blocking_input && !moving && pending_resource != noone) {
    if (instance_exists(pending_resource)) {
        if (obj_controller.IsInInteractionRange(id, pending_resource, 1)) {
            with (pending_resource) {
                interact(other);
            }
        }
    }
    
    pending_resource = noone;
}

if (instance_exists(obj_dialogue) && !obj_dialogue.active) {
    var prompt_npc = instance_nearest(x, y, obj_npc);
    var prompt_resource = instance_nearest(x, y, obj_resource);
    
    if (prompt_npc != noone && npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, prompt_npc, 1)) {
        with (obj_dialogue) {
            prompt("[E] Talk to " + prompt_npc.npc_name);
        }
    }
    else if (prompt_resource != noone && obj_controller.IsInInteractionRange(id, prompt_resource, 1)) {
        with (obj_dialogue) {
            prompt("[E] " + prompt_resource.resource_action + " " + prompt_resource.resource_name);
        }
    }
    else {
        with (obj_dialogue) {
            clear_prompt();
        }
    }
}

depth = -y
