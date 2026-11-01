-- CATACLYSM: DESTRUCTION ENGINE
-- ServerScriptService > Script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Store = DataStoreService:GetDataStore("Cataclysm_V3")

local SETTINGS = {
    Intermission = 20,
    Countdown = 8,
    RoundLength = 150,
    MapSize = 300,
    MaxDebris = 180,
}

local rng = Random.new()
local currentMap
local roundNumber = 0
local alive = {}
local destroyedParts = 0

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

local DISASTERS = {
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

--------------------------------------------------
-- PLAYER DATA
--------------------------------------------------

local function createStat(parent, name, value)
    local stat = Instance.new("IntValue")
    stat.Name = name
    stat.Value = value
    stat.Parent = parent
    return stat
end

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
        Store:SetAsync("P_" .. player.UserId, data)
    end)
end

local function setupPlayer(player)
    local saved

    pcall(function()
        saved = Store:GetAsync("P_" .. player.UserId)
    end)

    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    createStat(stats, "Coins", saved and saved.Coins or 100)
    createStat(stats, "Wins", saved and saved.Wins or 0)
    createStat(stats, "Survivals", saved and saved.Survivals or 0)
    createStat(stats, "Level", saved and saved.Level or 1)

    player:SetAttribute("SprintOwned", false)
    player:SetAttribute("ShieldOwned", false)
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

--------------------------------------------------
-- WORLD BUILDING
--------------------------------------------------

local function part(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.Material = material or Enum.Material.Concrete
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function buildMap()
    if currentMap then
        currentMap:Destroy()
    end

    currentMap = Instance.new("Folder")
    currentMap.Name = "CataclysmWorld"
    currentMap.Parent = workspace

    local themes = {
        {
            name = "METROPOLIS",
            ground = Color3.fromRGB(65, 75, 70),
            buildings = Color3.fromRGB(100, 110, 125)
        },
        {
            name = "DESERT CITY",
            ground = Color3.fromRGB(180, 145, 90),
            buildings = Color3.fromRGB(160, 120, 85)
        },
        {
            name = "FROST CITY",
            ground = Color3.fromRGB(190, 215, 230),
            buildings = Color3.fromRGB(100, 125, 150)
        }
    }

    local theme = themes[rng:NextInteger(1, #themes)]

    part(
        currentMap,
        "Ground",
        Vector3.new(SETTINGS.MapSize, 8, SETTINGS.MapSize),
        Vector3.new(0, -4, 0),
        theme.ground,
        Enum.Material.Ground
    )

    -- Roads
    part(
        currentMap,
        "MainRoad",
        Vector3.new(SETTINGS.MapSize, 0.3, 28),
        Vector3.new(0, 0.1, 0),
        Color3.fromRGB(35, 35, 38),
        Enum.Material.Asphalt
    )

    part(
        currentMap,
        "CrossRoad",
        Vector3.new(28, 0.3, SETTINGS.MapSize),
        Vector3.new(0, 0.15, 0),
        Color3.fromRGB(35, 35, 38),
        Enum.Material.Asphalt
    )

    -- Buildings
    for x = -2, 2 do
        for z = -2, 2 do
            if x ~= 0 or z ~= 0 then
                local height = rng:NextInteger(25, 65)

                local building = part(
                    currentMap,
                    "DestructibleBuilding",
                    Vector3.new(27, height, 27),
                    Vector3.new(x * 48, height / 2, z * 48),
                    theme.buildings,
                    Enum.Material.Concrete
                )

                building:SetAttribute("Health", 100)
                building:SetAttribute("MaxHealth", 100)
                building:SetAttribute("Destructible", true)

                -- Windows
                for floor = 1, math.floor(height / 12) do
                    for side = -1, 1 do
                        local window = part(
                            currentMap,
                            "BuildingWindow",
                            Vector3.new(0.3, 5, 5),
                            Vector3.new(
                                building.Position.X + 13.7,
                                floor * 12,
                                building.Position.Z + side * 7
                            ),
                            Color3.fromRGB(100, 190, 220),
                            Enum.Material.Glass
                        )

                        window.Transparency = 0.25
                        window.CanCollide = false
                        window:SetAttribute("Destructible", true)
                    end
                end
            end
        end
    end

    -- Shelter
    local shelter = part(
        currentMap,
        "EmergencyShelter",
        Vector3.new(30, 12, 30),
        Vector3.new(0, 6, 90),
        Color3.fromRGB(65, 90, 75),
        Enum.Material.Metal
    )

    shelter:SetAttribute("Shelter", true)

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "CataclysmSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(0, 1, 0)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Parent = currentMap

    event:FireAllClients("MapLoaded", theme.name)
end

--------------------------------------------------
-- DESTRUCTION ENGINE
--------------------------------------------------

local function createDebris(position, color, amount)
    for i = 1, math.min(amount, 12) do
        if destroyedParts >= SETTINGS.MaxDebris then
            break
        end

        destroyedParts += 1

        local chunk = Instance.new("Part")
        chunk.Name = "DisasterDebris"
        chunk.Size = Vector3.new(
            rng:NextNumber(1, 4),
            rng:NextNumber(1, 4),
            rng:NextNumber(1, 4)
        )

        chunk.Position = position + Vector3.new(
            rng:NextNumber(-4, 4),
            rng:NextNumber(0, 5),
            rng:NextNumber(-4, 4)
        )

        chunk.Color = color
        chunk.Material = Enum.Material.Concrete
        chunk.Anchored = false
        chunk.Parent = workspace

        chunk.AssemblyLinearVelocity = Vector3.new(
            rng:NextNumber(-50, 50),
            rng:NextNumber(20, 75),
            rng:NextNumber(-50, 50)
        )

        Debris:AddItem(chunk, 12)

        task.delay(12, function()
            destroyedParts = math.max(0, destroyedParts - 1)
        end)
    end
end

local function damageBuilding(building, damage)
    if not building or not building.Parent then return end
    if not building:GetAttribute("Destructible") then return end

    local health = building:GetAttribute("Health") or 100
    health -= damage

    building:SetAttribute("Health", health)

    -- Visual damage
    local ratio = math.clamp(health / 100, 0, 1)

    building.Color = Color3.new(
        0.35 + ratio * 0.35,
        0.2 + ratio * 0.4,
        0.18 + ratio * 0.5
    )

    if health <= 0 then
        local position = building.Position
        local color = building.Color

        createDebris(position, color, 12)

        building:Destroy()

        event:FireAllClients("BuildingDestroyed", position)
    end
end

local function explosionAt(position, radius, damage)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = radius
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace

    -- Damage nearby buildings
    for _, object in currentMap:GetChildren() do
        if object:IsA("BasePart")
            and object:GetAttribute("Destructible")
            and (object.Position - position).Magnitude < radius then

            damageBuilding(object, damage)
        end
    end

    -- Damage players
    for _, player in Players:GetPlayers() do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if root and (root.Position - position).Magnitude < radius then
            if not player:GetAttribute("ShieldOwned") then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:TakeDamage(35) end
            end
        end
    end
end

--------------------------------------------------
-- PLAYER DAMAGE
--------------------------------------------------

local function hurtPlayer(player, amount)
    if not alive[player] then return end

    if player:GetAttribute("ShieldOwned") then
        player:SetAttribute("ShieldOwned", false)
        event:FireClient(player, "Message", "SHIELD ACTIVATED!")
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid:TakeDamage(amount)
    end
end

--------------------------------------------------
-- METEOR SHOWER
--------------------------------------------------

local function meteorShower(id)
    for i = 1, 35 do
        if id ~= roundNumber then return end

        local meteor = Instance.new("Part")
        meteor.Name = "Meteor"
        meteor.Shape = Enum.PartType.Ball
        meteor.Size = Vector3.new(8, 8, 8)
        meteor.Material = Enum.Material.Neon
        meteor.Color = Color3.fromRGB(255, 70, 10)
        meteor.Position = Vector3.new(
            rng:NextInteger(-130, 130),
            140,
            rng:NextInteger(-130, 130)
        )
        meteor.Anchored = false
        meteor.Parent = workspace

        meteor.AssemblyLinearVelocity = Vector3.new(0, -100, 0)

        local hit = false

        meteor.Touched:Connect(function(object)
            if hit then return end
            hit = true

            local position = meteor.Position

            explosionAt(position, 30, 65)
            createDebris(position, Color3.fromRGB(100, 85, 75), 8)

            meteor:Destroy()
        end)

        Debris:AddItem(meteor, 10)
        task.wait(0.8)
    end
end

--------------------------------------------------
-- TORNADO
--------------------------------------------------

local function tornado(id)
    local funnel = Instance.new("Part")
    funnel.Name = "Tornado"
    funnel.Shape = Enum.PartType.Cylinder
    funnel.Size = Vector3.new(90, 35, 35)
    funnel.Anchored = true
    funnel.CanCollide = false
    funnel.Transparency = 0.25
    funnel.Color = Color3.fromRGB(65, 65, 70)
    funnel.Parent = workspace

    for i = 1, 100 do
        if id ~= roundNumber then break end

        local angle = i * 0.15

        funnel.Position = Vector3.new(
            math.cos(angle) * 65,
            45,
            math.sin(angle) * 65
        )

        for _, object in currentMap:GetChildren() do
            if object:IsA("BasePart")
                and object:GetAttribute("Destructible")
                and (object.Position - funnel.Position).Magnitude < 35 then

                if rng:NextNumber() < 0.08 then
                    damageBuilding(object, 15)
                end
            end
        end

        for _, player in Players:GetPlayers() do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root and (root.Position - funnel.Position).Magnitude < 40 then
                root.AssemblyLinearVelocity += Vector3.new(
                    rng:NextInteger(-25, 25),
                    35,
                    rng:NextInteger(-25, 25)
                )

                hurtPlayer(player, 3)
            end
        end

        task.wait(0.25)
    end

    funnel:Destroy()
end

--------------------------------------------------
-- TSUNAMI
--------------------------------------------------

local function tsunami(id)
    local wave = part(
        workspace,
        "Tsunami",
        Vector3.new(300, 65, 18),
        Vector3.new(-160, 32, 0),
        Color3.fromRGB(15, 115, 220),
        Enum.Material.Glass
    )

    wave.Transparency = 0.25
    wave.CanCollide = false

    for i = 1, 100 do
        if id ~= roundNumber then break end

        wave.Position += Vector3.new(3.2, 0, 0)

        for _, player in Players:GetPlayers() do
            local root = player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")

            if root and (root.Position - wave.Position).Magnitude < 35 then
                root.AssemblyLinearVelocity = Vector3.new(0, 55, 75)
                hurtPlayer(player, 7)
            end
        end

        for _, object in currentMap:GetChildren() do
            if object:IsA("BasePart")
                and object:GetAttribute("Destructible")
                and (object.Position - wave.Position).Magnitude < 30 then

                damageBuilding(object, 5)
            end
        end

        task.wait(0.2)
    end

    wave:Destroy()
end

--------------------------------------------------
-- EARTHQUAKE
--------------------------------------------------

local function earthquake(id)
    for i = 1, 35 do
        if id ~= roundNumber then return end

        for _, object in currentMap:GetChildren() do
            if object:IsA("BasePart")
                and object:GetAttribute("Destructible") then

                if rng:NextNumber() < 0.1 then
                    damageBuilding(object, 12)
                end
            end
        end

        for _, player in Players:GetPlayers() do
            hurtPlayer(player, 2)
        end

        task.wait(0.6)
    end
end

--------------------------------------------------
-- VOLCANO AND LAVA
--------------------------------------------------

local function volcano(id)
    for i = 1, 35 do
        if id ~= roundNumber then return end

        local lava = Instance.new("Part")
        lava.Name = "LavaBomb"
        lava.Shape = Enum.PartType.Ball
        lava.Size = Vector3.new(9, 9, 9)
        lava.Material = Enum.Material.Neon
        lava.Color = Color3.fromRGB(255, 75, 0)

        lava.Position = Vector3.new(
            rng:NextInteger(-100, 100),
            110,
            rng:NextInteger(-100, 100)
        )

        lava.Anchored = false
        lava.Parent = workspace
        lava.AssemblyLinearVelocity = Vector3.new(0, -75, 0)

        local touched = false

        lava.Touched:Connect(function()
            if touched then return end
            touched = true

            explosionAt(lava.Position, 22, 35)
            lava:Destroy()
        end)

        Debris:AddItem(lava, 10)
        task.wait(0.9)
    end
end

--------------------------------------------------
-- LIGHTNING
--------------------------------------------------

local function lightning(id)
    for i = 1, 30 do
        if id ~= roundNumber then return end

        local position = Vector3.new(
            rng:NextInteger(-130, 130),
            0,
            rng:NextInteger(-130, 130)
        )

        local bolt = part(
            workspace,
            "LightningStrike",
            Vector3.new(2, 150, 2),
            position + Vector3.new(0, 75, 0),
            Color3.fromRGB(220, 230, 255),
            Enum.Material.Neon
        )

        bolt.CanCollide = false

        explosionAt(position, 14, 25)

        Debris:AddItem(bolt, 0.2)
        task.wait(1.2)
    end
end

--------------------------------------------------
-- OTHER DISASTERS
--------------------------------------------------

local function otherDisaster(name, id)
    for i = 1, 45 do
        if id ~= roundNumber then return end

        local position = Vector3.new(
            rng:NextInteger(-120, 120),
            90,
            rng:NextInteger(-120, 120)
        )

        local hazard = Instance.new("Part")
        hazard.Name = name .. "Hazard"
        hazard.Shape = Enum.PartType.Ball
        hazard.Size = Vector3.new(7, 7, 7)
        hazard.Material = Enum.Material.Neon
        hazard.Color = Color3.fromRGB(180, 210, 255)
        hazard.Position = position
        hazard.Anchored = false
        hazard.Parent = workspace

        hazard.AssemblyLinearVelocity = Vector3.new(0, -80, 0)

        hazard.Touched:Connect(function(hit)
            local character = hit:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)

            if player then
                hurtPlayer(player, 20)
            end
        end)

        Debris:AddItem(hazard, 12)
        task.wait(1)
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
    elseif name == "Volcanic Eruption" or name == "Lava Flood" then
        volcano(id)
    elseif name == "Lightning Storm" then
        lightning(id)
    else
        otherDisaster(name, id)
    end
end

--------------------------------------------------
-- SHOP
--------------------------------------------------

shop.OnServerInvoke = function(player, action, item)
    if action ~= "Buy" then
        return false, "Invalid action"
    end

    local prices = {
        Sprint = 250,
        Shield = 400
    }

    if not prices[item] then
        return false, "Unknown item"
    end

    local stats = player:FindFirstChild("leaderstats")
    if not stats then return false, "Data unavailable" end

    local attribute = item .. "Owned"

    if player:GetAttribute(attribute) then
        return false, "Already owned"
    end

    if stats.Coins.Value < prices[item] then
        return false, "Not enough coins"
    end

    stats.Coins.Value -= prices[item]
    player:SetAttribute(attribute, true)

    if item == "Sprint" and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 24 end
    end

    return true, item .. " purchased!"
end

--------------------------------------------------
-- ROUND SYSTEM
--------------------------------------------------

local function teleportPlayers()
    alive = {}

    for _, player in Players:GetPlayers() do
        local character = player.Character

        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if root and humanoid and humanoid.Health > 0 then
                root.CFrame = CFrame.new(
                    rng:NextInteger(-110, 110),
                    10,
                    rng:NextInteger(-110, 110)
                )

                alive[player] = true
            end
        end
    end
end

local function startRound()
    roundNumber += 1
    local id = roundNumber

    destroyedParts = 0

    buildMap()
    teleportPlayers()

    local disaster = DISASTERS[rng:NextInteger(1, #DISASTERS)]

    event:FireAllClients("DisasterWarning", disaster)

    for i = SETTINGS.Countdown, 1, -1 do
        if id ~= roundNumber then return end

        event:FireAllClients("Countdown", i)
        task.wait(1)
    end

    event:FireAllClients("DisasterStarted", disaster)

    task.spawn(runDisaster, disaster, id)

    for i = SETTINGS.RoundLength, 1, -1 do
        if id ~= roundNumber then return end

        local survivors = 0

        for player in pairs(alive) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if not humanoid or humanoid.Health <= 0 then
                alive[player] = nil
            else
                survivors += 1
            end
        end

        event:FireAllClients("RoundTimer", i)
        event:FireAllClients("AliveCount", survivors)

        if survivors == 0 then break end

        task.wait(1)
    end

    roundNumber += 1

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

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

task.spawn(function()
    while true do
        for i = SETTINGS.Intermission, 1, -1 do
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

print("CATACLYSM V3 DESTRUCTION ENGINE ONLINE")
