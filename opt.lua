print("[GOAT OPTIMIZER] Starting v5.0 (Ground-First System)...")

local ENTRY_START = os.clock()
local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"

local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player

-- ═══════════════════════════════════════════════════════════
--  [1] نظام "الأرض أولاً" (Ground-First)
--  نمسك الشخصية، نطلب الأرض، ثم نبدأ تفعيل باقي الماب
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    local char
    repeat task.wait(0.1); char = player.Character until char
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    -- 1. تثبيت الشخصية (منع السقوط)
    hrp.Anchored = true
    print("[GOAT v5.0] Character anchored")
    
    -- 2. طلب الأرضية تحت أقدامنا فقط
    pcall(function()
        player:RequestStreamAroundAsync(hrp.Position)
    end)
    print("[GOAT v5.0] Requested ground stream")
    
    -- 3. الانتظار حتى تظهر الأرض
    local t0 = os.clock()
    while os.clock() - t0 < 10 do
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0))
        if ray then break end
        task.wait(0.2)
    end
    
    -- 4. فك التثبيت (الآن لدينا أرض)
    if hrp and hrp.Parent then
        hrp.Anchored = false
        print("[GOAT v5.0] Ground found, character released")
    end
end)

-- ═══════════════════════════════════════════════════════════
--  [2] منع كل الأجزاء والمؤثرات من الظهور (قبل أي شيء)
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    local char
    repeat task.wait(0.1); char = player.Character until char
    local hum = char:WaitForChild("Humanoid", 10)
    
    -- منع الأنميشن
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

    -- منع أي جزء أو مؤثر جديد من الظهور أو العمل
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

if _G.__GOAT_V50_RUNNING then return end
_G.__GOAT_V50_RUNNING = true

print("[GOAT v5.0] Initializing")

local character
repeat task.wait(0.1); character = player.Character until character
character:WaitForChild("Humanoid", 10)
local playerGui = player:WaitForChild("PlayerGui", 15)

local ENTRY_TIME = os.clock() - ENTRY_START
print(string.format("[GOAT v5.0] Entry time: %.2fs", ENTRY_TIME))

-- ═══════════════════════════════════════════════════════════
--  [3] الإشعار
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

-- ═══════════════════════════════════════════════════════════
--  [4] تحسين الإضاءة (لتسريع الريندر)
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
--  [5] queue_on_teleport
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

print("[GOAT v5.0] Ready")
