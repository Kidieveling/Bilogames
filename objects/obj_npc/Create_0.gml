npc_name = "UPDATE";
npc_text = "UPDATE";
dialogue_text = npc_name + ": " + npc_text;
npc_choices = [
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
