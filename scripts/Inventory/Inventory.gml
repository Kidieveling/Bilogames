function InventoryAddItem(_item) {
    for (var i = 0; i < global.inventory_slots; i++) {
        if (global.inventory[i] == noone) {
            global.inventory[i] = _item;
            return true;
        }
    }

    return false;
}


