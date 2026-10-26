local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")

local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"
local SETTINGS_FILE = "goat_optimizer_settings.txt"

local START_TIME = os.clock()

print("[GOAT OPTIMIZER] Script Started!")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player
local playerGui = player:WaitForChild("PlayerGui", 15)

-- ═══════════════════════════════════════════════════════════
--  نظام حفظ وقراءة الإعدادات
-- ═══════════════════════════════════════════════════════════
local Settings = {
    RemoveDecals = true,
    RemoveParticles = true,
    PlasticGraphics = true,
    LowLighting = true,
    DestroyUnallowed = true,
    PreloadTextures = true,
    AntiVoid = true,
    KillAnimations = true,
}

local function saveSettings()
    if writefile then
        local data = ""
        for k, v in pairs(Settings) do
            data = data .. k .. "=" .. tostring(v) .. "\n"
        end
        pcall(function() writefile(SETTINGS_FILE, data) end)
    end
end

local function loadSettings()
    if isfile and isfile(SETTINGS_FILE) then
        local success, data = pcall(function() return readfile(SETTINGS_FILE) end)
        if success and data then
            for line in data:gmatch("[^\n]+") do
                local key, val = line:match("^(.-)=(.*)$")
                if key and val then
                    Settings[key] = (val == "true")
                end
            end
        end
    end
end

loadSettings()

-- ═══════════════════════════════════════════════════════════
--  واجهة الإعدادات الاحترافية
-- ═══════════════════════════════════════════════════════════
local setGui = Instance.new("ScreenGui")
setGui.Name = "GoatSettings"
setGui.ResetOnSpawn = false
setGui.DisplayOrder = 99999
setGui.Parent = playerGui

local gearBtn = Instance.new("TextButton")
gearBtn.Size = UDim2.new(0, 45, 0, 45)
gearBtn.Position = UDim2.new(1, -65, 0.5, -22)
gearBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
gearBtn.Text = "⚙️"
gearBtn.TextSize = 22
gearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
gearBtn.Parent = setGui
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(1, 0)
local gearStroke = Instance.new("UIStroke", gearBtn)
gearStroke.Color = Color3.fromRGB(255, 255, 255)
gearStroke.Thickness = 1
gearStroke.Transparency = 0.5

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 300, 0, 400)
menu.Position = UDim2.new(0.5, -150, 0.5, -200)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menu.Visible = false
menu.Parent = setGui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 12)
local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = Color3.fromRGB(255, 255, 255)
menuStroke.Thickness = 1
menuStroke.Transparency = 0.4

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "GOAT OPTIMIZER SETTINGS"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.Parent = menu

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -100)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = menu

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- دالة إنشاء صف إعداد
local function createSettingRow(name, key, desc)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 45)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    row.BorderSizePixel = 0
    row.Parent = scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -70, 0, 14)
    descLabel.Position = UDim2.new(0, 12, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc or ""
    descLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextSize = 10
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 24)
    toggle.Position = UDim2.new(1, -54, 0.5, -12)
    toggle.BackgroundColor3 = Settings[key] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 60)
    toggle.Text = Settings[key] and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 10
    toggle.AutoButtonColor = false
    toggle.Parent = row
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

    toggle.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        toggle.BackgroundColor3 = Settings[key] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 60)
        toggle.Text = Settings[key] and "ON" or "OFF"
    end)
end

-- إضافة الإعدادات
createSettingRow("Remove Decals/Textures", "RemoveDecals", "إزالة الصور والملصقات")
createSettingRow("Remove Particles", "RemoveParticles", "إزالة المؤثرات (نار، دخان)")
createSettingRow("Plastic Graphics", "PlasticGraphics", "تحويل الجرافيكس إلى بطاطا")
createSettingRow("Low Lighting", "LowLighting", "إلغاء الظلال والتأثيرات")
createSettingRow("Destroy Unallowed Parts", "DestroyUnallowed", "حذف الأجزاء غير المسموحة")
createSettingRow("Preload Textures", "PreloadTextures", "تحميل الصور مسبقاً")
createSettingRow("Anti-Void", "AntiVoid", "منع السقوط في الفراغ")
createSettingRow("Kill Animations", "KillAnimations", "إيقاف الأنميشن")

-- زر APPLY
local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, -20, 0, 35)
applyBtn.Position = UDim2.new(0, 10, 1, -45)
applyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.Text = "APPLY & SAVE"
applyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
applyBtn.Font = Enum.Font.GothamBlack
applyBtn.TextSize = 14
applyBtn.Parent = menu
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 8)

applyBtn.MouseButton1Click:Connect(function()
    saveSettings()
    applyBtn.Text = "SAVED ✓"
    task.delay(1.5, function()
        applyBtn.Text = "APPLY & SAVE"
    end)
end)

-- فتح/إغلاق القائمة
gearBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

-- ═══════════════════════════════════════════════════════════
--  تطبيق الإعدادات
-- ═══════════════════════════════════════════════════════════
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

local ALLOWED_MAP_NAMES = {
    ["ground"] = true,
    ["ground_left"] = true,
    ["ground_right"] = true
}

local function isPlayerPart(obj)
    local current = obj
    while current and current ~= Workspace do
        if current:IsA("Model") and Players:GetPlayerFromCharacter(current) then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isAllowedPart(obj)
    local current = obj
    while current and current ~= Workspace do
        if current.Name:lower() == "plots" and current.Parent == Workspace then 
            return true 
        end
        current = current.Parent
    end

    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder and obj:IsDescendantOf(mapFolder) then
        local lowerName = obj.Name:lower()
        if ALLOWED_MAP_NAMES[lowerName] then
            return true
        end
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
        local isPlayer = isPlayerPart(obj)

        if Settings.DestroyUnallowed and not isPlayer and not isAllowedPart(obj) and not isUnderPlayer(obj) then
            if obj:IsA("BasePart") then
                obj:Destroy()
                return
            end
        end

        if Settings.RemoveParticles and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
           or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")) then
            obj.Enabled = false
        elseif Settings.RemoveDecals and (obj:IsA("Decal") or obj:IsA("Texture")) then
            obj.Texture = ""
        elseif Settings.PlasticGraphics and obj:IsA("BasePart") then
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

-- Anti-Void
if Settings.AntiVoid then
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

        if Settings.PreloadTextures then
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
        end
    end)
end

-- Kill Animations
if Settings.KillAnimations then
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
end

if not game:IsLoaded() then game.Loaded:Wait() end
if _G.__OPTIMIZER_RUNNING then return end
_G.__OPTIMIZER_RUNNING = true

-- تحسين الأجزاء الموجودة مسبقاً
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

-- Low Lighting
if Settings.LowLighting then
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
end

-- ═══════════════════════════════════════════════════════════
--  إعادة التطبيق عند Respawn
-- ═══════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════
--  queue_on_teleport
-- ═══════════════════════════════════════════════════════════
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
