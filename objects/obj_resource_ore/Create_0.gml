/// @description Mining node; creation code overrides obj_resource defaults.

event_inherited();

#region Creation Code

sprite_index = spr_ore_spawn;

resource_name = "Copper Node";
resource_action = "Swing Pickaxe";
resource_skill = "Mining";
required_level = 1;
required_tool_name = "Bronze Pickaxe";
item_name = "Copper Ore";
item_sprite = spr_copper_ore;
item_amount = 1;
item_type = Type.Resource;
item_price = 1;
item_object = obj_copper_ore;
xp_reward = 25;
gather_cooldown_max = 45;
resource_amount_min = 3;
resource_amount_max = 6;
resource_amount_available = irandom_range(resource_amount_min, resource_amount_max);
success_chance = 70;
depleted_sprite = spr_resource;
respawn_time_min = 720;
respawn_time_max = 1080;

#endregion
