npc_name = "UPDATE"
npc_text = "UPDATE"
npc_dialogue = npc_name + ": " + npc_text

with (obj_dialogue) {
    show(other.dialogue_text, other.npc_choices)
}
