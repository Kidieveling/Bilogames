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

moving = false
target_x = x
target_y = y

move_x = 0
move_y = 0

buffer_x = 0
buffer_y = 0
pending_dialogue_npc = noone
pending_resource = noone

facing_dir = 0
walk_frames = 1

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

