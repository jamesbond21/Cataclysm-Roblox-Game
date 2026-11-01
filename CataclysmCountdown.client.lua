-- CATACLYSM LIVE COUNTDOWN
-- Install later as a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("CataclysmEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "CataclysmCountdown"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local timer = Instance.new("TextLabel")
timer.Size = UDim2.fromScale(0.4, 0.2)
timer.Position = UDim2.fromScale(0.3, 0.36)
timer.BackgroundTransparency = 1
timer.Text = ""
timer.TextColor3 = Color3.fromRGB(255, 65, 45)
timer.TextScaled = true
timer.Font = Enum.Font.GothamBlack
timer.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Color = Color3.new(0, 0, 0)
stroke.Parent = timer

local function showCountdown(number)
    timer.Text = tostring(number)
    timer.TextTransparency = 0
    timer.Size = UDim2.fromScale(0.4, 0.2)

    local tween = TweenService:Create(
        timer,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.fromScale(0.55, 0.28)
        }
    )

    tween:Play()
    task.wait(0.7)
end

event.OnClientEvent:Connect(function(action, data)
    if action == "Countdown" then
        showCountdown(tonumber(data) or 0)

        if tonumber(data) == 1 then
            timer.Text = "SURVIVE!"
            task.wait(1)
            timer.Text = ""
        end
    end
end)
