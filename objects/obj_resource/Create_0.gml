/// @description Gather node: room creation code sets fields; gather loop in ResourceGather script.

#region Creation Code Defaults

resource_name = "UPDATE Resource";
resource_action = "Gather";
resource_skill = "";
required_level = 1;
required_tool_name = "";
required_resource_name = "";
required_resource_amount = 1;
item_name = "";
item_sprite = -1;
item_amount = 1;
item_type = Type.Resource;
item_price = 0;
item_object = noone;
xp_reward = 0;

gather_cooldown = 0;
gather_cooldown_max = 30;
gathering_active = false;
gathering_player = noone;
resource_amount_min = 3;
resource_amount_max = 6;
resource_amount_available = irandom_range(resource_amount_min, resource_amount_max);
success_chance = 75;
depleted = false;
depleted_sprite = spr_resource;
active_sprite = -1;
active_resource_action = "";
respawn_timer = 0;
respawn_time_min = 600;
respawn_time_max = 900;

#endregion

ResourceGather_Register(id);
