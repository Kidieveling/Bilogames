depth = 100
trader_name = "Trader"

interact = function(_player) {
    with (obj_dialogue) {
        show("Trader: I can help with supplies later.", [])
    }
}

get_context_options = function(_player) {
    var target = id

    return [
        {
            text: "Talk-to " + trader_name,
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
                    show("A trader looking after the shop.", [])
                }
            }
        }
    ]
}
