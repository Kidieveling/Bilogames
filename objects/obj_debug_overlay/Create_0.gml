/// @description Singleton dev HUD: F1 perf, F2 quest, F3 dialogue flags, F4 pathfinding.

if (instance_number(obj_debug_overlay) > 1) {
	instance_destroy(other);
	exit;
}

DebugOverlay_InitGlobals();

#region Perf Sampling State

show_perf = global.debug_panel_perf;
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

// Path lines and HUD panels draw above gameplay instances.
depth = 10000;
