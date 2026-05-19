tile_size = 32
move_speed = 3

TileXFromPosition = function(_x) {
    return floor(_x / tile_size)
}

TileYFromBottom = function(_y) {
    return floor((_y - 1) / tile_size)
}

InstanceTileX = function(_inst) {
    var _sprite = _inst.sprite_index
    if (_sprite == -1) {
        return TileXFromPosition(_inst.x)
    }
    
    var _visual_center_x = _inst.x + ((sprite_get_width(_sprite) / 2) - sprite_get_xoffset(_sprite))
    return TileXFromPosition(_visual_center_x)
}

InstanceTileY = function(_inst) {
    var _sprite = _inst.sprite_index
    if (_sprite == -1) {
        return TileYFromBottom(_inst.y)
    }
    
    var _visual_bottom_y = _inst.y + (sprite_get_height(_sprite) - sprite_get_yoffset(_sprite))
    return TileYFromBottom(_visual_bottom_y)
}

SnapToCurrentTile = function() {
	var _tx = TileXFromPosition(x);
	var _ty = TileYFromBottom(y);
	x = (_tx * tile_size) + tile_size / 2;
	y = (_ty + 1) * tile_size;
}

FinishCurrentTileMove = function() {
	if (moving) {
		x = target_x;
		y = target_y;
		moving = false;
	} else {
		SnapToCurrentTile();
	}
}

IsDialogueBlockingInput = function() {
	return instance_exists(obj_dialogue) && (obj_dialogue.active || obj_dialogue.input_cooldown > 0)
}

CancelActiveMovement = function() {
	FinishCurrentTileMove()
	buffer_x = 0
	buffer_y = 0
	queued_keyboard_x = 0
	queued_keyboard_y = 0
	queued_click_path = []
	walk_anim_hold = 0
	click_path = []
	click_path_index = 0
	pending_click_move = false
	if (instance_exists(obj_controller)) {
		obj_controller.CancelClickMove(id)
	}
}

TileMovement_IsStepBlocked = function(_next_x, _next_y) {
	if (_next_x < 0 || _next_x >= room_width || _next_y < tile_size || _next_y > room_height) {
		return true
	}
	
	var _next_tile_x = TileXFromPosition(_next_x)
	var _next_tile_y = TileYFromBottom(_next_y)
	
	if (instance_exists(obj_controller) && obj_controller.TileBlockedByNpc(_next_tile_x, _next_tile_y)) {
		return true
	}
	if (TileBlockedByObject(_next_tile_x, _next_tile_y, obj_resource)) {
		return true
	}
	
	return false
}

TileMovement_SetFacingFromBuffer = function(_bx, _by) {
	if (_bx == 0 && _by > 0) {
		facing_dir = 0
	} else if (_bx > 0 && _by > 0) {
		facing_dir = 1
	} else if (_bx > 0 && _by == 0) {
		facing_dir = 2
	} else if (_bx > 0 && _by < 0) {
		facing_dir = 3
	} else if (_bx == 0 && _by < 0) {
		facing_dir = 4
	} else if (_bx < 0 && _by < 0) {
		facing_dir = 5
	} else if (_bx < 0 && _by == 0) {
		facing_dir = 6
	} else if (_bx < 0 && _by > 0) {
		facing_dir = 7
	}
}

TileMovement_TryKeyboardStep = function(_input_x, _input_y) {
	if (moving || IsDialogueBlockingInput()) {
		return false
	}
	if (_input_x == 0 && _input_y == 0) {
		return false
	}
	
	var _next_x = x + _input_x * tile_size
	var _next_y = y + _input_y * tile_size
	
	if (TileMovement_IsStepBlocked(_next_x, _next_y)) {
		return false
	}
	
	TileMovement_SetFacingFromBuffer(_input_x, _input_y)
	target_x = _next_x
	target_y = _next_y
	move_x = _input_x
	move_y = _input_y
	moving = true
	pending_click_move = false
	return true
}

TileMovement_AdvanceClickStep = function() {
	if (moving) {
		return false
	}
	
	while (click_path_index < array_length(click_path)) {
		var _step = click_path[click_path_index]
		
		if (point_distance(x, y, _step.x, _step.y) < 1) {
			click_path_index += 1
			continue
		}
		
		if (TileMovement_IsStepBlocked(_step.x, _step.y)) {
			click_path = []
			click_path_index = 0
			pending_click_move = false
			if (instance_exists(obj_controller)) {
				obj_controller.ClearPendingInteraction(id)
			}
			return false
		}
		
		target_x = _step.x
		target_y = _step.y
		move_x = sign(target_x - x)
		move_y = sign(target_y - y)
		SetFacingFromVector(move_x, move_y)
		moving = true
		pending_click_move = true
		return true
	}
	
	click_path = []
	click_path_index = 0
	pending_click_move = false
	return false
}

TileMovement_QueueOrStartPath = function(_path_points) {
	buffer_x = 0
	buffer_y = 0
	queued_keyboard_x = 0
	queued_keyboard_y = 0
	
	if (array_length(_path_points) <= 0) {
		if (!moving) {
			click_path = []
			click_path_index = 0
			queued_click_path = []
			pending_click_move = false
		}
		return
	}
	
	if (moving) {
		queued_click_path = _path_points
		click_path = []
		click_path_index = 0
		pending_click_move = true
	} else {
		queued_click_path = []
		click_path = _path_points
		click_path_index = 0
		pending_click_move = true
		TileMovement_AdvanceClickStep()
	}
}

TileMovement_OnTileLanded = function(_input_x, _input_y) {
	x = target_x
	y = target_y
	moving = false
	
	if (array_length(click_path) > 0 && click_path_index >= array_length(click_path) - 1) {
		click_path = []
		click_path_index = 0
		pending_click_move = false
		
		if (pending_click_target != noone && (!instance_exists(pending_click_target) || !obj_controller.IsInInteractionRange(id, pending_click_target, 1))) {
			if (instance_exists(obj_controller)) {
				obj_controller.ClearPendingInteraction(id)
			} else {
				pending_click_target = noone
				pending_click_action = ""
				pending_click_action_label = ""
			}
		}
	} else if (array_length(click_path) > 0) {
		click_path_index += 1
	}
	
	if (queued_keyboard_x != 0 || queued_keyboard_y != 0) {
		var _qx = queued_keyboard_x
		var _qy = queued_keyboard_y
		queued_keyboard_x = 0
		queued_keyboard_y = 0
		queued_click_path = []
		click_path = []
		click_path_index = 0
		pending_click_move = false
		if (instance_exists(obj_controller)) {
			obj_controller.CancelClickMove(id)
		}
		TileMovement_TryKeyboardStep(_qx, _qy)
		return
	}
	
	if (array_length(queued_click_path) > 0) {
		click_path = queued_click_path
		queued_click_path = []
		click_path_index = 0
		pending_click_move = true
		TileMovement_AdvanceClickStep()
		return
	}
	
	if (array_length(click_path) > 0) {
		TileMovement_AdvanceClickStep()
		return
	}
	
	if (!IsDialogueBlockingInput() && (buffer_x != 0 || buffer_y != 0)) {
		TileMovement_TryKeyboardStep(buffer_x, buffer_y)
	}
	
	if (_input_x == 0 && _input_y == 0) {
		buffer_x = 0
		buffer_y = 0
	}
}

IsResourceTarget = function(_target) {
	return instance_exists(obj_controller) && obj_controller.IsResourceTarget(_target)
}

StepMovement_HandleKeyboardBuffer = function() {
	var input_x = 0
	var input_y = 0
	
	if (!IsDialogueBlockingInput()) {
		input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
		input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))
	}
	
	if (input_x != 0 || input_y != 0) {
		if (moving || array_length(click_path) > 0 || array_length(queued_click_path) > 0 || pending_click_move) {
			queued_keyboard_x = input_x
			queued_keyboard_y = input_y
			queued_click_path = []
			click_path = []
			click_path_index = 0
			pending_click_move = false
			if (instance_exists(obj_controller)) {
				obj_controller.CancelClickMove(id)
			}
		} else {
			buffer_x = input_x
			buffer_y = input_y
		}
		walk_anim_hold = 12
	}
}

StepInteraction = function() {
	var input_x = 0
	var input_y = 0
	if (!IsDialogueBlockingInput()) {
		input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
		input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))
	}
	
	var clicked_target = noone
	var hover_target = noone
	var mouse_over_fixed_ui = false
	if (instance_exists(obj_controller)) {
		mouse_over_fixed_ui = obj_controller.IsMouseOverFixedUI(mouse_x, mouse_y)
		hover_target = obj_controller.GetInteractTargetAtPoint(mouse_x, mouse_y)
	}
	
	if (!IsDialogueBlockingInput() && !mouse_over_fixed_ui && (mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_left))) {
		clicked_target = hover_target
	}
	
	if (!IsDialogueBlockingInput() && !mouse_over_fixed_ui && mouse_check_button_pressed(mb_right)) {
		obj_controller.CloseContextMenu()
		pending_context_target = clicked_target
		pending_context_x = mouse_x
		pending_context_y = mouse_y
		with (obj_controller) {
			OpenContextMenu(other.pending_context_target, other.pending_context_x, other.pending_context_y)
		}
	}
	
	if (!IsDialogueBlockingInput() && instance_exists(obj_controller) && obj_controller.menu_open) {
		var openMenuRect = obj_controller.GetContextMenuRect()
		if (!point_in_rectangle(mouse_x, mouse_y, openMenuRect.x, openMenuRect.y, openMenuRect.x + openMenuRect.w, openMenuRect.y + openMenuRect.h)) {
			obj_controller.CloseContextMenu()
		}
	}
	
	if (!IsDialogueBlockingInput() && mouse_check_button_pressed(mb_left)) {
		var controller = instance_find(obj_controller, 0)
		if (instance_exists(controller) && controller.menu_open) {
			var clickX = mouse_x
			var clickY = mouse_y
			var rect = controller.GetContextMenuRect()
			var optionIndex = floor((clickY - rect.y) / rect.option_h)
			if (point_in_rectangle(clickX, clickY, rect.x, rect.y, rect.x + rect.w, rect.y + rect.h) && optionIndex >= 0 && optionIndex < array_length(controller.menu_actions)) {
				controller.ChooseContextMenuOption(id, optionIndex)
			} else {
				controller.CloseContextMenu()
			}
		} else {
			var click_handled = false
			if (!mouse_over_fixed_ui && clicked_target != noone) {
				if (obj_controller.IsNpcTarget(clicked_target)) {
					if (npc_talk_cooldown <= 0) {
						if (obj_controller.IsInInteractionRange(id, clicked_target, 1)) {
							if (!moving) {
								click_handled = TryInteractWithTarget(clicked_target)
							}
						} else if (obj_controller.StartMoveToInteractTarget(id, clicked_target, 1, "npc_talk", "Talk-to")) {
							click_handled = true
						}
					}
				} else if (IsResourceTarget(clicked_target) && !clicked_target.depleted) {
					if (obj_controller.IsInInteractionRange(id, clicked_target, 1)) {
						if (!moving) {
							click_handled = TryInteractWithTarget(clicked_target)
						}
					} else if (obj_controller.StartMoveToInteractTarget(id, clicked_target, 1, "resource_use", clicked_target.resource_action)) {
						click_handled = true
					}
				}
			}
			
			if (!mouse_over_fixed_ui && !click_handled && !IsDialogueBlockingInput()) {
				obj_controller.CancelClickMove(id)
				obj_controller.StartMoveToPoint(id, mouse_x, mouse_y)
			}
		}
	}
}

StepMovement = function() {
	var input_x = 0
	var input_y = 0
	if (!IsDialogueBlockingInput()) {
		input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
		input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))
	}
	
	if (!moving && !IsDialogueBlockingInput()) {
		if (buffer_x != 0 || buffer_y != 0) {
			TileMovement_TryKeyboardStep(buffer_x, buffer_y)
			if (input_x == 0 && input_y == 0) {
				buffer_x = 0
				buffer_y = 0
			}
		}
	}
	
	if (IsDialogueBlockingInput()) {
		CancelActiveMovement()
	} else if (moving) {
		var dist = point_distance(x, y, target_x, target_y)
		
		if (dist <= move_speed) {
			TileMovement_OnTileLanded(input_x, input_y)
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
}

StepInteraction_ResolvePending = function() {
	if (!moving && !pending_click_move && pending_click_target != noone && pending_click_action != "") {
		if (instance_exists(pending_click_target)) {
			if (obj_controller.IsInInteractionRange(id, pending_click_target, 1)) {
				var pending_action_done = false
				if (pending_click_action == "npc_talk" && npc_talk_cooldown <= 0) {
					pending_action_done = TryInteractWithTarget(pending_click_target)
				} else if (pending_click_action == "resource_use") {
					pending_action_done = TryInteractWithTarget(pending_click_target)
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
	
	var npc = obj_controller.GetNearestNpcTarget(x, y)
	var npc_in_range = npc != noone && obj_controller.IsInInteractionRange(id, npc, 1)
	if (npc_in_range) {
		if (!IsDialogueBlockingInput() && npc_talk_cooldown <= 0 && keyboard_check_pressed(ord("E"))) {
			pending_dialogue_npc = npc
		}
	}
	
	var resource = noone
	var resource_distance = 100000000
	for (var resource_index = 0; resource_index < instance_number(obj_resource); resource_index++) {
		var possible_resource = instance_find(obj_resource, resource_index)
		if (possible_resource.depleted) {
			continue
		}
		
		var possible_resource_distance = point_distance(x, y, possible_resource.x, possible_resource.y)
		if (possible_resource_distance < resource_distance) {
			resource = possible_resource
			resource_distance = possible_resource_distance
		}
	}
	var resource_in_range = resource != noone && obj_controller.IsInInteractionRange(id, resource, 1)
	if (!npc_in_range && resource_in_range) {
		if (!IsDialogueBlockingInput() && keyboard_check_pressed(ord("E"))) {
			pending_resource = resource
		}
	}
	
	if (!IsDialogueBlockingInput() && !moving && pending_dialogue_npc != noone) {
		if (instance_exists(pending_dialogue_npc)) {
			if (npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, pending_dialogue_npc, 1)) {
				TryInteractWithTarget(pending_dialogue_npc)
			}
		}
		pending_dialogue_npc = noone
	}
	
	if (!IsDialogueBlockingInput() && !moving && pending_resource != noone) {
		if (instance_exists(pending_resource)) {
			if (obj_controller.IsInInteractionRange(id, pending_resource, 1)) {
				TryInteractWithTarget(pending_resource)
			}
		}
		pending_resource = noone
	}
}

StepInteraction_PromptsAndAnimation = function() {
	var input_x = 0
	var input_y = 0
	if (!IsDialogueBlockingInput()) {
		input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"))
		input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"))
	}
	
	var hover_target = noone
	if (instance_exists(obj_controller) && !obj_controller.IsMouseOverFixedUI(mouse_x, mouse_y)) {
		hover_target = obj_controller.GetInteractTargetAtPoint(mouse_x, mouse_y)
	}
	
	if (instance_exists(obj_dialogue) && !obj_dialogue.active) {
		var opening_prompt = StoryOpening_GetPromptText()
		var prompt_npc = obj_controller.GetNearestNpcTarget(x, y)
		var prompt_resource = noone
		var prompt_resource_distance = 100000000
		for (var prompt_resource_index = 0; prompt_resource_index < instance_number(obj_resource); prompt_resource_index++) {
			var possible_prompt_resource = instance_find(obj_resource, prompt_resource_index)
			if (possible_prompt_resource.depleted) {
				continue
			}
			
			var possible_prompt_resource_distance = point_distance(x, y, possible_prompt_resource.x, possible_prompt_resource.y)
			if (possible_prompt_resource_distance < prompt_resource_distance) {
				prompt_resource = possible_prompt_resource
				prompt_resource_distance = possible_prompt_resource_distance
			}
		}
		
		if (opening_prompt != "") {
			with (obj_dialogue) {
				prompt(opening_prompt)
			}
		} else if (hover_target != noone && obj_controller.IsNpcTarget(hover_target)) {
			with (obj_dialogue) {
				prompt(obj_controller.FormatTargetPrompt("Click", hover_target))
			}
		} else if (hover_target != noone && IsResourceTarget(hover_target) && !hover_target.depleted) {
			with (obj_dialogue) {
				prompt(obj_controller.FormatTargetPrompt("Click", hover_target))
			}
		} else if (prompt_npc != noone && npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, prompt_npc, 1)) {
			with (obj_dialogue) {
				prompt(obj_controller.FormatTargetPrompt("Interact", prompt_npc))
			}
		} else if (prompt_resource != noone && !prompt_resource.depleted && obj_controller.IsInInteractionRange(id, prompt_resource, 1)) {
			with (obj_dialogue) {
				prompt(obj_controller.FormatTargetPrompt("Interact", prompt_resource))
			}
		} else {
			with (obj_dialogue) {
				clear_prompt()
			}
		}
	}
	
	var walking_anim_active = moving || input_x != 0 || input_y != 0 || pending_click_move || walk_anim_hold > 0
	if (walking_anim_active) {
		walk_anim_frame = (walk_anim_frame + walk_anim_speed) mod walk_frames
	} else {
		walk_anim_frame = 0
	}
	image_index = (facing_dir * walk_frames) + floor(walk_anim_frame)
}

TryInteractWithTarget = function(_target) {
	if (!instance_exists(_target)) {
		return false
	}
	if (IsDialogueBlockingInput()) {
		return false
	}
	
	if (instance_exists(obj_controller) && obj_controller.IsNpcTarget(_target)) {
		obj_controller.FaceNpcTowardPlayer(_target, id)
	}
	
	with (_target) {
		interact(other)
	}
	
	if (IsDialogueBlockingInput()) {
		CancelActiveMovement()
	}
	
	return true
}

TileBlockedByObject = function(_tile_x, _tile_y, _object) {
    for (var _i = 0; _i < instance_number(_object); _i++) {
        var _inst = instance_find(_object, _i)
        if (InstanceTileX(_inst) == _tile_x && InstanceTileY(_inst) == _tile_y) {
            return true
        }
    }
    
    return false
}

SetFacingFromVector = function(_move_x, _move_y) {
    if (_move_x == 0 && _move_y > 0) {
        facing_dir = 0
    } else if (_move_x > 0 && _move_y > 0) {
        facing_dir = 1
    } else if (_move_x > 0 && _move_y == 0) {
        facing_dir = 2
    } else if (_move_x > 0 && _move_y < 0) {
        facing_dir = 3
    } else if (_move_x == 0 && _move_y < 0) {
        facing_dir = 4
    } else if (_move_x < 0 && _move_y < 0) {
        facing_dir = 5
    } else if (_move_x < 0 && _move_y == 0) {
        facing_dir = 6
    } else if (_move_x < 0 && _move_y > 0) {
        facing_dir = 7
    }
}

moving = false
target_x = x
target_y = y
click_path = []
click_path_index = 0
pending_click_move = false
pending_click_target = noone
pending_click_action = ""
pending_click_action_label = ""
pending_context_target = noone
pending_context_x = 0
pending_context_y = 0

move_x = 0
move_y = 0

buffer_x = 0
buffer_y = 0
queued_keyboard_x = 0
queued_keyboard_y = 0
queued_click_path = []
pending_dialogue_npc = noone
pending_resource = noone
npc_talk_cooldown = 0

facing_dir = 0
walk_frames = 4
walk_anim_frame = 0
walk_anim_speed = 0.08
walk_anim_hold = 0

image_speed = 0
depth = 0

x = (floor(x / tile_size) * tile_size) + tile_size / 2
y = (floor(y / tile_size) * tile_size) + tile_size

target_x = x
target_y = y

if (variable_global_exists("spawn_x")) {
    x = global.spawn_x;
    y = global.spawn_y;
}

