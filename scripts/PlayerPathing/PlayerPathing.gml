/// @description Click-to-walk path queue on the player; controller BFS feeds points via PlayerPathing_SetPath.

function PlayerPathing_Register(_inst) {
	with (_inst) {
		
		PlayerPathing_ClearClickPath = function() {
			click_path = [];
			click_path_index = 0;
			queued_click_path = [];
			pending_click_move = false;
		};
		
		PlayerPathing_AdvanceClickStep = function() {
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
					PlayerPathing_ClearClickPath();
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
			PlayerPathing_ClearClickPath();
			return false;
		};
		
		// Redirect mid-lerp waits for tile land — avoids snapping x/y when the player retargets.
		PlayerPathing_SetPath = function(_path_points) {
			buffer_x = 0;
			buffer_y = 0;
			queued_keyboard_x = 0;
			queued_keyboard_y = 0;
			queued_click_path = [];
			if (array_length(_path_points) <= 0) {
				if (!moving) {
					PlayerPathing_ClearClickPath();
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
				PlayerPathing_AdvanceClickStep();
			}
		};
		
		// Called from TileMovement_OnTileLanded after x/y snap. Returns true if pathing consumed the landing.
		PlayerPathing_OnTileLanded = function() {
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
			if (array_length(queued_click_path) > 0) {
				click_path = queued_click_path;
				queued_click_path = [];
				click_path_index = 0;
				pending_click_move = true;
				PlayerPathing_AdvanceClickStep();
				return true;
			}
			if (array_length(click_path) > 0) {
				PlayerPathing_AdvanceClickStep();
				return true;
			}
			return false;
		};
		
		PlayerPathing_HasActivePath = function() {
			return array_length(click_path) > 0 || array_length(queued_click_path) > 0 || pending_click_move;
		};
	}
}
