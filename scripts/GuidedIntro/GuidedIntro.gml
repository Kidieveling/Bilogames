/// @description Guided walking intro sequences (Welcomer tour + reusable step helpers)

#macro GUIDED_STEP_LINE "line"
#macro GUIDED_STEP_GO "go"
#macro GUIDED_STEP_PAUSE "pause"
#macro GUIDED_STEP_CHOICES "choices"
#macro GUIDED_STEP_ACTION "action"
#macro GUIDED_STEP_RETURN_HOME "return_home"
#macro GUIDED_STEP_INTRO_NODE "intro_node"

#macro GUIDED_MARKER_GATE "intro_gate"
#macro GUIDED_MARKER_TRAINERS "intro_trainers"
#macro GUIDED_MARKER_WORKYARD "intro_workyard"
#macro GUIDED_MARKER_TRIAL "intro_trial"

#macro GUIDED_ARRIVE_DIST 10
#macro GUIDED_WAIT_PLAYER_DIST 128

function GuidedIntro_FindMarker(_marker_id) {
	var found = noone;
	with (obj_intro_marker) {
		if (marker_id == _marker_id) {
			found = id;
		}
	}
	return found;
}

function GuidedIntro_Step_Line(_text, _opts = {}) {
	return {
		type: GUIDED_STEP_LINE,
		text: _text,
		speaker_name: variable_struct_exists(_opts, "speaker_name") ? _opts.speaker_name : DIALOGUE_WELCOMER_NAME,
		pause_after: variable_struct_exists(_opts, "pause_after") ? _opts.pause_after : 16,
		lock_player: variable_struct_exists(_opts, "lock_player") ? _opts.lock_player : false
	};
}

function GuidedIntro_Step_Go(_marker_id, _text, _opts = {}) {
	return {
		type: GUIDED_STEP_GO,
		marker_id: _marker_id,
		text: _text,
		speaker_name: variable_struct_exists(_opts, "speaker_name") ? _opts.speaker_name : DIALOGUE_WELCOMER_NAME,
		pause_after: variable_struct_exists(_opts, "pause_after") ? _opts.pause_after : 18,
		lock_player: variable_struct_exists(_opts, "lock_player") ? _opts.lock_player : false,
		wait_player: variable_struct_exists(_opts, "wait_player") ? _opts.wait_player : true
	};
}

function GuidedIntro_Step_Pause(_frames) {
	return { type: GUIDED_STEP_PAUSE, frames: _frames };
}

function GuidedIntro_Step_Choices(_choices, _opts = {}) {
	return {
		type: GUIDED_STEP_CHOICES,
		prompt: variable_struct_exists(_opts, "prompt") ? _opts.prompt : "",
		choices: _choices,
		lock_player: true
	};
}

function GuidedIntro_Step_Action(_fn) {
	return { type: GUIDED_STEP_ACTION, fn: _fn };
}

function GuidedIntro_Step_ReturnHome() {
	return { type: GUIDED_STEP_RETURN_HOME };
}

function GuidedIntro_Step_IntroNode(_node_id, _opts = {}) {
	return {
		type: GUIDED_STEP_INTRO_NODE,
		node_id: _node_id,
		lock_player: variable_struct_exists(_opts, "lock_player") ? _opts.lock_player : true
	};
}

function GuidedIntro_BuildWelcomerTourSteps(_welcomer) {
	return [
		GuidedIntro_Step_IntroNode(DIALOGUE_WELCOMER_NODE_ARRIVAL, { lock_player: true }),
		GuidedIntro_Step_Go(GUIDED_MARKER_GATE, "You are inside Hearthmere.", { pause_after: 16 }),
		GuidedIntro_Step_Line("These walls are not kindness. They are calculation.", { pause_after: 14 }),
		GuidedIntro_Step_IntroNode(DIALOGUE_WELCOMER_NODE_GATE, { lock_player: true }),
		GuidedIntro_Step_Go(GUIDED_MARKER_TRAINERS, "Trainers do not hand out trust.", { pause_after: 14 }),
		GuidedIntro_Step_IntroNode(DIALOGUE_WELCOMER_NODE_TRAINERS, { lock_player: true }),
		GuidedIntro_Step_Go(GUIDED_MARKER_WORKYARD, "Useful work keeps a frontier settlement standing.", { pause_after: 14 }),
		GuidedIntro_Step_IntroNode(DIALOGUE_WELCOMER_NODE_WORKYARD, { lock_player: true }),
		GuidedIntro_Step_Go(GUIDED_MARKER_TRIAL, "Someone important decided you were worth the risk.", { pause_after: 14 }),
		GuidedIntro_Step_IntroNode(DIALOGUE_WELCOMER_NODE_MARKLESS, { lock_player: true }),
		GuidedIntro_Step_IntroNode(DIALOGUE_WELCOMER_NODE_TRIAL, { lock_player: true }),
		GuidedIntro_Step_Action(function() {
			GameState_SetWelcomerGuidedTourComplete(true);
			GameState_SetWelcomerIntroComplete(true);
		}),
		GuidedIntro_Step_ReturnHome()
	];
}

function GuidedIntro_StartWelcomerTour(_welcomer) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		anchor_to_speaker = true;
		player_movement_locked = false;
	}
	Dialogue_SetSpeaker(_welcomer);
	
	with (_welcomer) {
		guided_tour_active = true;
		guided_step_index = 0;
		guided_phase = "begin_step";
		guided_target = noone;
		guided_line_started = false;
		guided_home_x = x;
		guided_home_y = y;
		guided_steps = GuidedIntro_BuildWelcomerTourSteps(id);
		guided_walk_speed = 1.6;
		face_player_while_dialogue = false;
	}
	
	GuidedIntro_BeginCurrentStep(_welcomer);
}

function GuidedIntro_IsTourActive(_welcomer) {
	return instance_exists(_welcomer) && _welcomer.guided_tour_active;
}

function GuidedIntro_GetCurrentStep(_welcomer) {
	if (!GuidedIntro_IsTourActive(_welcomer)) {
		return undefined;
	}
	if (_welcomer.guided_step_index < 0 || _welcomer.guided_step_index >= array_length(_welcomer.guided_steps)) {
		return undefined;
	}
	return _welcomer.guided_steps[_welcomer.guided_step_index];
}

function GuidedIntro_AdvanceStepIndex(_welcomer) {
	_welcomer.guided_step_index += 1;
	_welcomer.guided_phase = "begin_step";
	_welcomer.guided_target = noone;
	_welcomer.guided_line_started = false;
	
	if (_welcomer.guided_step_index >= array_length(_welcomer.guided_steps)) {
		GuidedIntro_EndTour(_welcomer);
		return;
	}
	
	GuidedIntro_BeginCurrentStep(_welcomer);
}

function GuidedIntro_BeginCurrentStep(_welcomer) {
	var step = GuidedIntro_GetCurrentStep(_welcomer);
	if (is_undefined(step)) {
		GuidedIntro_EndTour(_welcomer);
		return;
	}
	
	switch (step.type) {
		case GUIDED_STEP_LINE:
			_welcomer.guided_phase = "show_line";
			GuidedIntro_PresentTourLine(_welcomer, step);
			break;
		
		case GUIDED_STEP_GO:
			_welcomer.guided_target = GuidedIntro_FindMarker(step.marker_id);
			if (!instance_exists(_welcomer.guided_target)) {
				_welcomer.guided_target = noone;
			}
			_welcomer.guided_phase = "go";
			_welcomer.guided_pending_line = step;
			break;
		
		case GUIDED_STEP_PAUSE:
			_welcomer.guided_phase = "pause";
			_welcomer.guided_pause_timer = step.frames;
			break;
		
		case GUIDED_STEP_CHOICES:
			_welcomer.guided_phase = "choices";
			GuidedIntro_PresentTourChoices(_welcomer, step);
			break;
		
		case GUIDED_STEP_INTRO_NODE:
			_welcomer.guided_phase = "intro_node";
			DialogueWelcomer_PlayIntroNode(_welcomer, step.node_id, true);
			_welcomer.guided_line_started = true;
			break;
		
		case GUIDED_STEP_ACTION:
			if (variable_struct_exists(step, "fn")) {
				step.fn();
			}
			GuidedIntro_AdvanceStepIndex(_welcomer);
			break;
		
		case GUIDED_STEP_RETURN_HOME:
			_welcomer.guided_phase = "return_home";
			_welcomer.guided_target = noone;
			break;
	}
}

function GuidedIntro_PresentTourLine(_welcomer, _step) {
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		SetActiveSpeaker(_welcomer);
		player_movement_locked = _step.lock_player;
	}
	
	var beats = [
		DialogueBeat_Line(_step.speaker_name, _step.text, _step.pause_after)
	];
	DialogueConversation_Start(_welcomer, beats);
	_welcomer.guided_line_started = true;
}

function GuidedIntro_PresentTourChoices(_welcomer, _step) {
	Dialogue_EnsureInstance();
	with (obj_dialogue) {
		SetActiveSpeaker(_welcomer);
		player_movement_locked = _step.lock_player;
	}
	
	var beats = [DialogueBeat_Choices(_step.prompt, _step.choices)];
	DialogueConversation_Start(_welcomer, beats);
	_welcomer.guided_line_started = true;
}

function GuidedIntro_PresentGoLine(_welcomer, _step) {
	GuidedIntro_PresentTourLine(_welcomer, _step);
	_welcomer.guided_phase = "show_line";
}

function GuidedIntro_TickWelcomer(_welcomer) {
	if (!GuidedIntro_IsTourActive(_welcomer)) {
		return;
	}
	
	var player = instance_find(obj_player, 0);
	
	switch (_welcomer.guided_phase) {
		case "go":
			var pending = _welcomer.guided_pending_line;
			if (is_undefined(pending)) {
				GuidedIntro_AdvanceStepIndex(_welcomer);
				return;
			}
			
			if (instance_exists(_welcomer.guided_target)) {
				GuidedIntro_MoveToward(_welcomer, _welcomer.guided_target.x, _welcomer.guided_target.y);
			}
			
			var arrived = !instance_exists(_welcomer.guided_target)
				|| point_distance(_welcomer.x, _welcomer.y, _welcomer.guided_target.x, _welcomer.guided_target.y) <= GUIDED_ARRIVE_DIST;
			var player_ready = true;
			if (pending.wait_player && instance_exists(player)) {
				player_ready = point_distance(_welcomer.x, _welcomer.y, player.x, player.y) <= GUIDED_WAIT_PLAYER_DIST;
			}
			
			if (arrived && player_ready) {
				_welcomer.guided_phase = "show_line";
				GuidedIntro_PresentGoLine(_welcomer, pending);
			} else if (arrived && pending.wait_player) {
				_welcomer.guided_phase = "wait_player";
			}
			break;
		
		case "wait_player":
			pending = _welcomer.guided_pending_line;
			player_ready = true;
			if (pending.wait_player && instance_exists(player)) {
				player_ready = point_distance(_welcomer.x, _welcomer.y, player.x, player.y) <= GUIDED_WAIT_PLAYER_DIST;
			}
			if (player_ready) {
				_welcomer.guided_phase = "show_line";
				GuidedIntro_PresentGoLine(_welcomer, pending);
			} else if (instance_exists(player)) {
				GuidedIntro_FaceToward(_welcomer, player);
			}
			break;
		
		case "show_line":
		case "choices":
		case "intro_node":
			if (_welcomer.guided_line_started && instance_exists(obj_dialogue) && !obj_dialogue.active) {
				_welcomer.guided_line_started = false;
				with (obj_dialogue) {
					player_movement_locked = false;
				}
				GuidedIntro_AdvanceStepIndex(_welcomer);
			}
			break;
		
		case "pause":
			_welcomer.guided_pause_timer -= 1;
			if (_welcomer.guided_pause_timer <= 0) {
				GuidedIntro_AdvanceStepIndex(_welcomer);
			}
			break;
		
		case "return_home":
			GuidedIntro_MoveToward(_welcomer, _welcomer.guided_home_x, _welcomer.guided_home_y);
			if (point_distance(_welcomer.x, _welcomer.y, _welcomer.guided_home_x, _welcomer.guided_home_y) <= GUIDED_ARRIVE_DIST) {
				GuidedIntro_EndTour(_welcomer);
			}
			break;
	}
	
	_welcomer.depth = -_welcomer.y;
}

function GuidedIntro_MoveToward(_welcomer, _tx, _ty) {
	var dist = point_distance(_welcomer.x, _welcomer.y, _tx, _ty);
	if (dist <= GUIDED_ARRIVE_DIST) {
		_welcomer.x = _tx;
		_welcomer.y = _ty;
		return;
	}
	
	var dir = point_direction(_welcomer.x, _welcomer.y, _tx, _ty);
	_welcomer.x += lengthdir_x(_welcomer.guided_walk_speed, dir);
	_welcomer.y += lengthdir_y(_welcomer.guided_walk_speed, dir);
	GuidedIntro_FaceToward(_welcomer, { x: _tx, y: _ty });
}

function GuidedIntro_FaceToward(_welcomer, _target) {
	if (!instance_exists(_welcomer)) {
		return;
	}
	if (variable_instance_exists(_welcomer, "FaceTowardInstance") && instance_exists(_target)) {
		_welcomer.FaceTowardInstance(_target);
		return;
	}
	if (!is_struct(_target)) {
		return;
	}
	
	var _dx = _target.x - _welcomer.x;
	var _dy = _target.y - _welcomer.y;
	if (_dx != 0 || _dy != 0) {
		_welcomer.SetFacingFromMovement(_dx, _dy);
	}
}

function GuidedIntro_EndTour(_welcomer) {
	with (_welcomer) {
		guided_tour_active = false;
		guided_phase = "idle";
		guided_target = noone;
		guided_pending_line = undefined;
		face_player_while_dialogue = true;
	}
	
	if (instance_exists(obj_dialogue)) {
		with (obj_dialogue) {
			player_movement_locked = false;
			SetActiveSpeaker(noone);
		}
	}
}

function GuidedIntro_OnChoicePicked(_welcomer) {
	if (!GuidedIntro_IsTourActive(_welcomer)) {
		return;
	}
	if (_welcomer.guided_phase == "choices") {
		_welcomer.guided_line_started = true;
	}
}
