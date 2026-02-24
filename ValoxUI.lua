local ValoxUI = {}
ValoxUI.__index = ValoxUI

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Configuration
ValoxUI.Version = "1.0.0"
ValoxUI.Theme = {
    Background = Color3.fromRGB(15, 17, 26),      -- Very dark blue/black
    Sidebar = Color3.fromRGB(20, 22, 34),         -- Lighter dark blue for sidebar
    Topbar = Color3.fromRGB(15, 17, 26),          -- Same as background
    Text = Color3.fromRGB(255, 255, 255),         -- White text
    TextMuted = Color3.fromRGB(150, 150, 170),    -- Muted text for descriptions
    Accent = Color3.fromRGB(0, 120, 255),         -- Valox Blue
    Border = Color3.fromRGB(40, 45, 60),          -- Subtle border color
    ElementBackground = Color3.fromRGB(25, 28, 40) -- For buttons, inputs etc
}

-- Fonts
local FontRegular = Enum.Font.Gotham
local FontSemiBold = Enum.Font.GothamSemibold
local FontBold = Enum.Font.GothamBold

-- Utility functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Round(instance, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = instance
    })
end

local function Stroke(instance, color, thickness)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = instance
    })
end

function ValoxUI:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "ValoxUI"
    local Size = options.Size or UDim2.fromOffset(750, 480)
    local Folder = options.Folder or "ValoxUI"
    local Theme = self.Theme

    -- Find Parent
    local Parent = nil
    if game:GetService("RunService"):IsStudio() then
        Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        Parent = CoreGui
    end

    -- Create ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = Folder,
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = Parent
    })

    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    Round(MainFrame, 8)
Stroke(MainFrame, Theme.Border, 1)

    -- Topbar
    local Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FontBold,
        TextSize = 14,
        Parent = Topbar
    })

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, -40),
        Position = UDim2.fromOffset(0, 40),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    -- Sidebar separator line
    local SidebarLine = Create("Frame", {
        Name = "SidebarLine",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.fromScale(1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    -- Content Area (where tabs will go)
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -200, 1, -40),
        Position = UDim2.fromOffset(200, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Make Window Draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Notification Container
    if not CoreGui:FindFirstChild("ValoxUI_Notifications") then
        local NotifContainer = Create("Frame", {
            Name = "ValoxUI_Notifications",
            Size = UDim2.new(0, 300, 1, -20),
            Position = UDim2.new(1, -320, 0, 10),
            BackgroundTransparency = 1,
            Parent = Parent
        })
        
        Create("UIListLayout", {
            Parent = NotifContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    end

    -- Dialog Container
    local DialogContainer = Create("Frame", {
        Name = "DialogContainer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1, -- Invisible by default
        Visible = false,
        ZIndex = 100,
        Parent = MainFrame
    })

    -- Window Object
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentContainer = ContentContainer,
        Sidebar = Sidebar,
        DialogContainer = DialogContainer,
        Tabs = {},
        CurrentTab = nil
    }

    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.fromOffset(0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:Dialog(dialogOptions)
        dialogOptions = dialogOptions or {}
        local DlgTitle = dialogOptions.Title or "Dialog"
        local DlgContent = dialogOptions.Content or "Are you sure?"
        local DlgButtons = dialogOptions.Buttons or {}
        
        -- Dim background
        self.DialogContainer.Visible = true
        TweenService:Create(self.DialogContainer, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()

        local DialogBox = Create("Frame", {
            Name = "DialogBox",
            Size = UDim2.new(0, 300, 0, 150),
            Position = UDim2.new(0.5, 0, 0.45, 0), -- Slightly above center initially for animated drop
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.ElementBackground,
            ZIndex = 101,
            Parent = self.DialogContainer
        })
        Round(DialogBox, 8)
Stroke(DialogBox, Theme.Border, 1)

        -- Dropdown animation
        TweenService:Create(DialogBox, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

        local TitleLabel = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.fromOffset(20, 10),
            BackgroundTransparency = 1,
            Text = DlgTitle,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = FontBold,
            TextSize = 16,
            ZIndex = 102,
            Parent = DialogBox
        })

        local ContentLabel = Create("TextLabel", {
            Name = "Content",
            Size = UDim2.new(1, -40, 1, -100),
            Position = UDim2.fromOffset(20, 40),
            BackgroundTransparency = 1,
            Text = DlgContent,
            TextColor3 = Theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Font = FontRegular,
            TextSize = 14,
            ZIndex = 102,
            Parent = DialogBox
        })

        local ButtonContainer = Create("Frame", {
            Name = "ButtonContainer",
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 1, -50),
            BackgroundTransparency = 1,
            ZIndex = 102,
            Parent = DialogBox
        })
        
        local BtnLayout = Create("UIListLayout", {
            Parent = ButtonContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local function CloseDialog()
            TweenService:Create(self.DialogContainer, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            local t = TweenService:Create(DialogBox, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0.55, 0)})
            t:Play()
            t.Completed:Wait()
            DialogBox:Destroy()
            self.DialogContainer.Visible = false
        end

        for i, btn in pairs(DlgButtons) do
            local DialogBtn = Create("TextButton", {
                Name = btn.Title or "Button",
                Size = UDim2.new(0, 100, 1, 0),
                BackgroundColor3 = btn.Variant == "Primary" and Theme.Accent or Theme.Background,
                Text = btn.Title or "Button",
                TextColor3 = Theme.Text,
                Font = FontSemiBold,
                TextSize = 14,
                AutoButtonColor = false,
                ZIndex = 103,
                Parent = ButtonContainer
            })
            Round(DialogBtn, 6)
Stroke(DialogBtn, Theme.Border, 1)

            DialogBtn.MouseButton1Click:Connect(function()
                if btn.Callback then btn.Callback() end
                CloseDialog()
            end)
        end
    end

    function Window:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local TabTitle = tabOptions.Title or "Tab"
        local TabIcon = tabOptions.Icon or "rbxassetid://10888331510" -- Default generic icon
        
        -- Tab Button in Sidebar
        local TabBtn = Create("TextButton", {
            Name = TabTitle,
            Size = UDim2.new(1, -20, 0, 35),
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = TabContainer
        })
        Round(TabBtn, 6)

        local TabBtnText = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.fromOffset(35, 0),
            BackgroundTransparency = 1,
            Text = TabTitle,
            TextColor3 = Theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = FontSemiBold,
            TextSize = 13,
            Parent = TabBtn
        })

        local TabBtnIcon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0.5, -8),
            BackgroundTransparency = 1,
            Image = TabIcon,
            ImageColor3 = Theme.TextMuted,
            Parent = TabBtn
        })

        -- Content Frame for this Tab
        local TabContent = Create("ScrollingFrame", {
            Name = TabTitle .. "_Content",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentContainer
        })

        local ContentListLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        })

        -- Update CanvasSize automatically
        ContentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentListLayout.AbsoluteContentSize.Y + 10)
        end)
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Tab Object that holds elements
        local Tab = {
            Name = TabTitle,
            Button = TabBtn,
            Content = TabContent
        }

        table.insert(Window.Tabs, Tab)

        -- Selection Logic
        local function SelectTab()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Button.Title, TweenInfo.new(0.3), {TextColor3 = Theme.TextMuted}):Play()
                TweenService:Create(t.Button.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.TextMuted}):Play()
            end

            TabContent.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(TabBtnText, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play()
            TweenService:Create(TabBtnIcon, TweenInfo.new(0.3), {ImageColor3 = Theme.Text}):Play()
            Window.CurrentTab = TabTitle
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)

        -- Auto-select first tab
        if #Window.Tabs == 1 then
            SelectTab()
        end

        function Tab:Section(secOptions)
            secOptions = secOptions or {}
            local SecTitle = secOptions.Title or "Section"

            local SectionFrame = Create("Frame", {
                Name = SecTitle .. "_Section",
                Size = UDim2.new(1, -10, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabContent
            })

            local SectionLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = SecTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontBold,
                TextSize = 14,
                Parent = SectionFrame
            })

            return SectionFrame
        end

        function Tab:Label(labelOptions)
            labelOptions = labelOptions or {}
            local LabelText = labelOptions.Text or "Label"

            local LabelFrame = Create("Frame", {
                Name = "LabelFrame",
                Size = UDim2.new(1, -10, 0, 25),
                BackgroundTransparency = 1,
                Parent = TabContent
            })

            local Label = Create("TextLabel", {
                Name = "Text",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = LabelText,
                TextColor3 = Theme.TextMuted,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontRegular,
                TextSize = 13,
                Parent = LabelFrame
            })

            -- Adjust height based on text bounds
            Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
                LabelFrame.Size = UDim2.new(1, -10, 0, Label.TextBounds.Y + 10)
            end)

            return LabelFrame
        end

        function Tab:Button(btnOptions)
            btnOptions = btnOptions or {}
            local BtnTitle = btnOptions.Title or "Button"
            local BtnDesc = btnOptions.Desc or ""
            local BtnCallback = btnOptions.Callback or function() end

            local ButtonFrame = Create("TextButton", {
                Name = BtnTitle .. "_Button",
                Size = UDim2.new(1, -10, 0, BtnDesc == "" and 40 or 50),
                BackgroundColor3 = Theme.ElementBackground,
                Text = "",
                AutoButtonColor = false,
                Parent = TabContent
            })
            Round(ButtonFrame, 6)
Stroke(ButtonFrame, Theme.Border, 1)

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.fromOffset(10, BtnDesc == "" and 10 or 5),
                BackgroundTransparency = 1,
                Text = BtnTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = ButtonFrame
            })

            if BtnDesc ~= "" then
                local DescLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -20, 0, 15),
                    Position = UDim2.fromOffset(10, 25),
                    BackgroundTransparency = 1,
                    Text = BtnDesc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FontRegular,
                    TextSize = 12,
                    Parent = ButtonFrame
                })
            end

            -- Click Icon (Pointer)
            local ClickIcon = Create("ImageLabel", {
                Name = "ClickIcon",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -25, 0.5, -7),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10888331510", -- You can replace with a tap/click icon
                ImageColor3 = Theme.TextMuted,
                Parent = ButtonFrame
            })

            -- Animations & Interactions
            ButtonFrame.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 34, 48)}):Play()
            end)

            ButtonFrame.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end)

            ButtonFrame.MouseButton1Down:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -14, 0, (BtnDesc == "" and 40 or 50) - 2)}):Play()
            end)

            ButtonFrame.MouseButton1Up:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, BtnDesc == "" and 40 or 50)}):Play()
                BtnCallback()
            end)

            return ButtonFrame
        end

        function Tab:Toggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            local ToggleTitle = toggleOptions.Title or "Toggle"
            local ToggleDesc = toggleOptions.Desc or ""
            local Default = toggleOptions.Value or false
            local ToggleCallback = toggleOptions.Callback or function() end

            local State = Default

            local ToggleFrame = Create("TextButton", {
                Name = ToggleTitle .. "_Toggle",
                Size = UDim2.new(1, -10, 0, ToggleDesc == "" and 40 or 50),
                BackgroundColor3 = Theme.ElementBackground,
                Text = "",
                AutoButtonColor = false,
                Parent = TabContent
            })
            Round(ToggleFrame, 6)
Stroke(ToggleFrame, Theme.Border, 1)

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.fromOffset(10, ToggleDesc == "" and 10 or 5),
                BackgroundTransparency = 1,
                Text = ToggleTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = ToggleFrame
            })

            if ToggleDesc ~= "" then
                local DescLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -60, 0, 15),
                    Position = UDim2.fromOffset(10, 25),
                    BackgroundTransparency = 1,
                    Text = ToggleDesc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FontRegular,
                    TextSize = 12,
                    Parent = ToggleFrame
                })
            end

            -- Switch Visuals
            local SwitchBg = Create("Frame", {
                Name = "SwitchBg",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = State and ValoxUI.Theme.Accent or ValoxUI.Theme.Border,
                Parent = ToggleFrame
            })
            Round(SwitchBg, 10)

            local SwitchCircle = Create("Frame", {
                Name = "SwitchCircle",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, State and 22 or 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(240, 240, 240),
                Parent = SwitchBg
            })
            Round(SwitchCircle, 8)

            local function PlayAnimation()
                local bgGoal = State and Theme.Accent or Theme.Border
                local posGoal = State and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

                TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = bgGoal}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = posGoal}):Play()
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                State = not State
                PlayAnimation()
                ToggleCallback(State)
            end)

            return {
                Set = function(v)
                    State = v
                    PlayAnimation()
                    ToggleCallback(State)
                end
            }
        end

        function Tab:Slider(sliderOptions)
            sliderOptions = sliderOptions or {}
            local SliderTitle = sliderOptions.Title or "Slider"
            local SliderDesc = sliderOptions.Desc or ""
            local Min = sliderOptions.Value and sliderOptions.Value.Min or 0
            local Max = sliderOptions.Value and sliderOptions.Value.Max or 100
            local Default = sliderOptions.Value and sliderOptions.Value.Default or Min
            local SliderCallback = sliderOptions.Callback or function() end

            local Value = Default

            local SliderFrame = Create("Frame", {
                Name = SliderTitle .. "_Slider",
                Size = UDim2.new(1, -10, 0, SliderDesc == "" and 55 or 65),
                BackgroundColor3 = Theme.ElementBackground,
                Parent = TabContent
            })
            Round(SliderFrame, 6)
Stroke(SliderFrame, Theme.Border, 1)

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.fromOffset(10, 5),
                BackgroundTransparency = 1,
                Text = SliderTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = SliderFrame
            })

            local ValueLabel = Create("TextLabel", {
                Name = "ValueLabel",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(Value),
                TextColor3 = Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = SliderFrame
            })

            if SliderDesc ~= "" then
                local DescLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -60, 0, 15),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = SliderDesc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FontRegular,
                    TextSize = 12,
                    Parent = SliderFrame
                })
            end

            -- Slider Bar
            local SliderBg = Create("Frame", {
                Name = "SliderBg",
                Size = UDim2.new(1, -20, 0, 8),
                Position = UDim2.new(0, 10, 1, -15),
                BackgroundColor3 = Theme.Border,
                Parent = SliderFrame
            })
            Round(SliderBg, 4)

            local SliderFill = Create("Frame", {
                Name = "SliderFill",
                Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                Parent = SliderBg
            })
            Round(SliderFill, 4)
            
            local SliderKnob = Create("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SliderFill
            })
            Round(SliderKnob, 7)

            -- Dragging Logic
            local dragging = false

            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                Value = math.floor(Min + ((Max - Min) * pos))

                TweenService:Create(SliderFill, TweenInfo.new(0.05), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(Value)
                SliderCallback(Value)
            end

            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            SliderCallback(Value)

            return {
                Set = function(v)
                    v = math.clamp(v, Min, Max)
                    Value = v
                    local pos = (v - Min) / (Max - Min)
                    TweenService:Create(SliderFill, TweenInfo.new(0.2), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                    ValueLabel.Text = tostring(Value)
                    SliderCallback(Value)
                end
            }
        end

        function Tab:Input(inputOptions)
            inputOptions = inputOptions or {}
            local InputTitle = inputOptions.Title or "Input"
            local InputDesc = inputOptions.Desc or ""
            local Placeholder = inputOptions.Placeholder or "Enter text..."
            local Default = inputOptions.Value or ""
            local InputCallback = inputOptions.Callback or function() end

            local InputFrame = Create("Frame", {
                Name = InputTitle .. "_Input",
                Size = UDim2.new(1, -10, 0, InputDesc == "" and 40 or 50),
                BackgroundColor3 = Theme.ElementBackground,
                Parent = TabContent
            })
            Round(InputFrame, 6)
            local FrameStroke = Stroke(InputFrame, ValoxUI.Theme.Border, 1)

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -150, 0, 20),
                Position = UDim2.fromOffset(10, InputDesc == "" and 10 or 5),
                BackgroundTransparency = 1,
                Text = InputTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = InputFrame
            })

            if InputDesc ~= "" then
                local DescLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -150, 0, 15),
                    Position = UDim2.fromOffset(10, 25),
                    BackgroundTransparency = 1,
                    Text = InputDesc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FontRegular,
                    TextSize = 12,
                    Parent = InputFrame
                })
            end

            local TextBoxBg = Create("Frame", {
                Name = "TextBoxBg",
                Size = UDim2.new(0, 130, 0, 28),
                Position = UDim2.new(1, -140, 0.5, -14),
                BackgroundColor3 = Theme.Background,
                Parent = InputFrame
            })
            Round(TextBoxBg, 4)
            Stroke(TextBoxBg, ValoxUI.Theme.Border, 1)

            local TextBox = Create("TextBox", {
                Name = "InputBox",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.fromOffset(5, 0),
                BackgroundTransparency = 1,
                Text = Default,
                PlaceholderText = Placeholder,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = ValoxUI.Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontRegular,
                TextSize = 13,
                ClearTextOnFocus = false,
                Parent = TextBoxBg
            })

            TextBox.Focused:Connect(function()
                TweenService:Create(FrameStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
            end)

            TextBox.FocusLost:Connect(function()
                TweenService:Create(FrameStroke, TweenInfo.new(0.2), {Color = Theme.Border}):Play()
                InputCallback(TextBox.Text)
            end)

            return {
                Set = function(v)
                    TextBox.Text = tostring(v)
                    InputCallback(TextBox.Text)
                end
            }
        end

        function Tab:Dropdown(dropOptions)
            dropOptions = dropOptions or {}
            local DropTitle = dropOptions.Title or "Dropdown"
            local DropDesc = dropOptions.Desc or ""
            local Values = dropOptions.Values or {}
            local Default = dropOptions.Value or nil
            local AllowNone = dropOptions.AllowNone or false
            local DropCallback = dropOptions.Callback or function() end

            local Selected = Default
            local IsOpen = false

            local DropFrame = Create("Frame", {
                Name = DropTitle .. "_Dropdown",
                Size = UDim2.new(1, -10, 0, DropDesc == "" and 40 or 50),
                BackgroundColor3 = Theme.ElementBackground,
                ClipsDescendants = true,
                Parent = TabContent
            })
            Round(DropFrame, 6)
            local FrameStroke = Stroke(DropFrame, ValoxUI.Theme.Border, 1)

            local DropButton = Create("TextButton", {
                Name = "DropButton",
                Size = UDim2.new(1, 0, 0, DropDesc == "" and 40 or 50),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropFrame
            })

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -150, 0, 20),
                Position = UDim2.fromOffset(10, DropDesc == "" and 10 or 5),
                BackgroundTransparency = 1,
                Text = DropTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = DropButton
            })

            if DropDesc ~= "" then
                local DescLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -150, 0, 15),
                    Position = UDim2.fromOffset(10, 25),
                    BackgroundTransparency = 1,
                    Text = DropDesc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FontRegular,
                    TextSize = 12,
                    Parent = DropButton
                })
            end

            local SelectedLabel = Create("TextLabel", {
                Name = "SelectedLabel",
                Size = UDim2.new(0, 110, 0, 20),
                Position = UDim2.new(1, -145, 0.5, -10),
                BackgroundTransparency = 1,
                Text = Selected == nil and "None" or tostring(Selected),
                TextColor3 = Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = FontRegular,
                TextSize = 13,
                Parent = DropButton
            })

            local DropIcon = Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -25, 0.5, -7),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10888331510", -- Plus/Chevron icon
                ImageColor3 = Theme.TextMuted,
                Parent = DropButton
            })

            local Container = Create("ScrollingFrame", {
                Name = "Container",
                Size = UDim2.new(1, -20, 0, 0), -- Height expands when open
                Position = UDim2.fromOffset(10, DropDesc == "" and 40 or 50),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Border,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = DropFrame
            })

            local ListLayout = Create("UIListLayout", {
                Parent = Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })

            local OptionBtns = {}

            local function RefreshSize()
                if IsOpen then
                    local h = math.clamp(ListLayout.AbsoluteContentSize.Y, 0, 120)
                    TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, h)}):Play()
                    TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, (DropDesc == "" and 40 or 50) + h + 10)}):Play()
                else
                    TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                    TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, DropDesc == "" and 40 or 50)}):Play()
                end
                Container.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end

            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if IsOpen then RefreshSize() end
            end)

            DropButton.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                TweenService:Create(DropIcon, TweenInfo.new(0.2), {Rotation = IsOpen and 180 or 0}):Play()
                RefreshSize()
            end)

            local function SelectOption(val)
                if val == Selected and AllowNone then
                    Selected = nil
                else
                    Selected = val
                end

                SelectedLabel.Text = Selected == nil and "None" or tostring(Selected)
                DropCallback(Selected)

                for _, btn in pairs(OptionBtns) do
                    if btn.Name == "Option_" .. tostring(Selected) then
                        TweenService:Create(btn.Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                    else
                        TweenService:Create(btn.Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
                    end
                end
                
                IsOpen = false
                TweenService:Create(DropIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                RefreshSize()
            end

            local function BuildOptions(vals)
                for _, obj in pairs(Container:GetChildren()) do
                    if obj:IsA("TextButton") then obj:Destroy() end
                end
                table.clear(OptionBtns)

                for i, v in pairs(vals) do
                    local isObj = type(v) == "table"
                    local valName = isObj and v.Title or tostring(v)

                    local OptBtn = Create("TextButton", {
                        Name = "Option_" .. valName,
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundColor3 = Theme.Background,
                        BackgroundTransparency = 1,
                        Text = "  " .. valName,
                        TextColor3 = Theme.TextMuted,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = FontRegular,
                        TextSize = 13,
                        AutoButtonColor = false,
                        Parent = Container
                    })
                    Round(OptBtn, 4)

                    local Indicator = Create("Frame", {
                        Name = "Indicator",
                        Size = UDim2.new(0, 3, 1, -10),
                        Position = UDim2.new(0, -6, 0.5, -7), -- hidden by default to the left
                        BackgroundColor3 = Selected == (isObj and v or valName) and ValoxUI.Theme.Accent or ValoxUI.Theme.Background,
                        BorderSizePixel = 0,
                        Parent = OptBtn
                    })
                    Round(Indicator, 2)
                    OptBtn.Indicator = Indicator
                    
                    if Selected == (isObj and v or valName) then
                        Indicator.Position = UDim2.new(0, 0, 0.5, -7)
                    end

                    OptBtn.MouseEnter:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0, TextColor3 = Theme.Text}):Play()
                        if Selected ~= (isObj and v or valName) then
                            TweenService:Create(Indicator, TweenInfo.new(0.1), {Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = Theme.Border}):Play()
                        end
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundTransparency = 1, TextColor3 = Theme.TextMuted}):Play()
                        if Selected ~= (isObj and v or valName) then
                            TweenService:Create(Indicator, TweenInfo.new(0.1), {Position = UDim2.new(0, -6, 0.5, -7)}):Play()
                        end
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        SelectOption(isObj and v or valName)
                    end)

                    table.insert(OptionBtns, OptBtn)
                end
            end

            BuildOptions(Values)

            return {
                Refresh = function(newVals)
                    BuildOptions(newVals)
                end,
                Select = function(v)
                    SelectOption(v)
                end
            }
        end

        function Tab:Keybind(keyOptions)
            keyOptions = keyOptions or {}
            local KeyTitle = keyOptions.Title or "Keybind"
            local KeyDesc = keyOptions.Desc or ""
            local Default = keyOptions.Value or "None"
            local KeyCallback = keyOptions.Callback or function() end

            local CurrentKey = Default
            local IsBinding = false

            local KeyFrame = Create("Frame", {
                Name = KeyTitle .. "_Keybind",
                Size = UDim2.new(1, -10, 0, KeyDesc == "" and 40 or 50),
                BackgroundColor3 = Theme.ElementBackground,
                Parent = TabContent
            })
            Round(KeyFrame, 6)
Stroke(KeyFrame, Theme.Border, 1)

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -150, 0, 20),
                Position = UDim2.fromOffset(10, KeyDesc == "" and 10 or 5),
                BackgroundTransparency = 1,
                Text = KeyTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontSemiBold,
                TextSize = 14,
                Parent = KeyFrame
            })

            if KeyDesc ~= "" then
                local DescLabel = Create("TextLabel", {
                    Name = "Desc",
                    Size = UDim2.new(1, -150, 0, 15),
                    Position = UDim2.fromOffset(10, 25),
                    BackgroundTransparency = 1,
                    Text = KeyDesc,
                    TextColor3 = Theme.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = FontRegular,
                    TextSize = 12,
                    Parent = KeyFrame
                })
            end

            local BindButton = Create("TextButton", {
                Name = "BindButton",
                Size = UDim2.new(0, 80, 0, 26),
                Position = UDim2.new(1, -90, 0.5, -13),
                BackgroundColor3 = Theme.Background,
                Text = tostring(CurrentKey),
                TextColor3 = Theme.Text,
                Font = FontSemiBold,
                TextSize = 13,
                AutoButtonColor = false,
                Parent = KeyFrame
            })
            Round(BindButton, 4)
Stroke(BindButton, Theme.Border, 1)

            BindButton.MouseButton1Click:Connect(function()
                if not IsBinding then
                    IsBinding = true
                    BindButton.Text = "..."
                    TweenService:Create(BindStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
                end
            end)

            UserInputService.InputBegan:Connect(function(input)
                if IsBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                    local key = input.KeyCode.Name
                    
                    -- Filter out common keys that shouldn't be bound alone unless desired
                    if key ~= "Unknown" then
                        CurrentKey = key
                        BindButton.Text = CurrentKey
                        IsBinding = false
                        TweenService:Create(BindStroke, TweenInfo.new(0.2), {Color = Theme.Border}):Play()
                        KeyCallback(CurrentKey)
                    end
                elseif not IsBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode.Name == CurrentKey then
                        -- Optional: Fire callback when hotkey is pressed globally
                        -- KeyCallback(CurrentKey) 
                    end
                end
            end)

            return {
                Set = function(key)
                    CurrentKey = key
                    BindButton.Text = tostring(key)
                end
            }
        end

        function Tab:Paragraph(paraOptions)
            paraOptions = paraOptions or {}
            local ParaTitle = paraOptions.Title or "Paragraph"
            local ParaText = paraOptions.Text or paraOptions.Desc or ""
            local HasImage = paraOptions.Image ~= nil
            
            local ParaFrame = Create("Frame", {
                Name = ParaTitle .. "_Paragraph",
                Size = UDim2.new(1, -10, 0, 0), -- calculated below
                BackgroundColor3 = Theme.ElementBackground,
                Parent = TabContent
            })
            Round(ParaFrame, 6)
Stroke(ParaFrame, Theme.Border, 1)

            -- Optional Image
            local ImageObj
            local textOffsetX = 10

            if HasImage then
                textOffsetX = 50
                ImageObj = Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundTransparency = 1,
                    Image = paraOptions.Image,
                    ImageColor3 = paraOptions.ImageColor or ValoxUI.Theme.Accent,
                    Parent = ParaFrame
                })
            end

            local TitleLabel = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -(textOffsetX + 10), 0, 20),
                Position = UDim2.fromOffset(textOffsetX, 10),
                BackgroundTransparency = 1,
                Text = ParaTitle,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = FontBold,
                TextSize = 14,
                Parent = ParaFrame
            })

            local DescLabel = Create("TextLabel", {
                Name = "Desc",
                Size = UDim2.new(1, -(textOffsetX + 10), 0, 0),
                Position = UDim2.fromOffset(textOffsetX, 35),
                BackgroundTransparency = 1,
                Text = ParaText,
                TextColor3 = Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Font = FontRegular,
                TextSize = 13,
                Parent = ParaFrame
            })

            -- Calculate total height needed based on text wrapping
            DescLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                local textHeight = DescLabel.TextBounds.Y
                DescLabel.Size = UDim2.new(1, -(textOffsetX + 10), 0, textHeight)
                
                local totalHeight = math.max(35 + textHeight + 10, HasImage and 50 or 0)
                ParaFrame.Size = UDim2.new(1, -10, 0, totalHeight)
            end)
            
            -- Calculate total height needed based on text wrapping
            DescLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                local textHeight = DescLabel.TextBounds.Y
                DescLabel.Size = UDim2.new(1, -(textOffsetX + 10), 0, textHeight)
                
                local totalHeight = math.max(35 + textHeight + 10, HasImage and 50 or 0)
                ParaFrame.Size = UDim2.new(1, -10, 0, totalHeight)
            end)
            
            -- Trigger calculation initially
            DescLabel.Text = ParaText

            return ParaFrame
        end

        function Tab:Divider()
            local DividerFrame = Create("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, -10, 0, 1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            return DividerFrame
        end

        function Tab:Space(spaceOptions)
            spaceOptions = spaceOptions or {}
            local SpaceSize = spaceOptions.Size or 10

            local SpaceFrame = Create("Frame", {
                Name = "Space",
                Size = UDim2.new(1, -10, 0, SpaceSize),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            return SpaceFrame
        end

        return Tab
    end

    -- Return the Window object we can call :Tab() on
    return Window
end

function ValoxUI:Notify(notifOptions)
    notifOptions = notifOptions or {}
    local Title = notifOptions.Title or "Notification"
    local Content = notifOptions.Content or ""
    local Duration = notifOptions.Duration or 3
    local Theme = self.Theme

    -- Find Container
    local Parent = nil
    if game:GetService("RunService"):IsStudio() then
        Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        Parent = CoreGui
    end

    local Container = Parent:FindFirstChild("ValoxUI_Notifications")
    if not Container then return end -- Container not initialized yet by CreateWindow

    local NotifFrame = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, Content == "" and 40 or 60),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 1,
        Parent = Container
    })
    Round(NotifFrame, 6)
    local FrameStroke = Stroke(NotifFrame, Theme.Border, 1)
    FrameStroke.Transparency = 1

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, Content == "" and 10 or 5),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Theme.Text,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FontBold,
        TextSize = 14,
        Parent = NotifFrame
    })

    if Content ~= "" then
        local ContentLabel = Create("TextLabel", {
            Name = "Content",
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.fromOffset(10, 25),
            BackgroundTransparency = 1,
            Text = Content,
            TextColor3 = Theme.TextMuted,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Font = FontRegular,
            TextSize = 13,
            Parent = NotifFrame
        })
    end

    -- Animations
    TweenService:Create(NotifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(FrameStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    for _, child in pairs(NotifFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end
    end

    if Duration > 0 then
        task.delay(Duration, function()
            TweenService:Create(NotifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(FrameStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            for _, child in pairs(NotifFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                end
            end
            task.wait(0.3)
            NotifFrame:Destroy()
        end)
    end
end

return ValoxUI
