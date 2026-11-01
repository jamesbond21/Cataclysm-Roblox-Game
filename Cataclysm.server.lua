-- CATACLYSM: COMPLETE SERVER
-- Place as a Script in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local DATA = DataStoreService:GetDataStore("Cataclysm_PlayerData_V2")

local CONFIG = {
    Intermission = 20,
    Countdown = 8,
    RoundLength = 150,
    StartingCoins = 100,
}

local random = Random.new()
local activeRound = false
local currentMap
local alive = {}
local roundId = 0

-- REMOTES
local event = ReplicatedStorage:FindFirstChild("CataclysmEvent")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "CataclysmEvent"
    event.Parent = ReplicatedStorage
end

local shop = ReplicatedStorage:FindFirstChild("CataclysmShop")
if not shop then
    shop = Instance.new("RemoteFunction")
    shop.Name = "CataclysmShop"
    shop.Parent = ReplicatedStorage
end

-- DISASTERS
local disasters = {
    "Meteor Shower",
    "Tornado",
    "Tsunami",
    "Earthquake",
    "Volcanic Eruption",
    "Lightning Storm",
    "Flash Flood",
    "Hurricane",
    "Acid Rain",
    "Sandstorm",
    "Blizzard",
    "Lava Flood",
    "Black Hole",
    "Firestorm",
    "Low Gravity",
    "Falling Buildings"
}

-- MAP GENERATION
local function makePart(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.Concrete
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function buildMap()
    if currentMap then
        currentMap:Destroy()
    end

    currentMap = Instance.new("Folder")
    currentMap.Name = "CataclysmMap"
    currentMap.Parent = workspace

    local themes = {
        {
            name = "Coastal City",
            ground = Color3.fromRGB(75, 105, 95),
            building = Color3.fromRGB(105, 115, 130)
        },
        {
            name = "Desert Outpost",
            ground = Color3.fromRGB(194, 155, 90),
            building = Color3.fromRGB(175, 135, 90)
        },
        {
            name = "Snowbound City",
            ground = Color3.fromRGB(205, 220, 235),
            building = Color3.fromRGB(110, 130, 150)
        }
    }

    local theme = themes[random:NextInteger(1, #themes)]

    makePart(
        currentMap,
        "Ground",
        Vector3.new(300, 5, 300),
        Vector3.new(0, -3, 0),
        theme.ground,
        Enum.Material.Ground
    )

    for x = -2, 2 do
        for z = -2, 2 do
            local height = random:NextInteger(20, 55)

            local building = makePart(
                currentMap,
                "Building",
                Vector3.new(25, height, 25),
                Vector3.new(x * 48, height / 2, z * 48),
                theme.building,
                Enum.Material.Concrete
            )

            building:SetAttribute("Destructible", true)

            local windows = Instance.new("Folder")
            windows.Name = "Windows"
            windows.Parent = currentMap

            for floor = 1, math.floor(height / 12) do
                for side = -1, 1 do
                    local window = makePart(
                        windows,
                        "Window",
                        Vector3.new(0.4, 5, 5),
                        Vector3.new(
                            building.Position.X + 12.7,
                            floor * 12,
                            building.Position.Z + side * 7
                        ),
                        Color3.fromRGB(90, 190, 220),
                        Enum.Material.Glass
                    )
                    window.Transparency = 0.3
                end
            end
        end
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "CataclysmSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(0, 1, 0)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Parent = currentMap

    event:FireAllClients("MapLoaded", theme.name)
end

-- PLAYER DATA
local function savePlayer(player)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end

    local data = {
        Coins = stats.Coins.Value,
        Wins = stats.Wins.Value,
        Survivals = stats.Survivals.Value,
        Level = stats.Level.Value
    }

    pcall(function()
        DATA:SetAsync("Player_" .. player.UserId, data)
    end)
end

local function setupPlayer(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    local saved
    pcall(function()
        saved = DATA:GetAsync("Player_" .. player.UserId)
    end)

    local function addStat(name, default)
        local value = Instance.new("IntValue")
        value.Name = name
        value.Value = saved and saved[name] or default
        value.Parent = stats
        return value
    end

    addStat("Coins", CONFIG.StartingCoins)
    addStat("Wins", 0)
    addStat("Survivals", 0)
    addStat("Level", 1)

    player:SetAttribute("HasSprint", false)
    player:SetAttribute("HasShield", false)
    player:SetAttribute("HasMedkit", false)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    savePlayer(player)
    alive[player] = nil
end)

for _, player in Players:GetPlayers() do
    if not player:FindFirstChild("leaderstats") then
        setupPlayer(player)
    end
end

-- SHOP
shop.OnServerInvoke = function(player, action, item)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then
        return false, "Player data unavailable"
    end

    local prices = {
        Sprint = 250,
        Shield = 400,
        Medkit = 300
    }

    if action ~= "Buy" or not prices[item] then
        return false, "Invalid purchase"
    end

    if player:GetAttribute("Has" .. item) then
        return false, "Already owned"
    end

    if stats.Coins.Value < prices[item] then
        return false, "Not enough coins"
    end

    stats.Coins.Value -= prices[item]
    player:SetAttribute("Has" .. item, true)

    if item == "Sprint" and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 24 end
    end

    return true, item .. " purchased!"
end

-- TELEPORT PLAYERS
local function teleportPlayers()
    for _, player in Players:GetPlayers() do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = CFrame.new(
                random:NextInteger(-100, 100),
                8,
                random:NextInteger(-100, 100)
            )

            alive[player] = true
        end
    end
end

local function damagePlayer(player, amount)
    if not alive[player] then return end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if player:GetAttribute("HasShield") then
            player:SetAttribute("HasShield", false)
            event:FireClient(player, "Message", "Your shield absorbed a hit!")
            return
        end

        humanoid:TakeDamage(amount)
    end
end

-- DISASTER EFFECTS
local function meteorShower(id)
    for i = 1, 35 do
        if id ~= roundId then return end

        local meteor = Instance.new("Part")
        meteor.Name = "Meteor"
        meteor.Shape = Enum.PartType.Ball
        meteor.Size = Vector3.new(8, 8, 8)
        meteor.Material = Enum.Material.Neon
        meteor.Color = Color3.fromRGB(255, 75, 15)
        meteor.Position = Vector3.new(
            random:NextInteger(-140, 140),
            150,
            random:NextInteger(-140, 140)
        )
        meteor.Anchored = false
        meteor.CanCollide = true
        meteor.Parent = workspace
        meteor.AssemblyLinearVelocity = Vector3.new(0, -100, 0)

        meteor.Touched:Connect(function(hit)
            if not meteor.Parent then return end

            local character = hit:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)

            if player then damagePlayer(player, 45) end

            local explosion = Instance.new("Explosion")
            explosion.Position = meteor.Position
            explosion.BlastRadius = 16
            explosion.BlastPressure = 0
            explosion.Parent = workspace

            meteor:Destroy()
        end)

        Debris:AddItem(meteor, 10)
        task.wait(0.7)
    end
end

local function tornado(id)
    local tornadoPart = Instance.new("Part")
    tornadoPart.Name = "Tornado"
    tornadoPart.Shape = Enum.PartType.Cylinder
    tornadoPart.Size = Vector3.new(100, 35, 35)
    tornadoPart.Material = Enum.Material.SmoothPlastic
    tornadoPart.Color = Color3.fromRGB(90, 90, 95)
    tornadoPart.Transparency = 0.25
    tornadoPart.Anchored = true
    tornadoPart.CanCollide = false
    tornadoPart.Parent = workspace

    for i = 1, 120 do
        if id ~= roundId then break end

        local angle = i * 0.15
        tornadoPart.Position = Vector3.new(
            math.cos(angle) * 65,
            48,
            math.sin(angle) * 65
        )

        for _, player in Players:GetPlayers() do
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - tornadoPart.Position).Magnitude < 35 then
                root.AssemblyLinearVelocity += Vector3.new(
                    random:NextInteger(-25, 25),
                    35,
                    random:NextInteger(-25, 25)
                )
                damagePlayer(player, 3)
            end
        end

        task.wait(0.25)
    end

    tornadoPart:Destroy()
end

local function tsunami(id)
    local wave = makePart(
        workspace,
        "TsunamiWave",
        Vector3.new(300, 75, 12),
        Vector3.new(-160, 38, 0),
        Color3.fromRGB(20, 110, 200),
        Enum.Material.Glass
    )

    wave.Transparency = 0.2
    wave.CanCollide = false

    for i = 1, 100 do
        if id ~= roundId then break end

        wave.Position += Vector3.new(3.2, 0, 0)

        for _, player in Players:GetPlayers() do
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - wave.Position).Magnitude < 30 then
                root.AssemblyLinearVelocity = Vector3.new(0, 60, 100)
                damagePlayer(player, 8)
            end
        end

        task.wait(0.2)
    end

    wave:Destroy()
end

local function earthquake(id)
    for i = 1, 40 do
        if id ~= roundId then return end

        for _, part in currentMap:GetChildren() do
            if part:IsA("BasePart") and part.Name == "Building" then
                part.Orientation = Vector3.new(
                    random:NextInteger(-3, 3),
                    0,
                    random:NextInteger(-3, 3)
                )
            end
        end

        for _, player in Players:GetPlayers() do
            damagePlayer(player, 2)
        end

        task.wait(0.5)
    end
end

local function lightningStorm(id)
    for i = 1, 35 do
        if id ~= roundId then return end

        local position = Vector3.new(
            random:NextInteger(-130, 130),
            0,
            random:NextInteger(-130, 130)
        )

        local bolt = makePart(
            workspace,
            "Lightning",
            Vector3.new(2, 150, 2),
            position + Vector3.new(0, 75, 0),
            Color3.fromRGB(200, 220, 255),
            Enum.Material.Neon
        )

        bolt.CanCollide = false
        Debris:AddItem(bolt, 0.15)

        for _, player in Players:GetPlayers() do
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - position).Magnitude < 15 then
                damagePlayer(player, 40)
            end
        end

        task.wait(1)
    end
end

local function genericDisaster(name, id)
    for i = 1, 60 do
        if id ~= roundId then return end

        local position = Vector3.new(
            random:NextInteger(-130, 130),
            100,
            random:NextInteger(-130, 130)
        )

        local hazard = Instance.new("Part")
        hazard.Name = name .. "Hazard"
        hazard.Shape = Enum.PartType.Ball
        hazard.Size = Vector3.new(10, 10, 10)
        hazard.Material = Enum.Material.Neon
        hazard.Color = Color3.fromRGB(255, 80, 20)
        hazard.Position = position
        hazard.Anchored = false
        hazard.Parent = workspace

        hazard.AssemblyLinearVelocity = Vector3.new(0, -90, 0)

        hazard.Touched:Connect(function(hit)
            local character = hit:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)
            if player then damagePlayer(player, 35) end
        end)

        Debris:AddItem(hazard, 12)
        task.wait(0.8)
    end
end

local function runDisaster(name, id)
    if name == "Meteor Shower" then
        meteorShower(id)
    elseif name == "Tornado" then
        tornado(id)
    elseif name == "Tsunami" then
        tsunami(id)
    elseif name == "Earthquake" then
        earthquake(id)
    elseif name == "Lightning Storm" then
        lightningStorm(id)
    else
        genericDisaster(name, id)
    end
end

-- ROUND SYSTEM
local function startRound()
    roundId += 1
    local thisRound = roundId

    activeRound = true
    buildMap()
    teleportPlayers()

    local disaster = disasters[random:NextInteger(1, #disasters)]

    event:FireAllClients("DisasterWarning", disaster)

    for i = CONFIG.Countdown, 1, -1 do
        if thisRound ~= roundId then return end
        event:FireAllClients("Countdown", i)
        task.wait(1)
    end

    event:FireAllClients("DisasterStarted", disaster)

    task.spawn(function()
        runDisaster(disaster, thisRound)
    end)

    for i = CONFIG.RoundLength, 1, -1 do
        if thisRound ~= roundId then return end

        for player in pairs(alive) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if not humanoid or humanoid.Health <= 0 then
                alive[player] = nil
            end
        end

        local remaining = 0
        for _ in pairs(alive) do remaining += 1 end

        event:FireAllClients("RoundTimer", i)
        event:FireAllClients("AliveCount", remaining)

        if remaining == 0 then break end
        task.wait(1)
    end

    roundId += 1
    activeRound = false

    local survivors = 0

    for player in pairs(alive) do
        survivors += 1

        local stats = player:FindFirstChild("leaderstats")
        if stats then
            stats.Coins.Value += 100
            stats.Wins.Value += 1
            stats.Survivals.Value += 1
            stats.Level.Value = math.floor(stats.Wins.Value / 5) + 1
        end
    end

    event:FireAllClients("RoundEnded", survivors)

    for _, player in Players:GetPlayers() do
        savePlayer(player)
    end

    alive = {}
    task.wait(8)
end

-- MAIN GAME LOOP
task.spawn(function()
    while true do
        for i = CONFIG.Intermission, 1, -1 do
            event:FireAllClients("Intermission", i)
            task.wait(1)
        end

        startRound()
    end
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        savePlayer(player)
    end
end)

print("CATACLYSM SERVER STARTED")
