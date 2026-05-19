event_inherited();

sprite_index = spr_tree_spawn;

resource_name = "Normal Tree";
resource_action = "Chop";
resource_skill = "Woodcutting";
required_level = 1;
required_tool_name = "Bronze Axe";
item_name = "Normal Log";
item_sprite = spr_normal_log;
item_amount = 1;
item_type = Type.Resource;
item_price = 1;
item_object = obj_normal_log;
xp_reward = 25;
gather_cooldown_max = 45;
resource_amount_min = 4;
resource_amount_max = 7;
resource_amount_available = irandom_range(resource_amount_min, resource_amount_max);
success_chance = 75;
depleted_sprite = spr_resource;
respawn_time_min = 600;
respawn_time_max = 900;
