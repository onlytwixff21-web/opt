-- ==========================================
-- [ GOAT OPTIMIZER + SABCOM SYNC + SETTINGS ]
-- ==========================================

local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local ReplicatedFirst  = game:GetService("ReplicatedFirst")
local ContentProvider  = game:GetService("ContentProvider")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local SCRIPT_URL = "https://raw.githubusercontent.com/onlytwixff21-web/opt/refs/heads/main/opt.lua"
local START_TIME = os.clock()

print("[GOAT OPTIMIZER] Script Started!")

local player
repeat task.wait(0.1); player = Players.LocalPlayer until player
local playerGui = player:WaitForChild("PlayerGui", 15)

-- ==========================================
-- 1. إعدادات الحفظ (Settings Save/Load)
-- ==========================================
local SETTINGS_FILE = "GoatOptimizer_Settings.txt"
local CurrentMode = "NORMAL" -- الوضع الافتراضي

if writefile and isfile and readfile then
    pcall(function()
        if isfile(SETTINGS_FILE) then
            local savedMode = readfile(SETTINGS_FILE)
            if savedMode == "NORMAL" or savedMode == "EXTREME" then
                CurrentMode = savedMode
            end
        end
    end)
end

-- ==========================================
-- 2. قائمة الإعدادات (UI GUI)
-- ==========================================
local function createSettingsUI()
    local oldGui = playerGui:FindFirstChild("GoatSettingsUI")
    if oldGui then oldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoatSettingsUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 99999
    ScreenGui.Parent = playerGui

    -- زر الترس (Settings Button)
    local GearBtn = Instance.new("TextButton")
    GearBtn.Name = "GearBtn"
    GearBtn.Size = UDim2.new(0, 40, 0, 40)
    GearBtn.Position = UDim2.new(1, -50, 0, 100)
    GearBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    GearBtn.Text = "⚙️"
    GearBtn.TextSize = 24
    GearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GearBtn.Font = Enum.Font.GothamBold
    GearBtn.Parent = ScreenGui
    Instance.new("UICorner", GearBtn).CornerRadius = UDim.new(0, 8)

    -- القائمة المنسدلة
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Name = "MenuFrame"
    MenuFrame.Size = UDim2.new(0, 200, 0, 160)
    MenuFrame.Position = UDim2.new(1, -210, 0, 150)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui
    Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 10)
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.8
    UIStroke.Parent = MenuFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "SELECT MODE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = MenuFrame

    -- زر NORMAL
    local NormalBtn = Instance.new("TextButton")
    NormalBtn.Size = UDim2.new(0.9, 0, 0, 40)
    NormalBtn.Position = UDim2.new(0.05, 0, 0, 40)
    NormalBtn.BackgroundColor3 = CurrentMode == "NORMAL" and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    NormalBtn.Text = "NORMAL MODE"
    NormalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NormalBtn.Font = Enum.Font.GothamMedium
    NormalBtn.TextSize = 12
    NormalBtn.Parent = MenuFrame
    Instance.new("UICorner", NormalBtn).CornerRadius = UDim.new(0, 6)

    -- زر EXTREME
    local ExtremeBtn = Instance.new("TextButton")
    ExtremeBtn.Size = UDim2.new(0.9, 0, 0, 40)
    ExtremeBtn.Position = UDim2.new(0.05, 0, 0, 90)
    ExtremeBtn.BackgroundColor3 = CurrentMode == "EXTREME" and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(50, 50, 50)
    ExtremeBtn.Text = "EXTREME MODE"
    ExtremeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExtremeBtn.Font = Enum.Font.GothamMedium
    ExtremeBtn.TextSize = 12
    ExtremeBtn.Parent = MenuFrame
    Instance.new("UICorner", ExtremeBtn).CornerRadius = UDim.new(0, 6)

    -- حدث فتح/إغلاق القائمة
    GearBtn.MouseButton1Click:Connect(function()
        MenuFrame.Visible = not MenuFrame.Visible
    end)

    -- حدث اختيار الوضع
    local function setMode(mode)
        CurrentMode = mode
        NormalBtn.BackgroundColor3 = mode == "NORMAL" and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        ExtremeBtn.BackgroundColor3 = mode == "EXTREME" and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(50, 50, 50)
        
        if writefile then
            pcall(function() writefile(SETTINGS_FILE, mode) end)
        end
        
        -- تنبيه المستخدم
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 200, 0, 30)
        notif.Position = UDim2.new(0.5, -100, 0, 50)
        notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.Font = Enum.Font.GothamBold
        notif.TextSize = 14
        notif.Text = "MODE SET TO: " .. mode
        notif.Parent = ScreenGui
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
        
        task.delay(2, function() notif:Destroy() end)
        task.wait(1)
        -- إعادة تشغيل السكربت لتطبيق التغييرات (أو طلب من المستخدم إعادة التفعيل)
        print("[GOAT] Mode changed to: " .. mode .. ". Please re-execute the script to apply.")
    end

    NormalBtn.MouseButton1Click:Connect(function() setMode("NORMAL") end)
    ExtremeBtn.MouseButton1Click:Connect(function() setMode("EXTREME") end)
end

createSettingsUI()

-- ==========================================
-- 3. دالة اعتراض التحميل لوضع EXTREME
-- ==========================================
local function enableExtremeMode()
    print("[GOAT EXTREME] Extreme Mode Activated! Intercepting unallowed assets...")
    
    -- المسارات والأسماء المسموح لها بالتحميل
    local allowedWorkspaceParts = {
        ["GROUND"] = true,
        ["GROUND_LEFT"] = true,
        ["GROUND_RIGHT"] = true,
        ["PART"] = true,
    }

    local oldInstanceNew = Instance.new
    Instance.new = function(className, parent)
        local obj = oldInstanceNew(className)
        
        if parent then
            local fullPath = obj:GetFullName()
            local isAllowed = false
            
            -- 1. السماح بكل شيء داخل Workspace.Plots
            if fullPath:find("Workspace.Plots") or (parent and parent:GetFullName():find("Workspace.Plots")) then
                isAllowed = true
            end
            
            -- 2. السماح بالبارتات المحددة في Workspace
            if parent == Workspace and allowedWorkspaceParts[obj.Name] then
                isAllowed = true
            end
            
            -- إذا كان غير مسموح، يتم منعه
            if not isAllowed and (className == "Part" or className == "MeshPart" or className == "Model") then
                print("[Blocked] Prevented loading unallowed part: " .. tostring(obj.Name) .. " in " .. parent:GetFullName())
                obj:Destroy()
                return nil
            end
        end
        return obj
    end
end

-- ==========================================
-- 4. أكواد التحسين الأساسية (GOAT OPTIMIZER)
-- ==========================================
if CurrentMode == "EXTREME" then
    task.spawn(enableExtremeMode)
end

pcall(function()
    if Workspace.StreamingEnabled then
        Workspace.StreamingEnabled = false
    end
end)

pcall(function()
    ReplicatedFirst:RemoveDefaultLoadingScreen()
end)

local function clearScreens()
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "GoatSettingsUI" then
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
    task.defer(function() 
        if CurrentMode == "EXTREME" then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                 -- في وضع الاكستريم، يتم تجاهل التحسين للبارتات المسموح بها للحفاظ على المظهر
                local fullPath = obj:GetFullName()
                if fullPath:find("Workspace.Plots") or allowedWorkspaceParts[obj.Name] then return end
            end
        end
        optimizePart(obj) 
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
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}
        
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0), rayParams)
        if ray then break end
        task.wait(0.05)
    end

    if hrp and hrp.Parent then
        hrp.Anchored = false
    end
    
    clearScreens()
    
    local LOAD_TIME = os.clock() - START_TIME
    print(string.format("[GOAT OPTIMIZER] You can play now! (Load time: %.2fs)", LOAD_TIME))

    task.spawn(function()
        local textures = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                table.insert(textures, obj)
            end
        end
        
        if #textures > 0 then
            pcall(function()
                ContentProvider:PreloadAsync(textures)
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

-- ==========================================
-- 5. نظام جمع البيانات (sabcom Sync)
-- ==========================================
local function initSynchronizerCache()
    local _gu = debug.getupvalues or getupvalues
    if not _gu then return nil end
    
    local ok, sync = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    end)

    if not (ok and type(sync) == "table") then return nil end

    if type(sync.GetAllChannels) == "function" then
        local ok2, ups = pcall(_gu, sync.GetAllChannels)
        if ok2 and type(ups) == "table" then
            for _, u in pairs(ups) do
                if type(u) == "table" then
                    local uuidCount = 0
                    for tk, tv in pairs(u) do
                        if type(tk) == "string" and tk:match("%-") and type(tv) == "table" then
                            uuidCount = uuidCount + 1
                            if uuidCount >= 2 then
                                return u
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    task.wait(3) -- الانتظار حتى يتم تحميل البيانات
    local _AD, _MD, _TD
    pcall(function()
        local d = ReplicatedStorage:WaitForChild("Datas", 5)
        if d then
            _AD = require(d:WaitForChild("Animals"))
            _MD = require(d:WaitForChild("Mutations"))
            _TD = require(d:WaitForChild("Traits"))
        end
    end)

    if not _AD then return end

    local function formatNumber(val)
        local ok, NumberUtils = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("NumberUtils"))
        end)
        if ok and NumberUtils and NumberUtils.ToString then
            return "$" .. NumberUtils:ToString(val) .. "/s"
        end
        return "$" .. tostring(val) .. "/s"
    end

    local function printPlotData()
        local t = initSynchronizerCache()
        if not t then return end

        local totalPets = 0
        local plotCount = 0

        for plotName, channel in pairs(t) do
            if type(plotName) == "string" and plotName:match("%-") then
                plotCount = plotCount + 1
                local cacheTable = type(channel) == "table" and channel.CacheTable or nil
                if cacheTable then
                    local owner = rawget(cacheTable, "Owner")
                    local animalList = rawget(cacheTable, "AnimalList")
                    local ownerName = "Nadie"
                    if owner and typeof(owner) == "Instance" and owner:IsA("Player") then
                        ownerName = owner.Name
                    elseif type(owner) == "table" and owner.Name then
                        ownerName = owner.Name
                    end

                    print(string.format("\n📌 [PLOT: %s] | DUEÑO: %s", plotName, ownerName))

                    if animalList and type(animalList) == "table" then
                        for slot, petData in pairs(animalList) do
                            if type(petData) == "table" then
                                totalPets = totalPets + 1
                                local petIndex = petData.Index or "Unknown"
                                local info = _AD and _AD[petIndex]
                                local displayName = (info and info.DisplayName) or petIndex
                                local genValue = 0
                                if info and info.Generation then
                                    local mult = 1
                                    if petData.Mutation and petData.Mutation ~= "None" and _MD[petData.Mutation] then
                                        mult = mult + (_MD[petData.Mutation].Modifier or 0)
                                    end
                                    if type(petData.Traits) == "table" then
                                        for _, tr in ipairs(petData.Traits) do
                                            if _TD[tr] and _TD[tr].MultiplierModifier then
                                                mult = mult + _TD[tr].MultiplierModifier
                                            end
                                        end
                                    end
                                    genValue = info.Generation * mult
                                end
                                print(string.format(" └─ [%s] %s | Production: %s", tostring(slot), displayName, formatNumber(genValue)))
                            end
                        end
                    end
                end
            end
        end
        print("\n" .. string.rep("-", 40))
        print(string.format("Total Pets: %d", totalPets))
    end

    while true do
        task.wait(15)
        printPlotData()
    end
end)

-- ==========================================
-- 6. إشعار بدء التشغيل (Notification)
-- ==========================================
local function showNotification()
    if not playerGui or not playerGui.Parent then return end
    local old = playerGui:FindFirstChild("GoatOptimizerNotif")
    if old then pcall(function() old:Destroy() end) end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoatOptimizerNotif"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 52)
    Frame.Position = UDim2.new(0.5, -150, 0, -80)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "GOAT OPTIMIZER: " .. CurrentMode
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0, 20)
    }):Play()

    task.delay(3, function()
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
    end
end

task.spawn(function()
    task.wait(2)
    queueForNextServer()
end)

pcall(function()
    player.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started then
            queueForNextServer()
        end
    end)
end)
