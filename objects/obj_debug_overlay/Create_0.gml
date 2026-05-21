/// @description Singleton perf overlay; F3 toggles global.debug_overlay_enabled across rooms.

if (instance_number(obj_debug_overlay) > 1) {
	instance_destroy(other);
	exit;
}

#region State

if (!variable_global_exists("debug_overlay_enabled")) {
	global.debug_overlay_enabled = true;
}

enabled = global.debug_overlay_enabled;
fps_display = 60;
fps_smooth = 0.12;
frame_ms_display = 16.67;
frame_ms_max = 0;
frame_ms_max_reset_timer = 0;
anim_frame = 0;
anim_speed = 0.25;
walk_frames = 4;
pulse_timer = 0;
spike_flash = 0;

#endregion
