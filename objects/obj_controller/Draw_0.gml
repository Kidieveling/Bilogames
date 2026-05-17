/// @description Draw The Menu
draw_self();

var viewWidth = room_width;
var viewHeight = room_height;
if (view_camera[0] >= 0) {
	viewWidth = camera_get_view_width(view_camera[0]);
	viewHeight = camera_get_view_height(view_camera[0]);
}

draw_set_alpha(1);
draw_sprite(spr_skillBar, 0, CameraMiddleX(), CameraY() + viewHeight - sprite_get_yoffset(spr_skillBar) - 12);

draw_set_font(fntSmaller);
draw_set_color(c_white);
var skillTextY = CameraY() + viewHeight - sprite_get_yoffset(spr_skillBar) - 22;
var woodcuttingNextXP = SkillXPForNextLevel(global.woodcutting_level);
var miningNextXP = SkillXPForNextLevel(global.mining_level);
var smeltingNextXP = SkillXPForNextLevel(global.smelting_level);
draw_text(CameraMiddleX() - 220, skillTextY, "Woodcutting " + string(global.woodcutting_level) + "  " + string(global.woodcutting_xp) + "/" + string(woodcuttingNextXP));
draw_text(CameraMiddleX() - 40, skillTextY, "Mining " + string(global.mining_level) + "  " + string(global.mining_xp) + "/" + string(miningNextXP));
draw_text(CameraMiddleX() + 110, skillTextY, "Smelting " + string(global.smelting_level) + "  " + string(global.smelting_xp) + "/" + string(smeltingNextXP));

var hoveredItem = undefined;
	
//Back of the menu
draw_set_alpha(1);
var menuMargin = 16;
var menuScale = 2;
var menuLeft = CameraX() + viewWidth - 296 - menuMargin;
var menuTop = CameraY() + viewHeight - 296 - menuMargin + 18;
var menuX = menuLeft;
var menuY = menuTop;

draw_sprite_ext(spr_ui_panel, 0, menuLeft, menuTop, menuScale, menuScale, 0, c_white, 1);
	
	var tabY1 = menuTop - 27;
	var tabY2 = tabY1 + 28;
	var inventoryTabX1 = menuLeft + 22;
	var inventoryTabW = 80;
	var inventoryTabX2 = inventoryTabX1 + inventoryTabW;
	var spellsTabX1 = inventoryTabX2 + 8;
	var spellsTabW = 72;
	var spellsTabX2 = spellsTabX1 + spellsTabW;
	var questsTabX1 = spellsTabX2 + 8;
	var questsTabW = 72;
	var questsTabX2 = questsTabX1 + questsTabW;
	
	draw_set_font(fntSmaller);
	draw_set_alpha(1);
	if (selectedMenuTab == menuTabInventory) {
		draw_set_color(c_white);
	}
	else {
		draw_set_color(c_gray);
	}
	draw_sprite_stretched(spr_ui_tab, 0, inventoryTabX1, tabY1, inventoryTabW, 28);
	draw_text(inventoryTabX1 + (inventoryTabW - string_width("Inventory")) / 2, tabY1 + 8, "Inventory");
	if (selectedMenuTab == menuTabSpells) {
		draw_set_color(c_white);
	}
	else {
		draw_set_color(c_gray);
	}
	draw_sprite_stretched(spr_ui_tab, 0, spellsTabX1, tabY1, spellsTabW, 28);
	draw_text(spellsTabX1 + (spellsTabW - string_width("Skills")) / 2, tabY1 + 8, "Skills");
	if (selectedMenuTab == menuTabQuests) {
		draw_set_color(c_white);
	}
	else {
		draw_set_color(c_gray);
	}
	draw_sprite_stretched(spr_ui_tab, 0, questsTabX1, tabY1, questsTabW, 28);
	draw_text(questsTabX1 + (questsTabW - string_width("Quests")) / 2, tabY1 + 8, "Quests");
	
	//Items
	if (selectedMenuTab == menuTabInventory) {
		var itemHoveredThisFrame = false;
		var slotSize = 34;
		var slotDrawSize = 28;
		var slotHalf = slotSize / 2;
		var visibleInventorySlots = 30;
		var slotScale = 1;
		var slotSpacingX = 37;
		var slotSpacingY = 37;
		var inventoryGridX = menuLeft + 38;
		var inventoryGridY = menuTop + 50;
		
		for (var slot = 0; slot < visibleInventorySlots; slot++) {
			var slotColumn = slot mod menuWidth;
			var slotRow = slot div menuWidth;
			var slotX = inventoryGridX + (slotColumn * slotSpacingX);
			var slotY = inventoryGridY + (slotRow * slotSpacingY);
			draw_sprite_ext(spr_ui_slot, 0, slotX, slotY, slotScale, slotScale, 0, c_white, 1);
		}
		
		for(var i = 0; i < ds_grid_width(myItems); ++i) {
			var itemColumn = i mod menuWidth;
			var itemRow = i div menuWidth;
			var itemSlotX = inventoryGridX + (itemColumn * slotSpacingX);
			var itemSlotY = inventoryGridY + (itemRow * slotSpacingY);
			var itemX = itemSlotX + 16;
			var itemY = itemSlotY + 16;
			var sprite = myItems[# i, Item.Sprite];
			var itemIsHovered = point_in_rectangle(mouse_x, mouse_y, itemX - slotHalf, itemY - slotHalf, itemX + slotHalf, itemY + slotHalf);
			
			if (itemIsHovered) {
				draw_sprite(spr_ui_slot_selected, 0, itemSlotX - 3, itemSlotY - 3);
			}
			
			var spriteWidth = sprite_get_width(sprite);
			var spriteHeight = sprite_get_height(sprite);
			var drawScale = min(itemScale, slotDrawSize / max(spriteWidth, spriteHeight));
			var drawX = itemX - ((spriteWidth / 2) * drawScale) + (sprite_get_xoffset(sprite) * drawScale);
			var drawY = itemY - ((spriteHeight / 2) * drawScale) + (sprite_get_yoffset(sprite) * drawScale);
			draw_sprite_ext(sprite, 0, drawX, drawY, drawScale, drawScale, 0, c_white, 1);
			
			//Amount
			draw_set_color(c_white);
			draw_set_alpha(1);
			draw_set_font(fntSmaller);
			draw_text(itemX - 12, itemY + 5, myItems[# i, Item.Amount]);
			
			//Check if mouse is hovering over an item
			if (itemIsHovered) {
				itemHoveredThisFrame = true;
				draw_set_alpha(1);
				currentItemSlot = i;
				
				//Draw item info
				if (draggingItem == false && itemLocked == false && (hoveredItemSlot != i || currentItem == undefined || instance_exists(currentItem) == false)) {
					if (instance_exists(objItemParent)) {
						instance_destroy(objItemParent);
					}
					currentItem = instance_create_layer(-32, -32, "MenuItems", myItems[# i, Item.Object]);
					currentItem.price = myItems[# i, Item.Price];
					currentItem.type = myItems[# i, Item.Type];
					currentItem.name = myItems[# i, Item.Name];
					currentItem.isInMenu = true;
					hoveredItemSlot = i;
				}
				if (currentItem != undefined && instance_exists(currentItem)) {
					hoveredItem = currentItem;
				}
			}
		}
		
		if (itemHoveredThisFrame == false && draggingItem == false) {
			hoveredItemSlot = undefined;
		}
	}
	else if (selectedMenuTab == menuTabSpells) {
		draw_set_alpha(1);
		draw_set_font(fntSmaller);
		
		var skillSlotX = menuLeft + 34;
		var skillSlotY = menuTop + 52;
		var skillSlotW = 228;
		var skillSlotH = 58;
		var skillSlotGap = 12;
		
		var skillNames = ["Woodcutting", "Mining", "Smelting"];
		for (var s = 0; s < array_length(skillNames); s++) {
			var skillName = skillNames[s];
			var skillLevel = GetSkillLevel(skillName);
			var skillXP = GetSkillXP(skillName);
			var nextXP = SkillXPForNextLevel(skillLevel);
			var slotTop = skillSlotY + (s * (skillSlotH + skillSlotGap));
			var progressAmount = clamp(skillXP / max(1, nextXP), 0, 1);
			
			draw_sprite_stretched(spr_ui_skill_row, 0, skillSlotX, slotTop, skillSlotW, 56);
			
			draw_set_alpha(1);
			draw_set_color(c_white);
			draw_text(skillSlotX + 12, slotTop + 7, skillName + " Lv. " + string(skillLevel));
			draw_text(skillSlotX + 12, slotTop + 25, string(skillXP) + " / " + string(nextXP) + " XP");
			
			draw_sprite_stretched(spr_ui_xp_bar_back, 0, skillSlotX + 14, slotTop + 42, 200, 11);
			if (progressAmount > 0) {
				draw_sprite_part_ext(spr_ui_xp_bar_fill, 0, 0, 0, floor(sprite_get_width(spr_ui_xp_bar_fill) * progressAmount), sprite_get_height(spr_ui_xp_bar_fill), skillSlotX + 14, slotTop + 42, 200 / sprite_get_width(spr_ui_xp_bar_fill), 1, c_white, 1);
			}
		}
	}
	else {
		draw_set_alpha(1);
		draw_set_font(fntSmaller);
		
		var questX = menuLeft + 34;
		var questY = menuTop + 52;
		var questW = 228;
		var questH = 86;
		var questState = global.quest_woodcutting_state;
		var questProgress = GetWoodcuttingQuestProgress();
		var questRequired = global.quest_woodcutting_required_logs;
		var questProgressAmount = clamp(questProgress / max(1, questRequired), 0, 1);
		var questStatus = "Not started";
		if (questState == 1) {
			questStatus = "Active";
		}
		if (questState == 2) {
			questStatus = "Complete";
			questProgress = questRequired;
			questProgressAmount = 1;
		}
		
		draw_sprite_stretched(spr_ui_skill_row, 0, questX, questY, questW, questH);
		draw_set_color(c_white);
		draw_text(questX + 12, questY + 8, "Approval: Timber Duty");
		draw_text(questX + 12, questY + 28, questStatus);
		draw_text(questX + 12, questY + 46, "Normal Logs: " + string(questProgress) + " / " + string(questRequired));
		draw_sprite_stretched(spr_ui_xp_bar_back, 0, questX + 14, questY + 68, 200, 11);
		if (questProgressAmount > 0) {
			draw_sprite_part_ext(spr_ui_xp_bar_fill, 0, 0, 0, floor(sprite_get_width(spr_ui_xp_bar_fill) * questProgressAmount), sprite_get_height(spr_ui_xp_bar_fill), questX + 14, questY + 68, 200 / sprite_get_width(spr_ui_xp_bar_fill), 1, c_white, 1);
		}
	}
	
	//Draw locked item
	if (selectedMenuTab == menuTabInventory && itemLocked == true) {
		draw_set_alpha(0.5);
		draw_set_color(c_red);
		draw_rectangle(lockedItemX - 16, lockedItemY - 16, lockedItemX + 16, lockedItemY + 16, false);
		draw_set_alpha(1);
	}
	
	//Dragging System
	if (selectedMenuTab == menuTabInventory) {
		if (mouse_check_button(mb_middle)) {
			draggedItem = instance_find(objItemParent, 0);
			if (draggedItem != noone) {
				draggedItem.x = mouse_x;
				draggedItem.y = mouse_y;
				draggedItem.visible = true;
				draggedItem.image_xscale = itemScale;
				draggedItem.image_yscale = itemScale;
				draggingItem = true;
			}
		}
		if (mouse_check_button_pressed(mb_middle)) {
			draggedItemSlot = currentItemSlot;
		}
		if (mouse_check_button_released(mb_middle) && draggedItem != undefined && draggedItem != noone) {
			draggedItem.x = -100;
			draggedItem.y = -100;
			draggingItem = false;
			alarm[0] = 1;
		}
	}
	else {
		draggingItem = false;
	}
	
	//Ensure only 1 item exists at a time
	if (instance_number(objItemParent) > 1) {
		instance_destroy(objItemParent);
	}
	
	//Front of the inventory
	if (selectedMenuTab == menuTabInventory) {
		draw_sprite_stretched(spr_ui_xp_bar_back, 0, menuLeft + 30, menuTop + 250, 236, 11);
	}
	
if (selectedMenuTab == menuTabInventory && hoveredItem != undefined && hoveredItem != noone) {
	DrawHoverItemDetails(hoveredItem);
}

	

