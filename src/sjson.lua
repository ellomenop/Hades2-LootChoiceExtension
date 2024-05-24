---@meta _
---@diagnostic disable

local sjson = rom.mods['SGG_Modding-SJSON']
local guiPath = rom.path.combine(rom.paths.Content, 'Game/Obstacles/GUI.sjson')

sjson.hook(guiPath, function(data)
	-- Prebake each possibility to avoid need to reload sjson when config is changed at runtime
    table.insert(data.Obstacles, fourOptions)
    table.insert(data.Obstacles, fiveOptions)
    table.insert(data.Obstacles, sixOptions)

    print(sjson.encode(data))
end)

local order = {
    'Name',
    'InheritFrom',
    'DisplayInEditor',
    'Thing'
}

local fourOptions = sjson.to_object({
    Name = "BoonSlotBaseFourOptions",
    InheritFrom = "BoonSlotBase",
	DisplayInEditor = false,
    Thing = {
		TimeModifierFraction = 0.0,
		EditorOutlineDrawBounds = false,
		Graphic = "BoonSlotBase",
		Interact =
		{
		  HighlightOnAnimation = "null",
		  HighlightOffAnimation = "null",
		},
		Points = {
			{ X = -490, Y = 110 * .75 },
			{ X = 600, Y = 110 * .75 },
			{ X = 600, Y = -110 * .75 },
			{ X = -490, Y = -110 * .75 },
		}
	},
}, order)

local fiveOptions = sjson.to_object({
    Name = "BoonSlotBaseFiveOptions",
    InheritFrom = "BoonSlotBase",
	DisplayInEditor = false,
    Thing = {
		TimeModifierFraction = 0.0,
		EditorOutlineDrawBounds = false,
		Graphic = "BoonSlotBase",
		Interact =
		{
		  HighlightOnAnimation = "null",
		  HighlightOffAnimation = "null",
		},
		Points = {
			{ X = -490, Y = 110 * .6 },
			{ X = 600, Y = 110 * .6 },
			{ X = 600, Y = -110 * .6 },
			{ X = -490, Y = -110 * .6 },
		}
	  },
}, order)

local sixOptions = sjson.to_object({
    Name = "BoonSlotBaseSixOptions",
    InheritFrom = "BoonSlotBase",
	DisplayInEditor = false,
    Thing = {
		TimeModifierFraction = 0.0,
		EditorOutlineDrawBounds = false,
		Graphic = "BoonSlotBase",
		Interact =
		{
		  HighlightOnAnimation = "null",
		  HighlightOffAnimation = "null",
		},
		Points = {
			{ X = -490, Y = 110 * .5 },
			{ X = 600, Y = 110 * .5 },
			{ X = 600, Y = -110 * .5 },
			{ X = -490, Y = -110 * .5 },
		}
	  },
}, order)