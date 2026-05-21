/// @description Right-click world menu: talk, gather, or move; bound on obj_controller.

function ContextMenu_Register(_inst) {
	with (_inst) {
		
		#region Menu Layout
		
		GetContextMenuRect = function() {
			var option_count = max(1, array_length(menu_actions));
			var menu_h = option_count * menu_option_height;
			var view_w = room_width;
			var view_h = room_height;
			if (view_camera[0] >= 0) {
				view_w = camera_get_view_width(view_camera[0]);
				view_h = camera_get_view_height(view_camera[0]);
			}
			var view_left = CameraX();
			var view_top = CameraY();
			var view_right = view_left + view_w;
			var view_bottom = view_top + view_h;
			var menu_x = menu_world_x - (menu_width / 2);
			var menu_y = menu_world_y - (menu_h / 2);
			// Keep the popup inside the camera view when opened near edges.
			menu_x = clamp(menu_x, view_left + 4, max(view_left + 4, view_right - menu_width - 4));
			menu_y = clamp(menu_y, view_top + 4, max(view_top + 4, view_bottom - menu_h - 4));
			return {x: menu_x, y: menu_y, w: menu_width, h: menu_h, option_h: menu_option_height};
		};
		
		#endregion
		
		#region Open And Close
		
		OpenContextMenu = function(_target, _x, _y) {
			menu_open = true;
			menu_target = _target;
			menu_world_x = _x;
			menu_world_y = _y;
			menu_actions = [{ label: "Move here", action: "move_here" }];
			if (instance_exists(_target)) {
				if (IsNpcTarget(_target)) {
					menu_actions = [
						{ label: "Talk-to", action: "npc_talk" },
						{ label: "Move here", action: "move_here" }
					];
				} else if (IsResourceTarget(_target) && !_target.depleted) {
					var label = _target.resource_skill == "Woodcutting" ? "Chop down" : "Mine";
					menu_actions = [
						{ label: label, action: "resource_use" },
						{ label: "Move here", action: "move_here" }
					];
				}
			}
			if (array_length(menu_actions) == 0) {
				menu_open = false;
				menu_target = noone;
			}
		};
		CloseContextMenu = function() {
			menu_open = false;
			menu_target = noone;
			menu_actions = [];
		};
		
		#endregion
		
		#region Menu Actions
		
		ChooseContextMenuOption = function(_player, _option_index) {
			if (!menu_open) {
				return false;
			}
			if (_option_index < 0 || _option_index >= array_length(menu_actions)) {
				return false;
			}
			
			var action = menu_actions[_option_index];
			var target = menu_target;
			var action_name = action.action;
			var action_label = action.label;
			var move_x = menu_world_x;
			var move_y = menu_world_y;
			
			CloseContextMenu();
			
			if (!instance_exists(_player)) {
				return false;
			}
			
			if (action_name == "move_here") {
				if (instance_exists(target)) {
					// Path to a walkable tile beside the target, not onto its occupied cell.
					var target_tile_x = _player.InstanceTileX(target);
					var target_tile_y = _player.InstanceTileY(target);
					return StartMoveToAdjacentWalkableTile(_player, target_tile_x, target_tile_y, 3);
				}
				return StartMoveToPoint(_player, move_x, move_y);
			}
			
			if (!instance_exists(target)) {
				return false;
			}
			
			if (IsInInteractionRange(_player, target, 1)) {
				if (action_name == "npc_talk" && variable_instance_exists(_player, "npc_talk_cooldown") && _player.npc_talk_cooldown > 0) {
					return false;
				}
				if (!_player.moving) {
					return _player.TryInteractWithTarget(target);
				}
				return false;
			}
			
			// Out of range: walk adjacent, then run the same action when the path finishes.
			return StartMoveToInteractTarget(_player, target, 1, action_name, action_label);
			
			return false;
		};
		
		#endregion
	}
}
