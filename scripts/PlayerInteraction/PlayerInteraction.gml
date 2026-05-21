/// @description Click-to-path and E-key interact; talk/gather fire on tile land, not on click.

function PlayerInteraction_Register(_inst) {
	with (_inst) {
		
		IsResourceTarget = function(_target) {
			return instance_exists(obj_controller) && obj_controller.IsResourceTarget(_target);
		};
		
		#region Click And Context Menu
		
		StepInteraction = function() {
			var input_x = 0;
			var input_y = 0;
			if (!IsDialogueBlockingInput()) {
				input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
				input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
			}
			var clicked_target = noone;
			var hover_target = noone;
			var mouse_over_fixed_ui = false;
			if (instance_exists(obj_controller)) {
				mouse_over_fixed_ui = obj_controller.IsMouseOverFixedUI(mouse_x, mouse_y);
				hover_target = obj_controller.GetInteractTargetAtPoint(mouse_x, mouse_y);
			}
			if (instance_exists(obj_dialogue) && obj_dialogue.IsMouseOverDialogueGui(mouse_x, mouse_y)) {
				mouse_over_fixed_ui = true;
			}
			if (!IsDialogueBlockingInput() && !mouse_over_fixed_ui && (mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_left))) {
				clicked_target = hover_target;
			}
			if (!IsDialogueBlockingInput() && !mouse_over_fixed_ui && mouse_check_button_pressed(mb_right)) {
				obj_controller.CloseContextMenu();
				pending_context_target = clicked_target;
				pending_context_x = mouse_x;
				pending_context_y = mouse_y;
				with (obj_controller) {
					OpenContextMenu(other.pending_context_target, other.pending_context_x, other.pending_context_y);
				}
			}
			if (!IsDialogueBlockingInput() && instance_exists(obj_controller) && obj_controller.menu_open) {
				var openMenuRect = obj_controller.GetContextMenuRect();
				if (!point_in_rectangle(mouse_x, mouse_y, openMenuRect.x, openMenuRect.y, openMenuRect.x + openMenuRect.w, openMenuRect.y + openMenuRect.h)) {
					obj_controller.CloseContextMenu();
				}
			}
			if (!IsDialogueBlockingInput() && mouse_check_button_pressed(mb_left)) {
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
					var click_handled = false;
					if (!mouse_over_fixed_ui && clicked_target != noone) {
						if (obj_controller.IsNpcTarget(clicked_target)) {
							if (npc_talk_cooldown <= 0) {
								if (obj_controller.IsInInteractionRange(id, clicked_target, 1)) {
									if (!moving) {
										click_handled = TryInteractWithTarget(clicked_target);
									}
								} else if (obj_controller.StartMoveToInteractTarget(id, clicked_target, 1, "npc_talk", "Talk-to")) {
									click_handled = true;
								}
							}
						} else if (IsResourceTarget(clicked_target) && !clicked_target.depleted) {
							if (obj_controller.IsInInteractionRange(id, clicked_target, 1)) {
								if (!moving) {
									click_handled = TryInteractWithTarget(clicked_target);
								}
							} else if (obj_controller.StartMoveToInteractTarget(id, clicked_target, 1, "resource_use", clicked_target.resource_action)) {
								click_handled = true;
							}
						}
					}
					if (!mouse_over_fixed_ui && !click_handled && !IsDialogueBlockingInput()) {
						obj_controller.StartMoveToPoint(id, mouse_x, mouse_y);
					}
				}
			}
		};
		
		#endregion
		
		#region Path Arrival And E Key
		
		StepInteraction_ResolvePending = function() {
			if (!moving && !pending_click_move && pending_click_target != noone && pending_click_action != "") {
				if (instance_exists(pending_click_target)) {
					if (obj_controller.IsInInteractionRange(id, pending_click_target, 1)) {
						var pending_action_done = false;
						if (pending_click_action == "npc_talk" && npc_talk_cooldown <= 0) {
							pending_action_done = TryInteractWithTarget(pending_click_target);
						} else if (pending_click_action == "resource_use") {
							pending_action_done = TryInteractWithTarget(pending_click_target);
						}
						if (pending_action_done) {
							pending_click_target = noone;
							pending_click_action = "";
							pending_click_move = false;
							pending_click_action_label = "";
						}
					}
				} else {
					pending_click_target = noone;
					pending_click_action = "";
					pending_click_move = false;
					pending_click_action_label = "";
				}
			}
			var npc = obj_controller.GetNearestNpcTarget(x, y);
			var npc_in_range = npc != noone && obj_controller.IsInInteractionRange(id, npc, 1);
			if (npc_in_range) {
				if (!IsDialogueBlockingInput() && npc_talk_cooldown <= 0 && keyboard_check_pressed(ord("E"))) {
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
			// When NPC and resource share range, E favors talk — matches RPG expectation and avoids silent gather.
			var resource_in_range = resource != noone && obj_controller.IsInInteractionRange(id, resource, 1);
			if (!npc_in_range && resource_in_range) {
				if (!IsDialogueBlockingInput() && keyboard_check_pressed(ord("E"))) {
					pending_resource = resource;
				}
			}
			if (!IsDialogueBlockingInput() && !moving && pending_dialogue_npc != noone) {
				if (instance_exists(pending_dialogue_npc)) {
					if (npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, pending_dialogue_npc, 1)) {
						TryInteractWithTarget(pending_dialogue_npc);
					}
				}
				pending_dialogue_npc = noone;
			}
			if (!IsDialogueBlockingInput() && !moving && pending_resource != noone) {
				if (instance_exists(pending_resource)) {
					if (obj_controller.IsInInteractionRange(id, pending_resource, 1)) {
						TryInteractWithTarget(pending_resource);
					}
				}
				pending_resource = noone;
			}
		};
		
		#endregion
		
		#region Interact Dispatch
		
		TryInteractWithTarget = function(_target) {
			if (!instance_exists(_target)) {
				return false;
			}
			if (IsDialogueBlockingInput()) {
				return false;
			}
			if (instance_exists(obj_controller) && obj_controller.IsNpcTarget(_target)) {
				obj_controller.FaceNpcTowardPlayer(_target, id);
			}
			with (_target) {
				interact(other);
			}
			if (IsDialogueBlockingInput()) {
				CancelActiveMovement();
			}
			return true;
		};
		
		#endregion
	}
}
