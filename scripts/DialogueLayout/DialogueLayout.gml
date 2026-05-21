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
			
			var speakerName = panel_speaker_name;
			if (speakerName == "") {
				speakerName = DialogueUI_GetSpeakerName(GetActiveSpeaker());
			}
			
			var padding = DIALOGUEUI_PADDING;
			var lineGap = DIALOGUEUI_LINE_GAP;
			var panelW = display_get_gui_width() * DIALOGUEUI_WIDTH_FACTOR;
			var textWidth = panelW - padding * 2;
			var nameRowH = (speakerName != "") ? DIALOGUEUI_NAME_GAP : 0;
			// Phase 1: typewriter body; phase 2: full line stays, choices stack below (never replace body with choice labels).
			var bodyText = text_finished ? full_text : display_text;
			var bodyLines = max(1, ceil(string_width(bodyText) / max(1, textWidth)));
			var choicesBlockH = (choices_visible && text_finished)
				? DIALOGUEUI_CHOICE_TOP_GAP + array_length(choices) * DIALOGUEUI_CHOICE_ROW_HEIGHT
				: 0;
			
			var contentH = nameRowH + bodyLines * lineGap + choicesBlockH;
			var panelH = contentH + padding * 2;
			var panel = DialogueUI_GetPanelRect(panelH);
			
			layout.valid = true;
			layout.box_x1 = panel.x1;
			layout.box_y1 = panel.y1;
			layout.box_x2 = panel.x2;
			layout.box_y2 = panel.y2;
			layout.speaker_name = speakerName;
			layout.body_text = bodyText;
			layout.display_text = bodyText;
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
				UI_DrawDimScreen(0.15, c_black);
			}
			
			UI_DrawBorderedPanel(_layout.box_x1, _layout.box_y1, _layout.box_x2, _layout.box_y2,
				UI_DIALOGUE_PANEL_FILL, 0.88, UI_DIALOGUE_PANEL_BORDER, 1);
			
			var textX = _layout.box_x1 + _layout.padding_x;
			var textY = _layout.box_y1 + _layout.padding_y;
			
			if (_layout.speaker_name != "") {
				draw_set_color(make_color_rgb(200, 196, 184));
				draw_text(textX, textY, _layout.speaker_name + ":");
				textY += DIALOGUEUI_NAME_GAP;
			}
			
			draw_set_color(c_white);
			draw_text_ext(textX, textY, _layout.body_text, _layout.line_gap, _layout.text_width);
			
			if (choices_visible && text_finished) {
				UI_DrawChoiceList(_layout.choice_rects, choices, choice_index);
			}
		};
		
		#endregion
	}
}
