---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = PLUGIN

---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
public.config = config -- so other mods can access our config
loot_choices_at_room_load = config.choices

-- Mod is only set up to look good and function properly within these values
CHOICE_LIMIT = {
	MIN = 3,
	MAX = 6,
}

---@enum VowOptions
VowOptions = {
	RANDOM = "Random",
	ALL = "All"
}

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	if config.enabled == false then return end

	rom.gui.add_to_menu_bar(function()
		if rom.ImGui.BeginMenu("Configure") then
			rom.ImGui.Text("Number of reward choices:")

			local value, clicked = rom.ImGui.SliderInt("", config.choices, CHOICE_LIMIT.MIN, CHOICE_LIMIT.MAX)
			if clicked then
				config.choices = value
			end

			rom.ImGui.EndMenu()
		end
	end)

	import 'sjson.lua'
	import 'ready.lua'
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.


	-- Other mods should override this value
	config.choices = math.min(CHOICE_LIMIT.MAX, math.max(CHOICE_LIMIT.MIN, config.choices))

	import 'reload.lua'
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
	loader.load(on_ready, on_reload)
end)
