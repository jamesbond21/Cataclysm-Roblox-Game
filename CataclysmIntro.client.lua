-- CATACLYSM: CINEMATIC INTRO
-- Install later as a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("CataclysmIntro")
if old then old:Destroy() end

local blur = Instance.new("BlurEffect")
blur.Size = 18
blur.Parent = Lighting

local gui = Instance.new("ScreenGui")
gui.Name = "CataclysmIntro"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
background.Parent = gui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 38, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 7, 14))
})
gradient.Rotation = 45
gradient.Parent = background

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.2)
title.Position = UDim2.fromScale(0, 0.25)
title.BackgroundTransparency = 1
title.Text = "CATACLYSM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = background

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(255, 75, 45)
titleStroke.Thickness = 2
titleStroke.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromScale(1, 0.06)
subtitle.Position = UDim2.fromScale(0, 0.44)
subtitle.BackgroundTransparency = 1
subtitle.Text = "THE WORLD IS ABOUT TO END."
subtitle.TextColor3 = Color3.fromRGB(220, 220, 220)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.GothamMedium
subtitle.Parent = background

local play = Instance.new("TextButton")
play.Size = UDim2.fromScale(0.28, 0.085)
play.Position = UDim2.fromScale(0.36, 0.62)
play.BackgroundColor3 = Color3.fromRGB(190, 45, 35)
play.Text = "ENTER THE CHAOS"
play.TextColor3 = Color3.new(1, 1, 1)
play.TextScaled = true
play.Font = Enum.Font.GothamBold
play.Parent = background

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = play

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 150, 100)
stroke.Thickness = 2
stroke.Parent = play

-- Animate title
TweenService:Create(
    title,
    TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
):Play()

-- Camera intro
camera.CameraType = Enum.CameraType.Scriptable

local function cinematicCamera()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    local startPosition = root.Position + Vector3.new(35, 22, 35)
    local endPosition = root.Position + Vector3.new(20, 12, 20)

    camera.CFrame = CFrame.lookAt(startPosition, root.Position)

    TweenService:Create(
        camera,
        TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {CFrame = CFrame.lookAt(endPosition, root.Position)}
    ):Play()
end

task.spawn(cinematicCamera)

-- Subtle button animation
task.spawn(function()
    while gui.Parent do
        TweenService:Create(play, TweenInfo.new(0.8), {
            BackgroundColor3 = Color3.fromRGB(235, 65, 40)
        }):Play()
        task.wait(0.8)

        TweenService:Create(play, TweenInfo.new(0.8), {
            BackgroundColor3 = Color3.fromRGB(160, 35, 30)
        }):Play()
        task.wait(0.8)
    end
end)

play.MouseButton1Click:Connect(function()
    play.Active = false
    play.Text = "GOOD LUCK..."

    TweenService:Create(background, TweenInfo.new(1), {
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(blur, TweenInfo.new(1), {
        Size = 0
    }):Play()

    task.wait(1)

    camera.CameraType = Enum.CameraType.Custom

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        camera.CameraSubject = humanoid
    end

    blur:Destroy()
    gui:Destroy()
end)
