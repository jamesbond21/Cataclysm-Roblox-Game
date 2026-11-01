-- CATACLYSM: COMPLETE CLIENT
-- Place as a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("CataclysmEvent")
local shop = ReplicatedStorage:WaitForChild("CataclysmShop")

local gui = Instance.new("ScreenGui")
gui.Name = "CataclysmInterface"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function create(class, properties, parent)
    local object = Instance.new(class)

    for key, value in pairs(properties) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function label(text, size, position, parent, font)
    return create("TextLabel", {
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = font or Enum.Font.GothamBold
    }, parent)
end

local function button(text, size, position, parent)
    local b = create("TextButton", {
        Size = size,
        Position = position,
        BackgroundColor3 = Color3.fromRGB(170, 40, 30),
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true
    }, parent)

    create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, b)

    return b
end

-- AUDIO
local siren = create("Sound", {
    Name = "EmergencySiren",
    SoundId = "rbxassetid://9120386436",
    Volume = 0.5,
    Looped = true
}, SoundService)

-- BACKGROUND
local background = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(8, 12, 22)
}, gui)

local gradient = create("UIGradient", {
    Color = ColorSequence.new(
        Color3.fromRGB(35, 45, 65),
        Color3.fromRGB(5, 5, 12)
    ),
    Rotation = 45
}, background)

-- INTRO
local intro = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(8, 12, 22)
}, background)

local title = label(
    "CATACLYSM",
    UDim2.fromScale(0.9, 0.2),
    UDim2.fromScale(0.05, 0.2),
    intro,
    Enum.Font.GothamBlack
)

title.TextColor3 = Color3.fromRGB(255, 90, 55)

local subtitle = label(
    "THE WORLD IS ABOUT TO END.",
    UDim2.fromScale(0.9, 0.07),
    UDim2.fromScale(0.05, 0.4),
    intro
)

local play = button(
    "ENTER THE CHAOS",
    UDim2.fromScale(0.34, 0.09),
    UDim2.fromScale(0.33, 0.58),
    intro
)

local shopButton = button(
    "SHOP",
    UDim2.fromScale(0.2, 0.07),
    UDim2.fromScale(0.4, 0.7),
    intro
)

local howButton = button(
    "HOW TO PLAY",
    UDim2.fromScale(0.2, 0.06),
    UDim2.fromScale(0.4, 0.79),
    intro
)

-- MAIN HUD
local hud = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false
}, background)

local status = label(
    "WAITING FOR ROUND",
    UDim2.fromScale(0.7, 0.07),
    UDim2.fromScale(0.15, 0.04),
    hud,
    Enum.Font.GothamBlack
)

local timer = label(
    "",
    UDim2.fromScale(0.25, 0.09),
    UDim2.fromScale(0.375, 0.13),
    hud,
    Enum.Font.GothamBlack
)

local aliveLabel = label(
    "SURVIVORS: 0",
    UDim2.fromScale(0.25, 0.05),
    UDim2.fromScale(0.02, 0.03),
    hud
)

local message = label(
    "",
    UDim2.fromScale(0.8, 0.08),
    UDim2.fromScale(0.1, 0.78),
    hud,
    Enum.Font.GothamBlack
)

local warning = create("Frame", {
    Size = UDim2.fromScale(1, 0.17),
    Position = UDim2.fromScale(0, -0.2),
    BackgroundColor3 = Color3.fromRGB(180, 20, 20)
}, hud)

local warningTitle = label(
    "DISASTER WARNING",
    UDim2.fromScale(1, 0.55),
    UDim2.fromScale(0, 0.05),
    warning,
    Enum.Font.GothamBlack
)

local warningText = label(
    "FIND SHELTER!",
    UDim2.fromScale(1, 0.3),
    UDim2.fromScale(0, 0.62),
    warning
)

local countdown = label(
    "",
    UDim2.fromScale(0.5, 0.25),
    UDim2.fromScale(0.25, 0.36),
    hud,
    Enum.Font.GothamBlack
)

countdown.TextColor3 = Color3.fromRGB(255, 65, 35)

-- SHOP MENU
local shopFrame = create("Frame", {
    Size = UDim2.fromScale(0.8, 0.65),
    Position = UDim2.fromScale(0.1, 0.18),
    BackgroundColor3 = Color3.fromRGB(20, 25, 38),
    Visible = false
}, background)

create("UICorner", {
    CornerRadius = UDim.new(0, 15)
}, shopFrame)

label(
    "SURVIVAL SHOP",
    UDim2.fromScale(1, 0.15),
    UDim2.fromScale(0, 0.02),
    shopFrame,
    Enum.Font.GothamBlack
)

local shopMessage = label(
    "",
    UDim2.fromScale(1, 0.1),
    UDim2.fromScale(0, 0.83),
    shopFrame
)

local closeShop = button(
    "CLOSE",
    UDim2.fromScale(0.25, 0.1),
    UDim2.fromScale(0.375, 0.7),
    shopFrame
)

local items = {
    {"Sprint", "250 COINS"},
    {"Shield", "400 COINS"},
    {"Medkit", "300 COINS"}
}

for i, item in ipairs(items) do
    local b = button(
        item[1] .. " - " .. item[2],
        UDim2.fromScale(0.75, 0.13),
        UDim2.fromScale(0.125, 0.2 + (i - 1) * 0.16),
        shopFrame
    )

    b.MouseButton1Click:Connect(function()
        local success, purchased, result = pcall(function()
            return shop:InvokeServer("Buy", item[1])
        end)

        if success then
            shopMessage.Text = result or (purchased and "Purchased!" or "Purchase failed!")
        else
            shopMessage.Text = "SHOP ERROR"
        end
    end)
end

-- INTRO BUTTONS
play.MouseButton1Click:Connect(function()
    TweenService:Create(intro, TweenInfo.new(0.8), {
        BackgroundTransparency = 1
    }):Play()

    task.wait(0.8)
    intro.Visible = false
    hud.Visible = true
    background.BackgroundTransparency = 1
end)

shopButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = true
end)

closeShop.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

howButton.MouseButton1Click:Connect(function()
    message.Text = "SURVIVE DISASTERS. EARN COINS. BECOME A LEGEND."
    task.wait(5)
    message.Text = ""
end)

-- DISASTER WARNINGS
local colors = {
    ["Tornado"] = Color3.fromRGB(110, 35, 160),
    ["Tsunami"] = Color3.fromRGB(0, 100, 220),
    ["Meteor Shower"] = Color3.fromRGB(220, 65, 15),
    ["Earthquake"] = Color3.fromRGB(140, 95, 45),
    ["Volcanic Eruption"] = Color3.fromRGB(230, 45, 10),
    ["Lightning Storm"] = Color3.fromRGB(90, 90, 220),
    ["Blizzard"] = Color3.fromRGB(100, 180, 220),
    ["Hurricane"] = Color3.fromRGB(35, 70, 150)
}

local function showWarning(disaster)
    warningTitle.Text = "⚠ " .. string.upper(disaster) .. " ⚠"
    warningText.Text = "FIND SHELTER! SURVIVE!"

    warning.BackgroundColor3 =
        colors[disaster] or Color3.fromRGB(180, 20, 20)

    TweenService:Create(warning, TweenInfo.new(0.5), {
        Position = UDim2.fromScale(0, 0)
    }):Play()

    siren:Play()

    task.wait(4)

    TweenService:Create(warning, TweenInfo.new(0.5), {
        Position = UDim2.fromScale(0, -0.2)
    }):Play()
end

-- SERVER MESSAGES
event.OnClientEvent:Connect(function(action, data)

    if action == "MapLoaded" then
        status.Text = "LOCATION: " .. tostring(data)

    elseif action == "Intermission" then
        status.Text = "NEXT ROUND IN"
        timer.Text = tostring(data)

    elseif action == "DisasterWarning" then
        task.spawn(showWarning, tostring(data))

    elseif action == "Countdown" then
        countdown.Text = tostring(data)

        if tonumber(data) == 1 then
            task.wait(0.8)
            countdown.Text = "SURVIVE!"
        end

    elseif action == "DisasterStarted" then
        status.Text = "DISASTER: " .. tostring(data)
        countdown.Text = ""

    elseif action == "RoundTimer" then
        timer.Text = tostring(data) .. "s"

    elseif action == "AliveCount" then
        aliveLabel.Text = "SURVIVORS: " .. tostring(data)

    elseif action == "RoundEnded" then
        siren:Stop()
        countdown.Text = ""
        status.Text = "ROUND COMPLETE!"
        message.Text = "SURVIVORS: " .. tostring(data)

    elseif action == "Message" then
        message.Text = tostring(data)
        task.delay(3, function()
            message.Text = ""
        end)
    end
end)

print("CATACLYSM CLIENT STARTED")
