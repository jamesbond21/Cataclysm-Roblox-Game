-- CATACLYSM ULTIMATE CLIENT HUD
-- Install in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local event = RS:WaitForChild("CataclysmEvent")
local shop = RS:WaitForChild("CataclysmShop")

local gui = Instance.new("ScreenGui")
gui.Name = "CataclysmHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function create(class, props, parent)
    local obj = Instance.new(class)

    for key, value in pairs(props) do
        obj[key] = value
    end

    obj.Parent = parent
    return obj
end

local function style(obj)
    create("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, obj)

    create("UIStroke", {
        Color = Color3.fromRGB(0, 190, 255),
        Thickness = 2
    }, obj)
end

-- MAIN HUD

local top = create("Frame", {
    Size = UDim2.new(0.8, 0, 0, 105),
    Position = UDim2.new(0.1, 0, 0.025, 0),
    BackgroundColor3 = Color3.fromRGB(8, 15, 30),
    BackgroundTransparency = 0.08
}, gui)

style(top)

local title = create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 48),
    Position = UDim2.fromOffset(10, 5),
    BackgroundTransparency = 1,
    Text = "CATACLYSM",
    Font = Enum.Font.GothamBlack,
    TextColor3 = Color3.fromRGB(0, 220, 255),
    TextScaled = true
}, top)

local subtitle = create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.fromOffset(10, 55),
    BackgroundTransparency = 1,
    Text = "SURVIVE THE IMPOSSIBLE",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.new(1, 1, 1),
    TextScaled = true
}, top)

local timer = create("TextLabel", {
    Size = UDim2.fromOffset(80, 25),
    Position = UDim2.new(1, -90, 1, -28),
    BackgroundTransparency = 1,
    Text = "",
    Font = Enum.Font.GothamBlack,
    TextColor3 = Color3.fromRGB(255, 210, 80),
    TextScaled = true
}, top)

-- SHOP BUTTON

local shopButton = create("TextButton", {
    Size = UDim2.fromOffset(145, 48),
    Position = UDim2.new(1, -160, 1, -65),
    BackgroundColor3 = Color3.fromRGB(0, 125, 200),
    Text = "SURVIVAL SHOP",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextScaled = true
}, gui)

style(shopButton)

-- SHOP WINDOW

local shopFrame = create("Frame", {
    Size = UDim2.fromOffset(390, 350),
    Position = UDim2.new(0.5, -195, 0.5, -175),
    BackgroundColor3 = Color3.fromRGB(8, 15, 30),
    Visible = false
}, gui)

style(shopFrame)

create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 45),
    Position = UDim2.fromOffset(10, 5),
    BackgroundTransparency = 1,
    Text = "SURVIVAL GEAR",
    Font = Enum.Font.GothamBlack,
    TextColor3 = Color3.fromRGB(0, 220, 255),
    TextScaled = true
}, shopFrame)

local close = create("TextButton", {
    Size = UDim2.fromOffset(35, 35),
    Position = UDim2.new(1, -43, 0, 8),
    BackgroundColor3 = Color3.fromRGB(160, 40, 50),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextScaled = true
}, shopFrame)

local message = create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 1, -38),
    BackgroundTransparency = 1,
    Text = "Earn coins by surviving!",
    TextColor3 = Color3.new(1, 1, 1),
    TextScaled = true
}, shopFrame)

local items = {
    {"Sprint", "Move faster", 150},
    {"Medkit", "Emergency healing", 250},
    {"Shield", "Protective equipment", 350}
}

local buttons = {}

for i, item in ipairs(items) do

    local card = create("Frame", {
        Size = UDim2.new(1, -30, 0, 70),
        Position = UDim2.fromOffset(15, 60 + (i - 1) * 80),
        BackgroundColor3 = Color3.fromRGB(20, 35, 55)
    }, shopFrame)

    style(card)

    create("TextLabel", {
        Size = UDim2.new(0.55, 0, 0, 30),
        Position = UDim2.fromOffset(10, 5),
        BackgroundTransparency = 1,
        Text = item[1],
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = true
    }, card)

    create("TextLabel", {
        Size = UDim2.new(0.55, 0, 0, 25),
        Position = UDim2.fromOffset(10, 35),
        BackgroundTransparency = 1,
        Text = item[2],
        TextColor3 = Color3.fromRGB(180, 195, 215),
        TextScaled = true
    }, card)

    local button = create("TextButton", {
        Size = UDim2.fromOffset(115, 42),
        Position = UDim2.new(1, -125, 0.5, -21),
        BackgroundColor3 = Color3.fromRGB(0, 135, 200),
        Text = tostring(item[3]) .. " COINS",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextScaled = true
    }, card)

    buttons[item[1]] = button

    button.MouseButton1Click:Connect(function()

        local success, result = pcall(function()
            return shop:InvokeServer("Buy", item[1])
        end)

        if not success then
            message.Text = "Shop connection error!"
            return
        end

        local purchased, response = result, nil

        -- Server returns two values.
        if type(result) == "boolean" then
            purchased = result
        end

        if purchased then
            button.Text = "OWNED"
            message.Text = "Purchase successful!"
            button.BackgroundColor3 = Color3.fromRGB(40, 140, 75)
        else
            message.Text = tostring(response or "Purchase unsuccessful.")
        end
    end)
end

local function refreshShop()

    local success, data = pcall(function()
        return shop:InvokeServer("Get")
    end)

    if not success or not data then
        message.Text = "Could not load shop."
        return
    end

    message.Text = "YOUR COINS: " .. data.coins

    for name, button in pairs(buttons) do
        if data.owned[name] then
            button.Text = "OWNED"
            button.BackgroundColor3 = Color3.fromRGB(40, 140, 75)
        else
            button.Text = tostring(data.items[name].price) .. " COINS"
        end
    end
end

shopButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = not shopFrame.Visible

    if shopFrame.Visible then
        refreshShop()
    end
end)

close.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

-- RESULTS SCREEN

local results = create("Frame", {
    Size = UDim2.fromOffset(400, 270),
    Position = UDim2.new(0.5, -200, 0.5, -135),
    BackgroundColor3 = Color3.fromRGB(8, 15, 30),
    Visible = false
}, gui)

style(results)

create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 50),
    Position = UDim2.fromOffset(10, 10),
    BackgroundTransparency = 1,
    Text = "ROUND RESULTS",
    TextColor3 = Color3.fromRGB(0, 220, 255),
    Font = Enum.Font.GothamBlack,
    TextScaled = true
}, results)

local resultText = create("TextLabel", {
    Size = UDim2.new(1, -30, 1, -80),
    Position = UDim2.fromOffset(15, 65),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    TextWrapped = true
}, results)

-- SERVER EVENTS

event.OnClientEvent:Connect(function(kind, data)

    if kind == "HUD" then

        title.Text = data.title or "CATACLYSM"
        subtitle.Text = data.subtitle or ""

        timer.Text = data.timer and
            (tostring(data.timer) .. "s") or ""

        if data.danger then
            title.TextColor3 = Color3.fromRGB(255, 70, 60)
        else
            title.TextColor3 = Color3.fromRGB(0, 220, 255)
        end

        results.Visible = false

    elseif kind == "RESULTS" then

        results.Visible = true

        if #data > 0 then
            resultText.Text =
                "SURVIVORS:\n\n" .. table.concat(data, "\n")
        else
            resultText.Text = "NOBODY SURVIVED!"
        end

        task.delay(8, function()
            results.Visible = false
        end)
    end
end)

print("CATACLYSM HUD LOADED!")
