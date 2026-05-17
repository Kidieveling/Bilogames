depth = 25

tree_name = "Basic Tree"
required_level = 1
wood_amount = 1
xp_reward = 25

chop_cooldown = 0
chop_cooldown_max = 45

obj_tree_choices = [
	{
		text: "UPDATE",
		action: function() {
			with (obj_dialogue) {
				show("UPDATE: This NPC needs dialogue creation code lol.", []);
			}
		}
	},
	{
		text: "Goodbye.",
		action: function() {
			with (obj_dialogue) {
				hide();
			}
		}
	}
];

interact = function(_player) {
	if (!instance_exists(obj_dialogue)) {
		instance_create_layer(0, 0, "Instances", obj_dialogue);
	}
	
	with (obj_dialogue) {
		show(other.dialogue_text, other.npc_choices);
	}
};
