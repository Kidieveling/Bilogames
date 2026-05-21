/// @description Persistent dialogue controller instance state.
/// Session API, typewriter, beats, layout, and input are bound from Dialogue* scripts on Create.

#region Instance State

active = false;
active_speaker = noone;
conversation_speaker = noone;
text = "";
choices = [];
choice_index = 0;
input_cooldown = 0;

prompt_active = false;
prompt_text = "";
notice_text = "";
notice_timer = 0;

anchor_to_speaker = false;
player_movement_locked = false;

display_text = "";
full_text = "";
typewriter_index = 0;
typewriter_speed = 1;
typewriter_timer = 0;
text_finished = false;
choices_visible = false;

conv_active = false;
conv_beats = [];
conv_beat_index = 0;
conv_beat_type = "";
conv_pause_timer = 0;
conv_line_pause_after = 0;
conv_line_pause_active = false;
panel_speaker_name = "";
dialogue_dim_background = false;

#endregion

#region Script Bindings

DialogueSession_Register(id);
DialogueTypewriter_Register(id);
DialogueConversation_Register(id);
DialogueLayout_Register(id);
DialogueInput_Register(id);

#endregion
