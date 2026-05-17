if (!instance_exists(target) || (target.object_index == obj_resource && target.depleted)) {
	if (instance_exists(obj_controller)) {
		with (obj_controller) {
			CloseContextMenu();
		}
	}
	instance_destroy();
}

if (ignore_close_frames > 0) {
	ignore_close_frames -= 1;
}

if (!menu_ready) {
	actions = [];
	if (instance_exists(target)) {
		if (target.object_index == obj_npc) {
			actions = [{ label: "Talk-to", action: "npc_talk" }];
		} else if (target.object_index == obj_resource && !target.depleted) {
			var label = target.resource_skill == "Woodcutting" ? "Chop down" : "Mine";
			actions = [{ label: label, action: "resource_use" }];
		}
	}
	menu_ready = true;
	if (array_length(actions) == 0) {
		if (instance_exists(obj_controller)) {
			with (obj_controller) {
				CloseContextMenu();
			}
		}
		instance_destroy();
	}
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var left = menu_x;
var top = menu_y;
var total_h = array_length(actions) * option_h;

menu_x = clamp(menu_x, 0, max(0, gui_w - width));
menu_y = clamp(menu_y, 0, max(0, gui_h - total_h));
left = menu_x;
top = menu_y;

hover_index = -1;
for (var i = 0; i < array_length(actions); i++) {
	var y1 = top + i * option_h;
	var y2 = y1 + option_h;
	if (point_in_rectangle(mx, my, left, y1, left + width, y2)) {
		hover_index = i;
	}
}

if (mouse_check_button_pressed(mb_left)) {
	if (hover_index >= 0) {
		var action = actions[hover_index];
		if (is_struct(action) && variable_struct_exists(action, "action")) {
			var player = instance_find(obj_player, 0);
			if (instance_exists(player) && instance_exists(target)) {
				if (action.action == "npc_talk") {
					if (point_distance(player.x, player.y, target.x, target.y) <= global.tile_size) {
						with (target) {
							interact(player);
						}
					} else if (instance_exists(obj_controller)) {
						if (obj_controller.StartMoveToInteractTarget(player, target, 1)) {
							player.pending_click_target = target;
							player.pending_click_action = "npc_talk";
							player.pending_click_action_label = "Talk-to";
							player.pending_click_move = true;
						}
					}
				} else if (action.action == "resource_use") {
					if (point_distance(player.x, player.y, target.x, target.y) <= global.tile_size) {
						with (target) {
							interact(player);
						}
					} else if (instance_exists(obj_controller)) {
						if (obj_controller.StartMoveToInteractTarget(player, target, 1)) {
							player.pending_click_target = target;
							player.pending_click_action = "resource_use";
							player.pending_click_action_label = target.resource_action;
							player.pending_click_move = true;
						}
					}
				}
			}
		}
		if (instance_exists(obj_controller)) {
			with (obj_controller) {
				CloseContextMenu();
			}
		}
		instance_destroy();
	} else {
		if (instance_exists(obj_controller)) {
			with (obj_controller) {
				CloseContextMenu();
			}
		}
		instance_destroy();
	}
}

if (mouse_check_button_pressed(mb_right)) {
	if (ignore_close_frames <= 0) {
		if (instance_exists(obj_controller)) {
			with (obj_controller) {
				CloseContextMenu();
			}
		}
		instance_destroy();
	}
}
