# Skill Progression System

This document defines the working direction for skills, XP, crafting, and long-term skilling goals.

The goal is to make progression feel long-term and rewarding without forcing the player to repeat one action forever. Skills should support combat, quests, gear collection, reputation, and boss preparation.

## Core Design Goal

Progression is the backbone of the game.

Every skill should do at least one of these things:

- unlock useful items
- unlock new recipes
- support combat preparation
- support quests or reputation
- open access to stronger content
- create visible long-term goals

The player should usually understand what they are working toward next.

## Core Skill Loop

```text
Gather -> Refine -> Craft -> Improve -> Prove Mastery
```

Example:

```text
Chop Normal Log
Mine Copper Ore
Smelt Copper Ore into Copper Bar
Craft Copper Bar + Normal Log into a tool or weapon
Use that tool or weapon to reach better materials, quests, or combat goals
```

## Skill Families

### Gathering Skills

Gathering skills create the base materials for the rest of the game.

```text
Woodcutting: logs, branches, bark, resin
Mining: ores, gems, stone, coal
```

Design purpose:

- give steady XP
- feed crafting systems
- create simple early-game goals
- unlock better resource nodes over time

### Refining Skills

Refining skills turn raw materials into usable crafting components.

```text
Smelting: ore -> bars
Processing: optional future skill for bark, resin, cloth, leather, or other materials
```

Design purpose:

- make raw materials feel incomplete until processed
- create a bridge between gathering and crafting
- give players more than one step in the item economy

For now, Smelting is the main refining skill.

### Crafting Skills

Crafting skills turn refined materials into tools, weapons, stations, and utility items.

```text
Smithing: metal tools, metal weapons, armor pieces
Fletching: bows, arrows, staffs, handles
Carpentry: stations, shields, storage, settlement upgrades
Jeweling: rings, amulets, gem upgrades
Enchanting: magical effects on gear
```

Design purpose:

- turn gathered materials into meaningful rewards
- support combat progression
- support skill progression
- support quests and reputation

### Hybrid Skill Space

Some recipes should use more than one material type. This keeps skills connected instead of isolated.

Examples:

```text
Wood-heavy hybrid recipe: Normal Log + Copper Tip -> Bronze Arrows
Ore-heavy hybrid recipe: Copper Bar + Normal Log -> Copper Short Sword
Tool recipe: Copper Bar + Normal Log -> Bronze Axe
Station recipe: Normal Log + Copper Bar -> Workbench
```

Hybrid recipes are important because they make Mining, Woodcutting, Smelting, Smithing, Fletching, and Carpentry support each other.

## Leveling Philosophy

Early levels should teach the basics.

Mid levels should push the player toward recipes, quests, orders, upgrades, and new materials.

Late levels should be about mastery, rare materials, high-quality crafts, boss preparation, and major milestone rewards.

Max level should feel earned because the player engaged with the whole skill, not because they repeated one recipe thousands of times.

## XP Sources

### 1. Normal Action XP

Small steady XP from common actions.

Examples:

```text
Chop Normal Log: Woodcutting XP
Mine Copper Ore: Mining XP
Smelt Copper Ore into Copper Bar: Smelting XP
Craft Copper Short Sword: Smithing XP
Craft Simple Bow: Fletching XP
```

Normal action XP should always matter, but it should not be the only efficient path.

### 2. First-Time Craft XP

Large XP bonus the first time the player creates a recipe.

Purpose:

- encourages recipe discovery
- rewards trying new items
- reduces repetitive grinding
- makes unlocks feel exciting

Examples:

```text
Copper Bar: 25 XP normally, 100 XP first-time craft
Bronze Axe: 40 XP normally, 200 XP first-time craft
Copper Short Sword: 75 XP normally, 350 XP first-time craft
```

### 3. Quest and Trainer XP

Quests and trainers give directed XP for completing meaningful goals.

Examples:

```text
Woodcutting trainer asks for 5 Normal Logs
Mining trainer asks the player to mine Copper Ore
Crafting trainer asks the player to make a basic tool
Welcomer approval requires several starter tasks
```

Purpose:

- teaches systems
- creates clear goals
- connects skills to NPC progression
- makes reputation feel tied to real work

### 4. Crafting Orders

NPCs can request specific items and reward XP, coins, reputation, and sometimes recipes.

Examples:

```text
Blacksmith Order: 2 Bronze Axes + 1 Copper Short Sword
Fletcher Order: 1 Simple Bow + 25 Bronze Arrows
Carpenter Order: 1 Workbench + 1 Storage Chest
```

Orders should use varied recipes instead of huge item counts.

### 5. Recipe Milestones

Bonus XP for completing sets of related recipes.

Examples:

```text
Craft all Copper Smithing recipes
Craft every Normal Log recipe
Smelt every basic bar type
Complete all starter tool recipes
```

Purpose:

- gives completion goals
- encourages breadth
- supports collection-style progression

### 6. Discovery XP

XP for finding, gathering, refining, or using something new for the first time.

Examples:

```text
First Normal Tree chopped
First Copper Node mined
First Copper Bar smelted
First Simple Bow crafted
First gem cut
```

Discovery XP should be small to medium, but frequent enough to make exploration feel rewarding.

### 7. Skill Challenges

Small mastery checks that prove the player understands a skill tier.

Examples:

```text
Smithing Trial 1: Forge a Knife, Axe, and Pickaxe
Fletching Trial 1: Make Arrow Shafts, Simple Bow, and 25 Arrows
Mining Trial 1: Mine Copper Ore from multiple nodes
Woodcutting Trial 1: Gather Normal Logs from multiple trees
```

Skill challenges can unlock the next material tier, trainer approval, recipes, or reputation.

### 8. Quality Crafting

Crafted items can later have quality tiers.

Examples:

```text
Crude Copper Sword
Copper Sword
Fine Copper Sword
Masterwork Copper Sword
```

Higher skill improves the chance of better quality.

Quality crafting is a later-system idea. It should not be required for the first build, but it gives late-game players a reason to keep crafting without needing massive material counts.

## Anti-Grind Rules

Use variety instead of huge material counts.

Bad:

```text
Level 90 sword = 500 Copper Bars
```

Better:

```text
Level 90 sword = 2 rare bars + rare wood handle + rare gem + boss material
```

Rules:

- do not make progress rely on one repeated action forever
- use first-time bonuses to reward new recipes
- use orders to create changing goals
- use milestones to reward completion
- use challenges to gate important unlocks
- use rare ingredients for late-game difficulty
- avoid extreme material counts unless the item is optional prestige content

## Level Scaling Direction

The XP curve should feel similar in spirit to RuneScape-style long-term leveling, but the game should not copy OSRS directly.

Recommended direction:

```text
Levels 1-10: fast, tutorial pace
Levels 11-30: steady, unlock-focused
Levels 31-60: slower, recipe and quest driven
Levels 61-90: long-term, mastery driven
Levels 91-99 or max: rare goals, prestige, completion, boss preparation
```

The curve can be steep at the high end as long as the player has varied goals to pursue.

## Unlock Types

Leveling a skill can unlock:

- resource nodes
- material tiers
- recipes
- tools
- workstations
- quality chances
- trainer tasks
- crafting orders
- quest steps
- reputation ranks
- boss preparation items
- cosmetic or prestige rewards

The strongest unlocks should connect multiple systems.

Example:

```text
Smithing level unlocks a weapon recipe.
Mining and Smelting provide the bars.
Woodcutting and Fletching provide the handle.
A trainer order rewards reputation.
That reputation unlocks a boss preparation quest.
```

## Early Game Skill Path

This is the first intended progression chain.

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

This path gives the player:

- a reason to gather wood
- a reason to mine ore
- a reason to smelt bars
- starter tools
- starter combat gear
- a first workstation goal
- clear links between skills

## First Build Target

Start with a small complete chain before adding more systems.

Required first build:

```text
Mine Copper Ore
Smelt Copper Ore into Copper Bar
Chop Normal Log
Craft Copper Bar into Knife
Craft Copper Bar + Normal Log into Bronze Axe
Craft Copper Bar + Normal Log into Bronze Pickaxe
Craft Normal Log into Simple Bow
Craft 2 Copper Bars + Normal Log into Copper Short Sword
```

First build skill systems:

- Woodcutting XP
- Mining XP
- Smelting XP
- Smithing XP
- Fletching XP
- level display
- current XP display
- XP needed to next level
- first-time craft bonus tracking
- basic recipe requirements
- basic recipe unlock levels

Not required for first build:

- quality tiers
- crafting orders
- recipe milestone rewards
- rare materials
- boss materials
- late-game prestige

Those should come after the first chain feels good.

## Early Trainer Integration

The Welcomer should act as the starting approval gate.

Trainer roles:

```text
Welcomer: explains approval and directs the player to starter tasks
Woodcutting Trainer: teaches logs, gives starter wood task
Mining Trainer: teaches ore, gives starter mining task
Crafting/Smithing Trainer: teaches first recipes
```

The trainer loop should be:

```text
Talk to Welcomer
Get sent to trainer
Complete starter skill task
Return to trainer
Trainer marks approval
Return to Welcomer for overall progress
```

This makes quests, skills, and reputation feel connected from the beginning.

## Mid Game Direction

Mid game should expand the same structure instead of replacing it.

Possible mid-game goals:

- new regions with new resources
- trainer approval chains
- crafting orders
- recipe collections
- better tools
- first rare drops
- first real boss preparation items
- reputation ranks that unlock recipes or areas

Mid game should ask the player to choose priorities:

```text
Do I improve tools first?
Do I craft better combat gear?
Do I unlock a new region?
Do I complete trainer approvals?
Do I chase recipe collections?
```

## Late Game Direction

Late game should focus on mastery and meaningful rare goals.

Possible late-game goals:

- maxing skills
- rare gear collection
- masterwork crafting
- boss preparation items
- reputation completion
- recipe completion
- prestige cosmetics or titles

Late game difficulty should come from:

- rare resources
- harder bosses
- multi-system requirements
- high skill requirements
- difficult quest or reputation milestones

It should not come only from extreme material counts.

## Open Design Questions

These should be answered before the system becomes final:

1. What is the max level for each skill?
2. Should all skills share the same XP curve?
3. Should combat and crafting use the same level cap?
4. Should Smelting be separate from Smithing forever, or combined later?
5. Should Carpentry stay separate from Fletching?
6. Should quality crafting exist early, mid, or late?
7. How many trainer approvals are needed before leaving the tutorial area?
8. Should crafting orders be repeatable, daily-style, or finite?
9. Should rare gear mostly come from bosses, crafting, or both?
10. Should reputation unlock recipes, areas, bosses, or all three?

## Current Priority

The next design priority is to make the early game chain feel solid.

Focus order:

1. Woodcutting and Mining feel good.
2. Smelting turns ore into bars.
3. Basic crafting recipes consume materials correctly.
4. Skills gain XP and level at a satisfying pace.
5. Trainers guide the player through the first chain.
6. Quest UI shows the current skill objective clearly.
7. First-time craft XP and recipe unlocks are added.
8. Orders, milestones, and quality come later.

