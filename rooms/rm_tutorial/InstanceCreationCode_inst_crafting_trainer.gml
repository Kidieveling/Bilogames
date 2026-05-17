sprite_index = spr_crafting_trainer;

npc_name = "Crafting Trainer";
npc_text = "Want to learn about crafting?";
dialogue_text = npc_name + ": " + npc_text;

npc_choices = [
    {
        text: "Can you teach me?",
        action: function() {
            if (!HasItem(obj_controller.myItems, "Normal Log")) {
                with (obj_dialogue) {
                    show("Crafting Trainer: You need to gather some Normal Logs", []);
                }
            } else if (!HasItem(obj_controller.myItems, "Copper Ore")) {
                with (obj_dialogue) {
                    show("Crafting Trainer: You need to gather some Copper Ore", []);
                }
            } else if (!HasItem(obj_controller.myItems, "Knife")) {
                with (obj_controller) {
                    AddItem(myItems, ["Knife", spr_knife, 1, Type.Tool, 5, obj_knife]);
                }
            } else {
                with (obj_dialogue) {
                    show("Use your knife on a log and use your ore on a furnace", []);
                }
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