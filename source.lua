local Library = {}

function Library:Init()
    local CoreGui = game:GetService("CoreGui")
    local UIS = game:GetService("UserInputService")
    local Lighting = game:GetService("Lighting")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    if CoreGui:FindFirstChild("MC_LIB") then CoreGui.MC_LIB:Destroy() end

    local Blur = Instance.new("BlurEffect", Lighting)
    Blur.Size = 0
    Blur.Enabled = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MC_LIB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false
    pcall(function() ScreenGui.Parent = CoreGui end)

    local THEME = {
        Header = Color3.fromRGB(25, 25, 25),
        Main = Color3.fromRGB(32, 32, 32),
        Settings = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 255, 150),
        Text = Color3.fromRGB(255, 255, 255)
    }

    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            ScreenGui.Enabled = not ScreenGui.Enabled
            Blur.Enabled = ScreenGui.Enabled
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = ScreenGui.Enabled and 15 or 0}):Play()
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

        Instance.new("TextLabel", Frame).Size = UDim2.new(1, 0, 1, 0)
        Frame.TextLabel.Text = name:upper()
        Frame.TextLabel.Font = Enum.Font.SourceSansBold
        Frame.TextLabel.TextColor3 = THEME.Text
        Frame.TextLabel.TextSize = 16
        Frame.TextLabel.BackgroundTransparency = 1

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
                if callback then callback(enabled) end
            end)

            Button.MouseButton2Click:Connect(function()
                open = not open
                TweenService:Create(SettingsFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, open and SettingsFrame.UIListLayout.AbsoluteContentSize.Y or 0)}):Play()
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
                SLabel.TextXAlignment = Enum.TextXAlignment.Left
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

                SliderBack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                RunService.RenderStepped:Connect(function() if dragging then update() end end)
            end

            return Module
        end
        return Category
    end
end

-- ПРИМЕР ИСПОЛЬЗОВАНИЯ:
Library:Init()

local Combat = Library:CreateCategory("Combat", UDim2.new(0, 50, 0, 50))
local Killaura = Combat:AddModule("KillAura", function(state)
    print("Aura is:", state)
end)
Killaura:AddSlider("Range", 1, 15, 5, function(val)
    print("New Range:", val)
end)

local Movement = Library:CreateCategory("Movement", UDim2.new(0, 260, 0, 50))
Movement:AddModule("Fly", function(s) print("Fly:", s) end)
