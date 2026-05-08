/// Elemental System - Manages element composition for players and creatures
/// Elements: Fire, Water, Air, Earth (all percentages add up to 100)

/// Create elemental composition struct
function create_elemental_composition(fire = 25, water = 25, air = 25, earth = 25) {
    return {
        fire: fire,
        water: water,
        air: air,
        earth: earth
    };
}

/// Randomize elemental composition
function randomize_elemental_composition() {
    var fire = irandom(100);
    var remaining = 100 - fire;
    
    var water = irandom(remaining);
    remaining -= water;
    
    var air = irandom(remaining);
    var earth = 100 - fire - water - air;
    
    return create_elemental_composition(fire, water, air, earth);
}

/// Get elemental advantage/disadvantage (for potential future use)
function get_elemental_effectiveness(attacking_element, defending_element) {
    switch(attacking_element) {
        case "fire":
            if (defending_element == "air") return 1.5; // Fire beats Air
            if (defending_element == "earth") return 0.5; // Fire weak to Earth
            break;
        case "water":
            if (defending_element == "fire") return 1.5; // Water beats Fire
            if (defending_element == "air") return 0.5; // Water weak to Air
            break;
        case "air":
            if (defending_element == "earth") return 1.5; // Air beats Earth
            if (defending_element == "water") return 0.5; // Air weak to Water
            break;
        case "earth":
            if (defending_element == "water") return 1.5; // Earth beats Water
            if (defending_element == "fire") return 0.5; // Earth weak to Fire
            break;
    }
    return 1.0;
}

/// Print elemental composition for debugging
function print_elemental_composition(name, elements) {
    show_debug_message(name + " Elemental Composition:");
    show_debug_message("  Fire: " + string(elements.fire) + "%");
    show_debug_message("  Water: " + string(elements.water) + "%");
    show_debug_message("  Air: " + string(elements.air) + "%");
    show_debug_message("  Earth: " + string(elements.earth) + "%");
}
