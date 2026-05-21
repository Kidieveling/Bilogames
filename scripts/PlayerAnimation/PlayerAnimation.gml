/// @description Walk frames track tile-step lerp, not image_speed; facing rows map to spr_player compass directions.

function PlayerAnimation_Register(_inst) {
	with (_inst) {
		
		#region Facing
		
		SetFacingFromVector = function(_move_x, _move_y) {
			if (_move_x == 0 && _move_y > 0) {
				facing_dir = 0;
			} else if (_move_x > 0 && _move_y > 0) {
				facing_dir = 1;
			} else if (_move_x > 0 && _move_y == 0) {
				facing_dir = 2;
			} else if (_move_x > 0 && _move_y < 0) {
				facing_dir = 3;
			} else if (_move_x == 0 && _move_y < 0) {
				facing_dir = 4;
			} else if (_move_x < 0 && _move_y < 0) {
				facing_dir = 5;
			} else if (_move_x < 0 && _move_y == 0) {
				facing_dir = 6;
			} else if (_move_x < 0 && _move_y > 0) {
				facing_dir = 7;
			}
		};
		
		#endregion
		
		#region Prompts And Walk Frames
		
		StepInteraction_PromptsAndAnimation = function() {
			var input_x = 0;
			var input_y = 0;
			if (!IsDialogueBlockingInput()) {
				input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
				input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
			}
			var hover_target = noone;
			if (instance_exists(obj_controller) && !obj_controller.IsMouseOverFixedUI(mouse_x, mouse_y)) {
				hover_target = obj_controller.GetInteractTargetAtPoint(mouse_x, mouse_y);
			}
			if (instance_exists(obj_dialogue) && !obj_dialogue.active) {
				var opening_prompt = StoryOpening_GetPromptText();
				var prompt_npc = obj_controller.GetNearestNpcTarget(x, y);
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
				if (opening_prompt != "") {
					with (obj_dialogue) {
						prompt(opening_prompt);
					}
				} else if (hover_target != noone && obj_controller.IsNpcTarget(hover_target)) {
					with (obj_dialogue) {
						prompt(obj_controller.FormatTargetPrompt("Click", hover_target));
					}
				} else if (hover_target != noone && IsResourceTarget(hover_target) && !hover_target.depleted) {
					with (obj_dialogue) {
						prompt(obj_controller.FormatTargetPrompt("Click", hover_target));
					}
				} else if (prompt_npc != noone && npc_talk_cooldown <= 0 && obj_controller.IsInInteractionRange(id, prompt_npc, 1)) {
					with (obj_dialogue) {
						prompt(obj_controller.FormatTargetPrompt("Interact", prompt_npc));
					}
				} else if (prompt_resource != noone && !prompt_resource.depleted && obj_controller.IsInInteractionRange(id, prompt_resource, 1)) {
					with (obj_dialogue) {
						prompt(obj_controller.FormatTargetPrompt("Interact", prompt_resource));
					}
				} else {
					with (obj_dialogue) {
						clear_prompt();
					}
				}
			}
			var walking_anim_active = moving || input_x != 0 || input_y != 0 || pending_click_move || walk_anim_hold > 0;
			var anim_frame = 0;
			var frames_per_tile_step = 2;
			if (moving) {
				// image_index advances with lerp progress so foot cadence matches slide speed, not wall-clock time.
				var step_start_x = target_x - (move_x * tile_size);
				var step_start_y = target_y - (move_y * tile_size);
				var step_dist = point_distance(x, y, target_x, target_y);
				var step_total = max(1, point_distance(step_start_x, step_start_y, target_x, target_y));
				var step_t = 1 - (step_dist / step_total);
				step_t = clamp(step_t, 0, 0.999);
				anim_frame = floor(step_t * frames_per_tile_step);
				walk_anim_frame = anim_frame;
			} else if (walking_anim_active) {
				walk_anim_frame += walk_anim_speed;
				if (walk_anim_frame >= frames_per_tile_step) {
					walk_anim_frame -= frames_per_tile_step;
				}
				anim_frame = floor(walk_anim_frame);
			} else {
				walk_anim_frame = 0;
			}
			image_index = (facing_dir * walk_frames) + anim_frame;
		};
		
		#endregion
	}
}
