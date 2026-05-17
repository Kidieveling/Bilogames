/// @description Variables

myItems = ds_grid_create(0, Item.Height);

currentItem = undefined;
currentItemSlot = undefined;
hoveredItemSlot = undefined;
menuTabInventory = 0;
menuTabSpells = 1;
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

context_menu = noone;
menu_open = false;
menu_target = noone;
menu_world_x = 0;
menu_world_y = 0;
menu_gui_x = 0;
menu_gui_y = 0;
menu_actions = [];
menu_width = 132;
menu_option_height = 22;
interaction_range_tiles = 1;

SnapPointToTileCenter = function(_x, _y) {
	return {
		x: (floor(_x / global.tile_size) * global.tile_size) + global.tile_size / 2,
		y: (floor(_y / global.tile_size) * global.tile_size) + global.tile_size
	};
};

IsTileWalkable = function(_tile_x, _tile_y) {
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
	if (player.TileBlockedByObject(_tile_x, _tile_y, obj_npc)) {
		return false;
	}
	if (player.TileBlockedByObject(_tile_x, _tile_y, obj_resource)) {
		return false;
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

FindBestInteractionTile = function(_player, _target, _range_tiles) {
	if (!instance_exists(_player) || !instance_exists(_target)) {
		return {found: false, x: 0, y: 0};
	}
	
	var target_tile_x = _player.InstanceTileX(_target);
	var target_tile_y = _player.InstanceTileY(_target);
	var best_found = false;
	var best_x = _target.x;
	var best_y = _target.y;
	var best_score = 100000000;
	var search_radius = max(1, _range_tiles);
	
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
			
			var px = TileCenterX(tx);
			var py = TileCenterY(ty);
			var tile_score = point_distance(_player.x, _player.y, px, py);
			if (!best_found || tile_score < best_score) {
				best_found = true;
				best_score = tile_score;
				best_x = px;
				best_y = py;
			}
		}
	}
	
	return {found: best_found, x: best_x, y: best_y};
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
	var menu_y = menu_world_y - menu_h - 10;
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
	with (_player) {
		target_x = dest.x;
		target_y = dest.y;
		moving = true;
		pending_click_move = true;
		pending_click_target = noone;
		pending_click_action = "";
		pending_click_action_label = "";
		buffer_x = 0;
		buffer_y = 0;
	}
	return true;
};

StartMoveToInteractTarget = function(_player, _target, _range_tiles) {
	if (!instance_exists(_target)) {
		return false;
	}
	var dest = FindBestInteractionTile(_player, _target, _range_tiles);
	if (!dest.found) {
		return false;
	}
	with (_player) {
		target_x = dest.x;
		target_y = dest.y;
		moving = true;
		pending_click_move = true;
		pending_click_target = _target;
		pending_click_action = "";
		pending_click_action_label = "";
		buffer_x = 0;
		buffer_y = 0;
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
	menu_world_x = _target.x;
	menu_world_y = _target.bbox_top - 4;
	menu_gui_x = _x;
	menu_gui_y = _y;
	menu_actions = [];
	if (instance_exists(_target)) {
		if (_target.object_index == obj_npc) {
			menu_actions = [{ label: "Talk-to", action: "npc_talk" }];
		} else if (_target.object_index == obj_resource && !_target.depleted) {
			var label = _target.resource_skill == "Woodcutting" ? "Chop down" : "Mine";
			menu_actions = [{ label: label, action: "resource_use" }];
		}
	}
	if (array_length(menu_actions) == 0) {
		menu_open = false;
		menu_target = noone;
	}
};

CloseContextMenu = function() {
	context_menu = noone;
	menu_open = false;
	menu_target = noone;
	menu_actions = [];
};

ChooseContextMenuOption = function(_player, _option_index) {
	if (!menu_open || !instance_exists(menu_target)) {
		return false;
	}
	if (_option_index < 0 || _option_index >= array_length(menu_actions)) {
		return false;
	}
	
	var action = menu_actions[_option_index];
	var target = menu_target;
	var action_name = action.action;
	var action_label = action.label;
	
	CloseContextMenu();
	
	if (!instance_exists(_player) || !instance_exists(target)) {
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


