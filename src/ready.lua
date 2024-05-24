---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

-- Dictates how many loot choices game should try to show
modutil.mod.Path.Wrap("GetTotalLootChoices", function(base)
	return GetTotalLootChoices_override(base)
end)

-- Dictates how many loot choices game will actually show
modutil.mod.Path.Wrap("CalcNumLootChoices", function(base, isGodLoot, treatAsGodLootByShops)
	return CalcNumLootChoices_override(base, isGodLoot, treatAsGodLootByShops)
end)

-- Builds an individual boon slot on the boon offering screen
modutil.mod.Path.Wrap("CreateUpgradeChoiceButton", function(base, screen, lootData, itemIndex, itemData )
	return CreateUpgradeChoiceButton_wrap(base, screen, lootData, itemIndex, itemData )
end)

-- Builds the full set of boon loot UI elements.  Mod is using this for post cleanup
modutil.mod.Path.Wrap("CreateBoonLootButtons", function(base, screen, lootData, reroll )
	return CreateBoonLootButtons_wrap(base, screen, lootData, reroll )
end)

-- Runs when using the Rarify feature.  SGG bug here forced me to rearrange method calls / change input to the presentation that plays
modutil.mod.Path.Wrap("TryUpgradeBoon", function(base, lootData, screen, button)
	return TryUpgradeBoon_override(base, lootData, screen, button)
end)

-- Update the number of loot choices to use on each room load.  Holdover from old LootChoiceExt and maybe unnecessary these days
OnAnyLoad{ function()
	config.LastLootChoices = config.Choices
end}

