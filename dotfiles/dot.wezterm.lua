-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- changing the color scheme:
config.color_scheme = 'Monokai Pro (Gogh)'

-- Startup program
config.default_prog = { 'wsl' }

-- Launch menu
config.launch_menu = {
	{
		label = 'Nyagos',
		args = { 'nyagos.exe' }
	},
	{
		label = 'PowerShell',
		args = { 'powershell.exe', '-NoLogo' }
	},
	{
		label = 'wsl: default',
		args = { 'wsl' }
	},
	{
		label = 'mosh: void',
		args = { 'wsl', '--', 'mosh', 'void' }
	},
	{
		label = 'mosh: ops',
		args = { 'wsl', '--', 'mosh', '--server=".local/homebrew/bin/mosh-server"', 'ops' }
	},
}


-- Keybindings
config.keys = {
    {
      key = 'l',
      mods = 'ALT|SHIFT',
      action = wezterm.action.ShowLauncher
    },
}

-- Console face
config.font = wezterm.font("Consolas", {weight="Regular", stretch="Normal", style="Normal"})
config.font_size = 11.25
config.line_height = 1.1
config.audible_bell = "Disabled"

-- and finally, return the configuration to wezterm
return config
