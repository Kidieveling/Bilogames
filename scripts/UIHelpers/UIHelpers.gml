/// @description Fixed HUD hit tests, interact-target picking, and inventory hover panels; bound on obj_controller.

function UIHelpers_Register(_inst) {
	with (_inst) {
		
		#region Fixed UI Hit Test
		
		// Same layout math as Draw_0 / Step_0 so clicks on the panel never reach world pathing.
		
		GetFixedUIRect = function() {
			var viewWidth = room_width;
			var viewHeight = room_height;
			if (view_camera[0] >= 0) {
				viewWidth = camera_get_view_width(view_camera[0]);
				viewHeight = camera_get_view_height(view_camera[0]);
			}
			
			var menuMargin = 16;
			var menuLeft = CameraX() + viewWidth - 296 - menuMargin;
			var menuTop = CameraY() + viewHeight - 296 - menuMargin + 18;
			var tabTop = menuTop - 27;
			var tabBottom = tabTop + 28;
			var tabLeft = menuLeft + 22;
			var tabRight = tabLeft + 80 + 8 + 72 + 8 + 72;
			var skillBarX = CameraMiddleX();
			var skillBarY = CameraY() + viewHeight - sprite_get_yoffset(spr_skillBar) - 12;
			var skillBarLeft = skillBarX - sprite_get_xoffset(spr_skillBar);
			var skillBarTop = skillBarY - sprite_get_yoffset(spr_skillBar) - 22;
			var skillBarRight = skillBarLeft + sprite_get_width(spr_skillBar);
			var skillBarBottom = skillBarY - sprite_get_yoffset(spr_skillBar) + sprite_get_height(spr_skillBar);
			
			return {
				panel_x1: menuLeft,
				panel_y1: menuTop,
				panel_x2: menuLeft + 296,
				panel_y2: menuTop + 296,
				tab_x1: tabLeft,
				tab_y1: tabTop,
				tab_x2: tabRight,
				tab_y2: tabBottom,
				skill_x1: skillBarLeft,
				skill_y1: skillBarTop,
				skill_x2: skillBarRight,
				skill_y2: skillBarBottom
			};
		};
		IsMouseOverFixedUI = function(_mx, _my) {
			var ui = GetFixedUIRect();
			if (point_in_rectangle(_mx, _my, ui.panel_x1, ui.panel_y1, ui.panel_x2, ui.panel_y2)) {
				return true;
			}
			if (point_in_rectangle(_mx, _my, ui.tab_x1, ui.tab_y1, ui.tab_x2, ui.tab_y2)) {
				return true;
			}
			if (point_in_rectangle(_mx, _my, ui.skill_x1, ui.skill_y1, ui.skill_x2, ui.skill_y2)) {
				return true;
			}
			return false;
		};
		
		#endregion
		
		#region Target Classification
		
		FormatTargetPrompt = function(_prefix, _target) {
			if (!instance_exists(_target)) {
				return "";
			}
			
			if (IsNpcTarget(_target)) {
				return _prefix + " to talk to " + _target.npc_name;
			}
			
			if (IsResourceTarget(_target) && !_target.depleted) {
				var action_text = string_lower(_target.resource_action);
				var connector = " ";
				if (action_text == "swing pickaxe" || action_text == "smelt") {
					connector = " at ";
				}
				return _prefix + " to " + action_text + connector + _target.resource_name;
			}
			
			return "";
		};
		ArrayContainsValue = function(_array, _value) {
			for (var i = 0; i < array_length(_array); i++) {
				if (_array[i] == _value) {
					return true;
				}
			}
			return false;
		};
		IsNpcTarget = function(_target) {
			return instance_exists(_target) && object_is_ancestor(_target.object_index, obj_npc);
		};
		IsResourceTarget = function(_target) {
			return instance_exists(_target) && object_is_ancestor(_target.object_index, obj_resource);
		};
		FaceNpcTowardPlayer = function(_target, _player) {
			if (!instance_exists(_target) || !instance_exists(_player)) {
				return;
			}
			if (variable_instance_exists(_target, "FaceTowardInstance")) {
				_target.FaceTowardInstance(_player);
			}
		};
		GetInteractTargetAtPoint = function(_mx, _my) {
			var best = noone;
			var best_depth = 1000000;
			var candidates = [obj_npc, obj_resource];
			
			for (var c = 0; c < array_length(candidates); c++) {
				var obj = candidates[c];
				for (var i = 0; i < instance_number(obj); i++) {
					var inst = instance_find(obj, i);
					if (object_is_ancestor(inst.object_index, obj_resource) && inst.depleted) {
						continue;
					}
					if (!position_meeting(_mx, _my, inst)) {
						continue;
					}
					// Lower depth draws on top; pick the visually frontmost stack at the click.
					if (inst.depth < best_depth) {
						best = inst;
						best_depth = inst.depth;
					}
				}
			}
			return best;
		};
		
		#endregion
		
		#region Hover Tooltip
		
		DrawHoverItemDetails = function(_item) {
			if (_item == undefined || _item == noone) {
				return;
			}
			
			var viewWidth = room_width;
			var viewHeight = room_height;
			if (view_camera[0] >= 0) {
				viewWidth = camera_get_view_width(view_camera[0]);
				viewHeight = camera_get_view_height(view_camera[0]);
			}
			
			var panelWidth = 210;
			var panelHeight = 126;
			var panelGap = 12;
			var viewLeft = CameraX();
			var viewTop = CameraY();
			var viewRight = viewLeft + viewWidth;
			var viewBottom = viewTop + viewHeight;
			var panelX = mouse_x + panelGap;
			var panelY = mouse_y + panelGap;
			
			if (panelX + panelWidth > viewRight - 8) {
				panelX = mouse_x - panelWidth - panelGap;
			}
			if (panelY + panelHeight > viewBottom - 8) {
				panelY = mouse_y - panelHeight - panelGap;
			}
			
			panelX = clamp(panelX, viewLeft + 8, viewRight - panelWidth - 8);
			panelY = clamp(panelY, viewTop + 8, viewBottom - panelHeight - 8);
			
			UI_DrawBorderedPanel(panelX, panelY, panelX + panelWidth, panelY + panelHeight, c_black, 0.9, c_white, 1);
			
			draw_set_font(fntSmaller);
			draw_set_color(c_white);
			draw_text(panelX + 10, panelY + 8, _item.name);
			draw_text(panelX + 10, panelY + 28, GetItemTypeName(_item.type) + "  |  " + string(_item.price) + " gold");
			
			if (variable_instance_exists(_item, "damage") && _item.damage != undefined) {
				draw_text(panelX + 10, panelY + 48, "Damage: " + string(_item.damage));
			}
			if (variable_instance_exists(_item, "defense") && _item.defense != undefined) {
				draw_text(panelX + 10, panelY + 48, "Defense: " + string(_item.defense));
			}
			
			if (variable_instance_exists(_item, "description") && _item.description != undefined) {
				draw_text_ext(panelX + 10, panelY + 70, _item.description, 16, panelWidth - 20);
			}
		};
		GetItemTypeName = function(_type) {
			switch (_type) {
				case Type.Weapon: return "Weapon";
				case Type.Armor: return "Armor";
				case Type.Tool: return "Tool";
				case Type.Resource: return "Resource";
				case Type.Consumable: return "Consumable";
			}
			return "Item";
		};
		
		#endregion
	}
}
