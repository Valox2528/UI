--[[
    ValoxUI v2.0 - Demo Script
    A professional, comprehensive UI library for Roblox.
]]

local ValoxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox2528/UI/main/GardenUI.lua"))()

---------------------------------------------------------------
-- CREATE WINDOW
---------------------------------------------------------------
local Window = ValoxUI:CreateWindow({
    Title = "ValoxUI v2.0",
    Author = "Valox",
    Icon = "shield",
    Transparent = true, -- Enable glassmorphism
    Size = UDim2.fromOffset(820, 520),
})

---------------------------------------------------------------
-- MAIN TAB
---------------------------------------------------------------
local MainTab = Window:Tab({
    Title = "Main",
    Desc = "Core automation and essentials",
    Icon = "home",
})

MainTab:Button({
    Title = "Join Discord Server",
    Desc = "Copys the official Valox community link",
    Callback = function()
        setclipboard("https://discord.gg/valox")
        Window:Notify({
            Title = "Success",
            Content = "Discord link copied to clipboard!",
            Icon = "check"
        })
    end,
})

local AutoFarms = MainTab:Section({ Title = "Automation" })

AutoFarms:Toggle({
    Title = "Enable Auto Farm",
    Desc = "Automatically collects resources nearby",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})

AutoFarms:Slider({
    Title = "Farm Range",
    Min = 10, Max = 100, Default = 50,
    Callback = function(v) print("Range:", v) end
})

AutoFarms:Checkbox({
    Title = "Ignore Private Areas",
    Default = true,
    Callback = function(v) print("Ignore:", v) end
})

---------------------------------------------------------------
-- COMBAT TAB
---------------------------------------------------------------
local CombatTab = Window:Tab({
    Title = "Combat",
    Desc = "Kill aura and targeting features",
    Icon = "swords",
})

CombatTab:Toggle({
    Title = "Kill Aura",
    Desc = "Attacks targets within a specific radius",
    Callback = function(v) print("Kill Aura:", v) end
})

CombatTab:Keybind({
    Title = "Toggle Keybind",
    Default = Enum.KeyCode.V,
    Callback = function(key) print("New bind:", key.Name) end,
    OnPressed = function() print("Pressed Aura bind!") end
})

---------------------------------------------------------------
-- VISUALS TAB
---------------------------------------------------------------
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Desc = "ESP and UI Customization",
    Icon = "eye",
})

VisualsTab:Dropdown({
    Title = "ESP Mode",
    Values = {"Boxes", "Tracers", "Skeleton", "Head Circles"},
    Value = "Boxes",
    Callback = function(v) print("ESP:", v) end
})

VisualsTab:Dropdown({
    Title = "Select Targets",
    Values = {"Players", "NPCs", "Items", "Vehicles"},
    Multi = true,
    Value = {"Players", "NPCs"},
    Callback = function(v) print("Targets:", table.concat(v, ", ")) end
})

---------------------------------------------------------------
-- SETTINGS TAB
---------------------------------------------------------------
local SettingsTab = Window:Tab({
    Title = "Settings",
    Desc = "Manage the interface and saved configs",
    Icon = "settings",
})

SettingsTab:Dropdown({
    Title = "Theme Selection",
    Values = {"Dark", "Midnight", "Ocean"},
    Value = "Dark",
    Callback = function(v) ValoxUI:SetTheme(v) end
})

SettingsTab:Button({
    Title = "Unload Interface",
    Desc = "Completely remove the UI and stop scripts",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Unload",
            Content = "Are you sure you want to unload ValoxUI? All running tasks will be stopped.",
            Buttons = {
                { Title = "Cancel", Callback = function() print("Cancelled") end },
                { Title = "Unload", Accent = true, Callback = function() 
                    ValoxUI.DisconnectAll()
                    Window.ScreenGui:Destroy()
                end }
            }
        })
    end,
})

SettingsTab:Input({
    Title = "Config Name",
    Placeholder = "Example: Default",
    Callback = function(v) print("Config:", v) end
})

Window:Notify({
    Title = "Welcome!",
    Content = "ValoxUI v2.0 has been successfully loaded.",
    Duration = 5
})
