/// @description View/camera helpers for HUD anchoring and room-to-GUI coordinate conversion.

#region View Position

function CameraX() {
	if (view_camera[0] >= 0) {
		return camera_get_view_x(view_camera[0]);
	}
	return 0;
}

function CameraY() {
	if (view_camera[0] >= 0) {
		return camera_get_view_y(view_camera[0]);
	}
	return 0;
}

function CameraMiddleX() {
	if (view_camera[0] >= 0) {
		return CameraX() + camera_get_view_width(view_camera[0]) / 2;
	}
	return room_width / 2;
}

function CameraMiddleY() {
	if (view_camera[0] >= 0) {
		return CameraY() + camera_get_view_height(view_camera[0]) / 2;
	}
	return room_height / 2;
}

#endregion

#region Room To GUI

function Camera_RoomToGui(_room_x, _room_y) {
	var gui_w = display_get_gui_width();
	var gui_h = display_get_gui_height();
	
	if (view_camera[0] < 0) {
		return { x: _room_x, y: _room_y };
	}
	
	var cam = view_camera[0];
	var view_x = camera_get_view_x(cam);
	var view_y = camera_get_view_y(cam);
	var view_w = max(1, camera_get_view_width(cam));
	var view_h = max(1, camera_get_view_height(cam));
	
	return {
		x: (_room_x - view_x) * (gui_w / view_w),
		y: (_room_y - view_y) * (gui_h / view_h)
	};
}

#endregion
