/// @description Variables

myItems = ds_grid_create(0, Item.Height);

currentItem = undefined;
currentItemSlot = undefined;
hoveredItemSlot = undefined;
menuTabInventory = 0;
menuTabSpells = 1;
menuTabQuests = 2;
selectedMenuTab = menuTabInventory;
menuWidth = 6;
menuHeight = 48;
itemSeperation = 38;
itemScale = 2;
sortType = SortType.Name;

draggedItem = undefined;
draggingItem = false;
draggedItemSlot = undefined;

maxInventorySlots = 40;

itemLocked = false;
lockedItemX = undefined;
lockedItemY = undefined;
window_set_cursor(cr_none);

menu_open = false;
menu_target = noone;
menu_world_x = 0;
menu_world_y = 0;
menu_actions = [];
menu_width = 132;
menu_option_height = 22;
interaction_range_tiles = 1;

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

FormatTargetPrompt = function(_prefix, _target) {
	if (!instance_exists(_target)) {
		return "";
	}
	
	if (_target.object_index == obj_npc) {
		return _prefix + " to talk to " + _target.npc_name;
	}
	
	if (_target.object_index == obj_resource && !_target.depleted) {
		var action_text = string_lower(_target.resource_action);
		var connector = " ";
		if (action_text == "swing pickaxe" || action_text == "smelt") {
			connector = " at ";
		}
		return _prefix + " to " + action_text + connector + _target.resource_name;
	}
	
	return "";
};

if (!variable_global_exists("quest_woodcutting_state")) {
	global.quest_woodcutting_state = 0;
}
if (!variable_global_exists("quest_woodcutting_required_logs")) {
	global.quest_woodcutting_required_logs = 5;
}
if (!variable_global_exists("welcomer_approval_started")) {
	global.welcomer_approval_started = false;
}
if (!variable_global_exists("welcomer_woodcutting_approved")) {
	global.welcomer_woodcutting_approved = false;
}
if (!variable_global_exists("welcomer_woodcutting_acknowledged")) {
	global.welcomer_woodcutting_acknowledged = false;
}

StartWoodcuttingQuest = function() {
	if (global.quest_woodcutting_state == 0) {
		global.quest_woodcutting_state = 1;
	}
};

GetWoodcuttingQuestProgress = function() {
	return clamp(GetItemAmount(myItems, "Normal Log"), 0, global.quest_woodcutting_required_logs);
};

CanCompleteWoodcuttingQuest = function() {
	return global.quest_woodcutting_state == 1 && GetWoodcuttingQuestProgress() >= global.quest_woodcutting_required_logs;
};

CompleteWoodcuttingQuest = function() {
	if (!CanCompleteWoodcuttingQuest()) {
		return false;
	}
	if (!RemoveItem(myItems, "Normal Log", global.quest_woodcutting_required_logs)) {
		return false;
	}
	global.quest_woodcutting_state = 2;
	global.welcomer_woodcutting_approved = true;
	AddSkillXP("Woodcutting", 50);
	return true;
};

GetWoodcuttingQuestInfo = function() {
	var questState = global.quest_woodcutting_state;
	var questProgress = GetWoodcuttingQuestProgress();
	var questRequired = global.quest_woodcutting_required_logs;
	var questProgressAmount = clamp(questProgress / max(1, questRequired), 0, 1);
	var questStatus = "Not Started";
	var questObjective = "Speak with the Welcomer.";
	var questReturnTo = "Welcomer";
	var questRewards = "Bronze Axe + 50 WC XP + approval";
	
	if (global.welcomer_approval_started && questState == 0) {
		questObjective = "Speak with the Woodcutting Trainer.";
		questReturnTo = "Woodcutting Trainer";
	}
	
	if (questState == 1) {
		questStatus = "Active";
		questReturnTo = "Woodcutting Trainer";
		
		if (questProgress >= questRequired) {
			questObjective = "Return the logs.";
		} else {
			questObjective = "Collect " + string(questRequired) + " Normal Logs.";
		}
	}
	
	if (questState == 2) {
		questStatus = "Complete";
		questProgress = questRequired;
		questProgressAmount = 1;
		questObjective = "Report back to the Welcomer.";
		questReturnTo = "Welcomer";
		questRewards = "50 WC XP + timber approval earned";
		
		if (global.welcomer_woodcutting_acknowledged) {
			questObjective = "Next: speak with the Mining Trainer.";
			questReturnTo = "Mining Trainer";
		}
	}
	
	return {
		title: "Approval: Timber Duty",
		status: questStatus,
		objective: questObjective,
		return_to: questReturnTo,
		rewards: questRewards,
		progress: questProgress,
		required: questRequired,
		progress_amount: questProgressAmount
	};
};

SnapPointToTileCenter = function(_x, _y) {
	return {
		x: (floor(_x / global.tile_size) * global.tile_size) + global.tile_size / 2,
		y: (floor(_y / global.tile_size) * global.tile_size) + global.tile_size
	};
};

IsTileWalkable = function(_tile_x, _tile_y, _avoid_objects) {
	if (argument_count < 3) {
		_avoid_objects = true;
	}
	
	var player = instance_find(obj_player, 0);
	if (!instance_exists(player)) {
		return false;
	}
	if (_tile_x < 0 || _tile_x >= room_width div global.tile_size) {
		return false;
	}
	if (_tile_y < 0 || _tile_y >= room_height div global.tile_size) {
		return false;
	}
	if (_avoid_objects) {
		if (player.TileBlockedByObject(_tile_x, _tile_y, obj_npc)) {
			return false;
		}
		if (player.TileBlockedByObject(_tile_x, _tile_y, obj_resource)) {
			return false;
		}
	}
	return true;
};

TileCenterX = function(_tile_x) {
	return (_tile_x * global.tile_size) + global.tile_size / 2;
};

TileCenterY = function(_tile_y) {
	return ((_tile_y + 1) * global.tile_size);
};

FindNearestWalkableTileToPoint = function(_x, _y, _max_radius) {
	var base_tile_x = floor(_x / global.tile_size);
	var base_tile_y = floor((_y - 1) / global.tile_size);
	if (IsTileWalkable(base_tile_x, base_tile_y)) {
		return {found: true, x: TileCenterX(base_tile_x), y: TileCenterY(base_tile_y)};
	}
	for (var r = 1; r <= _max_radius; r++) {
		for (var dx = -r; dx <= r; dx++) {
			for (var dy = -r; dy <= r; dy++) {
				if (abs(dx) != r && abs(dy) != r) continue;
				var tx = base_tile_x + dx;
				var ty = base_tile_y + dy;
				if (IsTileWalkable(tx, ty)) {
					return {found: true, x: TileCenterX(tx), y: TileCenterY(ty)};
				}
			}
		}
	}
	return {found: false, x: _x, y: _y};
};

FindPathToTile = function(_player, _dest_tile_x, _dest_tile_y, _avoid_objects) {
	if (argument_count < 4) {
		_avoid_objects = true;
	}
	
	if (!instance_exists(_player)) {
		return {found: false, points: []};
	}
	
	var grid_w = room_width div global.tile_size;
	var grid_h = room_height div global.tile_size;
	if (_dest_tile_x < 0 || _dest_tile_x >= grid_w || _dest_tile_y < 0 || _dest_tile_y >= grid_h) {
		return {found: false, points: []};
	}
	
	var start_tile_x = _player.TileXFromPosition(_player.x);
	var start_tile_y = _player.TileYFromBottom(_player.y);
	if (start_tile_x == _dest_tile_x && start_tile_y == _dest_tile_y) {
		return {found: true, points: []};
	}
	if (!IsTileWalkable(_dest_tile_x, _dest_tile_y, _avoid_objects)) {
		return {found: false, points: []};
	}
	
	var visited = ds_grid_create(grid_w, grid_h);
	var parent_x = ds_grid_create(grid_w, grid_h);
	var parent_y = ds_grid_create(grid_w, grid_h);
	ds_grid_set_region(visited, 0, 0, grid_w - 1, grid_h - 1, false);
	ds_grid_set_region(parent_x, 0, 0, grid_w - 1, grid_h - 1, -1);
	ds_grid_set_region(parent_y, 0, 0, grid_w - 1, grid_h - 1, -1);
	
	var frontier = ds_queue_create();
	visited[# start_tile_x, start_tile_y] = true;
	ds_queue_enqueue(frontier, start_tile_y * grid_w + start_tile_x);
	
	var found = false;
	while (!ds_queue_empty(frontier)) {
		var current = ds_queue_dequeue(frontier);
		var cx = current mod grid_w;
		var cy = current div grid_w;
		
		if (cx == _dest_tile_x && cy == _dest_tile_y) {
			found = true;
			break;
		}
		
		var preferred_x = sign(_dest_tile_x - cx);
		var preferred_y = sign(_dest_tile_y - cy);
		var directions = [
			{dx: preferred_x, dy: preferred_y},
			{dx: preferred_x, dy: 0},
			{dx: 0, dy: preferred_y},
			{dx: preferred_x, dy: -preferred_y},
			{dx: -preferred_x, dy: preferred_y},
			{dx: -preferred_x, dy: 0},
			{dx: 0, dy: -preferred_y},
			{dx: -preferred_x, dy: -preferred_y},
			{dx: 1, dy: 0},
			{dx: -1, dy: 0},
			{dx: 0, dy: 1},
			{dx: 0, dy: -1},
			{dx: 1, dy: 1},
			{dx: 1, dy: -1},
			{dx: -1, dy: 1},
			{dx: -1, dy: -1}
		];
		
		for (var dir_index = 0; dir_index < array_length(directions); dir_index++) {
			var dx = directions[dir_index].dx;
			var dy = directions[dir_index].dy;
			if (dx == 0 && dy == 0) {
				continue;
			}
			
			var nx = cx + dx;
			var ny = cy + dy;
				if (nx < 0 || nx >= grid_w || ny < 0 || ny >= grid_h) {
					continue;
				}
				if (visited[# nx, ny]) {
					continue;
				}
				if (!IsTileWalkable(nx, ny, _avoid_objects)) {
					continue;
				}
				
				visited[# nx, ny] = true;
				parent_x[# nx, ny] = cx;
				parent_y[# nx, ny] = cy;
			ds_queue_enqueue(frontier, ny * grid_w + nx);
		}
	}
	
	var points = [];
	if (found) {
		var reverse_points = [];
		var path_x = _dest_tile_x;
		var path_y = _dest_tile_y;
		
		while (!(path_x == start_tile_x && path_y == start_tile_y)) {
			array_push(reverse_points, {x: TileCenterX(path_x), y: TileCenterY(path_y)});
			
			var next_path_x = parent_x[# path_x, path_y];
			var next_path_y = parent_y[# path_x, path_y];
			path_x = next_path_x;
			path_y = next_path_y;
		}
		
		for (var point_index = array_length(reverse_points) - 1; point_index >= 0; point_index--) {
			array_push(points, reverse_points[point_index]);
		}
	}
	
	ds_queue_destroy(frontier);
	ds_grid_destroy(visited);
	ds_grid_destroy(parent_x);
	ds_grid_destroy(parent_y);
	
	return {found: found, points: points};
};

StartTilePathMove = function(_player, _path_points) {
	if (!instance_exists(_player)) {
		return false;
	}
	
	with (_player) {
		click_path = _path_points;
		click_path_index = 0;
		buffer_x = 0;
		buffer_y = 0;
		
		if (array_length(click_path) <= 0) {
			moving = false;
			pending_click_move = false;
		} else {
			var first_step = click_path[0];
			target_x = first_step.x;
			target_y = first_step.y;
			move_x = sign(target_x - x);
			move_y = sign(target_y - y);
			SetFacingFromVector(move_x, move_y);
			moving = true;
			pending_click_move = true;
		}
	}
	
	return true;
};

IsInInteractionRange = function(_a, _b, _tiles) {
	if (!instance_exists(_a) || !instance_exists(_b)) {
		return false;
	}
	
	var tile_helper = instance_find(obj_player, 0);
	if (!instance_exists(tile_helper)) {
		return point_distance(_a.x, _a.y, _b.x, _b.y) <= (_tiles * global.tile_size);
	}
	
	var ax = tile_helper.InstanceTileX(_a);
	var ay = tile_helper.InstanceTileY(_a);
	var bx = tile_helper.InstanceTileX(_b);
	var by = tile_helper.InstanceTileY(_b);
	return max(abs(ax - bx), abs(ay - by)) <= _tiles;
};

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
	menu_x = clamp(menu_x, view_left + 4, max(view_left + 4, view_right - menu_width - 4));
	menu_y = clamp(menu_y, view_top + 4, max(view_top + 4, view_bottom - menu_h - 4));
	return {x: menu_x, y: menu_y, w: menu_width, h: menu_h, option_h: menu_option_height};
};

GetInteractTargetAtPoint = function(_mx, _my) {
	var best = noone;
	var best_depth = 1000000;
	var candidates = [obj_npc, obj_resource];
	for (var c = 0; c < array_length(candidates); c++) {
		var obj = candidates[c];
		for (var i = 0; i < instance_number(obj); i++) {
			var inst = instance_find(obj, i);
			if (obj == obj_resource && inst.depleted) {
				continue;
			}
			if (!position_meeting(_mx, _my, inst)) {
				continue;
			}
			if (inst.depth < best_depth) {
				best = inst;
				best_depth = inst.depth;
			}
		}
	}
	return best;
};

StartMoveToPoint = function(_player, _x, _y) {
	var dest = FindNearestWalkableTileToPoint(_x, _y, 3);
	if (!dest.found) {
		return false;
	}
	var dest_tile_x = floor(dest.x / global.tile_size);
	var dest_tile_y = floor((dest.y - 1) / global.tile_size);
	var path = FindPathToTile(_player, dest_tile_x, dest_tile_y, true);
	if (!path.found) {
		return false;
	}
	with (_player) {
		pending_click_target = noone;
		pending_click_action = "";
		pending_click_action_label = "";
	}
	return StartTilePathMove(_player, path.points);
};

StartMoveToInteractTarget = function(_player, _target, _range_tiles) {
	if (!instance_exists(_target)) {
		return false;
	}
	var target_tile_x = _player.InstanceTileX(_target);
	var target_tile_y = _player.InstanceTileY(_target);
	var search_radius = max(1, _range_tiles);
	var best_path = [];
	var best_found = false;
	var best_length = 100000000;
	var best_distance = 100000000;
	
	for (var dx = -search_radius; dx <= search_radius; dx++) {
		for (var dy = -search_radius; dy <= search_radius; dy++) {
			if (dx == 0 && dy == 0) {
				continue;
			}
			
			var tx = target_tile_x + dx;
			var ty = target_tile_y + dy;
			if (!IsTileWalkable(tx, ty)) {
				continue;
			}
			
			var candidate_path = FindPathToTile(_player, tx, ty, true);
			if (!candidate_path.found) {
				continue;
			}
			
			var candidate_length = array_length(candidate_path.points);
			var candidate_distance = point_distance(_player.x, _player.y, TileCenterX(tx), TileCenterY(ty));
			if (!best_found || candidate_length < best_length || (candidate_length == best_length && candidate_distance < best_distance)) {
				best_found = true;
				best_length = candidate_length;
				best_distance = candidate_distance;
				best_path = candidate_path.points;
			}
		}
	}
	
	if (!best_found) {
		return false;
	}
	with (_player) {
		pending_click_target = _target;
		pending_click_action = "";
		pending_click_action_label = "";
	}
	return StartTilePathMove(_player, best_path);
};

BeginInteractionMove = function(_player, _target, _action, _label) {
	if (!instance_exists(_target)) return false;
	with (_player) {
		pending_click_target = _target;
		pending_click_action = _action;
		pending_click_action_label = _label;
		pending_click_move = false;
	}
	return true;
};

ClearPendingInteraction = function(_player) {
	with (_player) {
		pending_click_target = noone;
		pending_click_action = "";
		pending_click_action_label = "";
		pending_click_move = false;
	}
};

OpenContextMenu = function(_target, _x, _y) {
	menu_open = true;
	menu_target = _target;
	menu_world_x = _x;
	menu_world_y = _y;
	menu_actions = [{ label: "Move here", action: "move_here" }];
	if (instance_exists(_target)) {
		if (_target.object_index == obj_npc) {
			menu_actions = [
				{ label: "Talk-to", action: "npc_talk" },
				{ label: "Move here", action: "move_here" }
			];
		} else if (_target.object_index == obj_resource && !_target.depleted) {
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
		with (_player) {
			pending_click_target = noone;
			pending_click_action = "";
			pending_click_action_label = "";
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
		with (target) {
			interact(_player);
		}
		return true;
	}
	
	if (StartMoveToInteractTarget(_player, target, 1)) {
		with (_player) {
			pending_click_target = target;
			pending_click_action = action_name;
			pending_click_action_label = action_label;
			pending_click_move = true;
		}
		return true;
	}
	
	return false;
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
	
	draw_set_alpha(0.9);
	draw_set_color(c_black);
	draw_rectangle(panelX, panelY, panelX + panelWidth, panelY + panelHeight, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(panelX, panelY, panelX + panelWidth, panelY + panelHeight, true);
	
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


