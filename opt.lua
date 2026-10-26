local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")

local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"
local SETTINGS_FILE = "goat_optimizer_mode.txt"

local START_TIME = os.clock()

print("[GOAT OPTIMIZER] Script Started!")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player
local playerGui = player:WaitForChild("PlayerGui", 15)

local function saveMode(mode)
    if writefile then pcall(function() writefile(SETTINGS_FILE, mode) end) end
end

local function loadMode()
    if isfile and isfile(SETTINGS_FILE) then
        local success, result = pcall(function() return readfile(SETTINGS_FILE) end)
        if success and (result == "NORMAL" or result == "EXTREME") then return result end
    end
    return nil
end

local currentMode = loadMode()

if not currentMode then
    local setGui = Instance.new("ScreenGui")
    setGui.Name = "GoatSettings"
    setGui.ResetOnSpawn = false
    setGui.DisplayOrder = 99999
    setGui.Parent = playerGui

    local gearBtn = Instance.new("TextButton")
    gearBtn.Size = UDim2.new(0, 40, 0, 40)
    gearBtn.Position = UDim2.new(1, -60, 0.5, -20)
    gearBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    gearBtn.Text = "⚙️"
    gearBtn.TextSize = 20
    gearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    gearBtn.Parent = setGui
    Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 250, 0, 180)
    menu.Position = UDim2.new(0.5, -125, 0.5, -90)
    menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    menu.Visible = false
    menu.Parent = setGui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", menu)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "OPTIMIZER MODE"
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.Parent = menu

    local function createModeBtn(text, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = menu
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local normalBtn = createModeBtn("NORMAL MODE", 50)
    local extremeBtn = createModeBtn("EXTREME MODE", 100)

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, -20, 0, 30)
    selectBtn.Position = UDim2.new(0, 10, 0, 145)
    selectBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selectBtn.Text = "SELECT"
    selectBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    selectBtn.Font = Enum.Font.GothamBlack
    selectBtn.TextSize = 14
    selectBtn.Parent = menu
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)

    local selectedMode = nil

    normalBtn.MouseButton1Click:Connect(function()
        selectedMode = "NORMAL"
        normalBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        normalBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        extremeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        extremeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    extremeBtn.MouseButton1Click:Connect(function()
        selectedMode = "EXTREME"
        extremeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        extremeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        normalBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        normalBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    gearBtn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)

    selectBtn.MouseButton1Click:Connect(function()
        if selectedMode then
            saveMode(selectedMode)
            setGui:Destroy()
            print("[GOAT OPTIMIZER] Mode saved: " .. selectedMode .. ". Please re-execute the script.")
        end
    end)
    return
end

print("[GOAT OPTIMIZER] Loaded mode: " .. currentMode)

pcall(function()
    if Workspace.StreamingEnabled then Workspace.StreamingEnabled = false end
end)

pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

local function clearScreens()
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "GoatSettings" and gui.Name ~= "GoatOptimizerNotif" then
                local name = gui.Name:lower()
                if name:find("load") or name:find("splash") or name:find("intro") or name:find("start") or name:find("title") then
                    pcall(function() gui:Destroy() end)
                end
            end
        end
    end
end

-- 💡 التعديل: التحقق من المسار المباشر (الأب هو Workspace)
local ALLOWED_NAMES = {
    ["ground"] = true,
    ["ground_left"] = true,
    ["ground_right"] = true,
    ["part"] = true
}

local function isAllowedPart(obj)
    local current = obj
    while current and current ~= Workspace do
        -- إذا كان المجلد الأب هو Plots، نسمح بكل ما بداخله
        if current.Name:lower() == "plots" then return true end
        
        -- نتحقق فقط من الأجزاء التي يكون أبوها المباشر هو Workspace
        if current.Parent == Workspace then
            local lowerName = current.Name:lower()
            if ALLOWED_NAMES[lowerName] then return true end
        end
        
        current = current.Parent
    end
    return false
end

local function isUnderPlayer(obj)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and obj:IsA("BasePart") then
        local dist = (Vector3.new(obj.Position.X, hrp.Position.Y, obj.Position.Z) - hrp.Position).Magnitude
        if obj.Position.Y < hrp.Position.Y + 5 and dist < 15 then
            return true
        end
    end
    return false
end

local function optimizePart(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
           or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Texture = ""
        elseif obj:IsA("BasePart") then
            if currentMode == "EXTREME" and not isAllowedPart(obj) and not isUnderPlayer(obj) then
                obj.Transparency = 1
                obj.CanCollide = false
            end
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

    if hrp and hrp.Parent then hrp.Anchored = false end
    
    clearScreens()
    
    local LOAD_TIME = os.clock() - START_TIME
    print(string.format("[GOAT OPTIMIZER] You can play now! (Load time: %.2fs)", LOAD_TIME))

    task.spawn(function()
        local textures = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then table.insert(textures, obj) end
        end
        if #textures > 0 then
            pcall(function() ContentProvider:PreloadAsync(textures) end)
            print(string.format("[GOAT OPTIMIZER] Preloaded %d textures!", #textures))
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
            animator.AnimationPlayed:Connect(function(track) pcall(function() track:Stop(0) end) end)
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
            optimizePart(obj)
            count = count + 1
            if count % 200 == 0 then RunService.Heartbeat:Wait() end
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
    Sub.Text = currentMode .. " MODE"
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
