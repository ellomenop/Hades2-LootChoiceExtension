---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.

function GetTotalLootChoices_override(base)
	return config.LastLootChoices
end

function CalcNumLootChoices_override(base, isGodLoot, treatAsGodLootByShops)
	local numChoices = config.LastLootChoices - GetNumMetaUpgrades("ReducedLootChoicesShrineUpgrade")
	if (isGodLoot or treatAsGodLootByShops) and HasHeroTraitValue("RestrictBoonChoices") then
			numChoices = numChoices - 1
	end
	return numChoices
end

function CreateUpgradeChoiceButton_wrap(base, screen, lootData, itemIndex, itemData )
	screen.MaxChoices = config.LastLootChoices
	local scaleFactor = 3.0 / config.LastLootChoices
	screen.ButtonSpacingY = rom.game.ScreenData.UpgradeChoice.ButtonSpacingY * scaleFactor
	screen.LineHeight = rom.game.ScreenData.UpgradeChoice.LineHeight * scaleFactor

	screen.RarityText.OffsetY = rom.game.ScreenData.UpgradeChoice.RarityText.OffsetY * scaleFactor
	screen.RarityText.FontSize = rom.game.ScreenData.UpgradeChoice.RarityText.FontSize * scaleFactor
	screen.DescriptionText.OffsetY = rom.game.ScreenData.UpgradeChoice.DescriptionText.OffsetY * scaleFactor
	screen.DescriptionText.TextSymbolScale = rom.game.ScreenData.UpgradeChoice.DescriptionText.TextSymbolScale * scaleFactor

	screen.IconOffsetY = rom.game.ScreenData.UpgradeChoice.IconOffsetY * scaleFactor
	screen.ExchangeIconOffsetY = rom.game.ScreenData.UpgradeChoice.ExchangeIconOffsetY * scaleFactor
	screen.BonusIconOffsetY = rom.game.ScreenData.UpgradeChoice.BonusIconOffsetY * scaleFactor
	screen.QuestIconOffsetY = rom.game.ScreenData.UpgradeChoice.QuestIconOffsetY * scaleFactor
	screen.PoseidonDuoIconOffsetY = rom.game.ScreenData.UpgradeChoice.PoseidonDuoIconOffsetY * scaleFactor

	screen.ElementIcon.YShift = rom.game.ScreenData.UpgradeChoice.ElementIcon.YShift * scaleFactor

	screen.ExchangeSymbol.Scale = rom.game.ScreenData.UpgradeChoice.ExchangeSymbol.Scale * scaleFactor
	screen.ExchangeSymbol.OffsetY = rom.game.ScreenData.UpgradeChoice.ExchangeSymbol.OffsetY * scaleFactor
	screen.ExchangeIconScale = rom.game.ScreenData.UpgradeChoice.ExchangeIconScale * scaleFactor

	local returnVal = base(screen, lootData, itemIndex, itemData)

	local components = screen.Components
	local purchaseButtonKey = "PurchaseButton"..itemIndex

	SetScale({ Id = components[purchaseButtonKey].Id, Fraction = scaleFactor, Duration = 0 })
	SetScaleX({ Id = components[purchaseButtonKey].Id, Fraction = 1 / scaleFactor, Duration = 0 })

	SetScale({ Id = components[purchaseButtonKey.."Highlight"].Id, Fraction = scaleFactor, Duration = 0 })
	SetScaleX({ Id = components[purchaseButtonKey.."Highlight"].Id, Fraction = 1 / scaleFactor, Duration = 0 })

	SetScaleX({ Id = components[purchaseButtonKey.."Icon"].Id, Fraction = scaleFactor, Duration = 0 })
	SetScaleY({ Id = components[purchaseButtonKey.."Icon"].Id, Fraction = scaleFactor, Duration = 0 })

	SetScaleX({ Id = components[purchaseButtonKey.."Frame"].Id, Fraction = scaleFactor, Duration = 0 })
	SetScaleY({ Id = components[purchaseButtonKey.."Frame"].Id, Fraction = scaleFactor, Duration = 0 })

	if (components[purchaseButtonKey.."ElementIcon"] ~= nil) then
		SetScaleX({ Id = components[purchaseButtonKey.."ElementIcon"].Id, Fraction = scaleFactor, Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."ElementIcon"].Id, Fraction = scaleFactor, Duration = 0 })
	end

	if (components[purchaseButtonKey.."ExchangeSymbol"] ~= nil) then
		SetScaleX({ Id = components[purchaseButtonKey.."ExchangeSymbol"].Id, Fraction = scaleFactor, Duration = 0 })
		SetScaleY({ Id = components[purchaseButtonKey.."ExchangeSymbol"].Id, Fraction = scaleFactor, Duration = 0 })
	end

	return returnVal
end