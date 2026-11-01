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
    title.Text = "⚠ " .. string.upper(disaster) .. " ⚠"
    message.Text = "DISASTER INCOMING! FIND SHELTER!"

    warning.BackgroundColor3 = Color3.fromRGB(170, 15, 15)

    TweenService:Create(warning, TweenInfo.new(0.5), {
        Position = UDim2.fromScale(0, 0)
    }):Play()

    for i = 1, 5 do
        warning.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        task.wait(0.3)
        warning.BackgroundColor3 = Color3.fromRGB(100, 5, 5)
        task.wait(0.3)
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
