-- ═══════════════════════════════════════════════════════════
--  GOAT OPTIMIZER  |  v2.0 Ultra-Zero-Lag + Auto-Reload
--  يعمل تلقائياً عند تغيير الخريطة (queue_on_teleport)
-- ═══════════════════════════════════════════════════════════

-- ⚠️ ضع رابط GitHub Raw الخاص بك هنا (ستحصل عليه في الخطوة 4)
local SCRIPT_URL = "https://raw.githubusercontent.com/USERNAME/REPO/main/GOAT.lua"

-- ═══════════════════════════════════════════════════════════
--  الجزء الأساسي: GOAT OPTIMIZER
-- ═══════════════════════════════════════════════════════════

pcall(function()
    if Workspace and Workspace.StreamingEnabled then
        Workspace.StreamingEnabled = false
    end
end)

if not game:IsLoaded() then game.Loaded:Wait() end

local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer

if _G.__GOAT_V20_ZL then return end
_G.__GOAT_V20_ZL = true

print("[GOAT v2.0-ZL] Starting (Zero-Lag)")

local function processTinyChunks(list, processFn)
    if #list == 0 then return end
    local i = 1
    local conn
    conn = RunService.Heartbeat:Connect(function()
        for _ = 1, 2 do
            if i > #list then
                conn:Disconnect()
                return
            end
            pcall(processFn, list[i])
            i = i + 1
        end
    end)
end

local function waitGround(maxT)
    maxT = maxT or 12
    local t0 = os.clock()
    while os.clock() - t0 < maxT do
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.FloorMaterial ~= Enum.Material.Air then return true end
        task.wait(0.1)
    end
    return false
end

local character = player.Character or player.CharacterAdded:Wait()
character:WaitForChild("Humanoid", 10)
waitGround(12)

local playerGui = player:WaitForChild("PlayerGui", 15)

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
    Sub.Text = "ACTIVATED • ZERO LAG"
    Sub.TextColor3 = Color3.fromRGB(180, 180, 180)
    Sub.Font = Enum.Font.GothamMedium
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Frame

    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0, 20)
    }):Play()

    task.delay(2, function()
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

local function flattenNearby()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 200)
    print("[GOAT v2.0-ZL] Nearby parts: " .. #parts)
    local function flatten(p)
        p.Material        = Enum.Material.Plastic
        p.CastShadow      = false
        p.Reflectance     = 0
        p.MaterialVariant = ""
    end
    task.spawn(function() processTinyChunks(parts, flatten) end)
end

local function disableNearbyEffects()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local effects = {}
    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 200)
    for _, part in ipairs(parts) do
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam")
               or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Sparkles") then
                table.insert(effects, child)
            end
        end
    end
    print("[GOAT v2.0-ZL] Nearby effects: " .. #effects)
    processTinyChunks(effects, function(e) e.Enabled = false end)
end

local function runOptimizer()
    showNotification()
    task.spawn(function() pcall(optimizeLighting) end)
    task.spawn(function() pcall(killAnimations) end)
    task.delay(1, function() pcall(flattenNearby) end)
    task.delay(2, function() pcall(disableNearbyEffects) end)
end

runOptimizer()

player.CharacterAdded:Connect(function(newChar)
    task.wait(1)
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

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
               or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("BasePart") then
                obj.Material    = Enum.Material.Plastic
                obj.CastShadow  = false
                obj.Reflectance = 0
            end
        end)
    end)
end)

print("[GOAT v2.0-ZL] Ready ✓ (Zero Lag, No Freeze)")

-- ═══════════════════════════════════════════════════════════
--  الحفظ الذاتي: إعادة التشغيل التلقائي بعد تغيير الخريطة
-- ═══════════════════════════════════════════════════════════

local function safeQueueOnTeleport(code)
    -- syn
    if type(syn) == "table" and syn.queue_on_teleport then
        local ok = pcall(function() syn.queue_on_teleport(code) end)
        if ok then return true end
    end
    -- fluxus
    if type(fluxus) == "table" and fluxus.queue_on_teleport then
        local ok = pcall(function() fluxus.queue_on_teleport(code) end)
        if ok then return true end
    end
    -- krnl
    if type(krnl) == "table" and krnl.queue_on_teleport then
        local ok = pcall(function() krnl.queue_on_teleport(code) end)
        if ok then return true end
    end
    -- delta
    if type(delta) == "table" and delta.queue_on_teleport then
        local ok = pcall(function() delta.queue_on_teleport(code) end)
        if ok then return true end
    end
    -- الدالة العامة
    if type(queue_on_teleport) == "function" then
        local ok = pcall(function() queue_on_teleport(code) end)
        if ok then return true end
    end
    return false
end

pcall(function()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started then
            -- نبني أمر إعادة التحميل من GitHub
            local payload = ('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL)
            local ok = safeQueueOnTeleport(payload)
            if ok then
                print("[GOAT] Queued for next map ✓")
            else
                warn("[GOAT] queue_on_teleport غير مدعوم - استخدم autoexec")
            end
        end
    end)
end)
