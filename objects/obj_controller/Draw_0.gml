/// @description Draw The Menu
draw_self();

var viewWidth = room_width;
var viewHeight = room_height;
if (view_camera[0] >= 0) {
	viewWidth = camera_get_view_width(view_camera[0]);
	viewHeight = camera_get_view_height(view_camera[0]);
}

draw_set_alpha(1);
draw_sprite(spr_HUD, 0, CameraX() + sprite_get_xoffset(spr_HUD), CameraY() + sprite_get_yoffset(spr_HUD));
draw_sprite(spr_skillBar, 0, CameraMiddleX(), CameraY() + viewHeight - sprite_get_yoffset(spr_skillBar) - 12);

if (isShowingMenu) {
	//Pause the game
	draw_set_color(c_black);
	draw_set_alpha(.75);
	draw_rectangle(0, 0, room_width, room_height, false);
	
	//Back of the inventory
	draw_set_alpha(1);
	var inventoryX = CameraX() + 175;
	var inventoryY = CameraMiddleY();
	var inventoryLeft = inventoryX - sprite_get_xoffset(spr_inventoryBackDrop);
	var inventoryTop = inventoryY - sprite_get_yoffset(spr_inventoryBackDrop);
	draw_sprite(spr_inventory, 0, inventoryX, inventoryY);
	draw_sprite(spr_inventoryBackDrop, 0, inventoryX, inventoryY);
	draw_sprite(spr_spellMenu, 0, CameraX() + viewWidth - sprite_get_xoffset(spr_spellMenu) - 48, inventoryY);
	
	//Items
	for(var i = 0; i < ds_grid_width(myItems); ++i) {
		var itemColumn = i mod menuWidth;
		var itemRow = i div menuWidth;
		var itemX = inventoryLeft + 43 + (itemColumn * itemSeperation);
		var itemY = inventoryTop + 83 + (itemRow * 36);
		var sprite = myItems[# i, Item.Sprite];
		
		var drawScale = min(itemScale, 32 / max(sprite_get_width(sprite), sprite_get_height(sprite)));
		draw_sprite_ext(sprite, 0, itemX, itemY, drawScale, drawScale, 0, c_white, 1);
		
		//Amount
		draw_set_color(c_white);
		draw_set_alpha(1);
		draw_set_font(fntSmaller);
		draw_text(itemX - 16, itemY + 4, myItems[# i, Item.Amount]);
		
		//Check if mouse is hovering over an item
		if (point_in_rectangle(mouse_x, mouse_y, itemX - 16, itemY - 16, itemX + 16, itemY + 16)) {
			draw_set_alpha(0.25);
			draw_set_color(c_blue);
			draw_rectangle(itemX - 16, itemY - 16, itemX + 16, itemY + 16, false);
			draw_set_alpha(1);
			currentItemSlot = i;
			
			//Draw item info
			if (instance_exists(myItems[# i, Item.Object]) == false && draggingItem == false && itemLocked == false) {
				currentItem = instance_create_layer(-32, -32, "MenuItems", myItems[# i, Item.Object]);
				currentItem.price = myItems[# i, Item.Price];
				currentItem.type = myItems[# i, Item.Type];
				currentItem.name = myItems[# i, Item.Name];
				currentItem.isInMenu = true;
				if (showingDescription) {
					currentItem.isShowingInfo = true;
				}
			}
			
			//Clicked on an item
			if (mouse_check_button_pressed(mb_left) && showingDescription == false) {
				sequence = layer_sequence_create("Instances", CameraMiddleX(), CameraMiddleY(), sqDescriptionAnimation);
			}
			//Lock Item
			if (mouse_check_button_pressed(mb_right) && itemLocked == false && showingDescription == true) {
				itemLocked = true;
				lockedItemX = itemX;
				lockedItemY = itemY;
			}
			else if (mouse_check_button_pressed(mb_right) && itemLocked == true) {
				itemLocked = false;
			}
		}
	}
	
	//Draw locked item
	if (itemLocked == true) {
		draw_set_alpha(0.5);
		draw_set_color(c_red);
		draw_rectangle(lockedItemX - 16, lockedItemY - 16, lockedItemX + 16, lockedItemY + 16, false);
		draw_set_alpha(1);
	}
	
	//Dragging System
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
	
	//Exit description
	if (point_in_rectangle(mouse_x, mouse_y, CameraX() + 580, CameraY() + 35, CameraX() + 620, CameraY() + 70) == true) {
		if(mouse_check_button_pressed(mb_left) && sequence != undefined) {
			layer_sequence_headdir(sequence, seqdir_left);
			layer_sequence_play(sequence);
			showingDescription = false;
			instance_destroy(objItemParent);
		}
	}
	
	//Ensure only 1 item exists at a time
	if (instance_number(objItemParent) > 1) {
		instance_destroy(objItemParent);
	}
	
	//Front of the inventory
	draw_sprite(spr_inventoryFront, 0, inventoryX, inventoryY + 20);
	draw_sprite(spr_scrollIndicator, 0, inventoryLeft + sprite_get_width(spr_inventoryBackDrop) - 25, inventoryTop + 380);
	
	//Sort Type
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_font(fntSmaller);
	if (sortType == SortType.Name) {
		draw_text(inventoryLeft + 37, inventoryTop + 397, "Sorting by Name");
	}
	if (sortType == SortType.Amount) {
		draw_text(inventoryLeft + 37, inventoryTop + 397, "Sorting by Amount");
	}
	if (sortType == SortType.Price) {
		draw_text(inventoryLeft + 37, inventoryTop + 397, "Sorting by Price");
	}
	if (sortType == SortType.Type) {
		draw_text(inventoryLeft + 37, inventoryTop + 397, "Sorting by Type");
	}
	
	//Press Button
	if (point_in_rectangle(mouse_x, mouse_y, CameraX() + 440, CameraY() + 435, CameraX() + 520, CameraY() + 470) == true && mouse_check_button_pressed(mb_left)) {
		show_message("Button pressed.");
	}
}

draw_sprite(spr_cursor, 0, mouse_x, mouse_y);









