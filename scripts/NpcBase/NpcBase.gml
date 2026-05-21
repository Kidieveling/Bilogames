/// @description NPC base: 8-way facing, default menu stub, interact; bound on obj_npc.

function NpcBase_Register(_inst) {
	with (_inst) {
		is_npc = true;
		image_speed = 0;
		facing_dir = 0;
		face_player_while_dialogue = true;
		
		FaceTowardInstance = function(_target) {
			if (!instance_exists(_target)) return;
			var dir = point_direction(x, y, _target.x, _target.y);
			var sector = floor(((dir + 22.5) mod 360) / 45);
			switch (sector) {
				case 0: facing_dir = 2; break;
				case 1: facing_dir = 3; break;
				case 2: facing_dir = 4; break;
				case 3: facing_dir = 5; break;
				case 4: facing_dir = 6; break;
				case 5: facing_dir = 7; break;
				case 6: facing_dir = 0; break;
				case 7: facing_dir = 1; break;
			}
			image_index = facing_dir;
		};
		
		npc_name = "UPDATE";
		npc_text = "UPDATE";
		dialogue_text = npc_name + ": " + npc_text;
		var npc_inst = id;
		npc_choices = [
			{
				text: "UPDATE",
				npc_inst: npc_inst,
				action: function() {
					if (instance_exists(self.npc_inst)) {
						Dialogue_ShowResponse(self.npc_inst, "UPDATE: This NPC needs dialogue creation code lol.");
					}
				}
			},
			Dialogue_MakeGoodbyeChoice()
		];
		
		OpenDialogueMenu = function() {
			Dialogue_PresentMenu(id, dialogue_text, npc_choices);
		};
		
		interact = function(_player) {
			Dialogue_InteractNpc(id, _player);
		};
	}
}
