# ValoxUI v2.0

A professional, comprehensive UI Library for Roblox scripts, designed to replicate the premium VALOXEXEC aesthetic.

![ValoxUI Banner](https://raw.githubusercontent.com/Valox2528/UI/main/assets/banner.png)

## Features

- **🚀 Performance**: Highly optimized instance management and light on resources.
- **🎨 Themes**: Built-in support for Dark, Midnight, and Ocean themes. Hot-swappable at runtime.
- **🔷 Squircles**: Smooth, modern rounded corners using custom squircle assets.
- **🖼️ Icon System**: Integrated Lucide Icon support with over 1000+ icons.
- **🎛️ 10+ Components**: 
  - Buttons, Toggles, Sliders
  - Inputs, Dropdowns, Checkboxes
  - Keybinds, Paragraphs, Sections
  - Notifications & Dialogs
- **🏠 Layouts**: Sidebar navigation with icons, content headers with subtitles.
- **✨ Polish**: Hover effects, smooth transitions, glassmorphism, and subtle shadows.

## Quick Start

```lua
local ValoxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox2528/UI/main/GardenUI.lua"))()

local Window = ValoxUI:CreateWindow({
    Title = "ValoxUI",
    Icon = "shield",
    Transparent = true
})

local Tab = Window:Tab({
    Title = "Dashboard",
    Icon = "layout-dashboard"
})

Tab:Button({
    Title = "Hello World",
    Callback = function()
        Window:Notify({
            Title = "Success",
            Content = "You clicked the button!",
            Icon = "check"
        })
    end
})
```

## Documentation

Coming soon! Check the `docs/` folder for progress.

## Credits

- **Valox** - UI Design & Branding
- Built with ❤️ for the Roblox Community.
