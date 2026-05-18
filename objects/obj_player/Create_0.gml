tile_size = 32
move_speed = 3

TileXFromPosition = function(_x) {
    return floor(_x / tile_size)
}

TileYFromBottom = function(_y) {
    return floor((_y - 1) / tile_size)
}

InstanceTileX = function(_inst) {
    var _sprite = _inst.sprite_index
    if (_sprite == -1) {
        return TileXFromPosition(_inst.x)
    }
    
    var _visual_center_x = _inst.x + ((sprite_get_width(_sprite) / 2) - sprite_get_xoffset(_sprite))
    return TileXFromPosition(_visual_center_x)
}

InstanceTileY = function(_inst) {
    var _sprite = _inst.sprite_index
    if (_sprite == -1) {
        return TileYFromBottom(_inst.y)
    }
    
    var _visual_bottom_y = _inst.y + (sprite_get_height(_sprite) - sprite_get_yoffset(_sprite))
    return TileYFromBottom(_visual_bottom_y)
}

TileBlockedByObject = function(_tile_x, _tile_y, _object) {
    for (var _i = 0; _i < instance_number(_object); _i++) {
        var _inst = instance_find(_object, _i)
        if (InstanceTileX(_inst) == _tile_x && InstanceTileY(_inst) == _tile_y) {
            return true
        }
    }
    
    return false
}

SetFacingFromVector = function(_move_x, _move_y) {
    if (_move_x == 0 && _move_y > 0) {
        facing_dir = 0
    } else if (_move_x > 0 && _move_y > 0) {
        facing_dir = 1
    } else if (_move_x > 0 && _move_y == 0) {
        facing_dir = 2
    } else if (_move_x > 0 && _move_y < 0) {
        facing_dir = 3
    } else if (_move_x == 0 && _move_y < 0) {
        facing_dir = 4
    } else if (_move_x < 0 && _move_y < 0) {
        facing_dir = 5
    } else if (_move_x < 0 && _move_y == 0) {
        facing_dir = 6
    } else if (_move_x < 0 && _move_y > 0) {
        facing_dir = 7
    }
}

moving = false
target_x = x
target_y = y
click_path = []
click_path_index = 0
pending_click_move = false
pending_click_target = noone
pending_click_action = ""
pending_click_action_label = ""
pending_context_target = noone
pending_context_x = 0
pending_context_y = 0

move_x = 0
move_y = 0

buffer_x = 0
buffer_y = 0
pending_dialogue_npc = noone
pending_resource = noone
npc_talk_cooldown = 0

facing_dir = 0
walk_frames = 4
walk_anim_frame = 0
walk_anim_speed = 0.08
walk_anim_hold = 0

image_speed = 0
depth = 0

x = (floor(x / tile_size) * tile_size) + tile_size / 2
y = (floor(y / tile_size) * tile_size) + tile_size

target_x = x
target_y = y

if (variable_global_exists("spawn_x")) {
    x = global.spawn_x;
    y = global.spawn_y;
}

