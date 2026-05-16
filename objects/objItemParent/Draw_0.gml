/// @description Draw Info
draw_self();

//Info for when displaying description sprite
if (isShowingInfo == true) {
	draw_set_alpha(1);
	//Name
	draw_set_font(fntSmaller);
	draw_set_color(c_red);
	draw_text_ext(CameraMiddleX() + 60, CameraY() + 125, name, 20, textWidth + 15);
	//Description
	draw_set_font(fntLarger);
	draw_set_color(c_black);
	draw_text_ext(CameraMiddleX() + 60, CameraMiddleY() - 75, description, 20, textWidth);
	//Attributes
	var attributeText = "";
	if (damage != undefined) {
		attributeText += "Damage: " + string(damage) + "\n";
	}
	if (defense != undefined) {
		attributeText += "Defense: " + string(defense) + "\n";
	}
	if (healthRestored != undefined) {
		attributeText += "Health: " + string(healthRestored) + "\n";
	}
	if (manaRestored != undefined) {
		attributeText += "Mana: " + string(manaRestored) + "\n";
	}
	if (ailmentsCured != undefined) {
		for(var i = 0; i < array_length(ailmentsCured); ++i) {
			if(i == Ailment.Confused) {
				attributeText += "Cures Confusion\n";
			}
			if(i == Ailment.Drunk) {
				attributeText += "Cures Drunkness\n";
			}
			if(i == Ailment.Poison) {
				attributeText += "Cures Poison\n";
			}
		}
	}
	if (attributeText != "") {
		draw_set_font(fntSmaller);
		draw_set_color(c_black);
		draw_text(CameraX() + 385, CameraY() + 332, attributeText);
	}
	//Buttons
	if (type == Type.Armor) {
		draw_sprite(sp_equipButton, 0, CameraX() + 480, CameraY() + 455);
	}
	if (type == Type.Weapon) {
		draw_sprite(sp_equipButton, 0, CameraX() + 480, CameraY() + 455);
	}
	if (type == Type.Consumable) {
		draw_sprite(spr_use_button, 0, CameraX() + 480, CameraY() + 455);
	}
}
if (isInMenu == true) {
	//Price
	draw_set_color(c_orange);
	draw_set_font(fntSmaller);
	draw_text_ext(CameraX() + 55, CameraY() + 390, name + " is worth " + string(price) + " gold each.",
	font_get_size(fntSmaller) * 1.5, sprite_get_width(spr_inventoryFront) - 20);
}
