/// @description Welcomer instance: presentation, tour fields, facing/animation, menu entry.

function WelcomerNpc_Register(_inst) {
	with (_inst) {
		sprite_index = spr_welcomer;
		visible = true;
		npc_name = "Welcomer";
		npc_text = "Easy now. You are inside Hearthmere, which means someone important decided you were worth the risk. Ask what you need to know before we speak of duty.";
		dialogue_text = npc_name + ": " + npc_text;
		image_speed = 0;
		walk_frames = 4;
		facing_dir = 4;
		image_index = facing_dir * walk_frames;
		walk_anim_frame = 0;
		walk_anim_speed = 0.18;
		face_player_while_dialogue = false;
		
		guided_tour_active = false;
		guided_step_index = 0;
		guided_steps = [];
		guided_phase = "idle";
		guided_target = noone;
		guided_pending_line = undefined;
		guided_line_started = false;
		guided_pause_timer = 0;
		guided_home_x = x;
		guided_home_y = y;
		guided_walk_speed = 1.6;
		intro_dialogue_node = "";
		intro_branches_asked = [];
		
		SetFacingFromMovement = function(_move_x, _move_y) {
			if (_move_x == 0 && _move_y > 0) facing_dir = 4;
			else if (_move_x > 0 && _move_y > 0) facing_dir = 3;
			else if (_move_x > 0 && _move_y == 0) facing_dir = 2;
			else if (_move_x > 0 && _move_y < 0) facing_dir = 1;
			else if (_move_x == 0 && _move_y < 0) facing_dir = 0;
			else if (_move_x < 0 && _move_y < 0) facing_dir = 7;
			else if (_move_x < 0 && _move_y == 0) facing_dir = 6;
			else if (_move_x < 0 && _move_y > 0) facing_dir = 5;
		};
		
		FaceTowardInstance = function(_target) {
			if (!instance_exists(_target)) return;
			var _dx = _target.x - x;
			var _dy = _target.y - y;
			if (_dx != 0 || _dy != 0) SetFacingFromMovement(_dx, _dy);
		};
		
		UpdateWelcomerAnimation = function() {
			var _dx = x - xprevious;
			var _dy = y - yprevious;
			var _moved = (_dx != 0 || _dy != 0);
			var _base = facing_dir * walk_frames;
			if (_moved) {
				SetFacingFromMovement(_dx, _dy);
				_base = facing_dir * walk_frames;
				walk_anim_frame += walk_anim_speed;
				if (walk_anim_frame >= walk_frames) walk_anim_frame -= walk_frames;
				image_index = _base + floor(walk_anim_frame);
			} else {
				walk_anim_frame = 0;
				image_index = _base;
			}
			image_speed = 0;
		};
		
		OpenDialogueMenu = function() {
			DialogueWelcomer_Open(id);
		};
		
		AcceptSecondChanceTrial = function() {
			DialogueWelcomer_AcceptSecondChanceTrial(id);
		};
		
		interact = function(_player) {
			if (guided_tour_active) return;
			Dialogue_InteractNpc(id, _player);
		};
	}
}
