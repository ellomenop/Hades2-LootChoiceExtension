---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- so only assign to values or define things here.

function GetTotalLootChoices_override()
	return config.LastLootChoices
end

function CalcNumLootChoices_override(isGodLoot, treatAsGodLootByShops)
	local numChoices = config.LastLootChoices - GetNumMetaUpgrades("ReducedLootChoicesShrineUpgrade")
	if (isGodLoot or treatAsGodLootByShops) and HasHeroTraitValue("RestrictBoonChoices") then
			numChoices = numChoices - 1
	end
	return numChoices
end

-- TODO: split into npcs / hammer / pom / chaos and allow enablement individually
local excludedSubjects = {
    "NPC_Arachne_01",
    "NPC_Narcissus_01",
    "NPC_Echo_01",
    "NPC_LordHades_01",
    "NPC_Medea_01",
    "NPC_Icarus_01",
    "NPC_Circe_01",
	"NPC_Artemis_Field_01",
	--[[
		"WeaponUpgrade", -- Hammer
		"StackUpgrade", -- Pom
		"TrialUpgrade" -- Chaos
	]]
}

local boonSlotObtacleNames = {
	[3] = "BoonSlotBase",
	[4] = "BoonSlotBaseFourOptions",
	[5] = "BoonSlotBaseFiveOptions",
	[6] = "BoonSlotBaseSixOptions"
}

local indicesToRemove = {}

function isBoonSubjectExcluded(subjectName)
    for _, name in ipairs(excludedSubjects) do
        if subjectName == name then
            return true
        end
    end
    return false
end

-- Main meat of the mod
function CreateUpgradeChoiceButton_wrap(base, screen, lootData, itemIndex, itemData )
	if config.enabled ~= true or isBoonSubjectExcluded(screen.SubjectName) then
		-- I'm worried this will break something down the line and also probably doesn't play nice with never see boon again heat
		if itemIndex > 3 then
			-- Attempt to fix "never see boon again" heat by cleaning up the extra nils after all buttons are created - but I think the list is used prior to this cleanup
			table.insert(indicesToRemove, itemIndex)
			return {Id = nil}
		end

		print("Using default boon screen behavior because " .. tostring(screen.SubjectName) .. " is excluded")
		return base(screen, lootData, itemIndex, itemData)
	end

	screen.MaxChoices = config.LastLootChoices
	local scaleFactor = 3.0 / config.LastLootChoices
	screen.PurchaseButton.Name = boonSlotObtacleNames[config.LastLootChoices] -- TODO: Change this for 5 and 6 boon hitboxes?

	-- Set up static data that determines how the layout is built
	print("Modifying screen data")
	resizeBoonScreenData(screen, scaleFactor)
	
	--print("Screen data: " .. sjson.encode(screen))
	local returnVal = base(screen, lootData, itemIndex, itemData)

	-- Resize and move components after they've been drawn to screen
	print("Resizing and tweaking components on boon screen")
	resizeBoonScreenComponents(screen, itemIndex, scaleFactor)

	return returnVal
end

function resizeBoonScreenData(screen, scaleFactor)
	screen.ButtonSpacingY = rom.game.ScreenData.UpgradeChoice.ButtonSpacingY * scaleFactor
	--screen.LineHeight = rom.game.ScreenData.UpgradeChoice.LineHeight * scaleFactor

	screen.StatLineLeft.LineSpacingBottom = rom.game.ScreenData.UpgradeChoice.StatLineLeft.LineSpacingBottom * scaleFactor
	screen.StatLineRight.LineSpacingBottom = rom.game.ScreenData.UpgradeChoice.StatLineLeft.LineSpacingBottom * scaleFactor

	-- Scaling FontSize by cube root looks better, tested and suggested by dwbl.
	screen.RarityText.OffsetY = rom.game.ScreenData.UpgradeChoice.RarityText.OffsetY * scaleFactor
	screen.RarityText.FontSize = rom.game.ScreenData.UpgradeChoice.RarityText.FontSize * scaleFactor ^ (1/3)
	screen.TitleText.OffsetY = rom.game.ScreenData.UpgradeChoice.TitleText.OffsetY * scaleFactor
	screen.TitleText.FontSize = rom.game.ScreenData.UpgradeChoice.TitleText.FontSize * scaleFactor ^ (1/3)
	screen.DescriptionText.OffsetY = rom.game.ScreenData.UpgradeChoice.DescriptionText.OffsetY * scaleFactor * scaleFactor
	screen.DescriptionText.FontSize = 20 * scaleFactor ^ (1/3)
	-- screen.DescriptionText.TextSymbolScale = rom.game.ScreenData.UpgradeChoice.DescriptionText.TextSymbolScale * scaleFactor

	screen.IconOffsetY = rom.game.ScreenData.UpgradeChoice.IconOffsetY * scaleFactor
	screen.ExchangeIconOffsetY = rom.game.ScreenData.UpgradeChoice.ExchangeIconOffsetY * scaleFactor
	screen.ExchangeIconOffsetX = rom.game.ScreenData.UpgradeChoice.ExchangeIconOffsetX + 5  * (config.LastLootChoices - 3)
	screen.ExchangeSymbol.OffsetX = rom.game.ScreenData.UpgradeChoice.ExchangeSymbol.OffsetX + 5  * (config.LastLootChoices - 3)
	screen.BonusIconOffsetY = rom.game.ScreenData.UpgradeChoice.BonusIconOffsetY * scaleFactor
	screen.QuestIconOffsetY = rom.game.ScreenData.UpgradeChoice.QuestIconOffsetY * scaleFactor
	screen.PoseidonDuoIconOffsetY = rom.game.ScreenData.UpgradeChoice.PoseidonDuoIconOffsetY * scaleFactor

	screen.ElementIcon.YShift = rom.game.ScreenData.UpgradeChoice.ElementIcon.YShift * scaleFactor

	screen.ExchangeSymbol.OffsetY = rom.game.ScreenData.UpgradeChoice.ExchangeSymbol.OffsetY * scaleFactor
end

-- Some components are not created via ScreenData config, so we rescale and tweak them after their creation
function resizeBoonScreenComponents(screen, itemIndex, scaleFactor)
	local components = screen.Components
	local purchaseButtonKey = "PurchaseButton"..itemIndex

	SetScaleY({ Id = components[purchaseButtonKey].Id, Fraction = scaleFactor, Duration = 0 })
	-- SetScaleX({ Id = components[purchaseButtonKey].Id, Fraction = 1 / scaleFactor, Duration = 0 })
	components[purchaseButtonKey].ScaleFactor = scaleFactor

	SetScaleY({ Id = components[purchaseButtonKey.."Highlight"].Id, Fraction = scaleFactor, Duration = 0 })

	-- The icons stop overlapping the boon properly when scaled down, so shift them a bit right to look normal again
	SetScaleX({ Id = components[purchaseButtonKey.."Icon"].Id, Fraction = scaleFactor, Duration = 0 })
	SetScaleY({ Id = components[purchaseButtonKey.."Icon"].Id, Fraction = scaleFactor, Duration = 0 })
	if (config.LastLootChoices ~= 3) then -- Move of Distance = 0 puts component to top left corner of screen
		Move({ Id = components[purchaseButtonKey.."Icon"].Id, Angle = 360, Distance = 5  * (config.LastLootChoices - 3) })
	end

	SetScaleX({ Id = components[purchaseButtonKey.."Frame"].Id, Fraction = scaleFactor, Duration = 0 })
	SetScaleY({ Id = components[purchaseButtonKey.."Frame"].Id, Fraction = scaleFactor, Duration = 0 })
	if (config.LastLootChoices ~= 3) then -- Move of Distance = 0 puts component to top left corner of screen
		Move({ Id = components[purchaseButtonKey.."Frame"].Id, Angle = 360, Distance = 5  * (config.LastLootChoices - 3) })
	end

	-- TODO: shift this down left ~5 pixels once vanilla UI is referenced
	if (components[purchaseButtonKey.."ElementIcon"] ~= nil) then
		SetScaleX({ Id = components[purchaseButtonKey.."ElementIcon"].Id, Fraction = scaleFactor, Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."ElementIcon"].Id, Fraction = scaleFactor, Duration = 0 })
	end

	if (components[purchaseButtonKey.."ExchangeSymbol"] ~= nil) then
		SetScaleX({ Id = components[purchaseButtonKey.."ExchangeSymbol"].Id, Fraction = scaleFactor, Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."ExchangeSymbol"].Id, Fraction = scaleFactor, Duration = 0 })

		SetScaleX({ Id = components[purchaseButtonKey.."ExchangeIcon"].Id, Fraction = scaleFactor, Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."ExchangeIcon"].Id, Fraction = scaleFactor, Duration = 0 })


		SetScaleX({ Id = components[purchaseButtonKey.."ExchangeIconFrame"].Id, Fraction = scaleFactor, Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."ExchangeIconFrame"].Id, Fraction = scaleFactor, Duration = 0 })


		if (config.LastLootChoices ~= 3) then -- Move of Distance = 0 puts component to top left corner of screen
			Move({ Id = components[purchaseButtonKey.."ExchangeSymbol"].Id, Angle = 360, Distance = 5  * (config.LastLootChoices - 3) })
			Move({ Id = components[purchaseButtonKey.."ExchangeIcon"].Id, Angle = 360, Distance = 5  * (config.LastLootChoices - 3) })
			Move({ Id = components[purchaseButtonKey.."ExchangeIconFrame"].Id, Angle = 360, Distance = 5  * (config.LastLootChoices - 3) })	
		end
	end

	if (components[purchaseButtonKey.."QuestIcon"] ~= nil) then
		SetScaleX({ Id = components[purchaseButtonKey.."QuestIcon"].Id, Fraction = scaleFactor , Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."QuestIcon"].Id, Fraction = scaleFactor, Duration = 0 })
	end
end

function CreateBoonLootButtons_wrap( base, screen, lootData, reroll )
	local returnVal = base(screen, lootData, reroll)
	-- Delete off the end of the list past 3 rewards as needed if this is an excluded subject
	for _, index in ipairs(indicesToRemove) do
		table.remove(screen.UpgradeButtons)
	end
	indicesToRemove = {}
	return returnVal
end

function TryUpgradeBoon_override(lootData, screen, button )

	local components = screen.Components

	local traitData = button.Data
	local validUpgradeIndex = false
	for i, upgradeData in pairs(lootData.UpgradeOptions) do
		if traitData.Name == upgradeData.ItemName and GetUpgradedRarity(traitData.Rarity) ~= nil and traitData.RarityLevels[GetUpgradedRarity(traitData.Rarity)] ~= nil then
			upgradeData.Rarity = GetUpgradedRarity(traitData.Rarity)
			validUpgradeIndex = i
		end
	end
	if validUpgradeIndex then
		
		local toDestroy = {}
		local destroyIndexes = {
		"PurchaseButton"..validUpgradeIndex,
		"PurchaseButton"..validUpgradeIndex.. "Lock",
		"PurchaseButton"..validUpgradeIndex.. "Highlight",
		"PurchaseButton"..validUpgradeIndex.. "Icon",
		"PurchaseButton"..validUpgradeIndex.. "ExchangeIcon",
		"PurchaseButton"..validUpgradeIndex.. "ExchangeIconFrame",
		"PurchaseButton"..validUpgradeIndex.. "QuestIcon",
		"PurchaseButton"..validUpgradeIndex.. "ElementIcon",
		"Backing"..validUpgradeIndex,
		"PurchaseButton"..validUpgradeIndex.. "Frame",
		"PurchaseButton"..validUpgradeIndex.. "Patch",
		}
		for i, indexName in pairs( destroyIndexes ) do
			if components[indexName] then
				table.insert(toDestroy, components[indexName].Id)
				components[indexName] = nil
			end
		end
		Destroy({ Ids = toDestroy })

		-- Base game uses button in the UpgradeBoonRarityPresentation instead of newButton.
		-- button gets destroyed from the above line at the same time (as its "PurchaseButton"..validUpgradeIndex). This seems to somehow lose scale / dimension data
		-- and results in the presentation staying full size / normal aspect ratio instead of matching the button dimensions
		local newButton = CreateUpgradeChoiceButton( screen, lootData, validUpgradeIndex, lootData.UpgradeOptions[validUpgradeIndex])
		UpgradeBoonRarityPresentation( newButton ) -- Only modified / moved line

		local notifyName = "ScreenInput"
		if screen.Name ~= nil then
			notifyName = notifyName..screen.Name
		end
		NotifyOnInteract({ Ids = { newButton.Id }, Notify = notifyName })
		return newButton
	end
end