# Documentation

Welcome to the ValoxUI v2.0 documentation!

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Creating a Window](#creating-a-window)
- [Adding Tabs](#adding-tabs)
- [UI Components](#ui-components)
  - [Buttons](#buttons)
  - [Toggles](#toggles)
  - [Sliders](#sliders)
  - [Inputs](#inputs)
  - [Dropdowns](#dropdowns)
- [Advanced Features](#advanced-features)
  - [Notifications](#notifications)
  - [Dialogs](#dialogs)
  - [Themes](#themes)

## Introduction

ValoxUI is a high-performance UI library for Roblox script hubs. It focuses on a clean, "VALOXEXEC" aesthetic with smooth animations and easy-to-use API.

## Installation

To use ValoxUI, simply load it via `loadstring`:

```lua
local ValoxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox2528/UI/main/GardenUI.lua"))()
```

## Creating a Window

```lua
local Window = ValoxUI:CreateWindow({
    Title = "My Script",
    Author = "Valox",
    Icon = "box",
    Size = UDim2.fromOffset(820, 520),
    Transparent = true
})
```

### Window Configuration

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | `string` | `"ValoxUI"` | The title shown in the topbar. |
| `Icon` | `string` | `"shield"` | Lucide icon name. |
| `Size` | `UDim2` | `820, 520` | Size of the window. |
| `Transparent` | `boolean` | `false` | Enables glassmorphism effect. |
