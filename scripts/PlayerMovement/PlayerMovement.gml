/// @description Tile-grid movement with per-frame lerp between centers; path steps and
/// keyboard repeats align to global movement ticks, not raw frame rate.

function PlayerMovement_Register(_inst) {
	with (_inst) {
		
		#region Tile Coordinates
		
		// Occupancy uses sprite feet/center, not the instance origin, so pathing matches the art.
		
		TileXFromPosition = function(_x) {
			return floor(_x / tile_size);
		};
		
		TileYFromBottom = function(_y) {
			return floor((_y - 1) / tile_size);
		};
		
		InstanceTileX = function(_inst) {
			var _sprite = _inst.sprite_index;
			if (_sprite == -1) {
				return TileXFromPosition(_inst.x);
			}
			var _visual_center_x = _inst.x + ((sprite_get_width(_sprite) / 2) - sprite_get_xoffset(_sprite));
			return TileXFromPosition(_visual_center_x);
		};
		
		InstanceTileY = function(_inst) {
			var _sprite = _inst.sprite_index;
			if (_sprite == -1) {
				return TileYFromBottom(_inst.y);
			}
			var _visual_bottom_y = _inst.y + (sprite_get_height(_sprite) - sprite_get_yoffset(_sprite));
			return TileYFromBottom(_visual_bottom_y);
		};
		
		SnapToCurrentTile = function() {
			var _tx = TileXFromPosition(x);
			var _ty = TileYFromBottom(y);
			x = (_tx * tile_size) + tile_size / 2;
			y = (_ty + 1) * tile_size;
		};
		
		FinishCurrentTileMove = function() {
			if (moving) {
				x = target_x;
				y = target_y;
				moving = false;
			} else {
				SnapToCurrentTile();
			}
		};
		
		#endregion
		
		#region Dialogue Gating
		
		IsDialogueBlockingInput = function() {
			if (!instance_exists(obj_dialogue)) {
				return false;
			}
			if (obj_dialogue.input_cooldown > 0) {
				return true;
			}
			if (obj_dialogue.Dialogue_PlayerMovementLocked()) {
				return true;
			}
			return false;
		};
		
		CancelActiveMovement = function() {
			FinishCurrentTileMove();
			buffer_x = 0;
			buffer_y = 0;
			queued_keyboard_x = 0;
			queued_keyboard_y = 0;
			queued_click_path = [];
			pending_keyboard_step = false;
			keyboard_hold_frames = 0;
			walk_anim_hold = 0;
			click_path = [];
			click_path_index = 0;
			pending_click_move = false;
			if (instance_exists(obj_controller)) {
				obj_controller.CancelClickMove(id);
			}
		};
		
		#endregion
		
		#region Step Execution
		
		TileMovement_IsStepBlocked = function(_next_x, _next_y) {
			if (!instance_exists(obj_controller)) {
				return true;
			}
			var _next_tile_x = TileXFromPosition(_next_x);
			var _next_tile_y = TileYFromBottom(_next_y);
			return !obj_controller.IsTileWalkable(_next_tile_x, _next_tile_y, true);
		};
		
		TileMovement_ClearClickPath = function() {
			click_path = [];
			click_path_index = 0;
			queued_click_path = [];
			pending_click_move = false;
		};
		
		TileMovement_PulseWalkAnim = function() {
			walk_anim_hold = max(walk_anim_hold, movement_tick_length);
		};
		
		TileMovement_BeginStep = function(_target_x, _target_y, _step_x, _step_y, _is_click_path) {
			target_x = _target_x;
			target_y = _target_y;
			move_x = _step_x;
			move_y = _step_y;
			SetFacingFromVector(_step_x, _step_y);
			moving = true;
			pending_click_move = _is_click_path;
			TileMovement_PulseWalkAnim();
		};
		
		TileMovement_TryKeyboardStep = function(_input_x, _input_y) {
			if (moving || IsDialogueBlockingInput()) {
				return false;
			}
			if (_input_x == 0 && _input_y == 0) {
				return false;
			}
			var _next_x = x + _input_x * tile_size;
			var _next_y = y + _input_y * tile_size;
			if (TileMovement_IsStepBlocked(_next_x, _next_y)) {
				return false;
			}
			TileMovement_BeginStep(_next_x, _next_y, _input_x, _input_y, false);
			return true;
		};
		
		TileMovement_AdvanceClickStep = function() {
			if (moving) {
				return false;
			}
			while (click_path_index < array_length(click_path)) {
				var _step = click_path[click_path_index];
				if (point_distance(x, y, _step.x, _step.y) < 1) {
					click_path_index += 1;
					continue;
				}
				if (TileMovement_IsStepBlocked(_step.x, _step.y)) {
					TileMovement_ClearClickPath();
					if (instance_exists(obj_controller)) {
						obj_controller.ClearPendingInteraction(id);
					}
					return false;
				}
				var _step_x = sign(_step.x - x);
				var _step_y = sign(_step.y - y);
				TileMovement_BeginStep(_step.x, _step.y, _step_x, _step_y, true);
				return true;
			}
			TileMovement_ClearClickPath();
			return false;
		};
		
		// Redirect mid-lerp waits for tile land — avoids snapping x/y when the player retargets.
		TileMovement_SetPath = function(_path_points) {
			buffer_x = 0;
			buffer_y = 0;
			queued_keyboard_x = 0;
			queued_keyboard_y = 0;
			queued_click_path = [];
			if (array_length(_path_points) <= 0) {
				if (!moving) {
					TileMovement_ClearClickPath();
				}
				return;
			}
			if (moving) {
				queued_click_path = _path_points;
				click_path = [];
				click_path_index = 0;
				pending_click_move = true;
			} else {
				click_path = _path_points;
				click_path_index = 0;
				pending_click_move = true;
				TileMovement_AdvanceClickStep();
			}
		};
		
		#endregion
		
		#region Tile Landed
		
		// Tile boundary is the only place queued paths, WASD overrides, and held keys reconcile.
		TileMovement_OnTileLanded = function(_input_x, _input_y) {
			x = target_x;
			y = target_y;
			moving = false;
			if (array_length(click_path) > 0 && click_path_index >= array_length(click_path) - 1) {
				click_path = [];
				click_path_index = 0;
				pending_click_move = false;
				if (pending_click_target != noone && (!instance_exists(pending_click_target) || !obj_controller.IsInInteractionRange(id, pending_click_target, 1))) {
					if (instance_exists(obj_controller)) {
						obj_controller.ClearPendingInteraction(id);
					} else {
						pending_click_target = noone;
						pending_click_action = "";
						pending_click_action_label = "";
					}
				}
			} else if (array_length(click_path) > 0) {
				click_path_index += 1;
			}
			if (queued_keyboard_x != 0 || queued_keyboard_y != 0) {
				var _qx = queued_keyboard_x;
				var _qy = queued_keyboard_y;
				queued_keyboard_x = 0;
				queued_keyboard_y = 0;
				keyboard_hold_frames = 0;
				TileMovement_ClearClickPath();
				if (instance_exists(obj_controller)) {
					obj_controller.CancelClickMove(id);
				}
				TileMovement_TryKeyboardStep(_qx, _qy);
				return;
			}
			if (array_length(queued_click_path) > 0) {
				click_path = queued_click_path;
				queued_click_path = [];
				click_path_index = 0;
				pending_click_move = true;
				TileMovement_AdvanceClickStep();
				return;
			}
			if (array_length(click_path) > 0) {
				TileMovement_AdvanceClickStep();
				return;
			}
			if (!IsDialogueBlockingInput() && (_input_x != 0 || _input_y != 0) && (buffer_x != 0 || buffer_y != 0)
				&& keyboard_hold_frames >= movement_tick_length) {
				TileMovement_TryKeyboardStep(buffer_x, buffer_y);
			}
			if (_input_x == 0 && _input_y == 0) {
				buffer_x = 0;
				buffer_y = 0;
				keyboard_hold_frames = 0;
			}
		};
		
		#endregion
		
		#region Step Events
		
		StepMovement_HandleKeyboardBuffer = function() {
			var input_x = 0;
			var input_y = 0;
			if (!IsDialogueBlockingInput()) {
				input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
				input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
			}
			if (input_x == 0 && input_y == 0) {
				keyboard_hold_frames = 0;
				return;
			}
			keyboard_hold_frames += 1;
			var key_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("A"))
				|| keyboard_check_pressed(ord("S")) || keyboard_check_pressed(ord("D"));
			var interrupting_click_move = array_length(click_path) > 0 || array_length(queued_click_path) > 0 || pending_click_move;
			if (moving && interrupting_click_move) {
				queued_keyboard_x = input_x;
				queued_keyboard_y = input_y;
				TileMovement_ClearClickPath();
				if (instance_exists(obj_controller)) {
					obj_controller.CancelClickMove(id);
				}
			} else if (moving) {
				buffer_x = input_x;
				buffer_y = input_y;
			} else {
				buffer_x = input_x;
				buffer_y = input_y;
				if (key_pressed) {
					pending_keyboard_step = true;
					keyboard_hold_frames = 1;
				}
			}
		};
		
		StepMovement = function() {
			var input_x = 0;
			var input_y = 0;
			if (!IsDialogueBlockingInput()) {
				input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
				input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
			}
			if (!moving && !IsDialogueBlockingInput() && pending_keyboard_step) {
				pending_keyboard_step = false;
				if (buffer_x != 0 || buffer_y != 0) {
					TileMovement_TryKeyboardStep(buffer_x, buffer_y);
				}
				keyboard_hold_frames = 1;
			}
			if (IsDialogueBlockingInput()) {
				CancelActiveMovement();
			} else if (moving) {
				var dist = point_distance(x, y, target_x, target_y);
				if (dist <= move_speed) {
					TileMovement_OnTileLanded(input_x, input_y);
				} else {
					var dir = point_direction(x, y, target_x, target_y);
					x += lengthdir_x(move_speed, dir);
					y += lengthdir_y(move_speed, dir);
				}
			} else {
				SnapToCurrentTile();
			}
		};
		
		#endregion
		
		#region Collision Helper
		
		TileBlockedByObject = function(_tile_x, _tile_y, _object) {
			for (var _i = 0; _i < instance_number(_object); _i++) {
				var _tile_inst = instance_find(_object, _i);
				if (InstanceTileX(_tile_inst) == _tile_x && InstanceTileY(_tile_inst) == _tile_y) {
					return true;
				}
			}
			return false;
		};
		
		#endregion
	}
}
