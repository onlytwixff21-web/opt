print("[GOAT OPTIMIZER] Starting v4.4...")

local ENTRY_START = os.clock()
local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"
local CHUNK_SIZE = 150
local FIRST_CHUNKS = 4
local CHUNK_INTERVAL = 0.3
local MAX_CHUNKS = 500
local MAX_REASONABLE_POS = 5000
local MAX_REASONABLE_SIZE = 3000

local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player
repeat
    task.wait(0.1)
    player = Players.LocalPlayer
until player

task.spawn(function()
    local char
    repeat
        task.wait(0.1)
        char = player.Character
    until char

    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(track)
                pcall(function() track:Stop(0) end)
            end)
        end
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = true end
    end

    Workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            pcall(function()
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Texture = ""
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                       or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.Plastic
                    obj.CastShadow = false
                    obj.Reflectance = 0
                end
            end)
        end)
    end)
end)

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.__GOAT_V44_RUNNING then return end
_G.__GOAT_V44_RUNNING = true

print("[GOAT v4.4] Initializing")

local character
repeat
    task.wait(0.1)
    character = player.Character
until character
character:WaitForChild("Humanoid", 10)

local playerGui = player:WaitForChild("PlayerGui", 15)

local function waitGround(maxT)
    maxT = maxT or 20
    local t0 = os.clock()
    while os.clock() - t0 < maxT do
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.FloorMaterial ~= Enum.Material.Air then return true end
        task.wait(0.1)
    end
    return false
end

waitGround(20)

local ENTRY_TIME = os.clock() - ENTRY_START
print(string.format("[GOAT v4.4] Entry time: %.2fs", ENTRY_TIME))

local function getSpawnPos()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or Vector3.new(0, 0, 0)
end

local function isReasonablePart(p)
    if not p then return false end
    local pos = p.Position
    if math.abs(pos.X) > MAX_REASONABLE_POS then return false end
    if math.abs(pos.Y) > MAX_REASONABLE_POS then return false end
    if math.abs(pos.Z) > MAX_REASONABLE_POS then return false end
    local size = p.Size
    if size.X > MAX_REASONABLE_SIZE or size.Y > MAX_REASONABLE_SIZE or size.Z > MAX_REASONABLE_SIZE then
        return false
    end
    return true
end

local function getMapBounds(spawnPos)
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    local count = 0
    local rejected = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if isReasonablePart(obj) then
                local p = obj.Position
                if p.X < minX then minX = p.X end
                if p.X > maxX then maxX = p.X end
                if p.Y < minY then minY = p.Y end
                if p.Y > maxY then maxY = p.Y end
                if p.Z < minZ then minZ = p.Z end
                if p.Z > maxZ then maxZ = p.Z end
                count = count + 1
            else
                rejected = rejected + 1
            end
        end
    end

    print(string.format("[GOAT v4.4] Parts: %d valid, %d rejected", count, rejected))

    if count < 10 then return nil end
    if minX == math.huge then return nil end

    return {
        minX = minX, maxX = maxX,
        minY = minY, maxY = maxY,
        minZ = minZ, maxZ = maxZ,
        count = count,
    }
end

local function buildChunks(bounds, spawnPos)
    local chunks = {}
    local xCount = math.ceil((bounds.maxX - bounds.minX) / CHUNK_SIZE)
    local yCount = math.ceil((bounds.maxY - bounds.minY) / CHUNK_SIZE)
    local zCount = math.ceil((bounds.maxZ - bounds.minZ) / CHUNK_SIZE)
    local total = xCount * yCount * zCount

    print(string.format("[GOAT v4.4] Map grid: %dx%dx%d = %d chunks",
        xCount, yCount, zCount, total))

    if total > MAX_CHUNKS then
        return nil, total
    end

    for ix = 0, xCount - 1 do
        for iy = 0, yCount - 1 do
            for iz = 0, zCount - 1 do
                local center = Vector3.new(
                    bounds.minX + (ix + 0.5) * CHUNK_SIZE,
                    bounds.minY + (iy + 0.5) * CHUNK_SIZE,
                    bounds.minZ + (iz + 0.5) * CHUNK_SIZE
                )
                local dist = (center - spawnPos).Magnitude
                table.insert(chunks, {
                    center = center,
                    dist = dist,
                })
            end
        end
    end

    table.sort(chunks, function(a, b) return a.dist < b.dist end)
    return chunks, total
end

local function getPartsInChunk(chunk)
    local parts = Workspace:GetPartBoundsInBox(
        CFrame.new(chunk.center),
        Vector3.new(CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE)
    )
    local filtered = {}
    for _, p in ipairs(parts) do
        if isReasonablePart(p) then
            table.insert(filtered, p)
        end
    end
    return filtered
end

local function optimizePart(p)
    pcall(function()
        p.Material        = Enum.Material.Plastic
        p.CastShadow      = false
        p.Reflectance     = 0
        p.MaterialVariant = ""
    end)
end

local function processChunk(chunk)
    local parts = getPartsInChunk(chunk)
    if #parts == 0 then return end
    local i = 1
    local conn
    conn = RunService.Heartbeat:Connect(function()
        for _ = 1, 5 do
            if i > #parts then conn:Disconnect(); return end
            pcall(optimizePart, parts[i])
            i = i + 1
        end
    end)
end

local function fallbackNearby()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 200)
    local filtered = {}
    for _, p in ipairs(parts) do
        if isReasonablePart(p) then
            table.insert(filtered, p)
        end
    end
    print("[GOAT v4.4] Fallback: optimizing " .. #filtered .. " nearby parts")
    local i = 1
    local conn
    conn = RunService.Heartbeat:Connect(function()
        for _ = 1, 3 do
            if i > #filtered then conn:Disconnect(); return end
            pcall(optimizePart, filtered[i])
            i = i + 1
        end
    end)
end

task.spawn(function()
    local spawnPos = getSpawnPos()
    print(string.format("[GOAT v4.4] Spawn: %.0f, %.0f, %.0f", spawnPos.X, spawnPos.Y, spawnPos.Z))

    local bounds = getMapBounds(spawnPos)
    if not bounds then
        print("[GOAT v4.4] Could not read map bounds, using fallback")
        fallbackNearby()
        return
    end

    print(string.format("[GOAT v4.4] Map bounds: X[%.0f..%.0f] Y[%.0f..%.0f] Z[%.0f..%.0f]",
        bounds.minX, bounds.maxX, bounds.minY, bounds.maxY, bounds.minZ, bounds.maxZ))

    local chunks, total = buildChunks(bounds, spawnPos)

    if not chunks then
        print(string.format("[GOAT v4.4] Too many chunks (%d > %d), using fallback",
            total, MAX_CHUNKS))
        fallbackNearby()
        return
    end

    print(string.format("[GOAT v4.4] Using chunk system (%d chunks)", total))

    for i = 1, math.min(FIRST_CHUNKS, #chunks) do
        print(string.format("[GOAT v4.4] Loading chunk %d/%d (dist: %.0f)",
            i, total, chunks[i].dist))
        processChunk(chunks[i])
    end

    task.spawn(function()
        for i = FIRST_CHUNKS + 1, #chunks do
            task.wait(CHUNK_INTERVAL)
            local c = chunks[i]
            print(string.format("[GOAT v4.4] Loading chunk %d/%d (dist: %.0f)",
                i, total, c.dist))
            processChunk(c)
        end
        print(string.format("[GOAT v4.4] All %d chunks optimized", total))
    end)
end)

local function showNotification()
    if not playerGui or not playerGui.Parent then return end
    local old = playerGui:FindFirstChild("GoatOptimizerNotif")
    if old then pcall(function() old:Destroy() end) end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoatOptimizerNotif"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = playerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 320, 0, 60)
    Frame.Position = UDim2.new(0.5, -160, 0, -80)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BackgroundTransparency = 0.05
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.3
    Stroke.Parent = Frame

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(1, -24, 0, 2)
    Accent.Position = UDim2.new(0.5, 0, 1, -6)
    Accent.AnchorPoint = Vector2.new(0.5, 1)
    Accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Accent.BorderSizePixel = 0
    Accent.Parent = Frame
    Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 26)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "GOAT OPTIMIZER"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, -30, 0, 16)
    Sub.Position = UDim2.new(0, 15, 0, 34)
    Sub.BackgroundTransparency = 1
    Sub.Text = string.format("ACTIVATED • Entry: %.1fs", ENTRY_TIME)
    Sub.TextColor3 = Color3.fromRGB(180, 180, 180)
    Sub.Font = Enum.Font.GothamMedium
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Frame

    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0, 20)
    }):Play()

    task.delay(3, function()
        if Frame and Frame.Parent then
            pcall(function()
                TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -160, 0, -80)
                }):Play()
            end)
            task.wait(0.3)
            if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
        end
    end)
end

showNotification()

local function optimizeLighting()
    pcall(function()
        Lighting.GlobalShadows            = false
        Lighting.Brightness               = 1.5
        Lighting.FogEnd                   = 9e9
        Lighting.FogStart                 = 0
        Lighting.EnvironmentDiffuseScale  = 0
        Lighting.EnvironmentSpecularScale = 0
    end)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("BloomEffect") or obj:IsA("BlurEffect")
           or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect")
           or obj:IsA("DepthOfFieldEffect") then
            pcall(function() obj.Enabled = false end)
        elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("Sky") then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function killAnimations(char)
    char = char or player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        pcall(function()
            for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
                t:Stop(0)
            end
        end)
    end
    local animate = char:FindFirstChild("Animate")
    if animate then pcall(function() animate.Disabled = true end) end
end

task.spawn(function() pcall(optimizeLighting) end)
task.spawn(function() pcall(killAnimations) end)

player.CharacterAdded:Connect(function(newChar)
    task.wait(1.5)
    pcall(function() killAnimations(newChar) end)
    local hum = newChar:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(track)
                task.defer(function() pcall(function() track:Stop(0) end) end)
            end)
        end
    end
end)

local function queueForNextServer()
    local payload = ('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL)
    if type(queue_on_teleport) == "function" then
        local ok = pcall(function() queue_on_teleport(payload) end)
        if ok then print("[GOAT] Queued"); return true end
    end
    if type(syn) == "table" and syn.queue_on_teleport then
        local ok = pcall(function() syn.queue_on_teleport(payload) end)
        if ok then print("[GOAT] Queued"); return true end
    end
    if type(fluxus) == "table" and fluxus.queue_on_teleport then
        local ok = pcall(function() fluxus.queue_on_teleport(payload) end)
        if ok then print("[GOAT] Queued"); return true end
    end
    if type(krnl) == "table" and krnl.queue_on_teleport then
        local ok = pcall(function() krnl.queue_on_teleport(payload) end)
        if ok then print("[GOAT] Queued"); return true end
    end
    if type(delta) == "table" and delta.queue_on_teleport then
        local ok = pcall(function() delta.queue_on_teleport(payload) end)
        if ok then print("[GOAT] Queued"); return true end
    end
    return false
end

task.spawn(function()
    task.wait(2)
    queueForNextServer()
end)

pcall(function()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started then
            queueForNextServer()
        end
    end)
end)

print("[GOAT v4.4] Ready")
