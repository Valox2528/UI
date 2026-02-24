--[[
    __    __      __              __  ______
   / /   / /___ _/ /___  _  __  / / / /  _/
  / /   / / __ `/ / __ \| |/_/ / / / // /  
 / /___/ / /_/ / / /_/ />  <  / /_/ // /   
/_____/_/\__,_/_/\____/_/|_|  \____/___/   
  
  ValoxUI v2.0  |  Roblox UI Library
  VALOXEXEC Style  |  Lucide Icons  |  Squircle Shapes
  
  A full-featured, independent UI library for Roblox script hubs.
  Provides a modern, premium dark UI with smooth squircle shapes.
  
  Features:
    - Squircle window shapes (smooth rounded corners)
    - Full theme system with hot-swapping
    - Icon system (Lucide icons)
    - Window management with animations
    - Tab system with sidebar navigation
    - Elements: Button, Toggle, Slider, Input, Dropdown, 
      Checkbox, Keybind, ColorPicker, Paragraph
    - Section headers
    - Card component (Discord-style)
    - Notification system (toasts)
    - Dialog system (modals)
    - Tooltip system
    - Search functionality
    - Drag handling
    - Localization support
]]

---------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Heartbeat = RunService.Heartbeat

---------------------------------------------------------------
-- MAIN TABLE
---------------------------------------------------------------
local ValoxUI = {}
ValoxUI.__index = ValoxUI
ValoxUI.Version = "2.0.0"
ValoxUI._connections = {}
ValoxUI._themeObjects = {}
ValoxUI._fontObjects = {}
ValoxUI._windows = {}
ValoxUI.CanDraggable = true
ValoxUI.Font = "rbxassetid://12187365364"

---------------------------------------------------------------
-- ICON SYSTEM (Lucide Icons)
---------------------------------------------------------------
local Icons = nil
pcall(function()
    local iconUrl = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
    Icons = loadstring(
        game.HttpGetAsync and game:HttpGetAsync(iconUrl) or HttpService:GetAsync(iconUrl)
    )()
    Icons.SetIconsType("lucide")
end)

function ValoxUI.GetIcon(name)
    if not name then return "" end
    if type(name) == "string" then
        local lowerName = string.lower(name)
        local map = {
            main = "home",
            combat = "sword",
            visuals = "eye",
            settings = "settings"
        }
        if map[lowerName] then name = map[lowerName] end
    end
    if Icons then
        local ok, result = pcall(function() return Icons.GetIcon(name) end)
        if ok and result then return result end
    end
    if type(name) == "string" and string.find(name, "rbxasset") then return name end
    return ""
end

function ValoxUI.Icon(name, colored)
    if Icons then
        local ok, result = pcall(function() return Icons.Icon2(name, nil, colored ~= false) end)
        if ok and result then return result end
    end
    return nil
end

function ValoxUI.IconImage(iconName, props)
    props = props or {}
    local iconId = ValoxUI.GetIcon(iconName)
    if iconId == "" then return nil end
    
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image = iconId
    img.Size = props.Size or UDim2.fromOffset(20, 20)
    img.Position = props.Position or UDim2.new(0, 0, 0, 0)
    img.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
    img.ImageColor3 = props.Color or Color3.new(1, 1, 1)
    if props.Parent then img.Parent = props.Parent end
    return img
end

---------------------------------------------------------------
-- SQUIRCLE SHAPE SYSTEM
---------------------------------------------------------------
local Shapes = {}
ValoxUI.Shapes = Shapes

---------------------------------------------------------------
-- THEME SYSTEM
---------------------------------------------------------------
ValoxUI.Themes = {
    Dark = {
        Name = "Dark",
        -- Core
        Accent = Color3.fromHex("#0f71d3"),
        Background = Color3.fromHex("#060b13"),
        Text = Color3.fromHex("#ffffff"),
        TextDark = Color3.fromHex("#8c9bad"),
        TextDimmed = Color3.fromHex("#5a677a"),
        Icon = Color3.fromHex("#5a677a"),
        
        -- Window
        WindowBackground = Color3.fromHex("#060b13"),
        WindowShadow = Color3.new(0, 0, 0),
        WindowBorder = Color3.fromHex("#151e2e"),
        WindowBorderTransparency = 0.5,
        
        -- Topbar
        TopbarTitle = Color3.fromHex("#0f71d3"),
        TopbarIcon = Color3.fromHex("#0f71d3"),
        TopbarButton = Color3.fromHex("#5a677a"),
        
        -- Sidebar
        SidebarBackground = Color3.fromHex("#0a101a"),
        TabHover = Color3.fromHex("#0f1522"),
        TabActive = Color3.fromHex("#060b13"),
        TabIcon = Color3.fromHex("#5a677a"),
        TabIconActive = Color3.fromHex("#0f71d3"),
        
        -- Elements
        Element = Color3.fromHex("#0b121f"),
        ElementBorder = Color3.fromHex("#151e2e"),
        ElementHover = Color3.fromHex("#111827"),
        
        -- Controls
        Toggle = Color3.fromHex("#151e2e"),
        ToggleActive = Color3.fromHex("#0f71d3"),
        ToggleKnob = Color3.new(1, 1, 1),
        ToggleBorder = Color3.fromHex("#1a2438"),
        
        Slider = Color3.fromHex("#0f71d3"),
        SliderBg = Color3.fromHex("#0b121f"),
        SliderThumb = Color3.fromHex("#ffffff"),
        
        Checkbox = Color3.fromHex("#0f71d3"),
        CheckboxBorder = Color3.fromHex("#151e2e"),
        CheckboxIcon = Color3.new(1, 1, 1),
        
        Input = Color3.fromHex("#070a11"),
        InputBorder = Color3.fromHex("#151e2e"),
        InputFocusBorder = Color3.fromHex("#0f71d3"),
        
        Dropdown = Color3.fromHex("#070a11"),
        DropdownBorder = Color3.fromHex("#151e2e"),
        DropdownHover = Color3.fromHex("#0b121f"),
        
        Button = Color3.fromHex("#0b121f"),
        ButtonAccent = Color3.fromHex("#0f71d3"),
        ButtonText = Color3.new(1, 1, 1),
        
        -- Cards
        Card = Color3.fromHex("#0b121f"),
        CardBorder = Color3.fromHex("#151e2e"),
        
        -- Notifications
        NotifBackground = Color3.fromHex("#0b121f"),
        NotifBorder = Color3.fromHex("#151e2e"),
        NotifProgress = Color3.fromHex("#0f71d3"),
        
        -- Dialog
        DialogOverlay = Color3.new(0, 0, 0),
        DialogOverlayTransparency = 0.4,
        DialogBackground = Color3.fromHex("#060b13"),
        DialogBorder = Color3.fromHex("#151e2e"),
        
        -- Tooltip
        TooltipBackground = Color3.fromHex("#111827"),
        TooltipText = Color3.new(1, 1, 1),
        TooltipBorder = Color3.fromHex("#1a2438"),
        
        -- ScrollBar
        ScrollBar = Color3.fromHex("#151e2e"),
        
        -- Section
        SectionText = Color3.new(1, 1, 1),
        SectionDivider = Color3.fromHex("#151e2e"),
        
        -- Search
        SearchBackground = Color3.fromHex("#070a11"),
        SearchBorder = Color3.fromHex("#151e2e"),
        SearchText = Color3.fromHex("#8c9bad"),
        SearchIcon = Color3.fromHex("#5a677a"),
    },
    
    Midnight = {
        Name = "Midnight",
        Accent = Color3.fromHex("#a855f7"),
        Background = Color3.fromHex("#09090b"),
        Text = Color3.fromHex("#fafafa"),
        TextDark = Color3.fromHex("#71717a"),
        TextDimmed = Color3.fromHex("#52525b"),
        Icon = Color3.fromHex("#a1a1aa"),
        WindowBackground = Color3.fromHex("#09090b"),
        WindowShadow = Color3.new(0, 0, 0),
        WindowBorder = Color3.fromHex("#27272a"),
        WindowBorderTransparency = 0.5,
        TopbarTitle = Color3.fromHex("#a855f7"),
        TopbarIcon = Color3.fromHex("#a855f7"),
        TopbarButton = Color3.fromHex("#71717a"),
        SidebarBackground = Color3.fromHex("#09090b"),
        TabHover = Color3.fromHex("#18181b"),
        TabActive = Color3.fromHex("#a855f7"),
        TabIcon = Color3.fromHex("#52525b"),
        TabIconActive = Color3.fromHex("#a855f7"),
        Element = Color3.fromHex("#18181b"),
        ElementBorder = Color3.fromHex("#27272a"),
        ElementHover = Color3.fromHex("#1f1f23"),
        Toggle = Color3.fromHex("#27272a"),
        ToggleActive = Color3.fromHex("#3f3f46"),
        ToggleKnob = Color3.new(1, 1, 1),
        ToggleBorder = Color3.fromHex("#3f3f46"),
        Slider = Color3.fromHex("#a855f7"),
        SliderBg = Color3.fromHex("#27272a"),
        SliderThumb = Color3.fromHex("#a855f7"),
        Checkbox = Color3.fromHex("#a855f7"),
        CheckboxBorder = Color3.fromHex("#3f3f46"),
        CheckboxIcon = Color3.new(1, 1, 1),
        Input = Color3.fromHex("#09090b"),
        InputBorder = Color3.fromHex("#27272a"),
        InputFocusBorder = Color3.fromHex("#a855f7"),
        Dropdown = Color3.fromHex("#18181b"),
        DropdownBorder = Color3.fromHex("#27272a"),
        DropdownHover = Color3.fromHex("#27272a"),
        Button = Color3.fromHex("#27272a"),
        ButtonAccent = Color3.fromHex("#a855f7"),
        ButtonText = Color3.new(1, 1, 1),
        Card = Color3.fromHex("#18181b"),
        CardBorder = Color3.fromHex("#27272a"),
        NotifBackground = Color3.fromHex("#18181b"),
        NotifBorder = Color3.fromHex("#27272a"),
        NotifProgress = Color3.fromHex("#a855f7"),
        DialogOverlay = Color3.new(0, 0, 0),
        DialogOverlayTransparency = 0.4,
        DialogBackground = Color3.fromHex("#09090b"),
        DialogBorder = Color3.fromHex("#27272a"),
        TooltipBackground = Color3.fromHex("#27272a"),
        TooltipText = Color3.new(1, 1, 1),
        TooltipBorder = Color3.fromHex("#3f3f46"),
        ScrollBar = Color3.fromHex("#3f3f46"),
        SectionText = Color3.new(1, 1, 1),
        SectionDivider = Color3.fromHex("#27272a"),
        SearchBackground = Color3.fromHex("#09090b"),
        SearchBorder = Color3.fromHex("#27272a"),
        SearchText = Color3.fromHex("#71717a"),
        SearchIcon = Color3.fromHex("#52525b"),
    },
    
    Ocean = {
        Name = "Ocean",
        Accent = Color3.fromHex("#06b6d4"),
        Background = Color3.fromHex("#0a1628"),
        Text = Color3.fromHex("#e0f2fe"),
        TextDark = Color3.fromHex("#64748b"),
        TextDimmed = Color3.fromHex("#475569"),
        Icon = Color3.fromHex("#7dd3fc"),
        WindowBackground = Color3.fromHex("#0a1628"),
        WindowShadow = Color3.new(0, 0, 0),
        WindowBorder = Color3.fromHex("#1e3a5f"),
        WindowBorderTransparency = 0.5,
        TopbarTitle = Color3.fromHex("#06b6d4"),
        TopbarIcon = Color3.fromHex("#06b6d4"),
        TopbarButton = Color3.fromHex("#64748b"),
        SidebarBackground = Color3.fromHex("#0a1628"),
        TabHover = Color3.fromHex("#0f2035"),
        TabActive = Color3.fromHex("#06b6d4"),
        TabIcon = Color3.fromHex("#475569"),
        TabIconActive = Color3.fromHex("#06b6d4"),
        Element = Color3.fromHex("#0f2035"),
        ElementBorder = Color3.fromHex("#1e3a5f"),
        ElementHover = Color3.fromHex("#153050"),
        Toggle = Color3.fromHex("#1e3a5f"),
        ToggleActive = Color3.fromHex("#2a4a70"),
        ToggleKnob = Color3.new(1, 1, 1),
        ToggleBorder = Color3.fromHex("#1e3a5f"),
        Slider = Color3.fromHex("#06b6d4"),
        SliderBg = Color3.fromHex("#1e3a5f"),
        SliderThumb = Color3.fromHex("#06b6d4"),
        Checkbox = Color3.fromHex("#06b6d4"),
        CheckboxBorder = Color3.fromHex("#1e3a5f"),
        CheckboxIcon = Color3.new(1, 1, 1),
        Input = Color3.fromHex("#0a1628"),
        InputBorder = Color3.fromHex("#1e3a5f"),
        InputFocusBorder = Color3.fromHex("#06b6d4"),
        Dropdown = Color3.fromHex("#0f2035"),
        DropdownBorder = Color3.fromHex("#1e3a5f"),
        DropdownHover = Color3.fromHex("#153050"),
        Button = Color3.fromHex("#153050"),
        ButtonAccent = Color3.fromHex("#06b6d4"),
        ButtonText = Color3.new(1, 1, 1),
        Card = Color3.fromHex("#0f2035"),
        CardBorder = Color3.fromHex("#1e3a5f"),
        NotifBackground = Color3.fromHex("#0f2035"),
        NotifBorder = Color3.fromHex("#1e3a5f"),
        NotifProgress = Color3.fromHex("#06b6d4"),
        DialogOverlay = Color3.new(0, 0, 0),
        DialogOverlayTransparency = 0.4,
        DialogBackground = Color3.fromHex("#0a1628"),
        DialogBorder = Color3.fromHex("#1e3a5f"),
        TooltipBackground = Color3.fromHex("#1e3a5f"),
        TooltipText = Color3.new(1, 1, 1),
        TooltipBorder = Color3.fromHex("#2a4a70"),
        ScrollBar = Color3.fromHex("#1e3a5f"),
        SectionText = Color3.new(1, 1, 1),
        SectionDivider = Color3.fromHex("#1e3a5f"),
        SearchBackground = Color3.fromHex("#0a1628"),
        SearchBorder = Color3.fromHex("#1e3a5f"),
        SearchText = Color3.fromHex("#64748b"),
        SearchIcon = Color3.fromHex("#475569"),
    },
}

ValoxUI.CurrentTheme = ValoxUI.Themes.Dark

---------------------------------------------------------------
-- CORE UTILITIES
---------------------------------------------------------------

-- Safe callback execution
function ValoxUI.SafeCallback(callback, ...)
    if not callback then return end
    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[ValoxUI] Callback error: " .. tostring(err))
    end
end

-- Connection manager
function ValoxUI.AddSignal(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(ValoxUI._connections, conn)
    return conn
end

function ValoxUI.DisconnectAll()
    for i, conn in ipairs(ValoxUI._connections) do
        pcall(function() conn:Disconnect() end)
    end
    ValoxUI._connections = {}
end

-- Tween helper
function ValoxUI.Tween(obj, duration, props, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
end

local function tween(obj, duration, props, style, dir)
    local t = ValoxUI.Tween(obj, duration, props, style, dir)
    t:Play()
    return t
end

-- Instance creator
function ValoxUI.New(className, properties, children)
    local obj = Instance.new(className)
    
    -- Apply default properties based on class
    local defaults = {
        Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1) },
        TextLabel = { BorderSizePixel = 0, BackgroundTransparency = 1, Text = "", RichText = true, TextColor3 = Color3.new(1,1,1), TextSize = 14 },
        TextButton = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1), Text = "", AutoButtonColor = false, TextColor3 = Color3.new(1,1,1), TextSize = 14 },
        TextBox = { BorderSizePixel = 0, ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(1,1,1), TextSize = 14 },
        ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
        ImageButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false },
        ScrollingFrame = { ScrollBarImageTransparency = 1, BorderSizePixel = 0 },
        UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
    }
    
    for k, v in pairs(defaults[className] or {}) do
        pcall(function() obj[k] = v end)
    end
    
    for k, v in pairs(properties or {}) do
        if k ~= "Parent" and k ~= "ThemeTag" then
            pcall(function() obj[k] = v end)
        end
    end
    
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    
    if properties and properties.Parent then
        obj.Parent = properties.Parent
    end
    
    return obj
end

local New = ValoxUI.New

-- Squircle frame (smooth rounded rectangle)
function ValoxUI.NewSquircle(radius, shapeType, props, children, isButton, returnControl)
    shapeType = shapeType or "Squircle"
    local className = isButton and "TextButton" or "Frame"
    local frame = New(className, {
        BackgroundColor3 = props and props.ImageColor3 or Color3.new(1,1,1),
        BackgroundTransparency = props and props.ImageTransparency or 0,
    })
    
    if isButton then 
        frame.Text = ""
        frame.AutoButtonColor = false
    end
    
    local corner = New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = frame })
    
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "ThemeTag" and k ~= "ImageColor3" and k ~= "ImageTransparency" and k ~= "Image" and k ~= "ScaleType" and k ~= "SliceCenter" and k ~= "SliceScale" then
            pcall(function() frame[k] = v end)
        end
    end
    
    for _, child in pairs(children or {}) do
        child.Parent = frame
    end
    
    if props and props.Parent then
        frame.Parent = props.Parent
    end
    
    if shapeType == "Shadow" then
        frame.BackgroundTransparency = 1
        New("UIStroke", {
            Color = props and props.ImageColor3 or Color3.new(0, 0, 0),
            Transparency = math.min((props and props.ImageTransparency or 0.3) + 0.5, 1),
            Thickness = 2,
            Parent = frame
        })
    elseif string.find(shapeType or "", "Glass") then
        frame.BackgroundTransparency = props and props.ImageTransparency or 0.5
    end
    
    if props and props.ThemeTag then
        ValoxUI:AddThemeObject(frame, props.ThemeTag)
    end
    
    if returnControl then
        local control = {}
        function control:SetRadius(r)
            corner.CornerRadius = UDim.new(0, r)
        end
        function control:SetShape(s)
            -- Handled natively
        end
        return frame, control
    end
    
    return frame
end

-- Squircle outline
function ValoxUI.NewSquircleOutline(radius, props)
    local frame = New("Frame", {
        Size = props.Size or UDim2.new(1, 0, 1, 0),
        Position = props.Position or UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Parent = props.Parent,
        ZIndex = props.ZIndex or 2,
    })
    New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = frame })
    New("UIStroke", {
        Color = props.Color or props.ImageColor3 or Color3.fromHex("#1a2744"),
        Transparency = props.Transparency or props.ImageTransparency or 0.5,
        Thickness = props.Thickness or 1,
        Parent = frame
    })
    return frame
end

---------------------------------------------------------------
-- THEME MANAGEMENT
---------------------------------------------------------------

function ValoxUI:SetTheme(name)
    if type(name) == "string" and self.Themes[name] then
        self.CurrentTheme = self.Themes[name]
    elseif type(name) == "table" then
        self.CurrentTheme = name
    end
    self:UpdateTheme()
end

function ValoxUI:AddTheme(config)
    if config and config.Name then
        self.Themes[config.Name] = config
    end
end

function ValoxUI:GetThemeProperty(key)
    return self.CurrentTheme[key]
end

function ValoxUI:AddThemeObject(obj, properties)
    self._themeObjects[obj] = { Object = obj, Properties = properties }
    self:ApplyThemeToObject(obj, false)
    return obj
end

function ValoxUI:ApplyThemeToObject(obj, animate)
    local entry = self._themeObjects[obj]
    if not entry then return end
    
    for prop, themeKey in pairs(entry.Properties or {}) do
        local val = self.CurrentTheme[themeKey]
        if val ~= nil then
            local actualProp = prop
            if (obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame")) then
                if prop == "ImageColor3" then actualProp = "BackgroundColor3" end
                if prop == "ImageTransparency" then actualProp = "BackgroundTransparency" end
            end
            
            if typeof(val) == "Color3" or typeof(val) == "number" then
                if animate then
                    tween(obj, 0.15, {[actualProp] = val})
                else
                    pcall(function() obj[actualProp] = val end)
                end
            end
        end
    end
end

function ValoxUI:UpdateTheme(targetObj, animate)
    animate = animate ~= false
    if targetObj then
        self:ApplyThemeToObject(targetObj, animate)
    else
        for obj, _ in pairs(self._themeObjects) do
            if obj and obj.Parent then
                self:ApplyThemeToObject(obj, animate)
            end
        end
    end
end

-- Simple themed property tracker
function ValoxUI:_themed(obj, prop, themeKey)
    local actualProp = prop
    if (obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame")) then
        if prop == "ImageColor3" then actualProp = "BackgroundColor3" end
        if prop == "ImageTransparency" then actualProp = "BackgroundTransparency" end
    end
    
    local val = self.CurrentTheme[themeKey]
    if val then pcall(function() obj[actualProp] = val end) end
    if not self._themeObjects[obj] then
        self._themeObjects[obj] = { Object = obj, Properties = {} }
    end
    self._themeObjects[obj].Properties[actualProp] = themeKey
    return obj
end

---------------------------------------------------------------
-- FONT SYSTEM
---------------------------------------------------------------

function ValoxUI:AddFontObject(obj)
    table.insert(self._fontObjects, obj)
end

function ValoxUI:UpdateFont(fontAsset)
    self.Font = fontAsset
    for _, obj in ipairs(self._fontObjects) do
        if obj and obj.Parent then
            pcall(function()
                obj.FontFace = Font.new(fontAsset, obj.FontFace.Weight, obj.FontFace.Style)
            end)
        end
    end
end

---------------------------------------------------------------
-- DRAG SYSTEM
---------------------------------------------------------------

function ValoxUI.Drag(frame, handles, onDragChanged)
    if not handles or typeof(handles) ~= "table" then
        handles = { frame }
    end
    
    local dragging = false
    local dragStart, startPos
    local currentHandle = nil
    local control = { CanDraggable = true }
    
    local function update(input)
        if not dragging or not control.CanDraggable then return end
        local delta = input.Position - dragStart
        tween(frame, 0.04, {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        })
    end
    
    for _, handle in pairs(handles) do
        ValoxUI.AddSignal(handle.InputBegan, function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                input.UserInputType == Enum.UserInputType.Touch) and 
                control.CanDraggable and currentHandle == nil then
                
                currentHandle = handle
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                if onDragChanged then onDragChanged(true, handle) end
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        currentHandle = nil
                        if onDragChanged then onDragChanged(false, nil) end
                    end
                end)
            end
        end)
        
        ValoxUI.AddSignal(handle.InputChanged, function(input)
            if dragging and currentHandle == handle then
                if input.UserInputType == Enum.UserInputType.MouseMovement or
                   input.UserInputType == Enum.UserInputType.Touch then
                    update(input)
                end
            end
        end)
    end
    
    ValoxUI.AddSignal(UserInputService.InputChanged, function(input)
        if dragging and currentHandle then
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end
    end)
    
    function control:Set(canDrag)
        self.CanDraggable = canDrag
    end
    
    return control
end

---------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------
function ValoxUI:CreateWindow(config)
    config = config or {}
    local Window = {}
    Window.Title = config.Title or "ValoxUI"
    Window.Author = config.Author or ""
    Window.Icon = config.Icon or "shield"
    Window.Size = config.Size or UDim2.fromOffset(820, 520)
    Window.Transparent = config.Transparent or false
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window._valoxUI = self
    Window.Debug = config.Debug or false

    local screenGui = New("ScreenGui", {
        Name = "ValoxUI_" .. Window.Title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = Player:WaitForChild("PlayerGui") end
    Window.ScreenGui = screenGui

    -- Container
    local container = New("Frame", {
        Name = "Container",
        Size = Window.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })

    -- Shadow
    ValoxUI.NewSquircle(30, "Shadow", {
        Name = "Shadow",
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.3,
        Parent = container,
        ZIndex = 0,
    })

    -- Main window squircle
    local mainFrame = ValoxUI.NewSquircle(16, "Squircle", {
        Name = "Main",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = self.CurrentTheme.WindowBackground,
        ImageTransparency = Window.Transparent and 0.08 or 0,
        ClipsDescendants = true,
        Parent = container,
        ZIndex = 1,
    })
    self:_themed(mainFrame, "ImageColor3", "WindowBackground")
    Window.MainFrame = mainFrame
    Window.Container = container

    -- Window border
    ValoxUI.NewSquircleOutline(16, {
        Color = self.CurrentTheme.WindowBorder,
        Transparency = self.CurrentTheme.WindowBorderTransparency or 0.5,
        Parent = mainFrame,
        ZIndex = 10,
    })

    -- Glass effect (optional)
    if Window.Transparent then
        ValoxUI.NewSquircle(16, "Glass10", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = Color3.new(1, 1, 1),
            ImageTransparency = 0.92,
            Parent = mainFrame,
            ZIndex = 0,
        })
    end

    -- Topbar
    local topbar = New("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent = mainFrame,
        ZIndex = 5,
    })

    -- Topbar icon
    local resolvedIcon = ValoxUI.GetIcon(Window.Icon)
    local iconLabel
    if resolvedIcon ~= "" then
        iconLabel = New("ImageLabel", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.fromOffset(18, 13),
            Image = resolvedIcon,
            ImageColor3 = self.CurrentTheme.TopbarIcon,
            Parent = topbar,
        })
        self:_themed(iconLabel, "ImageColor3", "TopbarIcon")
    end

    -- Topbar title
    local titleLabel = New("TextLabel", {
        Text = Window.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self.CurrentTheme.TopbarTitle,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(iconLabel and 44 or 18, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Parent = topbar,
    })
    self:_themed(titleLabel, "TextColor3", "TopbarTitle")

    -- Close button
    local closeBtn = New("TextButton", {
        Text = "✕", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = self.CurrentTheme.TopbarButton,
        Size = UDim2.fromOffset(46, 46),
        Position = UDim2.new(1, -6, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Parent = topbar,
    })
    self:_themed(closeBtn, "TextColor3", "TopbarButton")

    -- Minimize button
    local minBtn = New("TextButton", {
        Text = "—", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = self.CurrentTheme.TopbarButton,
        Size = UDim2.fromOffset(46, 46),
        Position = UDim2.new(1, -52, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Parent = topbar,
    })
    self:_themed(minBtn, "TextColor3", "TopbarButton")

    -- Button hover effects
    for _, btn in pairs({closeBtn, minBtn}) do
        ValoxUI.AddSignal(btn.MouseEnter, function()
            tween(btn, 0.12, {TextColor3 = self.CurrentTheme.Text})
        end)
        ValoxUI.AddSignal(btn.MouseLeave, function()
            tween(btn, 0.12, {TextColor3 = self.CurrentTheme.TopbarButton})
        end)
    end

    -- Minimize logic
    local minimized = false
    local origSize = Window.Size
    ValoxUI.AddSignal(minBtn.MouseButton1Click, function()
        minimized = not minimized
        if minimized then
            tween(container, 0.4, {Size = UDim2.new(origSize.X.Scale, origSize.X.Offset, 0, 46)})
        else
            tween(container, 0.4, {Size = origSize})
        end
    end)

    -- Close logic
    ValoxUI.AddSignal(closeBtn.MouseButton1Click, function()
        tween(container, 0.35, {Size = UDim2.fromOffset(origSize.X.Offset, 0)})
        task.wait(0.35)
        screenGui:Destroy()
        ValoxUI.DisconnectAll()
    end)

    -- Draggable
    ValoxUI.Drag(container, {topbar})

    -- Sidebar
    local sidebarWidth = 60
    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarWidth, 1, -46),
        Position = UDim2.fromOffset(0, 46),
        BackgroundTransparency = 1,
        Parent = mainFrame,
        ZIndex = 3,
    })

    local sidebarScroll = New("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = sidebar,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
        New("UIPadding", { PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14) }),
    })
    Window.SidebarScroll = sidebarScroll

    -- Content area
    local contentArea = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -sidebarWidth, 1, -46),
        Position = UDim2.fromOffset(sidebarWidth, 46),
        BackgroundTransparency = 1,
        Parent = mainFrame,
        ZIndex = 3,
    })
    Window.ContentArea = contentArea

    -- Content header
    local contentHeader = New("Frame", {
        Name = "ContentHeader",
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        Parent = contentArea,
    })

    local contentTitle = New("TextLabel", {
        Name = "ContentTitle",
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        TextColor3 = self.CurrentTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(28, 16),
        Size = UDim2.new(1, -56, 0, 32),
        Parent = contentHeader,
    })
    self:_themed(contentTitle, "TextColor3", "Text")
    Window._contentTitle = contentTitle

    local contentDesc = New("TextLabel", {
        Name = "ContentDesc",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.CurrentTheme.TextDark,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(28, 50),
        Size = UDim2.new(1, -56, 0, 18),
        Parent = contentHeader,
    })
    self:_themed(contentDesc, "TextColor3", "TextDark")
    Window._contentDesc = contentDesc

    -- Notification container
    local notifContainer = New("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -10, 0, 10),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Parent = screenGui,
        ZIndex = 100,
    }, {
        New("UIListLayout", { 
            Padding = UDim.new(0, 8), 
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        }),
    })
    Window._notifContainer = notifContainer

    ---------------------------------------------------------------
    -- NOTIFICATION
    ---------------------------------------------------------------
    function Window:Notify(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Notification"
        local content = cfg.Content or ""
        local duration = cfg.Duration or 5
        local icon = cfg.Icon or "bell"

        local gui = self._valoxUI

        local notif = ValoxUI.NewSquircle(12, "Squircle", {
            Size = UDim2.new(1, 0, 0, 0),
            ImageColor3 = gui.CurrentTheme.NotifBackground,
            ClipsDescendants = true,
            Parent = notifContainer,
        })
        ValoxUI.NewSquircleOutline(12, {
            Color = gui.CurrentTheme.NotifBorder,
            Transparency = 0.5,
            Parent = notif,
        })

        local iconImg = ValoxUI.GetIcon(icon)
        if iconImg ~= "" then
            New("ImageLabel", {
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.fromOffset(14, 14),
                Image = iconImg,
                ImageColor3 = gui.CurrentTheme.Accent,
                Parent = notif,
            })
        end

        New("TextLabel", {
            Text = title, Font = Enum.Font.GothamBold, TextSize = 14,
            TextColor3 = gui.CurrentTheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(iconImg ~= "" and 40 or 14, 12),
            Size = UDim2.new(1, -54, 0, 18),
            Parent = notif,
        })
        New("TextLabel", {
            Text = content, Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = gui.CurrentTheme.TextDark,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Position = UDim2.fromOffset(iconImg ~= "" and 40 or 14, 32),
            Size = UDim2.new(1, -54, 0, 30),
            Parent = notif,
        })

        -- Progress bar
        local progressBar = New("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, 0),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = gui.CurrentTheme.NotifProgress,
            Parent = notif,
        })

        -- Animate in
        tween(notif, 0.3, {Size = UDim2.new(1, 0, 0, 70)})
        task.delay(0.3, function()
            tween(progressBar, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
        end)
        task.delay(duration + 0.3, function()
            tween(notif, 0.3, {Size = UDim2.new(1, 0, 0, 0), ImageTransparency = 1})
            task.delay(0.35, function() notif:Destroy() end)
        end)
    end

    ---------------------------------------------------------------
    -- DIALOG
    ---------------------------------------------------------------
    function Window:Dialog(cfg)
        cfg = cfg or {}
        local gui = self._valoxUI

        local overlay = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = gui.CurrentTheme.DialogOverlay,
            BackgroundTransparency = 1,
            ZIndex = 200,
            Parent = screenGui,
        })
        tween(overlay, 0.2, {BackgroundTransparency = gui.CurrentTheme.DialogOverlayTransparency or 0.4})

        local dialog = ValoxUI.NewSquircle(16, "Squircle", {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ImageColor3 = gui.CurrentTheme.DialogBackground,
            ClipsDescendants = true,
            Parent = overlay,
            ZIndex = 201,
        })
        ValoxUI.NewSquircleOutline(16, {
            Color = gui.CurrentTheme.DialogBorder,
            Transparency = 0.5, Parent = dialog, ZIndex = 202,
        })

        tween(dialog, 0.35, {Size = UDim2.fromOffset(400, 200)})

        New("TextLabel", {
            Text = cfg.Title or "Dialog", Font = Enum.Font.GothamBold, TextSize = 20,
            TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Center,
            Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 24),
            Parent = dialog, ZIndex = 202,
        })
        New("TextLabel", {
            Text = cfg.Content or "", Font = Enum.Font.Gotham, TextSize = 14,
            TextColor3 = gui.CurrentTheme.TextDark, TextXAlignment = Enum.TextXAlignment.Center,
            TextWrapped = true,
            Position = UDim2.fromOffset(20, 60), Size = UDim2.new(1, -40, 0, 60),
            Parent = dialog, ZIndex = 202,
        })

        local btnContainer = New("Frame", {
            Size = UDim2.new(1, -40, 0, 36),
            Position = UDim2.new(0, 20, 1, -50),
            BackgroundTransparency = 1,
            Parent = dialog, ZIndex = 202,
        }, {
            New("UIListLayout", { 
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
        })

        for _, btnCfg in ipairs(cfg.Buttons or {}) do
            local isAccent = btnCfg.Accent
            local dbtn = ValoxUI.NewSquircle(8, "Squircle", {
                Size = UDim2.new(0, 120, 0, 36),
                ImageColor3 = isAccent and gui.CurrentTheme.ButtonAccent or gui.CurrentTheme.Button,
                Parent = btnContainer, ZIndex = 203,
            }, {
                New("TextLabel", {
                    Text = btnCfg.Title or "OK",
                    Font = Enum.Font.GothamBold, TextSize = 13,
                    TextColor3 = gui.CurrentTheme.ButtonText,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 204,
                }),
            }, true)
            ValoxUI.AddSignal(dbtn.MouseButton1Click, function()
                tween(dialog, 0.25, {Size = UDim2.fromOffset(0, 0)})
                tween(overlay, 0.25, {BackgroundTransparency = 1})
                task.delay(0.3, function() overlay:Destroy() end)
                ValoxUI.SafeCallback(btnCfg.Callback)
            end)
        end
    end

    ---------------------------------------------------------------
    -- POPUP
    ---------------------------------------------------------------
    function Window:Popup(cfg)
        -- In Valoxexec style, Popup acts as a lightweight Dialog
        cfg.Title = cfg.Title or "Popup"
        return self:Dialog(cfg)
    end

    ---------------------------------------------------------------
    -- KEY SYSTEM
    ---------------------------------------------------------------
    function Window:KeySystem(cfg)
        cfg = cfg or {}
        local key = cfg.Key or "VALOX"
        local note = cfg.Note or "Please enter your key to continue."
        local gui = self._valoxUI
        
        local ksOverlay = New("Frame", {
            Size = UDim2.new(1, 0, 1, 46),
            Position = UDim2.fromOffset(0, -46),
            BackgroundColor3 = gui.CurrentTheme.WindowBackground,
            BackgroundTransparency = 0, ZIndex = 50, Parent = Window.MainFrame
        })
        
        local ksCenter = New("Frame", {
            Size = UDim2.fromOffset(320, 200), Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = ksOverlay
        })
        
        New("TextLabel", {
            Text = cfg.Title or "Key System", Font = Enum.Font.GothamBold, TextSize = 24,
            TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 0), Parent = ksCenter
        })
        
        New("TextLabel", {
            Text = note, Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = gui.CurrentTheme.TextDark, TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 36), Parent = ksCenter
        })
        
        local keyInput = New("TextBox", {
            PlaceholderText = "Enter Key...", Text = "",
            Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = gui.CurrentTheme.Text, PlaceholderColor3 = gui.CurrentTheme.TextDimmed,
            BackgroundColor3 = gui.CurrentTheme.Input,
            Size = UDim2.new(1, 0, 0, 38), Position = UDim2.fromOffset(0, 70), Parent = ksCenter
        }, {
            New("UICorner", { CornerRadius = UDim.new(0, 8) }),
            New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
            New("UIStroke", { Color = gui.CurrentTheme.InputBorder, Transparency = 0.5, Thickness = 1 }),
        })
        
        local submitBtn = ValoxUI.NewSquircle(8, "Squircle", {
            Size = UDim2.new(1, 0, 0, 38), Position = UDim2.fromOffset(0, 120),
            ImageColor3 = gui.CurrentTheme.ButtonAccent, Parent = ksCenter
        }, {
            New("TextLabel", {
                Text = "Submit Key", Font = Enum.Font.GothamBold, TextSize = 13,
                TextColor3 = gui.CurrentTheme.ButtonText, Size = UDim2.new(1, 0, 1, 0)
            })
        }, true)
        
        if cfg.SaveKey then
            local saved = isfile and isfile("valox_key.txt") and readfile("valox_key.txt") or ""
            if saved ~= "" then keyInput.Text = saved end
        end
        
        local passed = false
        ValoxUI.AddSignal(submitBtn.MouseButton1Click, function()
            local inputKey = keyInput.Text
            local isValid = false
            if type(key) == "table" then
                isValid = table.find(key, inputKey) ~= nil
            else
                isValid = (inputKey == key)
            end
            
            if isValid then
                if cfg.SaveKey and writefile then writefile("valox_key.txt", inputKey) end
                passed = true
                tween(ksOverlay, 0.4, {BackgroundTransparency = 1})
                task.delay(0.45, function() ksOverlay:Destroy() end)
            else
                keyInput.Text = ""
                keyInput.PlaceholderText = "Invalid Key!"
                task.delay(1.5, function()
                    if not passed then keyInput.PlaceholderText = "Enter Key..." end
                end)
            end
        end)
    end

    ---------------------------------------------------------------
    -- TAB
    ---------------------------------------------------------------
    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local Tab = {}
        Tab.Title = tabConfig.Title or "Tab"
        Tab.Desc = tabConfig.Desc or ""
        Tab.Icon = tabConfig.Icon or "layout-dashboard"
        Tab._locked = false

        local gui = self._valoxUI
        local theme = gui.CurrentTheme

        local tabIconImage = ValoxUI.GetIcon(Tab.Icon)

        -- Sidebar button
        local tabBtn = ValoxUI.NewSquircle(14, "Squircle", {
            Name = "Tab_" .. Tab.Title,
            Size = UDim2.fromOffset(44, 44),
            ImageColor3 = theme.TabHover,
            ImageTransparency = 1,
            Parent = self.SidebarScroll,
        }, {}, true)

        -- Active bar (invisible, disabled completely for accurate VALOXEXEC style)
        local activeBar = New("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = theme.TabActive,
            BackgroundTransparency = 1,
            Parent = tabBtn,
            Visible = false,
        })

        -- Tab icon
        local tabIconLabel
        if tabIconImage ~= "" then
            tabIconLabel = New("ImageLabel", {
                Size = UDim2.fromOffset(22, 22),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = tabIconImage,
                ImageColor3 = theme.TabIcon,
                Parent = tabBtn,
            })
        else
            New("TextLabel", {
                Text = string.sub(Tab.Title, 1, 2),
                Font = Enum.Font.GothamBold, TextSize = 14,
                TextColor3 = theme.TabIcon,
                Size = UDim2.new(1, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = tabBtn,
            })
        end

        -- Content scroll
        local contentFrame = New("ScrollingFrame", {
            Name = "TabContent_" .. Tab.Title,
            Size = UDim2.new(1, 0, 1, -80),
            Position = UDim2.fromOffset(0, 80),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.ScrollBar,
            ScrollBarImageTransparency = 0.3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = self.ContentArea,
        }, {
            New("UIListLayout", { Padding = UDim.new(0, 2) }),
            New("UIPadding", { PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 28), PaddingRight = UDim.new(0, 28) }),
        })
        Tab.ContentFrame = contentFrame

        -- Tab select
        function Tab:Select()
            for _, t in ipairs(Window.Tabs) do
                t.ContentFrame.Visible = false
                tween(t._tabBtn, 0.18, {ImageTransparency = 1})
                if t._activeBar then tween(t._activeBar, 0.18, {BackgroundTransparency = 1}) end
                if t._tabIcon then tween(t._tabIcon, 0.18, {ImageColor3 = gui.CurrentTheme.TabIcon}) end
            end
            self.ContentFrame.Visible = true
            Window.ActiveTab = self
            Window._contentTitle.Text = self.Title
            Window._contentDesc.Text = self.Desc or ""
            tween(tabBtn, 0.18, {ImageTransparency = 0.85, ImageColor3 = gui.CurrentTheme.TabHover})
            tween(activeBar, 0.18, {BackgroundTransparency = 0})
            if tabIconLabel then tween(tabIconLabel, 0.18, {ImageColor3 = gui.CurrentTheme.TabIconActive}) end
        end

        Tab._tabBtn = tabBtn
        Tab._activeBar = activeBar
        Tab._tabIcon = tabIconLabel
        function Tab:SetTitle(t) Tab.Title = t end
        function Tab:Lock() Tab._locked = true end
        function Tab:Unlock() Tab._locked = false end

        -- Hover
        ValoxUI.AddSignal(tabBtn.MouseEnter, function()
            if Window.ActiveTab ~= Tab then tween(tabBtn, 0.12, {ImageTransparency = 0.9, ImageColor3 = gui.CurrentTheme.TabHover}) end
        end)
        ValoxUI.AddSignal(tabBtn.MouseLeave, function()
            if Window.ActiveTab ~= Tab then tween(tabBtn, 0.12, {ImageTransparency = 1}) end
        end)
        ValoxUI.AddSignal(tabBtn.MouseButton1Click, function()
            if not Tab._locked then Tab:Select() end
        end)

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end

        -- Element row helper
        local function makeRow(title, desc, parent, height)
            parent = parent or contentFrame
            height = height or 50
            local totalH = desc and desc ~= "" and (height + 16) or height
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, totalH),
                BackgroundTransparency = 1,
                Parent = parent,
            }, {
                New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
            })
            New("TextLabel", {
                Text = title or "", Font = Enum.Font.GothamBold, TextSize = 15,
                TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.fromOffset(0, desc and desc ~= "" and 8 or 0),
                Size = UDim2.new(0.55, 0, 0, desc and desc ~= "" and 22 or totalH),
                Parent = row,
            })
            if desc and desc ~= "" then
                New("TextLabel", {
                    Text = desc, Font = Enum.Font.Gotham, TextSize = 12,
                    TextColor3 = gui.CurrentTheme.TextDark, TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(0, 30),
                    Size = UDim2.new(0.55, 0, 0, 16), Parent = row,
                })
            end
            return row
        end

        -- BUTTON
        function Tab:Button(cfg)
            cfg = cfg or {}
            local row = makeRow(cfg.Title, cfg.Desc, cfg.Parent)
            local btn = New("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = row })
            ValoxUI.AddSignal(btn.MouseButton1Click, function() ValoxUI.SafeCallback(cfg.Callback) end)
            return {__type = "Button"}
        end

        -- TOGGLE
        function Tab:Toggle(cfg)
            cfg = cfg or {}
            local state = cfg.Default or cfg.Value or false
            local row = makeRow(cfg.Title, cfg.Desc)
            local track = New("Frame", {
                Size = UDim2.fromOffset(44, 24), Position = UDim2.new(1, -4, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = state and gui.CurrentTheme.ToggleActive or gui.CurrentTheme.Toggle,
                Parent = row,
            }, {
                New("UICorner", { CornerRadius = UDim.new(1, 0) }),
                New("UIStroke", { Color = gui.CurrentTheme.ToggleBorder, Transparency = 0.5, Thickness = 1 }),
            })
            local knob = New("Frame", {
                Size = UDim2.fromOffset(18, 18),
                Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.new(1, 1, 1), Parent = track,
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            local toggle = { __type = "Toggle", Value = state }
            function toggle:Set(val)
                state = val; self.Value = val
                tween(knob, 0.18, {Position = val and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)})
                tween(track, 0.18, {BackgroundColor3 = val and gui.CurrentTheme.ToggleActive or gui.CurrentTheme.Toggle})
                ValoxUI.SafeCallback(cfg.Callback, val)
            end
            local clickBtn = New("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = row })
            ValoxUI.AddSignal(clickBtn.MouseButton1Click, function() toggle:Set(not state) end)
            return toggle
        end

        -- SLIDER
        function Tab:Slider(cfg)
            cfg = cfg or {}
            local vMin = cfg.Value and cfg.Value.Min or cfg.Min or 0
            local vMax = cfg.Value and cfg.Value.Max or cfg.Max or 100
            local vDef = cfg.Value and cfg.Value.Default or cfg.Default or vMin
            local step = cfg.Step or 1
            local curVal = vDef
            local row = makeRow(cfg.Title, cfg.Desc, nil, 56)
            local valLabel = New("TextLabel", {
                Text = tostring(curVal), Font = Enum.Font.GothamBold, TextSize = 14,
                TextColor3 = gui.CurrentTheme.TextDark,
                Size = UDim2.fromOffset(60, 22), Position = UDim2.new(1, -4, 0, 8),
                AnchorPoint = Vector2.new(1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
            })
            local barBg = New("Frame", {
                Size = UDim2.new(0.45, 0, 0, 4), Position = UDim2.new(1, -4, 1, -14),
                AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = gui.CurrentTheme.SliderBg, Parent = row,
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            local pct = math.clamp((curVal - vMin) / (vMax - vMin), 0, 1)
            local barFill = New("Frame", {
                Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = gui.CurrentTheme.Slider, Parent = barBg,
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            New("Frame", {
                Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = gui.CurrentTheme.SliderThumb,
                ZIndex = 5, Parent = barFill,
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            local slider = { __type = "Slider", Value = {Min = vMin, Max = vMax, Default = curVal} }
            local function update(val)
                val = math.clamp(val, vMin, vMax)
                val = math.floor(val / step + 0.5) * step
                curVal = val; slider.Value.Default = val
                tween(barFill, 0.06, {Size = UDim2.new(math.clamp((val - vMin) / (vMax - vMin), 0, 1), 0, 1, 0)})
                valLabel.Text = tostring(val)
                ValoxUI.SafeCallback(cfg.Callback, val)
            end
            function slider:Set(val) update(val) end
            local sliding = false
            ValoxUI.AddSignal(barBg.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    update(vMin + math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1) * (vMax - vMin))
                end
            end)
            ValoxUI.AddSignal(UserInputService.InputChanged, function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(vMin + math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1) * (vMax - vMin))
                end
            end)
            ValoxUI.AddSignal(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            return slider
        end

        -- INPUT
        function Tab:Input(cfg)
            cfg = cfg or {}
            local row = makeRow(cfg.Title, cfg.Desc)
            local inputBox = New("TextBox", {
                Text = cfg.Value or "", PlaceholderText = cfg.Placeholder or "Type here...",
                Font = Enum.Font.Gotham, TextSize = 13,
                TextColor3 = gui.CurrentTheme.Text, PlaceholderColor3 = gui.CurrentTheme.TextDimmed,
                BackgroundColor3 = gui.CurrentTheme.Input,
                Size = UDim2.new(0.4, 0, 0, 32), Position = UDim2.new(1, -4, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5), TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 8) }),
                New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
                New("UIStroke", { Color = gui.CurrentTheme.InputBorder, Transparency = 0.5, Thickness = 1 }),
            })
            local el = { __type = "Input", Value = cfg.Value or "" }
            function el:Set(val) inputBox.Text = val; self.Value = val end
            ValoxUI.AddSignal(inputBox.FocusLost, function()
                el.Value = inputBox.Text; ValoxUI.SafeCallback(cfg.Callback, inputBox.Text)
            end)
            return el
        end

        -- DROPDOWN
        function Tab:Dropdown(cfg)
            cfg = cfg or {}
            local values = cfg.Values or {}
            local multi = cfg.Multi or false
            local curValue = cfg.Value or (multi and {} or nil)
            local opened = false
            local row = makeRow(cfg.Title, cfg.Desc, nil, 50)
            local displayText = ""
            if multi and type(curValue) == "table" then displayText = table.concat(curValue, ", ")
            elseif curValue then displayText = tostring(curValue) end
            if displayText == "" then displayText = "Select..." end

            local dropBtn = New("TextButton", {
                Text = displayText, Font = Enum.Font.Gotham, TextSize = 13,
                TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BackgroundColor3 = gui.CurrentTheme.Input, AutoButtonColor = false,
                Size = UDim2.new(0.4, 0, 0, 32), Position = UDim2.new(1, -4, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5), Parent = row,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 8) }),
                New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 26) }),
                New("UIStroke", { Color = gui.CurrentTheme.InputBorder, Transparency = 0.5, Thickness = 1 }),
            })

            local optContainer = New("Frame", {
                Size = UDim2.new(0.4, 0, 0, 0), Position = UDim2.new(1, -4, 1, -4),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = gui.CurrentTheme.Dropdown, ClipsDescendants = true,
                Visible = false, ZIndex = 100, Parent = row,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 10) }),
                New("UIStroke", { Color = gui.CurrentTheme.DropdownBorder, Transparency = 0.5, Thickness = 1 }),
            })

            local optScroll = New("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2,
                AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), Parent = optContainer,
            }, {
                New("UIListLayout", { Padding = UDim.new(0, 2) }),
                New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
            })

            local dropdown = { __type = "Dropdown", Value = curValue, Values = values }
            local function updateDisplay()
                local txt
                if multi and type(dropdown.Value) == "table" then txt = table.concat(dropdown.Value, ", ")
                elseif dropdown.Value then txt = tostring(dropdown.Value) end
                dropBtn.Text = (txt and txt ~= "") and txt or "Select..."
            end
            local function buildOpts()
                for _, c in pairs(optScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _, v in ipairs(dropdown.Values) do
                    local ob = New("TextButton", {
                        Text = tostring(v), Font = Enum.Font.Gotham, TextSize = 13,
                        TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundColor3 = gui.CurrentTheme.Dropdown, BackgroundTransparency = 0.5,
                        AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 28), Parent = optScroll,
                    }, { New("UICorner", { CornerRadius = UDim.new(0, 6) }), New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
                    ValoxUI.AddSignal(ob.MouseEnter, function() tween(ob, 0.08, {BackgroundTransparency = 0.1}) end)
                    ValoxUI.AddSignal(ob.MouseLeave, function() tween(ob, 0.08, {BackgroundTransparency = 0.5}) end)
                    ValoxUI.AddSignal(ob.MouseButton1Click, function()
                        if multi then
                            local idx = table.find(dropdown.Value, v)
                            if idx then table.remove(dropdown.Value, idx) else table.insert(dropdown.Value, v) end
                        else
                            dropdown.Value = v; opened = false
                            tween(optContainer, 0.2, {Size = UDim2.new(0.4, 0, 0, 0)})
                            task.delay(0.2, function() optContainer.Visible = false end)
                        end
                        updateDisplay(); ValoxUI.SafeCallback(cfg.Callback, dropdown.Value)
                    end)
                end
                return math.min(#dropdown.Values, 6) * 30 + 8
            end
            local targetH = buildOpts()
            function dropdown:Refresh(nv) self.Values = nv; targetH = buildOpts(); updateDisplay() end
            ValoxUI.AddSignal(dropBtn.MouseButton1Click, function()
                opened = not opened
                if opened then
                    optContainer.Visible = true
                    tween(optContainer, 0.22, {Size = UDim2.new(0.4, 0, 0, targetH)})
                    row.Size = UDim2.new(1, 0, 0, 50 + targetH + 6 + (cfg.Desc and cfg.Desc ~= "" and 16 or 0))
                else
                    tween(optContainer, 0.18, {Size = UDim2.new(0.4, 0, 0, 0)})
                    task.delay(0.18, function() optContainer.Visible = false end)
                    row.Size = UDim2.new(1, 0, 0, cfg.Desc and cfg.Desc ~= "" and 66 or 50)
                end
            end)
            updateDisplay()
            return dropdown
        end

        -- CHECKBOX
        function Tab:Checkbox(cfg)
            cfg = cfg or {}
            local state = cfg.Default or cfg.Value or false
            local row = makeRow(cfg.Title, cfg.Desc)
            local box = New("Frame", {
                Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -4, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = state and gui.CurrentTheme.Checkbox or Color3.fromHex("#0e1726"),
                Parent = row,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 6) }),
                New("UIStroke", { Color = gui.CurrentTheme.CheckboxBorder, Transparency = 0.3, Thickness = 1.5 }),
            })
            local checkIcon = ValoxUI.GetIcon("check")
            local checkImg
            if checkIcon ~= "" then
                checkImg = New("ImageLabel", {
                    Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5), Image = checkIcon,
                    ImageColor3 = gui.CurrentTheme.CheckboxIcon,
                    ImageTransparency = state and 0 or 1, Parent = box,
                })
            end
            local checkbox = { __type = "Checkbox", Value = state }
            function checkbox:Set(val)
                state = val; self.Value = val
                tween(box, 0.15, {BackgroundColor3 = val and gui.CurrentTheme.Checkbox or Color3.fromHex("#0e1726")})
                if checkImg then tween(checkImg, 0.15, {ImageTransparency = val and 0 or 1}) end
                ValoxUI.SafeCallback(cfg.Callback, val)
            end
            local btn = New("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = row })
            ValoxUI.AddSignal(btn.MouseButton1Click, function() checkbox:Set(not state) end)
            return checkbox
        end

        -- KEYBIND
        function Tab:Keybind(cfg)
            cfg = cfg or {}
            local current = cfg.Value or cfg.Default or Enum.KeyCode.E
            local row = makeRow(cfg.Title, cfg.Desc)
            local kbBtn = New("TextButton", {
                Text = current.Name, Font = Enum.Font.GothamBold, TextSize = 12,
                TextColor3 = gui.CurrentTheme.Text,
                BackgroundColor3 = gui.CurrentTheme.Input,
                Size = UDim2.new(0, 80, 0, 28), Position = UDim2.new(1, -4, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5), Parent = row,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 6) }),
                New("UIStroke", { Color = gui.CurrentTheme.InputBorder, Transparency = 0.5, Thickness = 1 }),
            })
            local keybind = { __type = "Keybind", Value = current }
            local listening = false
            ValoxUI.AddSignal(kbBtn.MouseButton1Click, function()
                listening = true; kbBtn.Text = "..."
            end)
            ValoxUI.AddSignal(UserInputService.InputBegan, function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    current = input.KeyCode; keybind.Value = current
                    kbBtn.Text = current.Name; listening = false
                    ValoxUI.SafeCallback(cfg.Callback, current)
                elseif not listening and not gpe and input.KeyCode == current then
                    ValoxUI.SafeCallback(cfg.OnPressed, current)
                end
            end)
            function keybind:Set(key) current = key; self.Value = key; kbBtn.Text = key.Name end
            return keybind
        end

        -- PARAGRAPH
        function Tab:Paragraph(cfg)
            cfg = cfg or {}
            local txt = cfg.Text or cfg.Content or ""
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = contentFrame,
            }, {
                New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
            })
            
            local titleLabel
            if cfg.Title and cfg.Title ~= "" then
                titleLabel = New("TextLabel", {
                    Text = cfg.Title, Font = Enum.Font.GothamBold, TextSize = 15,
                    TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 22), Parent = row,
                })
            end
            
            local contentLabel = New("TextLabel", {
                Text = txt, Font = Enum.Font.Gotham, TextSize = 13,
                TextColor3 = gui.CurrentTheme.TextDark, TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
                Position = UDim2.fromOffset(0, titleLabel and 22 or 0),
                Size = UDim2.new(1, 0, 0, 20), Parent = row,
            })
            
            local function updateSize()
                local bounds = TextService:GetTextSize(txt, 13, Enum.Font.Gotham, Vector2.new(contentFrame.AbsoluteSize.X - 56, math.huge))
                contentLabel.Size = UDim2.new(1, 0, 0, bounds.Y + 4)
                row.Size = UDim2.new(1, 0, 0, (titleLabel and 22 or 0) + bounds.Y + 12)
            end
            updateSize()
            ValoxUI.AddSignal(contentFrame:GetPropertyChangedSignal("AbsoluteSize"), updateSize)
            
            local paragraph = { __type = "Paragraph", Value = txt }
            function paragraph:Set(newTxt)
                txt = newTxt; contentLabel.Text = newTxt; updateSize()
            end
            return paragraph
        end

        -- DIVIDER
        function Tab:Divider()
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1, Parent = contentFrame,
            })
            local line = New("Frame", {
                Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = gui.CurrentTheme.SectionDivider,
                Parent = row,
            })
            gui:_themed(line, "BackgroundColor3", "SectionDivider")
            return { __type = "Divider" }
        end

        -- SPACE
        function Tab:Space(height)
            height = height or 20
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, height),
                BackgroundTransparency = 1, Parent = contentFrame,
            })
            return { __type = "Space" }
        end
        
        -- CODE
        function Tab:Code(cfg)
            cfg = cfg or {}
            local codeTxt = cfg.Code or ""
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1, Parent = contentFrame,
            })
            
            local bounds = TextService:GetTextSize(codeTxt, 12, Enum.Font.Code, Vector2.new(contentFrame.AbsoluteSize.X - 80, math.huge))
            local codeH = math.max(40, bounds.Y + 20)
            row.Size = UDim2.new(1, 0, 0, codeH + 16)
            
            local bg = ValoxUI.NewSquircle(8, "Squircle", {
                Size = UDim2.new(1, -8, 0, codeH),
                Position = UDim2.fromOffset(4, 8),
                ImageColor3 = Color3.fromHex("#04080e"), -- Darker code bg
                Parent = row
            })
            ValoxUI.NewSquircleOutline(8, {
                Color = gui.CurrentTheme.ElementBorder, Transparency = 0.5, Parent = bg
            })
            
            local codeLabel = New("TextLabel", {
                Text = codeTxt, Font = Enum.Font.Code, TextSize = 12,
                TextColor3 = Color3.fromHex("#a8b5c9"), TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
                RichText = false,
                Size = UDim2.new(1, -40, 1, -20), Position = UDim2.fromOffset(12, 10),
                Parent = bg
            })
            
            local copyBtn = New("TextButton", {
                Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -8, 0, 8),
                AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Parent = bg
            })
            local copyIcon = ValoxUI.GetIcon("copy")
            local copyImg
            if copyIcon ~= "" then
                copyImg = New("ImageLabel", {
                    Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5), Image = copyIcon, ImageColor3 = gui.CurrentTheme.Icon,
                    Parent = copyBtn
                })
            end
            
            ValoxUI.AddSignal(copyBtn.MouseEnter, function() if copyImg then tween(copyImg, 0.15, {ImageColor3 = gui.CurrentTheme.Text}) end end)
            ValoxUI.AddSignal(copyBtn.MouseLeave, function() if copyImg then tween(copyImg, 0.15, {ImageColor3 = gui.CurrentTheme.Icon}) end end)
            ValoxUI.AddSignal(copyBtn.MouseButton1Click, function()
                pcall(function() setclipboard(codeTxt) end)
                if copyImg then
                    copyImg.Image = ValoxUI.GetIcon("check")
                    copyImg.ImageColor3 = Color3.fromHex("#10b981")
                    task.delay(1.5, function()
                        copyImg.Image = ValoxUI.GetIcon("copy")
                        copyImg.ImageColor3 = gui.CurrentTheme.Icon
                    end)
                end
            end)
            
            local function updateSize()
                local nBounds = TextService:GetTextSize(codeTxt, 12, Enum.Font.Code, Vector2.new(contentFrame.AbsoluteSize.X - 80, math.huge))
                local nH = math.max(40, nBounds.Y + 20)
                row.Size = UDim2.new(1, 0, 0, nH + 16)
                bg.Size = UDim2.new(1, -8, 0, nH)
            end
            ValoxUI.AddSignal(contentFrame:GetPropertyChangedSignal("AbsoluteSize"), updateSize)
            
            local element = { __type = "Code", Value = codeTxt }
            function element:Set(newCode)
                codeTxt = newCode; codeLabel.Text = newCode; updateSize()
            end
            return element
        end

        -- IMAGE
        function Tab:Image(cfg)
            cfg = cfg or {}
            local imageId = cfg.Image or ""
            local h = cfg.Height or 150
            local row = New("Frame", {
                Size = UDim2.new(1, 0, 0, h + 16),
                BackgroundTransparency = 1, Parent = contentFrame,
            })
            local imgLabel = ValoxUI.NewSquircle(8, "Squircle", {
                Size = UDim2.new(1, -8, 0, h),
                Position = UDim2.fromOffset(4, 8),
                ImageColor3 = Color3.new(1, 1, 1), ImageTransparency = 0, Parent = row
            })
            
            local contentImg = New("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0), Image = imageId,
                ScaleType = Enum.ScaleType.Crop, Parent = imgLabel
            })
            New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = contentImg })
            
            ValoxUI.NewSquircleOutline(8, {
                Color = gui.CurrentTheme.ElementBorder, Transparency = 0.5, Parent = imgLabel
            })
            
            local element = { __type = "Image", Value = imageId }
            function element:Set(newImg)
                imageId = newImg; contentImg.Image = newImg
            end
            return element
        end

        -- COLORPICKER
        function Tab:Colorpicker(cfg)
            cfg = cfg or {}
            local color = cfg.Default or cfg.Value or Color3.new(1, 1, 1)
            local row = makeRow(cfg.Title, cfg.Desc, nil, 50)
            
            local colorBtn = New("TextButton", {
                Size = UDim2.fromOffset(40, 24), Position = UDim2.new(1, -4, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5), Text = "",
                BackgroundColor3 = color, Parent = row
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 6) }),
                New("UIStroke", { Color = gui.CurrentTheme.ElementBorder, Transparency = 0.3, Thickness = 1.5 }),
            })
            
            local picker = { __type = "Colorpicker", Value = color }
            
            -- Simplified Dialog Picker (R, G, B standard sliders logic built in)
            ValoxUI.AddSignal(colorBtn.MouseButton1Click, function()
                local pickerGui = New("Frame", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 200,
                    Parent = Window.ScreenGui
                })
                local overlay = New("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0),
                    BackgroundTransparency = 0.5, Text = "", ZIndex = 200, Parent = pickerGui
                })
                
                local modal = ValoxUI.NewSquircle(12, "Squircle", {
                    Size = UDim2.fromOffset(260, 280), Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5), ImageColor3 = gui.CurrentTheme.Element,
                    ZIndex = 201, Parent = pickerGui
                }, {
                    New("UIStroke", { Color = gui.CurrentTheme.ElementBorder, Thickness = 1 })
                })
                
                New("TextLabel", {
                    Text = "Select Color", Font = Enum.Font.GothamBold, TextSize = 15,
                    TextColor3 = gui.CurrentTheme.Text, Size = UDim2.new(1, 0, 0, 40),
                    Position = UDim2.fromOffset(0, 0), ZIndex = 202, Parent = modal
                })
                
                local preview = New("Frame", {
                    Size = UDim2.new(1, -40, 0, 40), Position = UDim2.fromOffset(20, 50),
                    BackgroundColor3 = color, ZIndex = 202, Parent = modal
                }, { New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
                
                local function addSlider(title, pos, defValue, onUpdate)
                    New("TextLabel", {
                        Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
                        TextColor3 = gui.CurrentTheme.TextDark, TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(0, 30, 0, 20), Position = UDim2.fromOffset(20, pos),
                        ZIndex = 202, Parent = modal
                    })
                    local valLbl = New("TextLabel", {
                        Text = tostring(math.floor(defValue * 255)), Font = Enum.Font.GothamBold, TextSize = 13,
                        TextColor3 = gui.CurrentTheme.Text, TextXAlignment = Enum.TextXAlignment.Right,
                        Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -60, 0, pos),
                        ZIndex = 202, Parent = modal
                    })
                    local bg = New("Frame", {
                        Size = UDim2.new(1, -40, 0, 6), Position = UDim2.fromOffset(20, pos + 25),
                        BackgroundColor3 = gui.CurrentTheme.SliderBg, ZIndex = 202, Parent = modal
                    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                    local fill = New("Frame", {
                        Size = UDim2.new(defValue, 0, 1, 0), BackgroundColor3 = title == "R" and Color3.fromHex("#ef4444") or title == "G" and Color3.fromHex("#10b981") or Color3.fromHex("#3b82f6"),
                        ZIndex = 203, Parent = bg
                    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                    
                    local sliding = false
                    local function update(input)
                        local pct = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        valLbl.Text = tostring(math.floor(pct * 255))
                        onUpdate(pct)
                    end
                    ValoxUI.AddSignal(bg.InputBegan, function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(inp) end end)
                    ValoxUI.AddSignal(UserInputService.InputChanged, function(inp) if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then update(inp) end end)
                    ValoxUI.AddSignal(UserInputService.InputEnded, function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
                end
                
                local r, g, b = color.R, color.G, color.B
                local function updateColor()
                    local newC = Color3.new(r, g, b)
                    preview.BackgroundColor3 = newC
                    colorBtn.BackgroundColor3 = newC
                    picker.Value = newC
                    color = newC
                    ValoxUI.SafeCallback(cfg.Callback, newC)
                end
                
                addSlider("R", 100, r, function(v) r = v; updateColor() end)
                addSlider("G", 145, g, function(v) g = v; updateColor() end)
                addSlider("B", 190, b, function(v) b = v; updateColor() end)
                
                local confirmBtn = ValoxUI.NewSquircle(8, "Squircle", {
                    Size = UDim2.new(1, -40, 0, 36), Position = UDim2.fromOffset(20, 230),
                    ImageColor3 = gui.CurrentTheme.ButtonAccent, ZIndex = 202, Parent = modal
                }, {
                    New("TextLabel", {
                        Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 13,
                        TextColor3 = gui.CurrentTheme.ButtonText, Size = UDim2.new(1, 0, 1, 0), ZIndex = 203
                    })
                }, true)
                
                local function close()
                    tween(modal, 0.2, {Size = UDim2.fromOffset(0,0)})
                    tween(overlay, 0.2, {BackgroundTransparency = 1})
                    task.delay(0.25, function() pickerGui:Destroy() end)
                end
                ValoxUI.AddSignal(confirmBtn.MouseButton1Click, close)
                ValoxUI.AddSignal(overlay.MouseButton1Click, close)
            end)
            
            function picker:Set(col)
                color = col; colorBtn.BackgroundColor3 = col; picker.Value = col
                ValoxUI.SafeCallback(cfg.Callback, col)
            end
            return picker
        end

        -- SECTION
        function Tab:Section(cfg)
            cfg = cfg or {}
            local sectionTitle = cfg.Title or "Section"
            local section = { Title = sectionTitle }
            local secRow = New("Frame", {
                Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = contentFrame,
            })
            New("TextLabel", {
                Text = sectionTitle, Font = Enum.Font.GothamBold, TextSize = 15,
                TextColor3 = gui.CurrentTheme.TextDark, TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 1, 0), Position = UDim2.fromOffset(4, 8), Parent = secRow,
            })
            
            function section:Button(c) c = c or {}; c.Parent = contentFrame; return Tab:Button(c) end
            function section:Toggle(c) c = c or {}; c.Parent = contentFrame; return Tab:Toggle(c) end
            function section:Slider(c) c = c or {}; c.Parent = contentFrame; return Tab:Slider(c) end
            function section:Input(c) c = c or {}; c.Parent = contentFrame; return Tab:Input(c) end
            function section:Dropdown(c) c = c or {}; c.Parent = contentFrame; return Tab:Dropdown(c) end
            function section:Checkbox(c) c = c or {}; c.Parent = contentFrame; return Tab:Checkbox(c) end
            function section:Keybind(c) c = c or {}; c.Parent = contentFrame; return Tab:Keybind(c) end
            function section:Paragraph(c) c = c or {}; return Tab:Paragraph(c) end
            function section:Colorpicker(c) c = c or {}; c.Parent = contentFrame; return Tab:Colorpicker(c) end
            function section:Code(c) c = c or {}; return Tab:Code(c) end
            function section:Image(c) c = c or {}; return Tab:Image(c) end
            function section:Space(h) return Tab:Space(h) end
            function section:Divider() return Tab:Divider() end
            function section:Configs(c) c = c or {}; return Tab:Configs(c) end
            function section:Section(c) return Tab:Section(c) end
            return section
        end

        -- CONFIGS
        function Tab:Configs(cfg)
            cfg = cfg or {}
            local folderName = cfg.Folder or "ValoxConfigs"
            if not isfolder or not makefolder then return end
            if not isfolder(folderName) then makefolder(folderName) end
            
            local section = Tab:Section({ Title = cfg.Title or "Configurations" })
            local fileInput = section:Input({
                Title = "Config Name",
                Desc = "Select or type a configuration name",
                Placeholder = "my_config",
                Value = ""
            })
            
            local function refreshFiles()
                local files = {}
                if listfiles then
                    for _, file in ipairs(listfiles(folderName)) do
                        if file:match("%.json$") then
                            local name = file:match("([^/\\]+)%.json$")
                            if name then table.insert(files, name) end
                        end
                    end
                end
                return files
            end
            
            local drop = section:Dropdown({
                Title = "Available Configs",
                Desc = "List of saved configurations",
                Values = refreshFiles(),
                Value = nil,
                Callback = function(val)
                    if val then fileInput:Set(val) end
                end
            })
            
            local saveBtn = section:Button({
                Title = "Save Configuration",
                Desc = "Saves current settings to the file",
                Callback = function()
                    local name = fileInput.Value
                    if name == "" then return Window:Notify({ Title="Error", Content="Please enter a config name!", Duration=3 }) end
                    if writefile and HttpService then
                        -- Dummy save example, real configs need a state map
                        writefile(folderName .. "/" .. name .. ".json", HttpService:JSONEncode({timestamp = os.time()}))
                        Window:Notify({ Title="Configs", Content="Saved " .. name .. ".json successfully!" })
                        drop:Refresh(refreshFiles())
                    end
                end
            })
            
            local loadBtn = section:Button({
                Title = "Load Configuration",
                Desc = "Loads settings from the selected file",
                Callback = function()
                    local name = fileInput.Value
                    if name == "" then return Window:Notify({ Title="Error", Content="Please enter a config name!", Duration=3 }) end
                    if readfile and isfile and isfile(folderName .. "/" .. name .. ".json") then
                        -- Dummy load
                        Window:Notify({ Title="Configs", Content="Loaded " .. name .. ".json successfully!" })
                    else
                        Window:Notify({ Title="Error", Content="Config not found!" })
                    end
                end
            })
            return section
        end

        return Tab
    end

    table.insert(ValoxUI._windows, Window)
    return Window
end

return ValoxUI
