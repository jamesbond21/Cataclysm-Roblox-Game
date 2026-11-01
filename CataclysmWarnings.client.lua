-- CATACLYSM DISASTER WARNING SYSTEM
-- Install as a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("CataclysmEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "CataclysmWarnings"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local warning = Instance.new("Frame")
warning.Size = UDim2.fromScale(1, 0.19)
warning.Position = UDim2.fromScale(0, -0.22)
warning.BackgroundColor3 = Color3.fromRGB(150, 15, 15)
warning.BackgroundTransparency = 0.08
warning.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.48)
title.Position = UDim2.fromScale(0, 0.05)
title.BackgroundTransparency = 1
title.Text = "⚠ DISASTER WARNING ⚠"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = warning

local message = Instance.new("TextLabel")
message.Size = UDim2.fromScale(1, 0.35)
message.Position = UDim2.fromScale(0, 0.55)
message.BackgroundTransparency = 1
message.Text = "TAKE COVER!"
message.TextColor3 = Color3.fromRGB(255, 230, 190)
message.TextScaled = true
message.Font = Enum.Font.GothamBold
message.Parent = warning

local function showWarning(disaster)
    local name = string.lower(disaster)

    local messages = {
        tornado = {"TORNADO INCOMING!", Color3.fromRGB(120, 30, 180)},
        tsunami = {"MASSIVE WAVE APPROACHING!", Color3.fromRGB(0, 100, 220)},
        meteor = {"METEOR STRIKE DETECTED!", Color3.fromRGB(220, 75, 15)},
        earthquake = {"GROUND COLLAPSE IMMINENT!", Color3.fromRGB(150, 100, 50)},
        volcano = {"VOLCANIC ERUPTION!", Color3.fromRGB(220, 45, 10)},
        flood = {"FLOOD WARNING!", Color3.fromRGB(0, 150, 180)},
        lightning = {"SEVERE LIGHTNING STORM!", Color3.fromRGB(100, 100, 220)},
        hurricane = {"HURRICANE APPROACHING!", Color3.fromRGB(40, 70, 150)}
    }

    local selected = messages[name] or {
        "EXTREME DISASTER DETECTED!",
        Color3.fromRGB(190, 20, 20)
    }

    title.Text = "⚠ " .. string.upper(disaster) .. " ⚠"
    message.Text = selected[1]
    warning.BackgroundColor3 = selected[2]

    TweenService:Create(warning, TweenInfo.new(0.5), {
        Position = UDim2.fromScale(0, 0)
    }):Play()

    task.wait(4)

    TweenService:Create(warning, TweenInfo.new(0.5), {
        Position = UDim2.fromScale(0, -0.22)
    }):Play()
end

    task.wait(2)

    TweenService:Create(warning, TweenInfo.new(0.5), {
        Position = UDim2.fromScale(0, -0.22)
    }):Play()
end

event.OnClientEvent:Connect(function(action, data)
    if action == "DisasterWarning" then
        showWarning(tostring(data))
    end
end)
