function inventory_add(_name, _amount, _sprite, _type) {
    if (argument_count < 4) {
        _type = "item"
    }

    for (var i = 0; i < array_length(global.inventory); i++) {
        var item = global.inventory[i]

        if (item != noone && item.name == _name) {
            item.amount += _amount
            global.inventory[i] = item
            return true
        }
    }

    for (var slot = 0; slot < array_length(global.inventory); slot++) {
        if (global.inventory[slot] == noone) {
            global.inventory[slot] = {
                name: _name,
                amount: _amount,
                sprite: _sprite,
                type: _type
            }
            return true
        }
    }

    return false
}

function inventory_has(_name) {
    return inventory_count(_name) > 0
}

function inventory_count(_name) {
    var count = 0

    for (var i = 0; i < array_length(global.inventory); i++) {
        var item = global.inventory[i]

        if (item != noone && item.name == _name) {
            count += item.amount
        }
    }

    return count
}
