-- ═══════════════════════════════════════════════════════════
--  GOAT OPTIMIZER  |  v3.1  |  Fast Entry + Zero Lag
--  منع Textures/Animations فوراً + Chunks + Auto-Reload
-- ═══════════════════════════════════════════════════════════

local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"

-- ═══════════════════════════════════════════════════════════
--  [0] منع الأنميشن والصور فوراً (قبل أي شيء آخر)
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local player = Players.LocalPlayer

    print("[GOAT OPTIMIZER] Fast block: Textures + Animations")

    -- انتظر الشخصية (بدون انتظار game.Loaded)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid", 5)

    -- إيقاف كل أنميشن
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

    -- اعتراض الصور والمؤثرات الجديدة
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

    -- مسح الموجود مسبقاً
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Texture = ""
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                   or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  انتظر تحميل اللعبة
-- ═══════════════════════════════════════════════════════════
if not game:IsLoaded() then game.Loaded:Wait() end

local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer

if _G.__GOAT_V31_RUNNING then return end
_G.__GOAT_V31_RUNNING = true

print("[GOAT OPTIMIZER] Starting v3.1")

-- ═══════════════════════════════════════════════════════════
--  [1] انتظر الأرض (منع الشاشة السوداء والسقوط)
-- ═══════════════════════════════════════════════════════════
local function waitGround(maxT)
    maxT = maxT or 15
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
waitGround(15)
print("[GOAT OPTIMIZER] Ground ready")

local playerGui = player:WaitForChild("PlayerGui", 15)

-- ═══════════════════════════════════════════════════════════
--  [2] إشعار
-- ═══════════════════════════════════════════════════════════
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
    Sub.Text = "ACTIVATED • FAST ENTRY"
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

-- ═══════════════════════════════════════════════════════════
--  [3] Chunks (2 عناصر/Frame - لا تجميد)
-- ═══════════════════════════════════════════════════════════
local function processTinyChunks(list, processFn)
    if #list == 0 then return end
    local i = 1
    local conn
    conn = RunService.Heartbeat:Connect(function()
        for _ = 1, 2 do
            if i > #list then conn:Disconnect(); return end
            pcall(processFn, list[i])
            i = i + 1
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  [4] تحسين الإضاءة
-- ═══════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════
--  [5] إزالة الأنميشن
-- ═══════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════
--  [6] تسطيح الأجزاء القريبة (200 stud)
-- ═══════════════════════════════════════════════════════════
local function flattenNearby()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 200)
    print("[GOAT OPTIMIZER] Nearby parts: " .. #parts)
    local function flatten(p)
        p.Material        = Enum.Material.Plastic
        p.CastShadow      = false
        p.Reflectance     = 0
        p.MaterialVariant = ""
    end
    task.spawn(function() processTinyChunks(parts, flatten) end)
end

-- ═══════════════════════════════════════════════════════════
--  [7] تعطيل المؤثرات القريبة
-- ═══════════════════════════════════════════════════════════
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
    print("[GOAT OPTIMIZER] Nearby effects: " .. #effects)
    processTinyChunks(effects, function(e) e.Enabled = false end)
end

-- ═══════════════════════════════════════════════════════════
--  [8] التشغيل الرئيسي
-- ═══════════════════════════════════════════════════════════
local function runOptimizer()
    showNotification()
    task.spawn(function() pcall(optimizeLighting) end)
    task.spawn(function() pcall(killAnimations) end)
    task.delay(1.5, function() pcall(flattenNearby) end)
    task.delay(2.5, function() pcall(disableNearbyEffects) end)
end

runOptimizer()

-- ═══════════════════════════════════════════════════════════
--  [9] إعادة التطبيق عند Respawn
-- ═══════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════
--  [10] queue_on_teleport (فوري)
-- ═══════════════════════════════════════════════════════════
local function queueForNextServer()
    local payload = ('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL)

    if type(queue_on_teleport) == "function" then
        local ok = pcall(function() queue_on_teleport(payload) end)
        if ok then print("[GOAT OPTIMIZER] ✓ Queued via queue_on_teleport"); return true end
    end
    if type(syn) == "table" and syn.queue_on_teleport then
        local ok = pcall(function() syn.queue_on_teleport(payload) end)
        if ok then print("[GOAT OPTIMIZER] ✓ Queued via syn"); return true end
    end
    if type(fluxus) == "table" and fluxus.queue_on_teleport then
        local ok = pcall(function() fluxus.queue_on_teleport(payload) end)
        if ok then print("[GOAT OPTIMIZER] ✓ Queued via fluxus"); return true end
    end
    if type(krnl) == "table" and krnl.queue_on_teleport then
        local ok = pcall(function() krnl.queue_on_teleport(payload) end)
        if ok then print("[GOAT OPTIMIZER] ✓ Queued via krnl"); return true end
    end
    if type(delta) == "table" and delta.queue_on_teleport then
        local ok = pcall(function() delta.queue_on_teleport(payload) end)
        if ok then print("[GOAT OPTIMIZER] ✓ Queued via delta"); return true end
    end
    warn("[GOAT OPTIMIZER] ✗ queue_on_teleport غير مدعوم")
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

print("[GOAT OPTIMIZER] Ready ✓ (Fast Entry, Zero Freeze)")
