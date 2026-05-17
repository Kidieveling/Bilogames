/// @description Draw dialogue box

if (active) {
	var screenWidth = display_get_gui_width();
	var screenHeight = display_get_gui_height();
	var boxWidth = min(560, screenWidth - 64);
	var boxHeight = 180;
	var boxX1 = 32;
	var boxY1 = screenHeight - boxHeight - 32;
	var boxX2 = boxX1 + boxWidth;
	var boxY2 = boxY1 + boxHeight;
	
	draw_set_alpha(0.9);
	draw_set_color(c_black);
	draw_rectangle(boxX1, boxY1, boxX2, boxY2, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(boxX1, boxY1, boxX2, boxY2, true);
	
	var textX = boxX1 + 24;
	var textY = boxY1 + 20;
	var textWidth = boxWidth - 48;
	
	draw_set_font(fntSmaller);
	draw_set_color(c_white);
	draw_text_ext(textX, textY, text, 18, textWidth);
	
	var choicesY = textY + 76;
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
