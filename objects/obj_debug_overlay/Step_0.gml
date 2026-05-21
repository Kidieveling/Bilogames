/// @description Smooth FPS/frame-time sampling; spike flash when a frame exceeds ~2× 60fps budget.

#region Toggle

if (keyboard_check_pressed(vk_f3)) {
	global.debug_overlay_enabled = !global.debug_overlay_enabled;
	enabled = global.debug_overlay_enabled;
}

if (!enabled) {
	exit;
}

#endregion

#region Metrics

var frame_ms = delta_time / 1000;
fps_display = lerp(fps_display, fps_real, fps_smooth);
frame_ms_display = lerp(frame_ms_display, frame_ms, fps_smooth);

frame_ms_max = max(frame_ms_max, frame_ms);
frame_ms_max_reset_timer += 1;
if (frame_ms_max_reset_timer >= max(1, room_speed)) {
	frame_ms_max = 0;
	frame_ms_max_reset_timer = 0;
}

if (frame_ms > 33) {
	spike_flash = 8;
} else if (spike_flash > 0) {
	spike_flash -= 1;
}

anim_frame = (anim_frame + anim_speed) mod walk_frames;
pulse_timer += 1;

#endregion
