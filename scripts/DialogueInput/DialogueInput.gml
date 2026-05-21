/// @description Dialogue GUI hit tests, choice navigation, and confirm handling; bound on obj_dialogue.

function DialogueInput_Register(_inst) {
	with (_inst) {
		
		#region Choice Activation
		
		// Welcomer branch handlers read self.welcomer on the choice struct — method() binds that scope.
		ActivateChoice = function(_index) {
			if (_index < 0 || _index >= array_length(choices)) {
				return;
			}
			
			choice_index = _index;
			var choice = choices[_index];
			
			if (is_struct(choice) && variable_struct_exists(choice, "action")) {
				var _action = choice.action;
				method(choice, _action)();
			} else {
				hide();
			}
		};
		
		#endregion
		
		#region Input Helpers
		
		IsMouseOverDialogueGui = function(_mx, _my) {
			if (!active) {
				return false;
			}
			
			var layout = ComputeDialogueLayout();
			if (!layout.valid) {
				return false;
			}
			
			return point_in_rectangle(_mx, _my, layout.box_x1, layout.box_y1, layout.box_x2, layout.box_y2);
		};
		
		Conversation_WantsChoiceInput = function() {
			return conv_active && choices_visible;
		};
		
		Conversation_WantsAdvanceInput = function() {
			if (!conv_active || !text_finished || choices_visible) {
				return false;
			}
			
			if (conv_beat_type == DIALOGUE_BEAT_LINE) {
				return true;
			}
			if (conv_beat_type == DIALOGUE_BEAT_PAUSE) {
				return true;
			}
			return false;
		};
		
		Dialogue_HandleChoiceInput = function(_layout, _mouse_gui_x, _mouse_gui_y, _confirm_choice) {
			if (!choices_visible || array_length(choices) <= 0) {
				return false;
			}
			
			if (keyboard_check_pressed(ord("W"))) {
				choice_index -= 1;
			}
			if (keyboard_check_pressed(ord("S"))) {
				choice_index += 1;
			}
			choice_index = clamp(choice_index, 0, array_length(choices) - 1);
			
			var confirm_choice = _confirm_choice;
			
			if (_layout.valid && array_length(_layout.choice_rects) > 0) {
				var hovered_choice = -1;
				for (var i = 0; i < array_length(_layout.choice_rects); ++i) {
					var row = _layout.choice_rects[i];
					if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, row.x1, row.y1, row.x2, row.y2)) {
						hovered_choice = i;
					}
				}
				
				if (hovered_choice >= 0) {
					choice_index = hovered_choice;
					if (mouse_check_button_pressed(mb_left)) {
						confirm_choice = true;
					}
				}
			}
			
			if (confirm_choice) {
				ActivateChoice(choice_index);
				input_cooldown = 6;
				return true;
			}
			
			return false;
		};
		
		StepDialogueInput = function() {
			if (input_cooldown > 0) {
				input_cooldown -= 1;
			}
			if (notice_timer > 0) {
				notice_timer -= 1;
			}
			if (active) {
				Dialogue_TickTypewriter();
			}
			if (conv_active) {
				Conversation_TickPause();
			}
			if (keyboard_check_pressed(vk_escape)) {
				if (instance_exists(obj_controller) && obj_controller.menu_open) {
					obj_controller.CloseContextMenu();
				}
				else if (active) {
					hide();
				}
				else if (notice_timer > 0) {
					notice_text = "";
					notice_timer = 0;
				}
				else if (prompt_active) {
					clear_prompt();
				}
			}
			if (!active) {
				return;
			}
			var mouse_gui_x = device_mouse_x_to_gui(0);
			var mouse_gui_y = device_mouse_y_to_gui(0);
			var layout = ComputeDialogueLayout();
			var confirm_e = keyboard_check_pressed(ord("E"));
			var confirm_advance = confirm_e || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);
			if (!text_finished) {
				if (layout.valid && point_in_rectangle(mouse_gui_x, mouse_gui_y, layout.box_x1, layout.box_y1, layout.box_x2, layout.box_y2)) {
					if (mouse_check_button_pressed(mb_left)) {
						confirm_e = true;
					}
				}
				if (confirm_e) {
					Dialogue_FinishTypewriter();
					input_cooldown = 4;
				}
				return;
			}
			// Phase 2: NPC line stays visible; choices auto-shown — E/click confirms selection only.
			if (choices_visible && array_length(choices) > 0) {
				Dialogue_HandleChoiceInput(layout, mouse_gui_x, mouse_gui_y, confirm_e);
				return;
			}
			if (conv_active) {
				if (Conversation_WantsAdvanceInput() && confirm_advance) {
					Conversation_TryAdvance();
					input_cooldown = 4;
				}
				return;
			}
			if (array_length(choices) <= 0 && confirm_e) {
				hide();
				input_cooldown = 6;
			}
		};
		
		#endregion
	}
}
