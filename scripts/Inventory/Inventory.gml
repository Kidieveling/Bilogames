/// @description Player inventory DS grid helpers, master item list, stacking rules, and skill XP curves.
/// Rows use Item.* columns; obj_controller owns the live player grid.

#region Debug And Grid Access

function InventoryDebugLog(message) {
	show_debug_message("[Inventory] " + string(message))
}

function Inventory_GetPlayerGrid() {
	if (instance_exists(obj_controller)) {
		return obj_controller.myItems;
	}
	return undefined;
}

#endregion

#region Master List Lookup

function Inventory_LookupMasterItem(item_name, amount) {
	if (is_undefined(amount)) {
		amount = 1;
	}
	if (!variable_global_exists("AllItems") || !ds_exists(global.AllItems, ds_type_grid)) {
		return undefined;
	}
	for (var i = 0; i < ds_grid_width(global.AllItems); i++) {
		if (global.AllItems[# i, Item.Name] == item_name) {
			return [
				global.AllItems[# i, Item.Name],
				global.AllItems[# i, Item.Sprite],
				amount,
				global.AllItems[# i, Item.Type],
				global.AllItems[# i, Item.Price],
				global.AllItems[# i, Item.Object]
			];
		}
	}
	return undefined;
}

function Inventory_GrantItem(grid, item_name, amount) {
	if (is_undefined(grid)) {
		grid = Inventory_GetPlayerGrid();
	}
	if (is_undefined(amount)) {
		amount = 1;
	}
	if (is_undefined(grid)) {
		return false;
	}
	var attributes = Inventory_LookupMasterItem(item_name, amount);
	if (is_undefined(attributes)) {
		InventoryDebugLog("Cannot grant unknown item: " + string(item_name));
		return false;
	}
	return AddItem(grid, attributes);
}

function AddItemToMasterList(attributes){
	
	if (variable_global_exists("AllItems") == false) {
		InventoryDebugLog("No variable found called AllItems.")
		return
	}
	if (ds_exists(global.AllItems, ds_type_grid) == false) {
		InventoryDebugLog("No AllItems DS grid found.");
		return
	}
	if (is_array(attributes) == false || array_length(attributes) != Item.Height) {
		InventoryDebugLog("Input for adding items isn't right.");
		return;
	}
	
	ds_grid_resize(global.AllItems, ds_grid_width(global.AllItems) + 1, ds_grid_height(global.AllItems))
	for (var i = 0; i < array_length(attributes); ++i) {
		global.AllItems[# ds_grid_width(global.AllItems) - 1, i] = attributes[i];
	}
}

#endregion

#region Grid Queries

function HasItem(grid, item_name) {
	for (var i = 0; i < ds_grid_width(grid); i++) {
		if (grid[# i, Item.Name] == item_name) {
			return true
		}
	}

	return false
}

function GetItemAmount(grid, item_name) {
	for (var i = 0; i < ds_grid_width(grid); i++) {
		if (grid[# i, Item.Name] == item_name) {
			return grid[# i, Item.Amount]
		}
	}
	
	return 0
}

function RemoveItem(grid, item_name, amount) {
	if (ds_exists(grid, ds_type_grid) == false) {
		InventoryDebugLog("No grid found.")
		return false
	}
	if (is_undefined(amount)) {
		amount = 1
	}
	
	for (var i = 0; i < ds_grid_width(grid); i++) {
		if (grid[# i, Item.Name] == item_name) {
			if (grid[# i, Item.Amount] > amount) {
				grid[# i, Item.Amount] -= amount
			} else {
				// Shift rows up instead of leaving a hole — grid width is slot count, not max capacity.
				for (var j = i; j < ds_grid_width(grid) - 1; j++) {
					for (var k = 0; k < Item.Height; k++) {
						grid[# j, k] = grid[# j + 1, k]
					}
				}
				ds_grid_resize(grid, ds_grid_width(grid) - 1, ds_grid_height(grid))
			}
			return true
		}
	}
	
	return false
}

#endregion

#region Add Item

function AddItem(grid, attributes) {
	var canStack = true
	var inventoryLimit = 40
	if (instance_exists(obj_controller)) {
		inventoryLimit = obj_controller.maxInventorySlots
	}
	
	if (ds_exists(grid, ds_type_grid) == false) {
		InventoryDebugLog("No grid found.")
		return false
	}
	if (is_array(attributes) == false || array_length(attributes) != Item.Height) {
		InventoryDebugLog("Wrong attributes.")
		return false
	}
	if (variable_global_exists("AllItems") == false) {
		InventoryDebugLog("No variable found called AllItems.")
		return false
	}
	if (ds_exists(global.AllItems, ds_type_grid) == false) {
		InventoryDebugLog("No AllItems DS grid found.")
		return false
	}
	
	var isInMasterList = false
	for(var i = 0; i < ds_grid_width(global.AllItems); ++i) {
		if (global.AllItems[# i, Item.Name] == attributes[Item.Name]) {
			isInMasterList = true
		}
	}
	if (isInMasterList == false) {
		InventoryDebugLog("Cannot find this item: " + string(attributes[Item.Name]))
		return false;
	}
	
	// Gear and tools occupy one slot each; split multi-quantity grants into separate rows.
	if (attributes[Item.Type] != Type.Consumable && attributes[Item.Type] != Type.Resource) {
		canStack = false
		if (attributes[Item.Amount] > 1) {
			for(var i = 0; i < attributes[Item.Amount]; ++i) {
				AddItem(grid, [attributes[Item.Name], attributes[Item.Sprite], 1, attributes[Item.Type], attributes[Item.Price], attributes[Item.Object]]);
			}
			return true;
		}
	}
	
	if (canStack) {
		for(var i = 0; i < ds_grid_width(grid); ++i) {
			if (attributes[Item.Name] == grid[# i, Item.Name]) {
				grid[# i, Item.Amount] += attributes[Item.Amount]
				return true
			}
		}
	}
	
	if (inventoryLimit <= ds_grid_width(grid)) {
		return false
	}
	
	ds_grid_resize(grid, ds_grid_width(grid) + 1, ds_grid_height(grid))
	for(var i = 0; i < array_length(attributes); ++i) {
		grid[# ds_grid_width(grid) - 1, i] = attributes[i]
	}
	
	return true
	
}

#endregion

#region Sort And Utilities

function SortInventory(grid, sortType) {
	
	switch(sortType) {
		case SortType.Name:
			sortType = Item.Name
		break
		case SortType.Amount:
			sortType = Item.Amount
		break
		case SortType.Price:
			sortType = Item.Price
		break
		case SortType.Type:
			sortType = Item.Type
		break
	}
	
	var sortedGrid = ds_grid_create(0, Item.Height)
	var lowestItem = 0, savedItems
	savedItems[0] = undefined
	
	for(var i = 0; i < ds_grid_width(grid); ++i) {
		for(var j = 0; j < ds_grid_width(grid); ++j) {
			var item1 = grid[# lowestItem, sortType]
			var item2 = grid[# j, sortType];
			if(item2 <= item1 && ArrayContains(savedItems, j) == false) {
				lowestItem = j
			}
		}
		AddItem(sortedGrid, [grid[# lowestItem, Item.Name], grid[# lowestItem, Item.Sprite], grid[# lowestItem, Item.Amount],
		grid[# lowestItem, Item.Type], grid[# lowestItem, Item.Price], grid[# lowestItem, Item.Object]]);
		savedItems[i] = lowestItem
		for(var l = 0; l < ds_grid_width(grid); ++l) {
			if(ArrayContains(savedItems, l) == false) {
				lowestItem = l
			}
		}
	}
	
	if (ds_grid_width(sortedGrid) > 0) {
		ds_grid_set_grid_region(grid, sortedGrid, 0, 0, ds_grid_width(sortedGrid) - 1, Item.Height - 1, 0, 0);
	}
	ds_grid_destroy(sortedGrid);
	return grid;
}

function ArrayContains(array, number) {
	for(var i = 0; i < array_length(array); ++i) {
		if (array[i] == number) {
			return true
		}
	}
	return false
}

#endregion

#region Skill XP

function SkillXPForNextLevel(level) {
	return SkillTotalXPForLevel(level + 1) - SkillTotalXPForLevel(level)
}

function SkillTotalXPForLevel(level) {
	var points = 0
	for (var i = 1; i < level; i++) {
		points += floor(i + 300 * power(2, i / 7))
	}
	return floor(points / 4)
}

function SkillExists(skill_name) {
	switch (skill_name) {
		case "Woodcutting":
		case "Mining":
		case "Smelting":
			return true
	}
	return false
}

function GetSkillLevel(skill_name) {
	switch (skill_name) {
		case "Woodcutting": return global.woodcutting_level
		case "Mining": return global.mining_level
		case "Smelting": return global.smelting_level
	}
	return 1
}

function GetSkillXP(skill_name) {
	switch (skill_name) {
		case "Woodcutting": return global.woodcutting_xp
		case "Mining": return global.mining_xp
		case "Smelting": return global.smelting_xp
	}
	return 0
}

function SetSkillLevel(skill_name, level) {
	switch (skill_name) {
		case "Woodcutting":
			global.woodcutting_level = level
		break
		
		case "Mining":
			global.mining_level = level
		break
		
		case "Smelting":
			global.smelting_level = level
		break
	}
}

function SetSkillXP(skill_name, xp) {
	switch (skill_name) {
		case "Woodcutting":
			global.woodcutting_xp = xp
		break
		
		case "Mining":
			global.mining_xp = xp
		break
		
		case "Smelting":
			global.smelting_xp = xp
		break
	}
}

function AddSkillXP(skill_name, amount) {
	var old_level = GetSkillLevel(skill_name)
	var new_xp = GetSkillXP(skill_name) + amount
	var new_level = old_level
	
	while (new_xp >= SkillXPForNextLevel(new_level)) {
		new_xp -= SkillXPForNextLevel(new_level)
		new_level += 1
	}
	
	SetSkillXP(skill_name, new_xp)
	SetSkillLevel(skill_name, new_level)
	
	return new_level > old_level
}

#endregion
