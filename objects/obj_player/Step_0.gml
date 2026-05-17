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
    click_path = []
    click_path_index = 0
    pending_click_move = false
    pending_click_target = noone
    pending_click_action = ""
    pending_click_action_label = ""
}

var clicked_target = noone
var hover_target = noone
var mouse_over_fixed_ui = false
if (instance_exists(obj_controller)) {
	mouse_over_fixed_ui = obj_controller.IsMouseOverFixedUI(mouse_x, mouse_y)
}
if (instance_exists(obj_controller) && !mouse_over_fixed_ui) {
	hover_target = obj_controller.GetInteractTargetAtPoint(mouse_x, mouse_y)
}

if (!dialogue_blocking_input && !mouse_over_fixed_ui && (mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_left))) {
	clicked_target = hover_target
}

if (!dialogue_blocking_input && !mouse_over_fixed_ui && mouse_check_button_pressed(mb_right)) {
	if (instance_exists(obj_controller)) {
		obj_controller.CloseContextMenu()
	}
	pending_context_target = clicked_target
	pending_context_x = mouse_x
	pending_context_y = mouse_y
	if (instance_exists(obj_controller)) {
		with (obj_controller) {
			OpenContextMenu(other.pending_context_target, other.pending_context_x, other.pending_context_y)
		}
	}
}

if (!dialogue_blocking_input && instance_exists(obj_controller) && obj_controller.menu_open) {
	var openMenuRect = obj_controller.GetContextMenuRect();
	if (!point_in_rectangle(mouse_x, mouse_y, openMenuRect.x, openMenuRect.y, openMenuRect.x + openMenuRect.w, openMenuRect.y + openMenuRect.h)) {
		obj_controller.CloseContextMenu();
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
		if (mouse_over_fixed_ui) {
			// Fixed UI handles this click.
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
        
        if (array_length(click_path) > 0 && click_path_index < array_length(click_path) - 1 && input_x == 0 && input_y == 0) {
            click_path_index += 1
            var next_click_step = click_path[click_path_index]
            var next_click_tile_x = TileXFromPosition(next_click_step.x)
            var next_click_tile_y = TileYFromBottom(next_click_step.y)
            var next_click_blocked = false
            
            if (
                next_click_step.x < 0 ||
                next_click_step.x >= room_width ||
                next_click_step.y < tile_size ||
                next_click_step.y > room_height
            ) {
                next_click_blocked = true
            }
            if (TileBlockedByObject(next_click_tile_x, next_click_tile_y, obj_npc)) {
                next_click_blocked = true
            }
            if (TileBlockedByObject(next_click_tile_x, next_click_tile_y, obj_resource)) {
                next_click_blocked = true
            }
            
            if (!next_click_blocked) {
                target_x = next_click_step.x
                target_y = next_click_step.y
                move_x = sign(target_x - x)
                move_y = sign(target_y - y)
                SetFacingFromVector(move_x, move_y)
                moving = true
                pending_click_move = true
            } else {
                click_path = []
                click_path_index = 0
                pending_click_move = false
                pending_click_target = noone
                pending_click_action = ""
                pending_click_action_label = ""
            }
        } else if (array_length(click_path) > 0 && click_path_index >= array_length(click_path) - 1) {
            click_path = []
            click_path_index = 0
            pending_click_move = false
        }

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

var npc = instance_nearest(x, y, obj_npc);
var npc_in_range = npc != noone && obj_controller.IsInInteractionRange(id, npc, 1);
if (npc_in_range) {
    if (!dialogue_blocking_input && npc_talk_cooldown <= 0 && keyboard_check_pressed(ord("E"))) {
        pending_dialogue_npc = npc;
    }
}

var resource = noone;
var resource_distance = 100000000;
for (var resource_index = 0; resource_index < instance_number(obj_resource); resource_index++) {
    var possible_resource = instance_find(obj_resource, resource_index);
    if (possible_resource.depleted) {
        continue;
    }
    
    var possible_resource_distance = point_distance(x, y, possible_resource.x, possible_resource.y);
    if (possible_resource_distance < resource_distance) {
        resource = possible_resource;
        resource_distance = possible_resource_distance;
    }
}
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
    var prompt_resource = noone;
    var prompt_resource_distance = 100000000;
    for (var prompt_resource_index = 0; prompt_resource_index < instance_number(obj_resource); prompt_resource_index++) {
        var possible_prompt_resource = instance_find(obj_resource, prompt_resource_index);
        if (possible_prompt_resource.depleted) {
            continue;
        }
        
        var possible_prompt_resource_distance = point_distance(x, y, possible_prompt_resource.x, possible_prompt_resource.y);
        if (possible_prompt_resource_distance < prompt_resource_distance) {
            prompt_resource = possible_prompt_resource;
            prompt_resource_distance = possible_prompt_resource_distance;
        }
    }
    
    if (hover_target != noone && hover_target.object_index == obj_npc) {
        with (obj_dialogue) {
            prompt(obj_controller.FormatTargetPrompt("Click", hover_target));
        }
    }
    else if (hover_target != noone && hover_target.object_index == obj_resource && !hover_target.depleted) {
        with (obj_dialogue) {
            prompt(obj_controller.FormatTargetPrompt("Click", hover_target));
        }
    }
    else if (prompt_npc != noone && npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, prompt_npc, 1)) {
        with (obj_dialogue) {
            prompt(obj_controller.FormatTargetPrompt("Interact", prompt_npc));
        }
    }
    else if (prompt_resource != noone && !prompt_resource.depleted && obj_controller.IsInInteractionRange(id, prompt_resource, 1)) {
        with (obj_dialogue) {
            prompt(obj_controller.FormatTargetPrompt("Interact", prompt_resource));
        }
    }
    else {
        with (obj_dialogue) {
            clear_prompt();
        }
    }
}

depth = -y
