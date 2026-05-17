/// @description Draw dialogue, prompts, and notices

if (active || prompt_active || notice_timer > 0) {
	var screenWidth = display_get_gui_width();
	var screenHeight = display_get_gui_height();
	var displayText = notice_text;
	if (prompt_active) {
		displayText = prompt_text;
	}
	if (active) {
		displayText = text;
	}
	
	draw_set_font(fntSmaller);
	
	var paddingX = 24;
	var paddingY = 18;
	var lineGap = 18;
	var maxBoxWidth = min(560, screenWidth - 64);
	var contentWidth = min(string_width(displayText), maxBoxWidth - paddingX * 2);
	
	if (active) {
		for (var c = 0; c < array_length(choices); ++c) {
			var measuredChoice = choices[c];
			if (is_struct(measuredChoice)) {
				measuredChoice = measuredChoice.text;
			}
			contentWidth = max(contentWidth, string_width("> " + string(measuredChoice)));
		}
	}
	
	var boxWidth = clamp(contentWidth + paddingX * 2, 180, maxBoxWidth);
	var textWidth = boxWidth - paddingX * 2;
	var textLines = max(1, ceil(string_width(displayText) / max(1, textWidth)));
	var contentHeight = textLines * lineGap;
	if (active) {
		contentHeight += 36 + array_length(choices) * 24;
	}
	var boxHeight = contentHeight + paddingY * 2;
	var skillBarTop = screenHeight - sprite_get_height(spr_skillBar) - 12;
	var boxX1 = 32;
	var boxY1 = skillBarTop - boxHeight - 12;
	var boxX2 = boxX1 + boxWidth;
	var boxY2 = boxY1 + boxHeight;
	
	draw_set_alpha(0.9);
	draw_set_color(c_black);
	draw_rectangle(boxX1, boxY1, boxX2, boxY2, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(boxX1, boxY1, boxX2, boxY2, true);
	
	var textX = boxX1 + paddingX;
	var textY = boxY1 + paddingY;
	
	draw_set_color(c_white);
	draw_text_ext(textX, textY, displayText, lineGap, textWidth);
	
	if (active) {
		var choicesY = textY + textLines * lineGap + 36;
		for (var i = 0; i < array_length(choices); ++i) {
			var prefix = "  ";
			if (i == choice_index) {
				prefix = "> ";
			}
			
			var choiceText = choices[i];
			if (is_struct(choiceText)) {
				choiceText = choiceText.text;
			}
			
			draw_text(textX, choicesY + i * 24, prefix + choiceText);
		}
	}
}
