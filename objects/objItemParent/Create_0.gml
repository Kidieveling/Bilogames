/// @description Item instance fields for world pickups and hidden menu preview clones (isInMenu).

#region Combat And Consumable Fields

description = undefined;
damage = undefined;
defense = undefined;
healthRestored = undefined;
manaRestored = undefined;
energyRestored = undefined;
ailmentsCured = undefined;
speedBoost = undefined;
healthChanged = undefined;
manaChanged = undefined;
energyChanged = undefined;

#endregion

#region Display And Menu Layer

type = undefined;
name = undefined;
price = undefined;

// Menu hover uses invisible instances on layer MenuItems; controller destroys them when hover ends.
isInMenu = false;

#endregion
