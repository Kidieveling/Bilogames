/// Battle System - Handles combat calculations

/// Calculate attack based on attacker's elemental composition
/// Air element increases hit count
function calculate_attack(attacker_elements, attacker_attack_stat) {
    var base_damage = attacker_attack_stat;
    var hit_count = 1; // Minimum 1 hit
    
    // Air element increases number of hits (20% air = 20% chance for extra hit, etc)
    var air_hits = floor(attacker_elements.air / 20); // Each 20% air = +1 potential hit
    if (random(100) < (attacker_elements.air mod 20) * 5) {
        air_hits += 1;
    }
    hit_count += air_hits;
    
    show_debug_message("Attack Calculation: " + string(hit_count) + " hits of " + string(base_damage) + " damage each");
    
    return {
        damage_per_hit: base_damage,
        hit_count: hit_count,
        total_damage: base_damage * hit_count
    };
}

/// Calculate defense based on defender's elemental composition
/// Earth element provides armor/hardening damage reduction
function calculate_defense(defender_elements, incoming_damage) {
    var armor_reduction = 0;
    
    // Earth element provides damage reduction (each 25% earth = 10% damage reduction)
    armor_reduction = (defender_elements.earth / 25) * 10;
    
    var damage_reduction_percent = min(armor_reduction, 75); // Cap at 75% reduction
    var final_damage = incoming_damage * (1 - (damage_reduction_percent / 100));
    
    show_debug_message("Defense Calculation: " + string(incoming_damage) + " damage reduced by " + string(damage_reduction_percent) + "% to " + string(final_damage));
    
    return {
        original_damage: incoming_damage,
        reduction_percent: damage_reduction_percent,
        final_damage: final_damage
    };
}

/// Execute a full turn of combat
function execute_combat_turn(attacker, defender) {
    show_debug_message("\\n=== COMBAT TURN ===");
    show_debug_message(attacker.name + " attacks " + defender.name + "!");
    
    // Calculate attack
    var attack_result = calculate_attack(attacker.elements, attacker.attack_stat);
    
    // Calculate defense
    var defense_result = calculate_defense(defender.elements, attack_result.total_damage);
    
    // Apply damage
    defender.current_hp -= defense_result.final_damage;
    defender.current_hp = max(0, defender.current_hp);
    
    show_debug_message(defender.name + " takes " + string(defense_result.final_damage) + " damage! HP: " + string(defender.current_hp) + "/" + string(defender.max_hp));
    show_debug_message("====================\\n");
    
    return defense_result.final_damage;
}
