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

var hoveredItem = undefined;
	
//Back of the menu
draw_set_alpha(1);
var menuMargin = 16;
var menuX = CameraX() + viewWidth - sprite_get_width(spr_inventoryBackDrop) / 2 - menuMargin;
var menuY = CameraY() + viewHeight - sprite_get_height(spr_inventoryBackDrop) / 2 - menuMargin;
var menuLeft = menuX - sprite_get_xoffset(spr_inventoryBackDrop);
var menuTop = menuY - sprite_get_yoffset(spr_inventoryBackDrop);
draw_sprite(spr_inventory, 0, menuX, menuY);
	
	if (selectedMenuTab == menuTabInventory) {
		draw_sprite(spr_inventoryBackDrop, 0, menuX, menuY);
	}
	else {
		draw_sprite(spr_spellMenu, 0, menuX, menuY);
	}
	
	var tabY1 = menuTop + 42;
	var tabY2 = tabY1 + 26;
	var inventoryTabX1 = menuLeft + 32;
	var inventoryTabX2 = inventoryTabX1 + 88;
	var spellsTabX1 = inventoryTabX2 + 8;
	var spellsTabX2 = spellsTabX1 + 72;
	
	draw_set_font(fntSmaller);
	draw_set_alpha(1);
	if (selectedMenuTab == menuTabInventory) {
		draw_set_color(c_white);
	}
	else {
		draw_set_color(c_gray);
	}
	draw_rectangle(inventoryTabX1, tabY1, inventoryTabX2, tabY2, true);
	draw_text(inventoryTabX1 + 10, tabY1 + 7, "Inventory");
	if (selectedMenuTab == menuTabSpells) {
		draw_set_color(c_white);
	}
	else {
		draw_set_color(c_gray);
	}
	draw_rectangle(spellsTabX1, tabY1, spellsTabX2, tabY2, true);
	draw_text(spellsTabX1 + 10, tabY1 + 7, "Spells");
	
	//Items
	if (selectedMenuTab == menuTabInventory) {
		for(var i = 0; i < ds_grid_width(myItems); ++i) {
			var itemColumn = i mod menuWidth;
			var itemRow = i div menuWidth;
			var itemX = menuLeft + 43 + (itemColumn * itemSeperation);
			var itemY = menuTop + 83 + (itemRow * 36);
			var sprite = myItems[# i, Item.Sprite];
			
			var drawScale = min(itemScale, 32 / max(sprite_get_width(sprite), sprite_get_height(sprite)));
			draw_sprite_ext(sprite, 0, itemX, itemY, drawScale, drawScale, 0, c_white, 1);
			
			//Amount
			draw_set_color(c_white);
			draw_set_alpha(1);
			draw_set_font(fntSmaller);
			draw_text(itemX - 16, itemY + 4, myItems[# i, Item.Amount]);
			
			//Check if mouse is hovering over an item
			var itemHoverPadding = 16;
			if (point_in_rectangle(mouse_x, mouse_y, itemX - itemHoverPadding, itemY - itemHoverPadding, itemX + itemHoverPadding, itemY + itemHoverPadding)) {
				draw_set_alpha(0.25);
				draw_set_color(c_blue);
				draw_rectangle(itemX - itemHoverPadding, itemY - itemHoverPadding, itemX + itemHoverPadding, itemY + itemHoverPadding, false);
				draw_set_alpha(1);
				currentItemSlot = i;
				
				//Draw item info
				if (instance_exists(myItems[# i, Item.Object]) == false && draggingItem == false && itemLocked == false) {
					currentItem = instance_create_layer(-32, -32, "MenuItems", myItems[# i, Item.Object]);
					currentItem.price = myItems[# i, Item.Price];
					currentItem.type = myItems[# i, Item.Type];
					currentItem.name = myItems[# i, Item.Name];
					currentItem.isInMenu = true;
				}
				if (instance_exists(myItems[# i, Item.Object])) {
					hoveredItem = instance_find(myItems[# i, Item.Object], 0);
				}
			}
		}
	}
	else {
		draw_set_alpha(1);
		draw_set_font(fntSmaller);
		draw_set_color(c_white);
		draw_text(menuLeft + 44, menuTop + 88, "No spells learned.");
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
		draw_sprite(spr_inventoryFront, 0, menuX, menuY + 20);
		draw_sprite(spr_scrollIndicator, 0, menuLeft + sprite_get_width(spr_inventoryBackDrop) - 25, menuTop + 380);
	}
	
	if (selectedMenuTab == menuTabInventory && hoveredItem != undefined && hoveredItem != noone) {
		DrawHoverItemDetails(hoveredItem);
	}
	
	
	//Press Button
if (point_in_rectangle(mouse_x, mouse_y, CameraX() + 440, CameraY() + 435, CameraX() + 520, CameraY() + 470) == true && mouse_check_button_pressed(mb_left)) {
	show_message("Button pressed.");
}









