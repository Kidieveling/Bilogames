/// @description BFS tile paths for click-to-move and interact-adjacent stops; bound on obj_controller.

function Pathfinding_Register(_inst) {
	with (_inst) {
		
		#region Tile Walkability
		
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
		
		#endregion
		
		#region Nearest Walkable Tile
		
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
		
		#endregion
		
		#region Path Reconstruction
		
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
		
		#endregion
		
		#region Walkability BFS
		
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
		
		#endregion
		
		#region Path Queries
		
		// Among reachable tiles, prefer closest to the click, then shortest BFS distance (tie-break).
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
		
		// Stand next to a blocked target tile: shortest path into the search box around it.
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
		
		#endregion
		
		#region Move Commands
		
		StartTilePathMove = function(_player, _path_points) {
			if (!instance_exists(_player)) {
				return false;
			}
			
			with (_player) {
				PlayerPathing_SetPath(_path_points);
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
			// Chebyshev tile distance matches one-step keyboard adjacency for interact range.
			return max(abs(ax - bx), abs(ay - by)) <= _tiles;
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
			
			// Player resolves pending_click_* after the final path tile lands.
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
				PlayerPathing_ClearClickPath();
				pending_click_target = noone;
				pending_click_action = "";
				pending_click_action_label = "";
			}
		};
		ClearPendingInteraction = function(_player) {
			CancelClickMove(_player);
		};
		
		#endregion
	}
}
