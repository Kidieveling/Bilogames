/// @description GUI panel layout and draw for dialogue, prompts, and notices; bound on obj_dialogue.

function DialogueLayout_Register(_inst) {
	with (_inst) {
		
		#region Layout
		
		ComputeDialogueLayout = function() {
			var layout = {
				valid: false,
				box_x1: 0,
				box_y1: 0,
				box_x2: 0,
				box_y2: 0,
				choice_rects: [],
				display_text: "",
				body_text: "",
				speaker_name: ""
			};
			
			if (!active) {
				return layout;
			}
			
			draw_set_font(fntSmaller);
			
			var bodyText = Dialogue_GetBodyTextForLayout();
			var speakerName = panel_speaker_name;
			if (speakerName == "") {
				speakerName = DialogueUI_GetSpeakerName(GetActiveSpeaker());
			}
			
			var padding = DIALOGUEUI_PADDING;
			var lineGap = DIALOGUEUI_LINE_GAP;
			var panelW = display_get_gui_width() * DIALOGUEUI_WIDTH_FACTOR;
			var textWidth = panelW - padding * 2;
			var nameRowH = (speakerName != "") ? DIALOGUEUI_NAME_GAP : 0;
			var bodyLines = max(1, ceil(string_width(bodyText) / max(1, textWidth)));
			
			// Panel height shrinks while typing — choice rows count only after the line is fully revealed.
			var choicesBlockH = choices_visible ? DIALOGUEUI_CHOICE_TOP_GAP + array_length(choices) * DIALOGUEUI_CHOICE_ROW_HEIGHT : 0;
			
			var contentH = nameRowH + bodyLines * lineGap + choicesBlockH;
			var panelH = contentH + padding * 2;
			var panel = DialogueUI_GetPanelRect(panelH);
			
			layout.valid = true;
			layout.box_x1 = panel.x1;
			layout.box_y1 = panel.y1;
			layout.box_x2 = panel.x2;
			layout.box_y2 = panel.y2;
			layout.speaker_name = speakerName;
			layout.body_text = text_finished ? full_text : display_text;
			layout.display_text = layout.body_text;
			layout.padding_x = padding;
			layout.padding_y = padding;
			layout.line_gap = lineGap;
			layout.text_width = textWidth;
			layout.text_lines = bodyLines;
			
			var textX = layout.box_x1 + padding;
			var textY = layout.box_y1 + padding;
			if (speakerName != "") {
				textY += nameRowH;
			}
			
			var choicesY = textY + bodyLines * lineGap + DIALOGUEUI_CHOICE_TOP_GAP;
			if (choices_visible) {
				for (var i = 0; i < array_length(choices); ++i) {
					array_push(layout.choice_rects, {
						x1: textX,
						y1: choicesY + i * DIALOGUEUI_CHOICE_ROW_HEIGHT,
						x2: layout.box_x2 - padding,
						y2: choicesY + (i + 1) * DIALOGUEUI_CHOICE_ROW_HEIGHT - 2
					});
				}
			}
			
			return layout;
		};
		
		ComputePromptLayout = function(_text) {
			var layout = {
				valid: false,
				box_x1: 0,
				box_y1: 0,
				box_x2: 0,
				box_y2: 0,
				choice_rects: [],
				display_text: _text,
				body_text: _text,
				speaker_name: "",
				padding_x: DIALOGUEUI_PADDING,
				padding_y: DIALOGUEUI_PADDING,
				line_gap: DIALOGUEUI_LINE_GAP,
				text_width: 0,
				text_lines: 1
			};
			
			if (_text == "") {
				return layout;
			}
			
			draw_set_font(fntSmaller);
			var padding = DIALOGUEUI_PADDING;
			var lineGap = DIALOGUEUI_LINE_GAP;
			var panelW = display_get_gui_width() * DIALOGUEUI_WIDTH_FACTOR;
			var textWidth = panelW - padding * 2;
			var bodyLines = max(1, ceil(string_width(_text) / max(1, textWidth)));
			var panelH = bodyLines * lineGap + padding * 2;
			var panel = DialogueUI_GetPanelRect(panelH);
			
			layout.valid = true;
			layout.box_x1 = panel.x1;
			layout.box_y1 = panel.y1;
			layout.box_x2 = panel.x2;
			layout.box_y2 = panel.y2;
			layout.text_width = textWidth;
			layout.text_lines = bodyLines;
			
			return layout;
		};
		
		#endregion
		
		#region Draw
		
		DrawDialogueLayout = function(_layout) {
			if (!_layout.valid) {
				return;
			}
			
			if (dialogue_dim_background) {
				draw_set_alpha(0.15);
				draw_set_color(c_black);
				draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
				draw_set_alpha(1);
			}
			
			draw_set_alpha(0.88);
			draw_set_color(make_color_rgb(12, 12, 16));
			draw_rectangle(_layout.box_x1, _layout.box_y1, _layout.box_x2, _layout.box_y2, false);
			draw_set_alpha(1);
			draw_set_color(make_color_rgb(90, 90, 98));
			draw_rectangle(_layout.box_x1, _layout.box_y1, _layout.box_x2, _layout.box_y2, true);
			
			var textX = _layout.box_x1 + _layout.padding_x;
			var textY = _layout.box_y1 + _layout.padding_y;
			
			if (_layout.speaker_name != "") {
				draw_set_color(make_color_rgb(200, 196, 184));
				draw_text(textX, textY, _layout.speaker_name);
				textY += DIALOGUEUI_NAME_GAP;
			}
			
			draw_set_color(c_white);
			draw_text_ext(textX, textY, _layout.body_text, _layout.line_gap, _layout.text_width);
			
			if (!choices_visible) {
				draw_set_color(c_white);
				return;
			}
			
			for (var i = 0; i < array_length(choices); ++i) {
				if (i >= array_length(_layout.choice_rects)) {
					break;
				}
				
				var choiceText = choices[i];
				if (is_struct(choiceText)) {
					choiceText = choiceText.text;
				}
				
				var row = _layout.choice_rects[i];
				var isSelected = (i == choice_index);
				
				if (isSelected) {
					draw_set_alpha(0.22);
					draw_set_color(make_color_rgb(70, 72, 88));
					draw_rectangle(row.x1 - 4, row.y1 - 2, row.x2 + 4, row.y2 + 2, false);
					draw_set_alpha(1);
				}
				
				draw_set_color(isSelected ? c_white : make_color_rgb(210, 210, 215));
				draw_text(row.x1, row.y1, (isSelected ? "> " : "  ") + choiceText);
			}
			
			draw_set_color(c_white);
		};
		
		#endregion
	}
}
