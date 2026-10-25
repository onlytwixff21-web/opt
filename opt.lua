local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player

pcall(function()
    if Workspace.StreamingEnabled then
        Workspace.StreamingEnabled = false
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
               or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("BasePart") then
                obj.Material        = Enum.Material.Plastic
                obj.CastShadow      = false
                obj.Reflectance     = 0
                obj.MaterialVariant = ""
            end
        end)
    end)
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
    
    local t0 = os.clock()
    while os.clock() - t0 < 10 do
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0))
        if ray then break end
        task.wait(0.05)
    end
    
    if hrp and hrp.Parent then
        hrp.Anchored = false
    end

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
    task.wait(2)

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, 150)
    
    for i, p in ipairs(parts) do
        pcall(function()
            if p:IsA("BasePart") then
                p.Material        = Enum.Material.Plastic
                p.CastShadow      = false
                p.Reflectance     = 0
                p.MaterialVariant = ""
            end
        end)
        
        if i % 3 == 0 then
            RunService.Heartbeat:Wait()
            task.wait(0.1)
        end
    end
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
    Sub.Text = "ACTIVATED • FAST LOAD"
    Sub.TextColor3 = Color3.fromRGB(180, 180, 180)
    Sub.Font = Enum.Font.GothamMedium
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Frame

    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0, 20)
    }):Play()

    task.delay(2, function()
        if Frame and Frame.Parent then
            pcall(function()
                TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -160, 0, -80)
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
