/// @description Fixed HUD: skill bar, menu panel, tabs, inventory grid, skills/quest panels; bound on obj_controller.

function ControllerUI_Register(_inst) {
	with (_inst) {
		
		GetMenuLayout = function() {
			var viewWidth = room_width;
			var viewHeight = room_height;
			if (view_camera[0] >= 0) {
				viewWidth = camera_get_view_width(view_camera[0]);
				viewHeight = camera_get_view_height(view_camera[0]);
			}
			var menuMargin = 16;
			var menuLeft = CameraX() + viewWidth - 296 - menuMargin;
			var menuTop = CameraY() + viewHeight - 296 - menuMargin + 18;
			var tabY1 = menuTop - 27;
			var tabY2 = tabY1 + 28;
			var inventoryTabX1 = menuLeft + 22;
			var inventoryTabX2 = inventoryTabX1 + 80;
			var spellsTabX1 = inventoryTabX2 + 8;
			var spellsTabX2 = spellsTabX1 + 72;
			var questsTabX1 = spellsTabX2 + 8;
			var questsTabX2 = questsTabX1 + 72;
			var inventoryGridX = menuLeft + 38;
			var inventoryGridY = menuTop + 50;
			return {
				view_width: viewWidth,
				view_height: viewHeight,
				menu_left: menuLeft,
				menu_top: menuTop,
				tab_y1: tabY1,
				tab_y2: tabY2,
				inventory_tab_x1: inventoryTabX1,
				inventory_tab_x2: inventoryTabX2,
				spells_tab_x1: spellsTabX1,
				spells_tab_x2: spellsTabX2,
				quests_tab_x1: questsTabX1,
				quests_tab_x2: questsTabX2,
				inventory_grid_x: inventoryGridX,
				inventory_grid_y: inventoryGridY
			};
		};
		
		StepFixedUI = function() {
			var layout = GetMenuLayout();
			
			if (mouse_check_button_pressed(mb_left)) {
				if (point_in_rectangle(mouse_x, mouse_y, layout.inventory_tab_x1, layout.tab_y1, layout.inventory_tab_x2, layout.tab_y2)) {
					selectedMenuTab = menuTabInventory;
				}
				if (point_in_rectangle(mouse_x, mouse_y, layout.spells_tab_x1, layout.tab_y1, layout.spells_tab_x2, layout.tab_y2)) {
					selectedMenuTab = menuTabSpells;
				}
				if (point_in_rectangle(mouse_x, mouse_y, layout.quests_tab_x1, layout.tab_y1, layout.quests_tab_x2, layout.tab_y2)) {
					selectedMenuTab = menuTabQuests;
				}
			}
			
			if (selectedMenuTab != menuTabInventory || !ds_exists(myItems, ds_type_grid)) {
				draggingItem = false;
				hoveredItemSlot = undefined;
				currentItemSlot = undefined;
				if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
					instance_destroy(currentItem);
				}
				currentItem = undefined;
				return;
			}
			
			var slotSize = 34;
			var slotHalf = slotSize / 2;
			var slotSpacingX = 37;
			var slotSpacingY = 37;
			var hoveredSlot = undefined;
			
			for (var i = 0; i < ds_grid_width(myItems); i++) {
				var itemColumn = i mod menuWidth;
				var itemRow = i div menuWidth;
				var itemSlotX = layout.inventory_grid_x + (itemColumn * slotSpacingX);
				var itemSlotY = layout.inventory_grid_y + (itemRow * slotSpacingY);
				var itemX = itemSlotX + 16;
				var itemY = itemSlotY + 16;
				
				if (point_in_rectangle(mouse_x, mouse_y, itemX - slotHalf, itemY - slotHalf, itemX + slotHalf, itemY + slotHalf)) {
					hoveredSlot = i;
					break;
				}
			}
			
			if (hoveredSlot != undefined) {
				currentItemSlot = hoveredSlot;
				if (!draggingItem && !itemLocked && (hoveredItemSlot != hoveredSlot || currentItem == undefined || !instance_exists(currentItem))) {
					if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
						instance_destroy(currentItem);
					}
					currentItem = instance_create_layer(-32, -32, "MenuItems", myItems[# hoveredSlot, Item.Object]);
					currentItem.visible = false;
					currentItem.price = myItems[# hoveredSlot, Item.Price];
					currentItem.type = myItems[# hoveredSlot, Item.Type];
					currentItem.name = myItems[# hoveredSlot, Item.Name];
					currentItem.isInMenu = true;
					hoveredItemSlot = hoveredSlot;
				}
			} else if (!draggingItem) {
				currentItemSlot = undefined;
				hoveredItemSlot = undefined;
				if (currentItem != undefined && instance_exists(currentItem) && variable_instance_exists(currentItem, "isInMenu") && currentItem.isInMenu) {
					instance_destroy(currentItem);
				}
				currentItem = undefined;
			}
			
			if (mouse_check_button(mb_middle)) {
				draggedItem = currentItem;
				if (draggedItem != undefined && instance_exists(draggedItem)) {
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
			if (mouse_check_button_released(mb_middle) && draggedItem != undefined && instance_exists(draggedItem)) {
				draggedItem.x = -100;
				draggedItem.y = -100;
				draggedItem.visible = false;
				draggingItem = false;
				alarm[0] = 1;
			}
		};
		
		SwapInventoryDragSlots = function() {
			if (currentItemSlot == undefined || draggedItemSlot == undefined) {
				return;
			}
			var tempGrid = ds_grid_create(1, Item.Height);
			ds_grid_set_grid_region(tempGrid, myItems, currentItemSlot, 0, currentItemSlot, Item.Height - 1, 0, 0);
			ds_grid_set_grid_region(myItems, myItems, draggedItemSlot, 0, draggedItemSlot, Item.Height - 1, currentItemSlot, 0);
			ds_grid_set_grid_region(myItems, tempGrid, 0, 0, 0, Item.Height - 1, draggedItemSlot, 0);
			ds_grid_destroy(tempGrid);
		};
		
		DrawFixedUI = function() {
			var layout = GetMenuLayout();
			var viewWidth = layout.view_width;
			var viewHeight = layout.view_height;
			var menuLeft = layout.menu_left;
			var menuTop = layout.menu_top;
			var hoveredItem = undefined;
			
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
			
			draw_set_alpha(1);
			var menuScale = 2;
			draw_sprite_ext(spr_ui_panel, 0, menuLeft, menuTop, menuScale, menuScale, 0, c_white, 1);
			
			var tabY1 = layout.tab_y1;
			var inventoryTabX1 = layout.inventory_tab_x1;
			var inventoryTabW = 80;
			var inventoryTabX2 = layout.inventory_tab_x2;
			var spellsTabX1 = layout.spells_tab_x1;
			var spellsTabW = 72;
			var spellsTabX2 = layout.spells_tab_x2;
			var questsTabX1 = layout.quests_tab_x1;
			var questsTabW = 72;
			var questsTabX2 = layout.quests_tab_x2;
			
			draw_set_font(fntSmaller);
			draw_set_alpha(1);
			draw_set_color(selectedMenuTab == menuTabInventory ? c_white : c_gray);
			draw_sprite_stretched(spr_ui_tab, 0, inventoryTabX1, tabY1, inventoryTabW, 28);
			draw_text(inventoryTabX1 + (inventoryTabW - string_width("Inventory")) / 2, tabY1 + 8, "Inventory");
			draw_set_color(selectedMenuTab == menuTabSpells ? c_white : c_gray);
			draw_sprite_stretched(spr_ui_tab, 0, spellsTabX1, tabY1, spellsTabW, 28);
			draw_text(spellsTabX1 + (spellsTabW - string_width("Skills")) / 2, tabY1 + 8, "Skills");
			draw_set_color(selectedMenuTab == menuTabQuests ? c_white : c_gray);
			draw_sprite_stretched(spr_ui_tab, 0, questsTabX1, tabY1, questsTabW, 28);
			draw_text(questsTabX1 + (questsTabW - string_width("Quests")) / 2, tabY1 + 8, "Quests");
			
			if (selectedMenuTab == menuTabInventory) {
				var slotSize = 34;
				var slotDrawSize = 28;
				var slotHalf = slotSize / 2;
				var visibleInventorySlots = 30;
				var slotScale = 1;
				var slotSpacingX = 37;
				var slotSpacingY = 37;
				var inventoryGridX = layout.inventory_grid_x;
				var inventoryGridY = layout.inventory_grid_y;
				
				for (var slot = 0; slot < visibleInventorySlots; slot++) {
					var slotColumn = slot mod menuWidth;
					var slotRow = slot div menuWidth;
					var slotX = inventoryGridX + (slotColumn * slotSpacingX);
					var slotY = inventoryGridY + (slotRow * slotSpacingY);
					draw_sprite_ext(spr_ui_slot, 0, slotX, slotY, slotScale, slotScale, 0, c_white, 1);
				}
				
				for (var i = 0; i < ds_grid_width(myItems); ++i) {
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
					
					draw_set_color(c_white);
					draw_set_alpha(1);
					draw_set_font(fntSmaller);
					draw_text(itemX - 12, itemY + 5, myItems[# i, Item.Amount]);
					
					if (itemIsHovered && currentItem != undefined && instance_exists(currentItem)) {
						hoveredItem = currentItem;
					}
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
				var questX = menuLeft + 30;
				var questY = menuTop + 46;
				var questW = 236;
				var questH = 214;
				var questInfo = Quest_Woodcutting_GetQuestInfo();
				UI_DrawBorderedPanel(questX, questY, questX + questW, questY + questH, c_black, 0.78, c_white, 0.9);
				draw_set_color(c_white);
				draw_text(questX + 12, questY + 8, questInfo.title);
				draw_set_color(c_yellow);
				draw_text(questX + 12, questY + 30, "Status: " + questInfo.status);
				draw_set_color(c_white);
				draw_text(questX + 12, questY + 56, "Objective");
				draw_text_ext(questX + 12, questY + 72, questInfo.objective, 16, questW - 24);
				draw_set_color(c_yellow);
				draw_text(questX + 12, questY + 112, "Return: " + questInfo.return_to);
				draw_set_color(c_white);
				draw_text(questX + 12, questY + 136, "Rewards");
				draw_text_ext(questX + 12, questY + 152, questInfo.rewards, 16, questW - 24);
				draw_text(questX + 12, questY + 178, "Normal Logs: " + string(questInfo.progress) + " / " + string(questInfo.required));
				draw_sprite_stretched(spr_ui_xp_bar_back, 0, questX + 14, questY + 196, 208, 11);
				if (questInfo.progress_amount > 0) {
					draw_sprite_part_ext(spr_ui_xp_bar_fill, 0, 0, 0, floor(sprite_get_width(spr_ui_xp_bar_fill) * questInfo.progress_amount), sprite_get_height(spr_ui_xp_bar_fill), questX + 14, questY + 196, 208 / sprite_get_width(spr_ui_xp_bar_fill), 1, c_white, 1);
				}
			}
			
			if (selectedMenuTab == menuTabInventory && itemLocked == true) {
				UI_DrawPanel(lockedItemX - 16, lockedItemY - 16, lockedItemX + 16, lockedItemY + 16, c_red, 0.5);
			}
			if (selectedMenuTab == menuTabInventory) {
				draw_sprite_stretched(spr_ui_xp_bar_back, 0, menuLeft + 30, menuTop + 250, 236, 11);
			}
			if (selectedMenuTab == menuTabInventory && hoveredItem != undefined && hoveredItem != noone) {
				DrawHoverItemDetails(hoveredItem);
			}
		};
	}
}
