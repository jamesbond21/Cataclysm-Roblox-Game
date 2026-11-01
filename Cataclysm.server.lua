-- CATACLYSM: ULTIMATE SERVER SCRIPT
-- Place in ServerScriptService

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local DSS = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Store = DSS:GetDataStore("CataclysmPlayerData_V1")

local INTERMISSION = 15
local PREPARATION = 10
local ROUND_LENGTH = 60

local disasters = {
    "MEGA TSUNAMI",
    "METEOR APOCALYPSE",
    "TORNADO",
    "EARTHQUAKE",
    "VOLCANO",
    "GLOBAL FREEZE",
    "ACID RAIN",
    "LIGHTNING STORM",
    "BLACK HOLE",
    "GRAVITY FAILURE",
    "SUPER HAILSTORM",
    "FIRE RAIN",
    "SANDSTORM",
    "FLASH FLOOD",
    "PLANETARY COLLISION",
    "DOUBLE DISASTER"
}

local maps = {
    "COASTAL CITY",
    "DESERT OUTPOST",
    "SNOWBOUND CITY"
}

local event = Instance.new("RemoteEvent")
event.Name = "CataclysmEvent"
event.Parent = RS

local shop = Instance.new("RemoteFunction")
shop.Name = "CataclysmShop"
shop.Parent = RS

local owned = {}
local alive = {}
local currentMap

local prices = {
    Sprint = 150,
    Medkit = 250,
    Shield = 350
}

local function hud(title, subtitle, timer, danger)
    event:FireAllClients("HUD", {
        title = title,
        subtitle = subtitle,
        timer = timer,
        danger = danger
    })
end

local function createPart(parent, name, size, position, color, material)
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

local function buildMap(theme)
    if currentMap then currentMap:Destroy() end

    currentMap = Instance.new("Folder")
    currentMap.Name = "CataclysmMap"
    currentMap.Parent = workspace

    local groundColor = Color3.fromRGB(75, 125, 75)

    if theme == "DESERT OUTPOST" then
        groundColor = Color3.fromRGB(194, 155, 91)
    elseif theme == "SNOWBOUND CITY" then
        groundColor = Color3.fromRGB(220, 235, 245)
    end

    createPart(currentMap, "Ground",
        Vector3.new(250, 5, 250),
        Vector3.new(0, -3, 0),
        groundColor,
        Enum.Material.Ground
    )

    for i = 1, 18 do
        local x = math.random(-95, 95)
        local z = math.random(-95, 95)
        local height = math.random(15, 45)

        local building = Instance.new("Model")
        building.Name = "Building"
        building.Parent = currentMap

        local base = createPart(
            building,
            "BuildingBody",
            Vector3.new(15, height, 15),
            Vector3.new(x, height / 2, z),
            Color3.fromRGB(
                math.random(80, 180),
                math.random(80, 180),
                math.random(80, 180)
            )
        )

        base.Anchored = true

        local roof = createPart(
            building,
            "Roof",
            Vector3.new(17, 2, 17),
            Vector3.new(x, height + 1, z),
            Color3.fromRGB(45, 45, 55)
        )

        roof.Parent = building
    end

    for i = 1, 8 do
        local x = math.random(-100, 100)
        local z = math.random(-100, 100)

        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "SurvivorSpawn"
        spawn.Size = Vector3.new(7, 1, 7)
        spawn.Position = Vector3.new(x, 3, z)
        spawn.Anchored = true
        spawn.Neutral = true
        spawn.Transparency = 1
        spawn.CanCollide = false
        spawn.Parent = currentMap
    end
end

local function damagePlayers(position, radius, damage)
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if root and humanoid and humanoid.Health > 0 then
            if (root.Position - position).Magnitude < radius then
                humanoid:TakeDamage(damage)
            end
        end
    end
end

local function meteor()
    for i = 1, 25 do
        local x = math.random(-110, 110)
        local z = math.random(-110, 110)

        local rock = Instance.new("Part")
        rock.Shape = Enum.PartType.Ball
        rock.Size = Vector3.new(9, 9, 9)
        rock.Position = Vector3.new(x, 130, z)
        rock.Material = Enum.Material.Neon
        rock.Color = Color3.fromRGB(255, 85, 25)
        rock.Anchored = false
        rock.Parent = workspace

        rock.AssemblyLinearVelocity = Vector3.new(
            math.random(-15, 15),
            -110,
            math.random(-15, 15)
        )

        rock.Touched:Connect(function(hit)
            if rock:GetAttribute("Exploded") then return end
            rock:SetAttribute("Exploded", true)

            damagePlayers(rock.Position, 25, 55)

            local explosion = Instance.new("Explosion")
            explosion.Position = rock.Position
            explosion.BlastRadius = 12
            explosion.BlastPressure = 30000
            explosion.Parent = workspace

            Debris:AddItem(rock, 1)
        end)

        Debris:AddItem(rock, 10)
        task.wait(0.25)
    end
end

local function tornado()
    local twister = Instance.new("Part")
    twister.Name = "CataclysmTornado"
    twister.Shape = Enum.PartType.Cylinder
    twister.Size = Vector3.new(55, 25, 25)
    twister.Anchored = true
    twister.CanCollide = false
    twister.Material = Enum.Material.Neon
    twister.Color = Color3.fromRGB(90, 100, 110)
    twister.Parent = workspace

    local start = os.clock()

    while os.clock() - start < 45 do
        local angle = os.clock() * 2
        local x = math.cos(angle) * 65
        local z = math.sin(angle) * 65

        twister.CFrame =
            CFrame.new(x, 20, z) *
            CFrame.Angles(0, 0, math.rad(90))

        damagePlayers(twister.Position, 30, 8)

        for _, part in ipairs(workspace:GetPartBoundsInRadius(twister.Position, 25)) do
            if part:IsA("BasePart") and not part.Anchored then
                part.AssemblyLinearVelocity =
                    Vector3.new(math.random(-70,70), 80, math.random(-70,70))
            end
        end

        task.wait(0.5)
    end

    twister:Destroy()
end

local function tsunami()
    local wave = createPart(
        workspace,
        "MegaTsunami",
        Vector3.new(250, 65, 12),
        Vector3.new(-140, 30, 0),
        Color3.fromRGB(0, 130, 255),
        Enum.Material.Neon
    )

    wave.CanCollide = false
    local tween = TweenService:Create(
        wave,
        TweenInfo.new(35, Enum.EasingStyle.Linear),
        {Position = Vector3.new(140, 30, 0)}
    )

    tween:Play()

    local start = os.clock()
    while os.clock() - start < 35 do
        damagePlayers(wave.Position, 45, 12)
        task.wait(1)
    end

    wave:Destroy()
end

local function earthquake()
    for i = 1, 20 do
        for _, part in ipairs(currentMap:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "BuildingBody" then
                if math.random() < 0.15 then
                    part.Anchored = false
                    Debris:AddItem(part, 20)
                end
            end
        end

        damagePlayers(Vector3.new(0, 0, 0), 120, 4)
        task.wait(2)
    end
end

local function volcano()
    for i = 1, 18 do
        local lava = Instance.new("Part")
        lava.Shape = Enum.PartType.Ball
        lava.Size = Vector3.new(12, 12, 12)
        lava.Position = Vector3.new(0, 5, 0)
        lava.Color = Color3.fromRGB(255, 70, 0)
        lava.Material = Enum.Material.Neon
        lava.Anchored = false
        lava.Parent = workspace

        lava.AssemblyLinearVelocity = Vector3.new(
            math.random(-70, 70),
            math.random(65, 110),
            math.random(-70, 70)
        )

        lava.Touched:Connect(function(hit)
            local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
            if hum then hum:TakeDamage(35) end
        end)

        Debris:AddItem(lava, 12)
        task.wait(1)
    end
end

local function fallingHazards(color, material, damage)
    for i = 1, 45 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(5, 5, 5)
        p.Position = Vector3.new(
            math.random(-115, 115),
            100,
            math.random(-115, 115)
        )
        p.Color = color
        p.Material = material
        p.Anchored = false
        p.Parent = workspace

        p.Touched:Connect(function(hit)
            local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
            if hum then hum:TakeDamage(damage) end
        end)

        Debris:AddItem(p, 12)
        task.wait(0.3)
    end
end

local function runDisaster(name)
    if name == "MEGA TSUNAMI" then
        tsunami()
    elseif name == "METEOR APOCALYPSE" then
        meteor()
    elseif name == "TORNADO" then
        tornado()
    elseif name == "EARTHQUAKE" then
        earthquake()
    elseif name == "VOLCANO" then
        volcano()
    elseif name == "GLOBAL FREEZE" then
        fallingHazards(Color3.fromRGB(150,220,255), Enum.Material.Ice, 8)
    elseif name == "ACID RAIN" then
        fallingHazards(Color3.fromRGB(100,255,50), Enum.Material.Neon, 12)
    elseif name == "LIGHTNING STORM" then
        for i = 1, 30 do
            local pos = Vector3.new(math.random(-100,100), 2, math.random(-100,100))
            local bolt = createPart(workspace, "Lightning", Vector3.new(2,120,2), pos + Vector3.new(0,60,0), Color3.new(1,1,0), Enum.Material.Neon)
            damagePlayers(pos, 18, 45)
            Debris:AddItem(bolt, 0.15)
            task.wait(0.7)
        end
    elseif name == "BLACK HOLE" then
        local hole = Instance.new("Part")
        hole.Shape = Enum.PartType.Ball
        hole.Size = Vector3.new(18,18,18)
        hole.Position = Vector3.new(0,35,0)
        hole.Anchored = true
        hole.CanCollide = false
        hole.Material = Enum.Material.Neon
        hole.Color = Color3.new(0,0,0)
        hole.Parent = workspace

        for i = 1, 45 do
            for _, p in ipairs(workspace:GetPartBoundsInRadius(hole.Position, 90)) do
                if p:IsA("BasePart") and not p.Anchored and p ~= hole then
                    p.AssemblyLinearVelocity = (hole.Position-p.Position).Unit*100
                end
            end
            damagePlayers(hole.Position, 20, 10)
            task.wait(1)
        end
        hole:Destroy()
    elseif name == "GRAVITY FAILURE" then
        workspace.Gravity = 45
        task.wait(45)
        workspace.Gravity = 196.2
    elseif name == "SUPER HAILSTORM" then
        fallingHazards(Color3.fromRGB(220,240,255), Enum.Material.Ice, 18)
    elseif name == "FIRE RAIN" then
        fallingHazards(Color3.fromRGB(255,70,0), Enum.Material.Neon, 20)
    elseif name == "SANDSTORM" then
        fallingHazards(Color3.fromRGB(190,150,90), Enum.Material.Sand, 5)
    elseif name == "FLASH FLOOD" then
        tsunami()
    elseif name == "PLANETARY COLLISION" then
        meteor()
        damagePlayers(Vector3.new(0,0,0), 120, 15)
    elseif name == "DOUBLE DISASTER" then
        meteor()
        tornado()
    end
end

local function loadPlayer(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    for name, value in pairs({
        Coins = 0,
        Wins = 0,
        Survivals = 0,
        Level = 1
    }) do
        local v = Instance.new("IntValue")
        v.Name = name
        v.Value = value
        v.Parent = stats
    end

    owned[player.UserId] = {
        Sprint = false,
        Medkit = false,
        Shield = false
    }

    local success, data = pcall(function()
        return Store:GetAsync(player.UserId)
    end)

    if success and type(data) == "table" then
        for name, value in pairs(data.stats or {}) do
            if stats:FindFirstChild(name) then
                stats[name].Value = value
            end
        end

        for name, value in pairs(data.owned or {}) do
            if owned[player.UserId][name] ~= nil then
                owned[player.UserId][name] = value
            end
        end
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(1)
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum and owned[player.UserId].Sprint then
            hum.WalkSpeed = 24
        end
    end)
end

local function savePlayer(player)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end

    local data = {
        stats = {},
        owned = owned[player.UserId] or {}
    }

    for _, v in ipairs(stats:GetChildren()) do
        if v:IsA("IntValue") then
            data.stats[v.Name] = v.Value
        end
    end

    pcall(function()
        Store:SetAsync(player.UserId, data)
    end)
end

Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(player)
    savePlayer(player)
    owned[player.UserId] = nil
    alive[player] = nil
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayer(player)
    end
end)

shop.OnServerInvoke = function(player, action, item)
    local stats = player:FindFirstChild("leaderstats")
    local inventory = owned[player.UserId]

    if not stats or not inventory then
        return false, "Player data loading."
    end

    if action == "Get" then
        return {
            coins = stats.Coins.Value,
            owned = inventory,
            items = {
                Sprint = {price=prices.Sprint},
                Medkit = {price=prices.Medkit},
                Shield = {price=prices.Shield}
            }
        }
    end

    if action == "Buy" then
        if not prices[item] then
            return false, "Unknown item."
        end

        if inventory[item] then
            return false, "Already owned!"
        end

        if stats.Coins.Value < prices[item] then
            return false, "Not enough coins!"
        end

        stats.Coins.Value -= prices[item]
        inventory[item] = true

        if item == "Sprint" and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 24 end
        end

        return true, "Purchased " .. item .. "!"
    end

    return false, "Invalid shop request."
end

local function startRound()
    alive = {}

    local theme = maps[math.random(1, #maps)]
    local disaster = disasters[math.random(1, #disasters)]

    buildMap(theme)

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            player.Character:PivotTo(CFrame.new(
                math.random(-90,90), 8, math.random(-90,90)
            ))
            alive[player] = true
        end
    end

    for t = INTERMISSION, 1, -1 do
        hud("CATACLYSM", "Next round begins soon...", t, false)
        task.wait(1)
    end

    for t = PREPARATION, 1, -1 do
        hud("DISASTER WARNING", theme .. " | Prepare yourself!", t, false)
        task.wait(1)
    end

    hud("⚠ " .. disaster .. " ⚠", "SURVIVE!", 0, true)

    local disasterThread = task.spawn(function()
        runDisaster(disaster)
    end)

    for t = ROUND_LENGTH, 1, -1 do
        for _, player in ipairs(Players:GetPlayers()) do
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                alive[player] = nil
            end
        end

        hud(disaster, "Find shelter and survive!", t, true)
        task.wait(1)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if alive[player] then
            local stats = player:FindFirstChild("leaderstats")
            if stats then
                stats.Coins.Value += 100
                stats.Wins.Value += 1
                stats.Survivals.Value += 1
                stats.Level.Value = math.floor(stats.Survivals.Value / 5) + 1
            end
        end
    end

    local survivors = {}
    for player in pairs(alive) do
        table.insert(survivors, player.Name)
    end

    event:FireAllClients("RESULTS", survivors)

    task.wait(8)

    if currentMap then
        currentMap:Destroy()
        currentMap = nil
    end
end

while true do
    local success, err = pcall(startRound)
    if not success then
        warn("Cataclysm round error:", err)
        workspace.Gravity = 196.2
        task.wait(5)
    end
end
