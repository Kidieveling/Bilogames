/// @description F1–F4 panel toggles; perf metrics tick when F1 panel is on.

#region Hotkeys

if (keyboard_check_pressed(vk_f1)) {
	DebugOverlay_TogglePanel(DEBUG_OVERLAY_PERF);
	show_perf = global.debug_panel_perf;
}
if (keyboard_check_pressed(vk_f2)) {
	DebugOverlay_TogglePanel(DEBUG_OVERLAY_QUEST);
}
if (keyboard_check_pressed(vk_f3)) {
	DebugOverlay_TogglePanel(DEBUG_OVERLAY_DIALOGUE);
}
if (keyboard_check_pressed(vk_f4)) {
	DebugOverlay_TogglePanel(DEBUG_OVERLAY_PATH);
}

#endregion

if (!DebugOverlay_AnyPanelActive()) {
	exit;
}

#region Perf Metrics

if (show_perf) {
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
}

pulse_timer += 1;

#endregion
