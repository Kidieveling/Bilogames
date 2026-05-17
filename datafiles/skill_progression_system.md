# Skill Progression System

This is the core direction for leveling and crafting skills in the game.

The goal is to make high levels difficult to reach without making the player repeat the same action forever.

## Core Loop

```text
Gather -> Refine -> Craft -> Enhance
```

## Main Skills

```text
Woodcutting: gather logs, branches, bark, resin
Mining: gather ores, gems, stone, coal
Smelting: turn ore into bars
Smithing: turn bars into metal gear
Fletching: turn logs into bows, arrows, staffs, handles
Carpentry: turn logs into stations, shields, storage, upgrades
Jeweling: turn gems and bars into rings and amulets
Enchanting: add magic effects to crafted gear
```

## Leveling Philosophy

Early levels teach the basics with simple repeatable actions.

Mid levels push the player toward recipes, requests, upgrades, and new materials.

Late levels are about mastery: rare ingredients, full recipe sets, high-quality crafts, and harder goals.

Max level should feel earned because the player explored the whole skill, not because they repeated one recipe thousands of times.

## XP Sources

### Normal Action XP

Small steady XP from basic gathering, refining, and crafting.

Examples:

```text
Mine Copper Ore: Mining XP
Chop Normal Log: Woodcutting XP
Smelt Copper Ore into Copper Bar: Smelting XP
Craft Copper Short Sword: Smithing XP
```

### First-Time Craft XP

Large bonus XP the first time the player makes a recipe.

This encourages recipe discovery instead of grinding one item.

Examples:

```text
Copper Bar: 25 XP normally, 100 XP first-time craft
Bronze Axe: 40 XP normally, 200 XP first-time craft
Copper Short Sword: 75 XP normally, 350 XP first-time craft
```

### Crafting Orders

NPCs request specific items and reward XP, coins, and sometimes recipes.

Examples:

```text
Blacksmith Order: 2 Bronze Axes + 1 Copper Short Sword
Fletcher Order: 1 Simple Bow + 25 Bronze Arrows
Carpenter Order: 1 Workbench + 1 Storage Chest
```

### Recipe Milestones

Bonus XP for completing recipe groups.

Examples:

```text
Complete all Copper Smithing recipes: Smithing XP bonus
Craft every Normal Log item: Fletching XP bonus
Smelt every basic bar type: Smelting XP bonus
```

### Discovery XP

XP for finding or using a new resource for the first time.

Examples:

```text
First Normal Tree chopped: Woodcutting XP
First Copper Node mined: Mining XP
First Copper Bar smelted: Smelting XP
First Sapphire cut: Jeweling XP
```

### Skill Challenges

Small goals that test the skill and unlock the next tier.

Examples:

```text
Smithing Trial 1: Forge a Knife, Axe, and Pickaxe
Fletching Trial 1: Make Arrow Shafts, Simple Bow, and 25 Arrows
Mining Trial 1: Mine Copper Ore from 3 different nodes
```

### Quality Crafts

Crafted items can have quality tiers.

Higher skill improves the odds of better results.

Examples:

```text
Crude Copper Sword
Copper Sword
Fine Copper Sword
Masterwork Copper Sword
```

Late-game XP can come from making high-quality items instead of mass-producing basic ones.

## Early Recipe Path

```text
Woodcutting level 1: Normal Log
Mining level 1: Copper Ore
Smelting level 1: Copper Ore -> Copper Bar
Smithing level 1: Copper Bar -> Knife
Smithing level 2: Copper Bar + Normal Log -> Bronze Axe
Smithing level 2: Copper Bar + Normal Log -> Bronze Pickaxe
Fletching level 2: Normal Log -> Simple Bow
Smithing level 5: 2 Copper Bars + Normal Log -> Copper Short Sword
Carpentry level 5: Normal Log + Copper Bar -> Workbench
```

## Design Rules

Use variety instead of huge material counts.

Bad:

```text
Level 90 sword = 500 Copper Bars
```

Better:

```text
Level 90 sword = 2 Mithril Bars + Ancient Wood Handle + Fire Gem
```

Give players several ways to level a skill.

```text
Basic actions
First-time crafts
NPC orders
Recipe milestones
Discovery XP
Skill challenges
Quality crafting
```

## Implementation Checklist

1. Add skill globals for Smelting, Smithing, Fletching, Carpentry, Jeweling, and Enchanting.
2. Create a recipe data structure.
3. Track which recipes the player has crafted before.
4. Add first-time craft XP.
5. Add material requirements to recipes.
6. Add recipe output items.
7. Add NPC crafting orders.
8. Add recipe milestone rewards.
9. Add discovery tracking for new resources.
10. Add quality tiers for crafted gear.

## First Build Target

Start small with the first complete chain:

```text
Mine Copper Ore
Smelt Copper Ore into Copper Bar
Chop Normal Log
Smith Copper Bar into Knife
Smith Copper Bar + Normal Log into Bronze Axe
Smith Copper Bar + Normal Log into Bronze Pickaxe
Fletch Normal Log into Simple Bow
Smith 2 Copper Bars + Normal Log into Copper Short Sword
```

Once this works, expand with orders, milestones, and quality.
