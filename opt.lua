local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"

print("[GOAT OPTIMIZER] Script Started!")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player

pcall(function()
    if Workspace.StreamingEnabled then
        Workspace.StreamingEnabled = false
    end
end)

-- تغطية الشاشة السوداء بشاشة أنيقة من صنعنا (حتى لا ترى سواداً)
local overlay = Instance.new("ScreenGui")
overlay.Name = "GoatOptimizerOverlay"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.DisplayOrder = 9999999
overlay.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
bg.BorderSizePixel = 0
bg.Parent = overlay

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "Loading Ground..."
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.Font = Enum.Font.GothamBlack
text.TextSize = 24
text.Parent = bg

-- منع تحميل الأجزاء الأخرى (إخفائها فوراً) حتى نسمح نحن بظهورها
local hiddenParts = {}
Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        pcall(function()
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.CastShadow = false
                obj.Reflectance = 0
                obj.MaterialVariant = ""
                if obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" then
                    obj.Transparency = 1
                    hiddenParts[obj] = true
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Texture = ""
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            end
        end)
    end)
end)

-- تثبيت اللاعب وطلب الأرضية
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
    while os.clock() - t0 < 2 do
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0))
        if ray then break end
        task.wait(0.05)
    end
    
    if hrp and hrp.Parent then
        hrp.Anchored = false
    end

    -- إزالة الملصق بالقوة
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") or gui:IsA("Frame") then
                local name = gui.Name:lower()
                if name:find("load") or name:find("intro") or name:find("splash") or name:find("start") or name:find("title") then
                    pcall(function() gui:Destroy() end)
                end
            end
        end
    end
    
    -- إزالة شاشة التغطية بعد التأكد من الأرضية
    if overlay and overlay.Parent then
        overlay:Destroy()
        print("[GOAT OPTIMIZER] You can play now!")
    end
end)

-- إعادة تطبيق منع الأجزاء عند الموت
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.3)
    local humanoid = newChar:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(track)
                task.defer(function() pcall(function() track:Stop(0) end) end)
            end)
        end
    end
end)

-- تحميل الأجزاء "شوية بشوية" بعد أن تبدأ اللعب
task.spawn(function()
    task.wait(2) -- ننتظرك لتستقر وتلعب

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 150)
    print("[GOAT OPTIMIZER] Processing " .. #parts .. " parts slowly...")
    
    for i, p in ipairs(parts) do
        pcall(function()
            if p:IsA("BasePart") then
                p.Material        = Enum.Material.Plastic
                p.CastShadow      = false
                p.Reflectance     = 0
                p.MaterialVariant = ""
                p.Transparency    = 0 -- إظهار الجزء تدريجياً
                hiddenParts[p] = nil
            end
        end)
        
        if i % 3 == 0 then
            RunService.Heartbeat:Wait()
            task.wait(0.1)
        end
    end
    print("[GOAT OPTIMIZER] All systems ready!")
end)

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
        elseif obj:IsA("Atmosphere") then
            pcall(function() obj:Destroy() end)
        end
    end
end

task.spawn(function() pcall(optimizeLighting) end)

local function queueForNextServer()
    local payload = ('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL)
    if type(queue_on_teleport) == "function" then
        pcall(function() queue_on_teleport(payload) end)
    elseif type(syn) == "table" and syn.queue_on_teleport then
        pcall(function() syn.queue_on_teleport(payload) end)
    elseif type(fluxus) == "table" and fluxus.queue_on_teleport then
        pcall(function() fluxus.queue_on_teleport(payload) end)
    elseif type(krnl) == "table" and krnl.queue_on_teleport then
        pcall(function() krnl.queue_on_teleport(payload) end)
    elseif type(delta) == "table" and delta.queue_on_teleport then
        pcall(function() delta.queue_on_teleport(payload) end)
    end
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
