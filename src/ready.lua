---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

modutil.mod.Path.Wrap("GetTotalLootChoices", function(base)
	return GetTotalLootChoices_override(base)
end)

modutil.mod.Path.Wrap("CalcNumLootChoices", function(base, isGodLoot, treatAsGodLootByShops)
	return CalcNumLootChoices_override(base, isGodLoot, treatAsGodLootByShops)
end)

modutil.mod.Path.Wrap("CreateUpgradeChoiceButton", function(base, screen, lootData, itemIndex, itemData )
	return CreateUpgradeChoiceButton_wrap(base, screen, lootData, itemIndex, itemData )
end)

OnAnyLoad{ function()
	config.LastLootChoices = config.Choices + RandomInt( config.MinExtraLootChoices, config.MaxExtraLootChoices )
end}

