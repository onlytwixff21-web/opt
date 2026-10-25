print("[GOAT OPTIMIZER] Starting v6.0 (10-Batch Smart System)...")

local ENTRY_START = os.clock()
local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"

local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player

-- ═══════════════════════════════════════════════════════════
--  [1] إزالة شاشة التحميل (للدخول السريع)
-- ═══════════════════════════════════════════════════════════
pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
    print("[GOAT v6.0] Loading screen removed")
end)

-- ═══════════════════════════════════════════════════════════
--  [2] نظام الأرضية أولاً (Anti-Void)
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    local char
    repeat task.wait(0.1); char = player.Character until char
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    hrp.Anchored = true
    
    pcall(function()
        player:RequestStreamAroundAsync(hrp.Position)
    end)
    
    local t0 = os.clock()
    while os.clock() - t0 < 10 do
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0))
        if ray then break end
        task.wait(0.1)
    end
    
    if hrp and hrp.Parent then
        hrp.Anchored = false
        print("[GOAT v6.0] Ground found, character released")
    end
end)

-- ═══════════════════════════════════════════════════════════
--  [3] منع الأنميشن والصور (فوراً)
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    local char
    repeat task.wait(0.1); char = player.Character until char
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
                end
            end)
        end)
    end)
end)

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.__GOAT_V60_RUNNING then return end
_G.__GOAT_V60_RUNNING = true

-- ═══════════════════════════════════════════════════════════
--  [4] نظام الـ 10 مجموعات (Smart Batches)
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 1. جلب كل الأجزاء القريبة منك (200 stud)
    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 200)
    local spawnPos = hrp.Position

    -- 2. فلترة الأجزاء الشاذة (التي تسبب أخطاء في الحساب)
    local validParts = {}
    for _, p in ipairs(parts) do
        if p:IsA("BasePart") then
            local pos = p.Position
            if math.abs(pos.X) < 5000 and math.abs(pos.Y) < 5000 and math.abs(pos.Z) < 5000 then
                table.insert(validParts, p)
            end
        end
    end

    -- 3. ترتيب الأجزاء: الأرضية (Y منخفض) أولاً، ثم الأقرب مسافة
    table.sort(validParts, function(a, b)
        -- إذا كان أحدهما أرضية (Y أقل)، نعطيه أولوية
        local aIsGround = (a.Position.Y < spawnPos.Y - 2)
        local bIsGround = (b.Position.Y < spawnPos.Y - 2)
        
        if aIsGround and not bIsGround then return true end
        if bIsGround and not aIsGround then return false end
        
        -- إذا كانا في نفس المستوى، الأقرب أولاً
        local distA = (a.Position - spawnPos).Magnitude
        local distB = (b.Position - spawnPos).Magnitude
        return distA < distB
    end)

    local totalParts = #validParts
    print(string.format("[GOAT v6.0] Found %d nearby parts", totalParts))
    
    if totalParts == 0 then return end

    -- 4. تقسيم الأجزاء إلى 10 مجموعات
    local batchSize = math.ceil(totalParts / 10)
    
    local function optimizePart(p)
        pcall(function()
            p.Material        = Enum.Material.Plastic
            p.CastShadow      = false
            p.Reflectance     = 0
            p.MaterialVariant = ""
        end)
    end

    -- 5. معالجة المجموعات
    for batchNum = 1, 10 do
        local startIdx = (batchNum - 1) * batchSize + 1
        local endIdx = math.min(batchNum * batchSize, totalParts)
        
        if startIdx <= totalParts then
            print(string.format("[GOAT v6.0] Processing Batch %d/10 (%d parts)", batchNum, endIdx - startIdx + 1))
            
            -- نمر على الأجزاء في هذه المجموعة
            for i = startIdx, endIdx do
                optimizePart(validParts[i])
                
                -- تنفس كل 10 أجزاء لمنع التجميد
                if i % 10 == 0 then
                    RunService.Heartbeat:Wait()
                end
            end
            
            -- انتظار بسيط بين كل مجموعة والأخرى (0.05 ثانية)
            -- هذا يعطي المعالج وقتاً للراحة
            task.wait(0.05)
        end
    end
    
    print("[GOAT v6.0] All batches processed smoothly")
end)

-- ═══════════════════════════════════════════════════════════
--  [5] الإشعار
-- ═══════════════════════════════════════════════════════════
local playerGui = player:WaitForChild("PlayerGui", 15)
local ENTRY_TIME = os.clock() - ENTRY_START

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
    Sub.Text = string.format("ACTIVATED • %.1fs", ENTRY_TIME)
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

-- ═══════════════════════════════════════════════════════════
--  [6] تحسين الإضاءة + الأنميشن
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

-- ═══════════════════════════════════════════════════════════
--  [7] queue_on_teleport
-- ═══════════════════════════════════════════════════════════
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

print("[GOAT v6.0] Ready")
