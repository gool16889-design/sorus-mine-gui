-- [[ СЕРВИСЫ ]]
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- [[ УДАЛЕНИЕ СТАРОЙ КОПИИ ]]
if CoreGui:FindFirstChild("MC_Library_Source") then CoreGui.MC_Library_Source:Destroy() end

-- [[ НАСТРОЙКИ РАЗМЫТИЯ ]]
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0
Blur.Enabled = false

-- [[ ОСНОВНАЯ БИБЛИОТЕКА ]]
local Library = {}

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "MC_Library_Source"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false

    local THEME = {
        Header = Color3.fromRGB(25, 25, 25),
        Main = Color3.fromRGB(32, 32, 32),
        Settings = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 255, 150),
        Text = Color3.fromRGB(255, 255, 255)
    }

    -- Открытие на INSERT
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            ScreenGui.Enabled = not ScreenGui.Enabled
            Blur.Enabled = ScreenGui.Enabled
            TS:Create(Blur, TweenInfo.new(0.3), {Size = ScreenGui.Enabled and 15 or 0}):Play()
        end
    end)

    function Library:CreateCategory(name, pos)
        local Frame = Instance.new("Frame", ScreenGui)
        Frame.Size = UDim2.new(0, 190, 0, 35)
        Frame.Position = pos
        Frame.BackgroundColor3 = THEME.Header
        Frame.BorderSizePixel = 0
        Frame.Active = true
        Frame.Draggable = true

        local Title = Instance.new("TextLabel", Frame)
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.Text = name:upper()
        Title.Font = Enum.Font.SourceSansBold
        Title.TextColor3 = THEME.Text
        Title.TextSize = 16
        Title.BackgroundTransparency = 1

        local Container = Instance.new("Frame", Frame)
        Container.Position = UDim2.new(0, 0, 1, 0)
        Container.BackgroundColor3 = THEME.Main
        Container.BorderSizePixel = 0
        local Layout = Instance.new("UIListLayout", Container)
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
        end)

        local Category = {}

        function Category:AddModule(modName, callback)
            local ModFrame = Instance.new("Frame", Container)
            ModFrame.Size = UDim2.new(1, 0, 0, 32)
            ModFrame.BackgroundTransparency = 1

            local Button = Instance.new("TextButton", ModFrame)
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundColor3 = THEME.Main
            Button.BorderSizePixel = 0
            Button.Text = "  " .. modName
            Button.Font = Enum.Font.SourceSans
            Button.TextColor3 = THEME.Text
            Button.TextSize = 15
            Button.TextXAlignment = Enum.TextXAlignment.Left

            local SettingsFrame = Instance.new("Frame", Container)
            SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
            SettingsFrame.BackgroundColor3 = THEME.Settings
            SettingsFrame.ClipsDescendants = true
            SettingsFrame.BorderSizePixel = 0
            Instance.new("UIListLayout", SettingsFrame)

            local enabled, open = false, false

            Button.MouseButton1Click:Connect(function()
                enabled = not enabled
                Button.TextColor3 = enabled and THEME.Accent or THEME.Text
                if callback then task.spawn(callback, enabled) end
            end)

            Button.MouseButton2Click:Connect(function()
                open = not open
                local target = open and SettingsFrame.UIListLayout.AbsoluteContentSize.Y or 0
                TS:Create(SettingsFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, target)}):Play()
            end)

            local Module = {}

            function Module:AddSlider(setName, min, max, default, sliderCallback)
                local SFrame = Instance.new("Frame", SettingsFrame)
                SFrame.Size = UDim2.new(1, 0, 0, 45)
                SFrame.BackgroundTransparency = 1

                local SLabel = Instance.new("TextLabel", SFrame)
                SLabel.Size = UDim2.new(1, 0, 0, 20)
                SLabel.Position = UDim2.new(0, 10, 0, 5)
                SLabel.Text = setName .. ": " .. default
                SLabel.Font = Enum.Font.SourceSans
                SLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SLabel.TextSize = 13
                SLabel.TextXAlignment = 0
                SLabel.BackgroundTransparency = 1

                local SliderBack = Instance.new("Frame", SFrame)
                SliderBack.Size = UDim2.new(0.8, 0, 0, 4)
                SliderBack.Position = UDim2.new(0.1, 0, 0.7, 0)
                SliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                SliderBack.BorderSizePixel = 0

                local SliderFill = Instance.new("Frame", SliderBack)
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = THEME.Accent
                SliderFill.BorderSizePixel = 0

                local dragging = false
                local function update()
                    local pos = math.clamp((UIS:GetMouseLocation().X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    SLabel.Text = setName .. ": " .. val
                    if sliderCallback then sliderCallback(val) end
                end

                SliderBack.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                RS.RenderStepped:Connect(function() if dragging then update() end end)
                
                return Module
            end

            return Module
        end
        return Category
    end
    return self
end

-- ==========================================================
-- [ ПРИМЕР: КАК ДОБАВЛЯТЬ ФУНКЦИИ И ОКОШКИ ]
-- ==========================================================

local Main = Library:Init()

-- 1. Создаем Окошко (Категорию)
local Movement = Main:CreateCategory("Movement", UDim2.new(0, 50, 0, 50))
local Combat = Main:CreateCategory("Combat", UDim2.new(0, 260, 0, 50))

-- 2. Добавляем функции в Movement
local WalkSpeedValue = 50
Movement:AddModule("Speed Hack", function(state)
    local Hum = game.Players.LocalPlayer.Character.Humanoid
    Hum.WalkSpeed = state and WalkSpeedValue or 16
end):AddSlider("Speed Amount", 16, 250, 50, function(v)
    WalkSpeedValue = v
end)

Movement:AddModule("Fly Mode", function(state)
    print("Fly is now:", state)
end)

-- 3. Добавляем функции в Combat
Combat:AddModule("Kill Aura", function(state)
    print("Aura status:", state)
end):AddSlider("Aura Range", 1, 15, 5, function(v)
    print("New Range:", v)
end)

Combat:AddModule("Auto Clicker", function(state)
    print("Clicking:", state)
end)

return Library
