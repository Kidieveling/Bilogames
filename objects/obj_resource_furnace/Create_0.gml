/// @description Smelting station; consumes ore from inventory, no auto-gather loop.

event_inherited();

#region Creation Code

sprite_index = spr_furnace;

resource_name = "Furnace";
resource_action = "Smelt";
resource_skill = "Smelting";
required_level = 1;
required_resource_name = "Copper Ore";
required_resource_amount = 1;
item_name = "Copper Bar";
item_sprite = spr_copper_bar;
item_amount = 1;
item_type = Type.Resource;
item_price = 1;
item_object = obj_copper_bar;
xp_reward = 25;
gather_cooldown_max = 45;

#endregion
