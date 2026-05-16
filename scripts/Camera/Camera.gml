
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
