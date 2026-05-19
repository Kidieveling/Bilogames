/// @description Variables

GameState_Init();

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

TileBlockedByNpc = function(_tile_x, _tile_y) {
	var player = instance_find(obj_player, 0);
	if (!instance_exists(player)) {
		return false;
	}
	
	return player.TileBlockedByObject(_tile_x, _tile_y, obj_npc);
};

GetNearestNpcTarget = function(_x, _y) {
	var nearest = noone;
	var nearest_distance = 100000000;
	
	for (var i = 0; i < instance_number(obj_npc); i++) {
		var inst = instance_find(obj_npc, i);
		var dist = point_distance(_x, _y, inst.x, inst.y);
		if (dist < nearest_distance) {
			nearest = inst;
			nearest_distance = dist;
		}
	}
	
	return nearest;
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
		if (TileBlockedByNpc(_tile_x, _tile_y)) {
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

BuildPathPointsFromParents = function(_start_tile_x, _start_tile_y, _dest_tile_x, _dest_tile_y, _parent_x, _parent_y) {
	var points = [];
	if (_start_tile_x == _dest_tile_x && _start_tile_y == _dest_tile_y) {
		return points;
	}
	
	var reverse_points = [];
	var path_x = _dest_tile_x;
	var path_y = _dest_tile_y;
	
	while (!(path_x == _start_tile_x && path_y == _start_tile_y)) {
		array_push(reverse_points, {x: TileCenterX(path_x), y: TileCenterY(path_y)});
		var next_path_x = _parent_x[# path_x, path_y];
		var next_path_y = _parent_y[# path_x, path_y];
		path_x = next_path_x;
		path_y = next_path_y;
	}
	
	for (var point_index = array_length(reverse_points) - 1; point_index >= 0; point_index--) {
		array_push(points, reverse_points[point_index]);
	}
	
	return points;
};

RunWalkabilityBFS = function(_player, _avoid_objects) {
	if (argument_count < 2) {
		_avoid_objects = true;
	}
	
	if (!instance_exists(_player)) {
		return { ok: false };
	}
	
	var grid_w = room_width div global.tile_size;
	var grid_h = room_height div global.tile_size;
	var start_tile_x = _player.TileXFromPosition(_player.x);
	var start_tile_y = _player.TileYFromBottom(_player.y);
	start_tile_x = clamp(start_tile_x, 0, grid_w - 1);
	start_tile_y = clamp(start_tile_y, 0, grid_h - 1);
	
	var visited = ds_grid_create(grid_w, grid_h);
	var parent_x = ds_grid_create(grid_w, grid_h);
	var parent_y = ds_grid_create(grid_w, grid_h);
	var dist = ds_grid_create(grid_w, grid_h);
	ds_grid_set_region(visited, 0, 0, grid_w - 1, grid_h - 1, false);
	ds_grid_set_region(parent_x, 0, 0, grid_w - 1, grid_h - 1, -1);
	ds_grid_set_region(parent_y, 0, 0, grid_w - 1, grid_h - 1, -1);
	ds_grid_set_region(dist, 0, 0, grid_w - 1, grid_h - 1, -1);
	
	var frontier = ds_queue_create();
	visited[# start_tile_x, start_tile_y] = true;
	dist[# start_tile_x, start_tile_y] = 0;
	ds_queue_enqueue(frontier, start_tile_y * grid_w + start_tile_x);
	
	// Cardinals first, then diagonals: shortest step count still uses diagonals when they reduce distance;
	// straight horizontal/vertical routes stay cardinal instead of zigzag diagonals.
	var neighbor_dx = [1, -1, 0, 0, 1, 1, -1, -1];
	var neighbor_dy = [0, 0, 1, -1, 1, -1, 1, -1];
	
	while (!ds_queue_empty(frontier)) {
		var current = ds_queue_dequeue(frontier);
		var cx = current mod grid_w;
		var cy = current div grid_w;
		var current_dist = dist[# cx, cy];
		
		for (var dir_index = 0; dir_index < array_length(neighbor_dx); dir_index++) {
			var ndx = neighbor_dx[dir_index];
			var ndy = neighbor_dy[dir_index];
			var nx = cx + ndx;
			var ny = cy + ndy;
			if (nx < 0 || nx >= grid_w || ny < 0 || ny >= grid_h) {
				continue;
			}
			if (visited[# nx, ny]) {
				continue;
			}
			if (!IsTileWalkable(nx, ny, _avoid_objects)) {
				continue;
			}
			// Diagonal steps require both adjacent cardinal tiles walkable (no corner cutting).
			if (ndx != 0 && ndy != 0) {
				if (!IsTileWalkable(cx + ndx, cy, _avoid_objects) || !IsTileWalkable(cx, cy + ndy, _avoid_objects)) {
					continue;
				}
			}
			
			visited[# nx, ny] = true;
			parent_x[# nx, ny] = cx;
			parent_y[# nx, ny] = cy;
			dist[# nx, ny] = current_dist + 1;
			ds_queue_enqueue(frontier, ny * grid_w + nx);
		}
	}
	
	ds_queue_destroy(frontier);
	
	return {
		ok: true,
		grid_w: grid_w,
		grid_h: grid_h,
		start_tile_x: start_tile_x,
		start_tile_y: start_tile_y,
		visited: visited,
		parent_x: parent_x,
		parent_y: parent_y,
		dist: dist
	};
};

FindBestPathTowardWorldPoint = function(_player, _world_x, _world_y, _avoid_objects) {
	if (argument_count < 4) {
		_avoid_objects = true;
	}
	
	var bfs = RunWalkabilityBFS(_player, _avoid_objects);
	if (!bfs.ok) {
		return { found: false, points: [] };
	}
	
	var grid_w = bfs.grid_w;
	var grid_h = bfs.grid_h;
	var start_tile_x = bfs.start_tile_x;
	var start_tile_y = bfs.start_tile_y;
	var visited = bfs.visited;
	var parent_x = bfs.parent_x;
	var parent_y = bfs.parent_y;
	var dist = bfs.dist;
	
	var best_found = false;
	var best_dest_x = -1;
	var best_dest_y = -1;
	var best_d_click = 100000000;
	var best_path_len = 100000000;
	
	for (var ty = 0; ty < grid_h; ty++) {
		for (var tx = 0; tx < grid_w; tx++) {
			if (!visited[# tx, ty]) {
				continue;
			}
			
			var tcx = TileCenterX(tx);
			var tcy = TileCenterY(ty);
			var d_click = point_distance(_world_x, _world_y, tcx, tcy);
			var path_len = dist[# tx, ty];
			
			if (!best_found || d_click < best_d_click || (d_click == best_d_click && path_len < best_path_len)) {
				best_found = true;
				best_dest_x = tx;
				best_dest_y = ty;
				best_d_click = d_click;
				best_path_len = path_len;
			}
		}
	}
	
	var points = [];
	if (best_found) {
		points = BuildPathPointsFromParents(start_tile_x, start_tile_y, best_dest_x, best_dest_y, parent_x, parent_y);
	}
	
	ds_grid_destroy(visited);
	ds_grid_destroy(parent_x);
	ds_grid_destroy(parent_y);
	ds_grid_destroy(dist);
	
	return { found: best_found, points: points };
};

FindBestPathInTileRadius = function(_player, _center_tile_x, _center_tile_y, _search_radius, _avoid_objects) {
	if (argument_count < 5) {
		_avoid_objects = true;
	}
	
	var bfs = RunWalkabilityBFS(_player, _avoid_objects);
	if (!bfs.ok) {
		return {found: false, points: []};
	}
	
	var grid_w = bfs.grid_w;
	var grid_h = bfs.grid_h;
	var start_tile_x = bfs.start_tile_x;
	var start_tile_y = bfs.start_tile_y;
	var visited = bfs.visited;
	var parent_x = bfs.parent_x;
	var parent_y = bfs.parent_y;
	var dist = bfs.dist;
	
	var search_radius = max(0, _search_radius);
	var best_found = false;
	var best_dest_x = -1;
	var best_dest_y = -1;
	var best_length = 100000000;
	var best_distance = 100000000;
	
	for (var dx = -search_radius; dx <= search_radius; dx++) {
		for (var dy = -search_radius; dy <= search_radius; dy++) {
			var tx = _center_tile_x + dx;
			var ty = _center_tile_y + dy;
			if (tx < 0 || tx >= grid_w || ty < 0 || ty >= grid_h) {
				continue;
			}
			if (!visited[# tx, ty]) {
				continue;
			}
			
			var candidate_length = dist[# tx, ty];
			var candidate_distance = point_distance(_player.x, _player.y, TileCenterX(tx), TileCenterY(ty));
			if (!best_found || candidate_length < best_length || (candidate_length == best_length && candidate_distance < best_distance)) {
				best_found = true;
				best_length = candidate_length;
				best_distance = candidate_distance;
				best_dest_x = tx;
				best_dest_y = ty;
			}
		}
	}
	
	var points = [];
	if (best_found) {
		points = BuildPathPointsFromParents(start_tile_x, start_tile_y, best_dest_x, best_dest_y, parent_x, parent_y);
	}
	
	ds_grid_destroy(visited);
	ds_grid_destroy(parent_x);
	ds_grid_destroy(parent_y);
	ds_grid_destroy(dist);
	
	return {found: best_found, points: points};
};

StartTilePathMove = function(_player, _path_points) {
	if (!instance_exists(_player)) {
		return false;
	}
	
	with (_player) {
		TileMovement_SetPath(_path_points);
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
			if (object_is_ancestor(inst.object_index, obj_resource) && inst.depleted) {
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

StartMoveToAdjacentWalkableTile = function(_player, _center_tile_x, _center_tile_y, _search_radius) {
	if (!instance_exists(_player)) {
		return false;
	}
	
	var path_result = FindBestPathInTileRadius(_player, _center_tile_x, _center_tile_y, _search_radius, true);
	if (!path_result.found) {
		return false;
	}
	
	with (_player) {
		pending_click_target = noone;
		pending_click_action = "";
		pending_click_action_label = "";
	}
	return StartTilePathMove(_player, path_result.points);
};

StartMoveToPoint = function(_player, _x, _y) {
	if (!instance_exists(_player)) {
		return false;
	}
	
	var path_result = FindBestPathTowardWorldPoint(_player, _x, _y, true);
	if (!path_result.found) {
		return false;
	}
	
	with (_player) {
		pending_click_target = noone;
		pending_click_action = "";
		pending_click_action_label = "";
	}
	return StartTilePathMove(_player, path_result.points);
};

StartMoveToInteractTarget = function(_player, _target, _range_tiles, _action = "", _label = "") {
	if (!instance_exists(_target)) {
		return false;
	}
	
	var target_tile_x = _player.InstanceTileX(_target);
	var target_tile_y = _player.InstanceTileY(_target);
	var search_radius = max(1, _range_tiles);
	if (!StartMoveToAdjacentWalkableTile(_player, target_tile_x, target_tile_y, search_radius)) {
		return false;
	}
	
	with (_player) {
		pending_click_target = _target;
		pending_click_action = _action;
		pending_click_action_label = _label;
		pending_click_move = true;
	}
	return true;
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

CancelClickMove = function(_player) {
	if (!instance_exists(_player)) {
		return;
	}
	
	with (_player) {
		click_path = [];
		click_path_index = 0;
		pending_click_move = false;
		pending_click_target = noone;
		pending_click_action = "";
		pending_click_action_label = "";
	}
};

ClearPendingInteraction = function(_player) {
	CancelClickMove(_player);
};

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
	
	return StartMoveToInteractTarget(_player, target, 1, action_name, action_label);
	
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


