active = false
text = ""
choices = []
choice_index = 0
input_cooldown = 0

show = function(_text, _choices) {
    text = _text

    if (array_length(_choices) == 0) {
        choices = [
            {
                text: "OK",
                action: function() {
                    with (obj_dialogue) {
                        hide()
                    }
                }
            }
        ]
    } else {
        choices = _choices
    }

    choice_index = 0
    active = true
};


hide = function() {
    active = false
    text = ""
    choices = []
    choice_index = 0
    input_cooldown = 2
}
