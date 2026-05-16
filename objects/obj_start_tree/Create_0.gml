depth = 25

tree_name = "Tree"
required_level = 1
wood_amount = 1
xp_reward = 25

chop_cooldown = 0
chop_cooldown_max = 45

interact = function(_player) {
    if (!inventory_has("Bronze axe")) {
        with (obj_dialogue) {
            show("You need an axe to chop this tree.", [])
        }
        return
    }

    if (global.woodcutting_level < required_level) {
        with (obj_dialogue) {
            show("You need level " + string(other.required_level) + " Woodcutting to chop this tree.", [])
        }
        return
    }

    if (chop_cooldown > 0) {
        return
    }

    chop_cooldown = chop_cooldown_max

    var success_chance = 35 + global.woodcutting_level * 4
    success_chance = clamp(success_chance, 35, 90)

    if (irandom(99) < success_chance) {
        if (inventory_add("Wood", wood_amount, spr_item_wood, "resource")) {
            global.woodcutting_xp += xp_reward

            with (obj_dialogue) {
                show("You get some wood.", [])
            }
        } else {
            with (obj_dialogue) {
                show("Your inventory is full.", [])
            }
        }
    } else {
        with (obj_dialogue) {
            show("You swing your axe, but fail to get any wood.", [])
        }
    }
}

get_context_options = function(_player) {
    var target = id

    return [
        {
            text: "Chop tree",
            action: function() {
                with (target) {
                    interact(_player)
                }
            }
        },
        {
            text: "Examine",
            action: function() {
                with (obj_dialogue) {
                    show("A " + string(target.tree_name) + ". It requires level " + string(target.required_level) + " Woodcutting.", [])
                }
            }
        }
    ]
}
