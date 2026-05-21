/// @description Player instance state; movement, interaction, and animation logic
/// are bound from PlayerMovement / PlayerInteraction / PlayerAnimation scripts.

#region Movement Configuration

tile_size = 32;
movement_tick_length = MOVEMENT_TICK_LENGTH;
// Logic steps on movement ticks; pixels lerp between tile centers so visuals stay smooth.
move_speed = max(1, tile_size div movement_tick_length);

#endregion

#region Tile Movement State

moving = false;
target_x = x;
target_y = y;
move_x = 0;
move_y = 0;

click_path = [];
click_path_index = 0;
pending_click_move = false;

// Pathing fills these; interact() runs in StepInteraction_ResolvePending after the last tile lands.
pending_click_target = noone;
pending_click_action = "";
pending_click_action_label = "";

#endregion

#region Keyboard Input Buffer

buffer_x = 0;
buffer_y = 0;
pending_keyboard_step = false;
keyboard_hold_frames = 0;
queued_keyboard_x = 0;
queued_keyboard_y = 0;
queued_click_path = [];

#endregion

#region Interaction State

pending_context_target = noone;
pending_context_x = 0;
pending_context_y = 0;
pending_dialogue_npc = noone;
pending_resource = noone;
npc_talk_cooldown = 0;

#endregion

#region Animation State

facing_dir = 0;
walk_frames = 4;
walk_anim_frame = 0;
walk_anim_speed = 0.06;
walk_anim_hold = 0;

#endregion

#region Spawn And Presentation

image_speed = 0;
depth = 0;

x = (floor(x / tile_size) * tile_size) + tile_size / 2;
y = (floor(y / tile_size) * tile_size) + tile_size;

target_x = x;
target_y = y;

if (variable_global_exists("spawn_x")) {
	x = global.spawn_x;
	y = global.spawn_y;
}

#endregion

#region Script Bindings

// Pathing before movement (OnTileLanded delegates); animation before movement (BeginStep faces).
PlayerAnimation_Register(id);
PlayerPathing_Register(id);
PlayerMovement_Register(id);
PlayerInteraction_Register(id);

#endregion
