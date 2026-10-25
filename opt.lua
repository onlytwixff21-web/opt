local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"

print("[GOAT OPTIMIZER] Script Started!")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player

pcall(function()
    if Workspace.StreamingEnabled then
        Workspace.StreamingEnabled = false
    end
end)

pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

local playerGui = player:WaitForChild("PlayerGui", 15)

local function clearScreens()
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local name = gui.Name:lower()
                if name:find("load") or name:find("splash") or name:find("intro") or name:find("start") or name:find("title") then
                    pcall(function() gui:Destroy() end)
                end
            end
        end
    end
end

local function optimizePart(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
           or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Texture = ""
        elseif obj:IsA("BasePart") then
            obj.Material        = Enum.Material.Plastic
            obj.CastShadow      = false
            obj.Reflectance     = 0
            obj.MaterialVariant = ""
        end
    end)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function() optimizePart(obj) end)
end)

task.spawn(function()
    local char
    repeat task.wait(0.1); char = player.Character until char
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    hrp.Anchored = true
    
    pcall(function()
        player:RequestStreamAroundAsync(hrp.Position)
    end)
    
    local nearbyParts = Workspace:GetPartBoundsInRadius(hrp.Position, 300)
    local hiddenForBoost = {}
    for _, p in ipairs(nearbyParts) do
        if p:IsA("BasePart") and p.Name ~= "Baseplate" then
            pcall(function()
                p.Material        = Enum.Material.Plastic
                p.CastShadow      = false
                p.Reflectance     = 0
                p.MaterialVariant = ""
                
                if p.Transparency < 1 then
                    hiddenForBoost[p] = p.Transparency
                    p.Transparency = 1
                end
            end)
        end
    end

    local t0 = os.clock()
    local groundFound = false
    while os.clock() - t0 < 10 do
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}
        
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0), rayParams)
        if ray then
            groundFound = true
            break
        end
        task.wait(0.05)
    end

    if hrp and hrp.Parent then
        hrp.Anchored = false
    end
    
    clearScreens()
    print("[GOAT OPTIMIZER] You can play now!")

    task.delay(0.5, function()
        for p, origTrans in pairs(hiddenForBoost) do
            pcall(function()
                if p and p.Parent then
                    p.Transparency = origTrans
                end
            end)
        end
    end)
end)

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
end)

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.__OPTIMIZER_RUNNING then return end
_G.__OPTIMIZER_RUNNING = true

task.spawn(function()
    task.wait(1)

    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            pcall(function()
                obj.Material        = Enum.Material.Plastic
                obj.CastShadow      = false
                obj.Reflectance     = 0
                obj.MaterialVariant = ""
            end)
            count = count + 1
            if count % 200 == 0 then 
                RunService.Heartbeat:Wait()
            end
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

-- 💡 الإشعار الجديد (بدون إيموجي، سموت وأنيق)
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
    Frame.Size = UDim2.new(0, 300, 0, 52)
    Frame.Position = UDim2.new(0.5, -150, 0, -80)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.6
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "GOAT OPTIMIZER"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, -20, 0, 14)
    Sub.Position = UDim2.new(0, 12, 0, 28)
    Sub.BackgroundTransparency = 1
    Sub.Text = "ACTIVATED"
    Sub.TextColor3 = Color3.fromRGB(150, 150, 150)
    Sub.Font = Enum.Font.GothamMedium
    Sub.TextSize = 10
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Frame

    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0, 20)
    }):Play()

    task.delay(2.5, function()
        if Frame and Frame.Parent then
            pcall(function()
                TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -150, 0, -80)
                }):Play()
            end)
            task.wait(0.35)
            if ScreenGui and ScreenGui.Parent then pcall(function() ScreenGui:Destroy() end) end
        end
    end)
end

showNotification()

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

local function queueForNextServer()
    local payload = ('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL)
    if type(queue_on_teleport) == "function" then
        pcall(function() queue_on_teleport(payload) end)
        return
    end
    if type(syn) == "table" and syn.queue_on_teleport then
        pcall(function() syn.queue_on_teleport(payload) end)
        return
    end
    if type(fluxus) == "table" and fluxus.queue_on_teleport then
        pcall(function() fluxus.queue_on_teleport(payload) end)
        return
    end
    if type(krnl) == "table" and krnl.queue_on_teleport then
        pcall(function() krnl.queue_on_teleport(payload) end)
        return
    end
    if type(delta) == "table" and delta.queue_on_teleport then
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
