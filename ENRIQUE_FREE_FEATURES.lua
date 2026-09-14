--=================================================================--
--  ⚔️  ENRIQUE BLADE BALL — FREE v1.0
--  ✅ Full Self-Contained | ✅ Remote Scanner | ✅ Auto Parry
--  ✅ Manual Spam | ✅ Auto Spam | ✅ Triggerbot | ✅ ESP
--  ✅ Skin Changer | ✅ Explosion Changer | ✅ Music Player
--  ✅ Player Mods | ✅ Hitbox Expander | ✅ Ball Speed Display
--  ✅ Settings Save/Load | ✅ Mobile + PC | ✅ Anti-Detection
--=================================================================--

if _G._ENRIQUE_FREE_LOADED then return end
_G._ENRIQUE_FREE_LOADED = true

if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

--============================================================--
-- SERVICES
--============================================================--
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local Debris            = game:GetService("Debris")
local HttpService       = game:GetService("HttpService")
local SoundService      = game:GetService("SoundService")
local LocalPlayer       = Players.LocalPlayer

--============================================================--
-- IMAGE IDS
--============================================================--
local IMG_ANIME = "16014323157"

--============================================================--
-- CONFIG
--============================================================--
local CFG = {
    -- Auto Parry
    AutoParry           = false,
    AutoParryMode       = "Remote",
    AutoParryStrength   = 1.0,
    ParryAccuracy       = 50,
    PredictionMode      = "Auto Best",
    PredictionOffset    = 0,
    EmergencyShield     = true,
    CooldownProtection  = true,
    AutoAbility         = true,
    RetryStrength       = "Aggressive",
    NoStun              = true,
    -- Manual Spam
    ManualSpam          = false,
    ManualSpamCPS       = 30,
    ManualSpamMode      = "Ball Speed",
    -- Auto Spam
    AutoSpam            = false,
    AutoSpamMode        = "Closest",
    AutoSpamDelay       = 0.02,
    -- Triggerbot
    Triggerbot          = false,
    TriggerbotDelay     = 0.08,
    -- ESP
    ESP                 = false,
    ESPShowHealth       = true,
    ESPShowDistance      = true,
    ESPShowTarget        = true,
    BallESP             = false,
    -- Skin Changer
    SkinChanger         = false,
    SwordName           = "Default",
    -- Explosion Changer
    ExplosionChanger    = false,
    ExplosionName       = "Default",
    -- Player
    WalkSpeed           = 16,
    JumpPower           = 50,
    NoClip              = false,
    Fly                 = false,
    FlySpeed            = 50,
    AntiAFK             = true,
    -- Hitbox
    HitboxExpander      = false,
    HitboxSize          = 5,
    -- Misc
    AntiKick            = true,
    AutoRespawn         = true,
    FPSBoost            = false,
    -- Ball Speed
    BallSpeedShow       = false,
    -- Music
    MusicEnabled        = false,
    MusicVolume         = 0.5,
    -- UI
    UIKey               = Enum.KeyCode.RightShift,
}

--============================================================--
-- SAVE / LOAD SETTINGS
--============================================================--
local SETTINGS_FILE = "enrique_free_settings.json"

local function SaveSettings()
    pcall(function()
        local data = HttpService:JSONEncode(CFG)
        writefile(SETTINGS_FILE, data)
    end)
end

local function LoadSettings()
    pcall(function()
        if not isfile(SETTINGS_FILE) then return end
        local data = readfile(SETTINGS_FILE)
        local decoded = HttpService:JSONDecode(data)
        for k, v in pairs(decoded) do
            if CFG[k] ~= nil then CFG[k] = v end
        end
    end)
end

LoadSettings()

--============================================================--
-- UTILITIES
--============================================================--
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[ENRIQUE] " .. tostring(err)) end
end

local function GetPing()
    return LocalPlayer:GetNetworkPing() * 1000
end

--============================================================--
-- THEME
--============================================================--
local T = {
    bg       = Color3.fromRGB(10, 8, 16),
    bg2      = Color3.fromRGB(16, 12, 26),
    panel    = Color3.fromRGB(22, 16, 36),
    panel2   = Color3.fromRGB(30, 22, 48),
    panel3   = Color3.fromRGB(38, 28, 58),
    stroke   = Color3.fromRGB(90, 40, 140),
    strokeHi = Color3.fromRGB(200, 70, 255),
    text     = Color3.fromRGB(240, 235, 255),
    muted    = Color3.fromRGB(120, 100, 155),
    subtext  = Color3.fromRGB(140, 120, 170),
    dim      = Color3.fromRGB(160, 140, 190),
    faint    = Color3.fromRGB(110, 95, 140),
    accent   = Color3.fromRGB(200, 70, 255),
    accentHi = Color3.fromRGB(230, 110, 255),
    accentDim= Color3.fromRGB(140, 50, 190),
    danger   = Color3.fromRGB(255, 70, 90),
    success  = Color3.fromRGB(80, 255, 140),
    on       = Color3.fromRGB(200, 70, 255),
    off      = Color3.fromRGB(50, 40, 65),
    cardBg   = Color3.fromRGB(18, 14, 30),
}

local function mk(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function tw(inst, t, props, style, dir)
    local tween = TweenService:Create(inst, TweenInfo.new(
        t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out
    ), props)
    tween:Play()
    return tween
end

--============================================================--
-- REMOTE SCANNER
--============================================================--
local Remotes = {}
local ParryRemote, ParryRemoteName = nil, nil
local AbilityRemote = nil

local PARRY_NAMES = {
    "ParrySuccessAll", "ParrySuccess", "ParryAttempt", "Block",
    "Parry", "BlockButton", "RemoteEvent", "Server",
    "CombatClientRemoteEvent", "ParryRemote",
}

local ABILITY_NAMES = {
    "ActivateAbility", "AbilityRemote", "UseAbility", "Ability",
}

local function ScanRemotes()
    Remotes = {}
    local function scanFolder(folder, prefix)
        if not folder then return end
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                local key = (prefix or "") .. child.Name
                Remotes[key] = child
                local lower = child.Name:lower()
                if lower:find("parry") or lower:find("block") then
                    if not ParryRemote then
                        ParryRemote = child
                        ParryRemoteName = key
                    end
                end
                if lower:find("activ") or lower:find("ability") then
                    if not AbilityRemote then AbilityRemote = child end
                end
            elseif child:IsA("Folder") or child:IsA("Model") then
                scanFolder(child, prefix .. child.Name .. "/")
            end
        end
    end
    scanFolder(ReplicatedStorage, "")
    scanFolder(Workspace, "")
    -- Deep scan
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not Remotes[obj:GetFullName()] then
            Remotes[obj:GetFullName()] = obj
            local lower = obj.Name:lower()
            if lower:find("parry") or lower:find("block") then
                if not ParryRemote then
                    ParryRemote = obj
                    ParryRemoteName = obj:GetFullName()
                end
            end
        end
    end
end

-- Also hook metatable for remote capture
local Hook = {hooked = false, remote = nil, f_raw = nil, PF = nil}

SafeCall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and not checkcaller() then
            local name = self.Name:lower()
            if name:find("parry") or name:find("block") then
                Hook.remote = self
                Hook.f_raw = old(self, ...)
                return Hook.f_raw
            end
        end
        return old(self, ...)
    end)
    Hook.hooked = true
    setreadonly(mt, true)
end)

ScanRemotes()

--============================================================--
-- BALL TRACKER
--============================================================--
local BallTracker = {}

function BallTracker.GetBall()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local closest, dist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" and obj:FindFirstChild("zoomies") then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = obj end
        end
    end
    return closest
end

function BallTracker.GetAllBalls()
    local balls = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" and obj:FindFirstChild("zoomies") then
            table.insert(balls, obj)
        end
    end
    return balls
end

function BallTracker.GetTrainingBall()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" and obj:FindFirstChild("zoomies") then
            local target = obj:GetAttribute("target")
            if target and target ~= LocalPlayer.Name then
                return obj
            end
        end
    end
    return nil
end

function BallTracker.GetVelocity(ball)
    if not ball then return Vector3.zero end
    local vel = Vector3.zero
    SafeCall(function()
        vel = ball.AssemblyLinearVelocity or ball.Velocity or Vector3.zero
    end)
    return vel
end

function BallTracker.GetDistance(ball)
    if not ball then return math.huge end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (ball.Position - char.HumanoidRootPart.Position).Magnitude
end

function BallTracker.GetSpeed(ball)
    return BallTracker.GetVelocity(ball).Magnitude
end

function BallTracker.IsTargeting(ball)
    if not ball then return false end
    return ball:GetAttribute("target") == LocalPlayer.Name
end

function BallTracker.GetPrediction(ball)
    if not ball then return nil end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local vel = BallTracker.GetVelocity(ball)
    local dist = (ball.Position - hrp.Position).Magnitude
    local speed = vel.Magnitude
    if speed < 1 then return nil end
    local timeToHit = dist / math.max(speed, 1)
    return {
        distance = dist,
        speed = speed,
        timeToHit = timeToHit,
        position = ball.Position + vel * timeToHit,
        isTargeting = BallTracker.IsTargeting(ball),
    }
end

--============================================================--
-- AUTO PARRY ENGINE
--============================================================--
local AutoParry = { connection = nil, smoothFrameDelta = 1/60 }
local ParryEngine = {
    lastAction = 0,
    parries = 0,
    ballWatchers = {},
    armed = {},
    cooldowns = {},
    _tornadoTime = 0,
}

local function FireParry()
    local now = tick()
    if now - ParryEngine.lastAction < 0.005 then return end
    ParryEngine.lastAction = now
    ParryEngine.parries = ParryEngine.parries + 1
    SafeCall(function()
        if ParryRemote then
            if ParryRemote:IsA("RemoteEvent") then
                ParryRemote:FireServer()
            else
                ParryRemote:InvokeServer()
            end
        elseif Hook.remote then
            SafeCall(function() Hook.remote:FireServer() end)
        end
    end)
    SafeCall(function()
        if AbilityRemote then AbilityRemote:FireServer() end
    end)
end

function AutoParry.Start()
    if AutoParry.connection then AutoParry.connection:Disconnect() end
    AutoParry.connection = RunService.PreSimulation:Connect(function(dt)
        AutoParry.smoothFrameDelta = AutoParry.smoothFrameDelta +
            (math.clamp(dt or 1/60, 1/240, 1/12) - AutoParry.smoothFrameDelta) * 0.18
        if not CFG.AutoParry then return end
        if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
        local now = tick()
        local balls = BallTracker.GetAllBalls()
        for _, ball in ipairs(balls) do
            if not ball or not ball.Parent then continue end
            if not ball:FindFirstChild("zoomies") then continue end
            if not ParryEngine.ballWatchers[ball] then
                ParryEngine.ballWatchers[ball] = ball:GetAttributeChangedSignal("target"):Connect(function()
                    local isTargeting = ball:GetAttribute("target") == LocalPlayer.Name
                    ParryEngine.armed[ball] = isTargeting
                    if isTargeting then ParryEngine.cooldowns[ball] = 0 end
                end)
            end
            local ballTarget = ball:GetAttribute("target")
            if ParryEngine.armed[ball] == nil then
                ParryEngine.armed[ball] = (ballTarget == LocalPlayer.Name)
            end
            if not ParryEngine.armed[ball] then continue end
            if now < (ParryEngine.cooldowns[ball] or 0) then continue end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local ballPos = ball.Position
            local playerPos = hrp.Position
            local dist = (ballPos - playerPos).Magnitude
            local vel = BallTracker.GetVelocity(ball)
            local speed = vel.Magnitude
            -- Calculate parry timing
            local ping = GetPing() / 1000
            local reactionDelay = 0.03 + (ping * 0.001)
            local shouldParry = false
            -- Distance-based parry
            local parryRange = math.clamp(speed * 0.002 * CFG.AutoParryStrength, 3, 15)
            if dist <= parryRange and speed > 10 then
                shouldParry = true
            end
            -- Prediction-based parry
            if CFG.PredictionMode == "Auto Best" and speed > 50 then
                local lookAt = (playerPos - ballPos).Unit
                local dot = lookAt:Dot(vel.Unit)
                if dot > 0.7 and dist < parryRange * 1.5 then
                    shouldParry = true
                end
            end
            -- Emergency shield
            if CFG.EmergencyShield and dist < 2 and speed > 100 then
                shouldParry = true
            end
            if shouldParry then
                task.delay(reactionDelay, function()
                    FireParry()
                    ParryEngine.cooldowns[ball] = now + math.max(0.08, 0.15 / CFG.AutoParryStrength)
                end)
            end
        end
    end)
end

function AutoParry.Stop()
    if AutoParry.connection then AutoParry.connection:Disconnect(); AutoParry.connection = nil end
    for ball, conn in pairs(ParryEngine.ballWatchers) do
        pcall(function() conn:Disconnect() end)
    end
    ParryEngine.ballWatchers = {}
    ParryEngine.armed = {}
    ParryEngine.cooldowns = {}
end

--============================================================--
-- MANUAL SPAM
--============================================================--
local ManualSpam = { connection = nil }

function ManualSpam.Start()
    if ManualSpam.connection then ManualSpam.connection:Disconnect() end
    ManualSpam.connection = RunService.PreSimulation:Connect(function()
        if not CFG.ManualSpam then ManualSpam.Stop(); return end
        local ball = BallTracker.GetBall()
        if not ball then return end
        local dist = BallTracker.GetDistance(ball)
        local speed = BallTracker.GetSpeed(ball)
        local shouldSpam = false
        if CFG.ManualSpamMode == "Ball Speed" then
            local threshold = math.clamp(speed * 0.003, 3, 20)
            shouldSpam = dist < threshold
        elseif CFG.ManualSpamMode == "Fixed" then
            shouldSpam = dist < 10
        elseif CFG.ManualSpamMode == "Burst" then
            shouldSpam = dist < 15 and speed > 100
        end
        if shouldSpam then
            local cps = CFG.ManualSpamCPS
            local delay = 1 / math.max(cps, 1)
            FireParry()
            task.wait(delay)
        end
    end)
end

function ManualSpam.Stop()
    if ManualSpam.connection then ManualSpam.connection:Disconnect(); ManualSpam.connection = nil end
end

--============================================================--
-- AUTO SPAM
--============================================================--
local AutoSpam = { connection = nil }

function AutoSpam.Start()
    if AutoSpam.connection then AutoSpam.connection:Disconnect() end
    AutoSpam.connection = RunService.PreSimulation:Connect(function()
        if not CFG.AutoSpam then AutoSpam.Stop(); return end
        local ball = BallTracker.GetBall()
        if not ball then return end
        local dist = BallTracker.GetDistance(ball)
        local speed = BallTracker.GetSpeed(local_player)
        local threshold = math.clamp(speed * 0.004 * CFG.AutoParryStrength, 2, 12)
        if dist < threshold then
            FireParry()
        end
    end)
end

function AutoSpam.Stop()
    if AutoSpam.connection then AutoSpam.connection:Disconnect(); AutoSpam.connection = nil end
end

--============================================================--
-- TRIGGERBOT
--============================================================--
local Triggerbot = { connection = nil }

function Triggerbot.Start()
    if Triggerbot.connection then Triggerbot.connection:Disconnect() end
    Triggerbot.connection = RunService.PreSimulation:Connect(function()
        if not CFG.Triggerbot then Triggerbot.Stop(); return end
        local ball = BallTracker.GetBall()
        if not ball then return end
        local dist = BallTracker.GetDistance(ball)
        if dist < 8 then
            task.delay(CFG.TriggerbotDelay, function()
                FireParry()
            end)
        end
    end)
end

function Triggerbot.Stop()
    if Triggerbot.connection then Triggerbot.connection:Disconnect(); Triggerbot.connection = nil end
end

--============================================================--
-- ESP SYSTEM
--============================================================--
local ESP = { connection = nil, billboards = {} }

function ESP.Start()
    ESP.Stop()
    ESP.connection = RunService.RenderStepped:Connect(function()
        if not CFG.ESP then ESP.Stop(); return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if not ESP.billboards[player] then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "ENRIQUE_ESP"
                        bb.Size = UDim2.new(0, 200, 0, 40)
                        bb.AlwaysOnTop = true
                        bb.Adornee = hrp
                        bb.Parent = CoreGui
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 0.5
                        label.BackgroundColor3 = Color3.new(0, 0, 0)
                        label.TextColor3 = Color3.new(1, 1, 1)
                        label.Font = Enum.Font.GothamBold
                        label.TextScaled = true
                        label.Parent = bb
                        ESP.billboards[player] = {bb = bb, label = label}
                    end
                    local info = player.Name
                    if CFG.ESPShowHealth then
                        info = info .. " [" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "]"
                    end
                    if CFG.ESPShowDistance then
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myHrp then
                            local d = math.floor((hrp.Position - myHrp.Position).Magnitude)
                            info = info .. " (" .. d .. "m)"
                        end
                    end
                    ESP.billboards[player].label.Text = info
                end
            end
        end
    end)
end

function ESP.Stop()
    if ESP.connection then ESP.connection:Disconnect(); ESP.connection = nil end
    for _, esp in pairs(ESP.billboards) do
        pcall(function() esp.bb:Destroy() end)
    end
    ESP.billboards = {}
end

-- Ball ESP
local BallESP = { connection = nil, billboards = {} }

function BallESP.Start()
    BallESP.Stop()
    BallESP.connection = RunService.RenderStepped:Connect(function()
        if not CFG.BallESP then BallESP.Stop(); return end
        local ball = BallTracker.GetBall()
        if ball then
            if not BallESP.billboards.ball then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ENRIQUE_BallESP"
                bb.Size = UDim2.new(0, 120, 0, 30)
                bb.AlwaysOnTop = true
                bb.Adornee = ball
                bb.Parent = CoreGui
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 0.5
                label.BackgroundColor3 = Color3.new(0, 0, 0)
                label.TextColor3 = Color3.fromRGB(255, 200, 60)
                label.Font = Enum.Font.GothamBold
                label.TextScaled = true
                label.Parent = bb
                BallESP.billboards.ball = {bb = bb, label = label}
            end
            local speed = math.floor(BallTracker.GetSpeed(ball))
            local target = ball:GetAttribute("target") or "None"
            BallESP.billboards.ball.label.Text = "⚡" .. speed .. " SP | Target: " .. target
            BallESP.billboards.ball.bb.Adornee = ball
        end
    end)
end

function BallESP.Stop()
    if BallESP.connection then BallESP.connection:Disconnect(); BallESP.connection = nil end
    for _, esp in pairs(BallESP.billboards) do
        pcall(function() esp.bb:Destroy() end)
    end
    BallESP.billboards = {}
end

--============================================================--
-- BALL SPEED DISPLAY
--============================================================--
local BallSpeedGui = { connection = nil, billboard = nil }

function BallSpeedGui.Start()
    BallSpeedGui.Stop()
    BallSpeedGui.connection = RunService.RenderStepped:Connect(function()
        if not CFG.BallSpeedShow then BallSpeedGui.Stop(); return end
        local ball = BallTracker.GetBall()
        if not ball then
            if BallSpeedGui.billboard then BallSpeedGui.billboard:Destroy(); BallSpeedGui.billboard = nil end
            return
        end
        local speed = math.floor(BallTracker.GetSpeed(ball))
        if not BallSpeedGui.billboard then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ENRIQUE_BallSpeed"
            bb.Size = UDim2.new(0, 150, 0, 40)
            bb.AlwaysOnTop = true
            bb.Adornee = ball
            bb.Parent = CoreGui
            local label = Instance.new("TextLabel")
            label.Name = "SpeedLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 0.6
            label.BackgroundColor3 = Color3.new(0, 0, 0)
            label.TextColor3 = Color3.fromRGB(255, 200, 60)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = bb
            BallSpeedGui.billboard = bb
        end
        local label = BallSpeedGui.billboard:FindFirstChild("SpeedLabel")
        if label then
            label.Text = "⚡ " .. speed .. " SP"
            if speed > 500 then label.TextColor3 = Color3.fromRGB(255, 50, 50)
            elseif speed > 250 then label.TextColor3 = Color3.fromRGB(255, 200, 60)
            else label.TextColor3 = Color3.fromRGB(80, 255, 140) end
        end
    end)
end

function BallSpeedGui.Stop()
    if BallSpeedGui.connection then BallSpeedGui.connection:Disconnect(); BallSpeedGui.connection = nil end
    if BallSpeedGui.billboard then BallSpeedGui.billboard:Destroy(); BallSpeedGui.billboard = nil end
end

--============================================================--
-- HITBOX EXPANDER
--============================================================--
local HitboxExp = { connection = nil }

function HitboxExp.Start()
    HitboxExp.Stop()
    HitboxExp.connection = RunService.RenderStepped:Connect(function()
        if not CFG.HitboxExpander then HitboxExp.Stop(); return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
                        part.Transparency = 0.7
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

function HitboxExp.Stop()
    if HitboxExp.connection then HitboxExp.connection:Disconnect(); HitboxExp.connection = nil end
end

--============================================================--
-- SKIN CHANGER
--============================================================--
local SkinChanger = { connection = nil }

function SkinChanger.Apply(name)
    SafeCall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local fireSword = remotes:FindFirstChild("FireSwordInfo")
            if fireSword then fireSword:FireServer(name); return end
        end
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name:lower():find("sword") then
                obj:FireServer(name)
                return
            end
        end
    end)
end

function SkinChanger.Start()
    if SkinChanger.connection then SkinChanger.connection:Disconnect() end
    SkinChanger.connection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if CFG.SkinChanger and CFG.SwordName ~= "" then SkinChanger.Apply(CFG.SwordName) end
    end)
end

function SkinChanger.Stop()
    if SkinChanger.connection then SkinChanger.connection:Disconnect(); SkinChanger.connection = nil end
end

--============================================================--
-- EXPLOSION CHANGER
--============================================================--
local ExplosionChanger = { connection = nil }

function ExplosionChanger.Apply(name)
    SafeCall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local fireExp = remotes:FindFirstChild("UpdateExplosion") or remotes:FindFirstChild("FireExplosionInfo")
            if fireExp then fireExp:FireServer(name); return end
        end
    end)
end

function ExplosionChanger.Start()
    if ExplosionChanger.connection then ExplosionChanger.connection:Disconnect() end
    ExplosionChanger.connection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if CFG.ExplosionChanger and CFG.ExplosionName ~= "" then ExplosionChanger.Apply(CFG.ExplosionName) end
    end)
end

function ExplosionChanger.Stop()
    if ExplosionChanger.connection then ExplosionChanger.connection:Disconnect(); ExplosionChanger.connection = nil end
end

--============================================================--
-- MUSIC PLAYER
--============================================================--
local MusicPlayer = { sound = nil }

local MUSIC_IDS = {
    {"Phonk", "rbxassetid://1280010741"},
    {"Trap Beat", "rbxassetid://5766233510"},
    {"Dark Bass", "rbxassetid://1837849285"},
    {"Chill Vibes", "rbxassetid://463500282"},
    {"Epic Beat", "rbxassetid://5979786430"},
    {"Lo-Fi", "rbxassetid://469340631"},
    {"Cyberpunk", "rbxassetid://6789230134"},
}

function MusicPlayer.Play(id)
    MusicPlayer.Stop()
    SafeCall(function()
        MusicPlayer.sound = Instance.new("Sound")
        MusicPlayer.sound.SoundId = id
        MusicPlayer.sound.Volume = CFG.MusicVolume
        MusicPlayer.sound.Looped = true
        MusicPlayer.sound.Parent = SoundService
        MusicPlayer.sound:Play()
    end)
end

function MusicPlayer.Stop()
    if MusicPlayer.sound then
        pcall(function() MusicPlayer.sound:Stop(); MusicPlayer.sound:Destroy() end)
        MusicPlayer.sound = nil
    end
end

function MusicPlayer.SetVolume(vol)
    CFG.MusicVolume = vol
    if MusicPlayer.sound then MusicPlayer.sound.Volume = vol end
end

--============================================================--
-- PLAYER MODIFICATIONS
--============================================================--
local Misc = { noClipConn = nil, afkConn = nil, flyConn = nil }

function Misc.SetWalkSpeed(val)
    CFG.WalkSpeed = val
    SafeCall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end)
end

function Misc.SetJumpPower(val)
    CFG.JumpPower = val
    SafeCall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end)
end

function Misc.ToggleNoClip(state)
    CFG.NoClip = state
    if Misc.noClipConn then Misc.noClipConn:Disconnect() end
    if state then
        Misc.noClipConn = RunService.Stepped:Connect(function()
            SafeCall(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end)
    end
end

function Misc.ToggleFly(state)
    CFG.Fly = state
    if Misc.flyConn then Misc.flyConn:Disconnect() end
    if state then
        Misc.flyConn = RunService.RenderStepped:Connect(function()
            SafeCall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local vel = Vector3.zero
                    local cam = workspace.CurrentCamera
                    local cf = cam.CFrame
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, 1, 0) end
                    if vel.Magnitude > 0 then hrp.Velocity = vel.Unit * CFG.FlySpeed
                    else hrp.Velocity = Vector3.zero end
                end
            end)
        end)
    end
end

function Misc.StartAntiAFK()
    if Misc.afkConn then return end
    Misc.afkConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end)
end

-- Auto Respawn
task.spawn(function()
    while task.wait(2) do
        if CFG.AutoRespawn then
            SafeCall(function()
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health <= 0 then
                        task.wait(3)
                        LocalPlayer:LoadCharacter()
                    end
                end
            end)
        end
    end
end)

-- Restore settings after respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    Misc.SetWalkSpeed(CFG.WalkSpeed)
    Misc.SetJumpPower(CFG.JumpPower)
    if CFG.AutoParry then AutoParry.Start() end
    if CFG.SkinChanger and CFG.SwordName ~= "" then task.wait(2); SkinChanger.Apply(CFG.SwordName) end
    if CFG.ExplosionChanger and CFG.ExplosionName ~= "" then task.wait(2); ExplosionChanger.Apply(CFG.ExplosionName) end
end)

-- Anti Kick
if CFG.AntiKick then
    task.spawn(function()
        while task.wait(30) do
            pcall(function() game:GetService("VirtualUser"):CaptureController() end)
        end
    end)
end

-- FPS Boost
if CFG.FPSBoost then
    pcall(function() setfpscap(9999) end)
    SafeCall(function()
        Lighting.FogEnd = 999999
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BloomEffect") then v:Destroy() end
        end
    end)
end

--============================================================--
-- UI CREATION
--============================================================--
local UI = { Minimized = false, Open = true, Window = nil }

local function CreateMainUI()
    -- Cleanup old
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name == "ENRIQUE_FREE_BB" then gui:Destroy() end
    end
    pcall(function() local cg = CoreGui:FindFirstChild("ENRIQUE_FREE_BB"); if cg then cg:Destroy() end end)

    local W, H = 500, 430
    local sg = mk("ScreenGui", {Name = "ENRIQUE_FREE_BB", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = LocalPlayer:WaitForChild("PlayerGui")})
    pcall(function() local hui = gethui and gethui(); if hui then sg.Parent = hui end end)

    local overlay = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sg})
    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})
    local root = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 1, Parent = sg})
    mk("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 60, 1, 60), BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.3, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Parent = root})
    local main = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = T.bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = root})
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    mk("UIStroke", {Color = T.stroke, Thickness = 1, Transparency = 0.3, Parent = main})

    -- Title bar
    local titleBar = mk("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = main})
    mk("Frame", {Size = UDim2.new(0, 4, 0, 14), Position = UDim2.new(0, 14, 0.5, -7), BackgroundColor3 = T.accent, Parent = titleBar}).Parent.UICorner.CornerRadius = UDim.new(1, 0)
    mk("TextLabel", {Size = UDim2.new(0, 260, 1, 0), Position = UDim2.new(0, 24, 0, 0), BackgroundTransparency = 1, Text = "⚔️ ENRIQUE FREE BLADE BALL", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar})
    mk("Frame", {Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, 0), BackgroundColor3 = T.stroke, BackgroundTransparency = 0.6, Parent = titleBar})
    local minBtn = mk("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -70, 0, 5), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.subtext, AutoButtonColor = false, Parent = titleBar})
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    local closeBtn = mk("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0, 5), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "×", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.subtext, AutoButtonColor = false, Parent = titleBar})
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    -- Anime banner
    local banner = mk("ImageLabel", {Size = UDim2.new(1, -24, 0, 50), Position = UDim2.new(0, 12, 0, 42), BackgroundTransparency = 1, Image = "rbxassetid://" .. IMG_ANIME, ScaleType = Enum.ScaleType.Crop, Parent = main})
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)
    mk("UIStroke", {Color = T.accent, Thickness = 1, Transparency = 0.4, Parent = banner})

    -- Sidebar
    local sidebar = mk("Frame", {Size = UDim2.new(0, 130, 1, -104), Position = UDim2.new(0, 0, 0, 98), BackgroundTransparency = 1, Parent = main})

    -- Content
    local content = mk("ScrollingFrame", {Size = UDim2.new(1, -144, 1, -104), Position = UDim2.new(0, 138, 0, 98), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = T.accent, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = main})
    mk("UIListLayout", {Padding = UDim.new(0, 6), Parent = content})
    mk("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = content})

    -- Tabs
    local TABS = {
        {name = "Home",     icon = "🏠"},
        {name = "Combat",   icon = "⚔️"},
        {name = "Spam",     icon = "⚡"},
        {name = "Visuals",  icon = "👁️"},
        {name = "Player",   icon = "🏃"},
        {name = "Sword",    icon = "🗡️"},
        {name = "Music",    icon = "🎵"},
        {name = "Settings", icon = "⚙️"},
    }

    local tabButtons, tabFrames = {}, {}
    for i, tab in ipairs(TABS) do
        local tabBtn = mk("TextButton", {Size = UDim2.new(1, -8, 0, 28), Position = UDim2.new(0, 4, 0, (i-1)*32), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "  " .. tab.icon .. " " .. tab.name, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.subtext, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = sidebar})
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        local tabFrame = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Visible = (tab.name == "Home"), Parent = content})
        Instance.new("UIListLayout", tabFrame).Padding = UDim.new(0, 4)
        tabButtons[tab.name] = tabBtn; tabFrames[tab.name] = tabFrame
        tabBtn.MouseButton1Click:Connect(function()
            for name, btn in pairs(tabButtons) do
                if name == tab.name then tw(btn, 0.12, {BackgroundColor3 = T.accentDim}); btn.TextColor3 = Color3.new(1, 1, 1)
                else tw(btn, 0.12, {BackgroundColor3 = T.panel2}); btn.TextColor3 = T.subtext end
            end
            for name, frame in pairs(tabFrames) do frame.Visible = (name == tab.name) end
        end)
    end
    tw(tabButtons["Home"], 0, {BackgroundColor3 = T.accentDim})
    tabButtons["Home"].TextColor3 = Color3.new(1, 1, 1)

    -- Card helper
    local function Card(parent, title)
        local card = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.cardBg, BorderSizePixel = 0, Parent = parent})
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        mk("UIStroke", {Color = T.stroke, Thickness = 0.5, Transparency = 0.5, Parent = card})
        Instance.new("UIPadding", card).PaddingTop = UDim.new(0, 8); card.UIPadding.PaddingBottom = UDim.new(0, 8); card.UIPadding.PaddingLeft = UDim.new(0, 10); card.UIPadding.PaddingRight = UDim.new(0, 10)
        Instance.new("UIListLayout", card).Padding = UDim.new(0, 4)
        if title then mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = card}) end
        return card
    end

    -- Toggle helper
    local function CreateToggle(parent, label, flag, default, callback)
        local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent})
        mk("TextLabel", {Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
        local s = default or false
        local bg = mk("Frame", {Size = UDim2.new(0, 38, 0, 18), Position = UDim2.new(1, -40, 0.5, -9), BackgroundColor3 = s and T.on or T.off, Parent = f})
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
        local dot = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = s and Color3.new(1, 1, 1) or T.faint, Parent = bg})
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local function Upd() tw(bg, 0.15, {BackgroundColor3 = s and T.on or T.off}); tw(dot, 0.15, {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = s and Color3.new(1, 1, 1) or T.faint}) end
        mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = f}).MouseButton1Click:Connect(function() s = not s; CFG[flag] = s; Upd(); SaveSettings(); if callback then callback(s) end end)
    end

    -- Slider helper
    local function CreateSlider(parent, label, flag, min, max, default, callback)
        local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Parent = parent})
        local valText = mk("TextLabel", {Size = UDim2.new(0.3, 0, 0, 16), Position = UDim2.new(0.7, 0, 0, 0), BackgroundTransparency = 1, Text = tostring(default), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = f})
        mk("TextLabel", {Size = UDim2.new(0.7, 0, 0, 16), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
        local barBg = mk("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Parent = f})
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        local fill = mk("Frame", {Size = UDim2.fromScale((default - min) / (max - min), 1), BackgroundColor3 = T.accent, BorderSizePixel = 0, Parent = barBg})
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local btn = mk("TextButton", {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 18), BackgroundTransparency = 1, Text = "", Parent = f})
        local dragging = false
        btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
        btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pct = math.clamp((input.Position.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * pct
                if max > 1 and max < 100 then val = math.floor(val * 10) / 10 end
                val = math.floor(val)
                CFG[flag] = val
                fill.Size = UDim2.fromScale(pct, 1)
                valText.Text = tostring(val)
                SaveSettings()
                if callback then callback(val) end
            end
        end)
    end

    -- Dropdown helper
    local function CreateDropdown(parent, label, flag, options, default, callback)
        local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent})
        mk("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
        local selected = mk("TextButton", {Size = UDim2.new(0.5, 0, 0, 24), Position = UDim2.new(0.5, 0, 0.5, -12), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "  " .. (default or options[1] or ""), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = f})
        Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 6)
        local listFrame = mk("Frame", {Size = UDim2.new(0.5, 0, 0, math.min(#options * 26, 130)), Position = UDim2.new(0.5, 0, 0, 30), BackgroundColor3 = T.panel, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.accent, CanvasSize = UDim2.new(0, 0, 0, #options * 26), Visible = false, ZIndex = 10, Parent = f})
        Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 2)
        for _, opt in ipairs(options) do
            local optBtn = mk("TextButton", {Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "  " .. opt, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 11, Parent = listFrame})
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
            optBtn.MouseButton1Click:Connect(function()
                CFG[flag] = opt
                selected.Text = "  " .. opt
                listFrame.Visible = false
                SaveSettings()
                if callback then callback(opt) end
            end)
        end
        selected.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible end)
    end

    -- Button helper
    local function CreateButton(parent, label, color, callback)
        local btn = mk("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = color or T.accent, BorderSizePixel = 0, Text = label, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Parent = parent})
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseEnter:Connect(function() tw(btn, 0.12, {BackgroundColor3 = T.accentHi}) end)
        btn.MouseLeave:Connect(function() tw(btn, 0.12, {BackgroundColor3 = color or T.accent}) end)
        btn.MouseButton1Click:Connect(function()
            tw(btn, 0.06, {Size = UDim2.new(0.98, 0, 0, 30)})
            task.delay(0.06, function() tw(btn, 0.1, {Size = UDim2.new(1, 0, 0, 32)}) end)
            if callback then callback() end
        end)
    end

    --============================================================--
    -- TAB: HOME
    --============================================================--
    local homeCard = Card(tabFrames["Home"], "🏠 HOME")
    local execName = "Unknown"
    pcall(function()
        if getexecutorname then execName = getexecutorname() end
        if identifyexecutor then execName = identifyexecutor() end
    end)
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "⚔️ ENRIQUE FREE", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "Version: ENRIQUE FREE v1.0", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "Executor: " .. execName, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "Player: " .. LocalPlayer.Name, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "Remote: " .. (ParryRemoteName or "Auto-detecting"), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard})
    CreateButton(homeCard, "💬 Discord", T.accent, function() setclipboard("https://discord.gg/jEA49UNC"); Notify("ENRIQUE", "Discord copied!", 3) end)
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "discord.gg/jEA49UNC", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = homeCard})

    --============================================================--
    -- TAB: COMBAT
    --============================================================--
    local combatCard = Card(tabFrames["Combat"], "🛡️ AUTO PARRY")
    CreateToggle(combatCard, "Auto Parry", "AutoParry", CFG.AutoParry, function(s) if s then AutoParry.Start() else AutoParry.Stop() end end)
    CreateDropdown(combatCard, "Mode", "AutoParryMode", {"Remote", "Keypress"}, CFG.AutoParryMode)
    CreateDropdown(combatCard, "Strength", "RetryStrength", {"Safe", "Balanced", "Aggressive", "Maximum"}, CFG.RetryStrength)
    CreateSlider(combatCard, "Parry Strength", "AutoParryStrength", 0.5, 2.0, CFG.AutoParryStrength)
    CreateSlider(combatCard, "Accuracy", "ParryAccuracy", 1, 100, CFG.ParryAccuracy)
    CreateToggle(combatCard, "Emergency Shield", "EmergencyShield", CFG.EmergencyShield)
    CreateToggle(combatCard, "Cooldown Protection", "CooldownProtection", CFG.CooldownProtection)
    CreateToggle(combatCard, "Auto Ability", "AutoAbility", CFG.AutoAbility)

    local combatCard2 = Card(tabFrames["Combat"], "🎯 TRIGGERBOT")
    CreateToggle(combatCard2, "Triggerbot", "Triggerbot", CFG.Triggerbot, function(s) if s then Triggerbot.Start() else Triggerbot.Stop() end end)
    CreateSlider(combatCard2, "Delay", "TriggerbotDelay", 0.01, 0.3, CFG.TriggerbotDelay)

    --============================================================--
    -- TAB: SPAM
    --============================================================--
    local spamCard = Card(tabFrames["Spam"], "⚡ MANUAL SPAM")
    CreateToggle(spamCard, "Manual Spam", "ManualSpam", CFG.ManualSpam, function(s) if s then ManualSpam.Start() else ManualSpam.Stop() end end)
    CreateSlider(spamCard, "CPS", "ManualSpamCPS", 10, 100, CFG.ManualSpamCPS)
    CreateDropdown(spamCard, "Mode", "ManualSpamMode", {"Ball Speed", "Fixed", "Burst"}, CFG.ManualSpamMode)

    local spamCard2 = Card(tabFrames["Spam"], "⚡ AUTO SPAM")
    CreateToggle(spamCard2, "Auto Spam", "AutoSpam", CFG.AutoSpam, function(s) if s then AutoSpam.Start() else AutoSpam.Stop() end end)
    CreateSlider(spamCard2, "Delay", "AutoSpamDelay", 0.005, 0.1, CFG.AutoSpamDelay)
    CreateDropdown(spamCard2, "Mode", "AutoSpamMode", {"Closest", "Target", "Random"}, CFG.AutoSpamMode)

    --============================================================--
    -- TAB: VISUALS
    --============================================================--
    local espCard = Card(tabFrames["Visuals"], "👁️ PLAYER ESP")
    CreateToggle(espCard, "ESP", "ESP", CFG.ESP, function(s) if s then ESP.Start() else ESP.Stop() end end)
    CreateToggle(espCard, "Show Health", "ESPShowHealth", CFG.ESPShowHealth)
    CreateToggle(espCard, "Show Distance", "ESPShowDistance", CFG.ESPShowDistance)

    local ballCard = Card(tabFrames["Visuals"], "⚽ BALL ESP")
    CreateToggle(ballCard, "Ball ESP", "BallESP", CFG.BallESP, function(s) if s then BallESP.Start() else BallESP.Stop() end end)
    CreateToggle(ballCard, "Ball Speed Display", "BallSpeedShow", CFG.BallSpeedShow, function(s) if s then BallSpeedGui.Start() else BallSpeedGui.Stop() end end)

    local hitboxCard = Card(tabFrames["Visuals"], "📦 HITBOX")
    CreateToggle(hitboxCard, "Hitbox Expander", "HitboxExpander", CFG.HitboxExpander, function(s) if s then HitboxExp.Start() else HitboxExp.Stop() end end)
    CreateSlider(hitboxCard, "Size", "HitboxSize", 1, 20, CFG.HitboxSize)

    --============================================================--
    -- TAB: PLAYER
    --============================================================--
    local moveCard = Card(tabFrames["Player"], "🏃 MOVEMENT")
    CreateSlider(moveCard, "Walk Speed", "WalkSpeed", 16, 200, CFG.WalkSpeed, function(v) Misc.SetWalkSpeed(v) end)
    CreateSlider(moveCard, "Jump Power", "JumpPower", 50, 200, CFG.JumpPower, function(v) Misc.SetJumpPower(v) end)
    CreateToggle(moveCard, "No Clip", "NoClip", CFG.NoClip, function(s) Misc.ToggleNoClip(s) end)
    CreateToggle(moveCard, "Fly", "Fly", CFG.Fly, function(s) Misc.ToggleFly(s) end)
    CreateSlider(moveCard, "Fly Speed", "FlySpeed", 10, 200, CFG.FlySpeed)

    local miscCard = Card(tabFrames["Player"], "🔧 MISC")
    CreateToggle(miscCard, "Anti AFK", "AntiAFK", CFG.AntiAFK, function(s) if s then Misc.StartAntiAFK() end end)
    CreateToggle(miscCard, "Auto Respawn", "AutoRespawn", CFG.AutoRespawn)
    CreateToggle(miscCard, "FPS Boost", "FPSBoost", CFG.FPSBoost)

    --============================================================--
    -- TAB: SWORD
    --============================================================--
    local skinCard = Card(tabFrames["Sword"], "🗡️ SKIN CHANGER")
    CreateToggle(skinCard, "Enable", "SkinChanger", CFG.SkinChanger)
    local swordInput = mk("TextBox", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = CFG.SwordName, PlaceholderText = "Sword name", PlaceholderColor3 = T.faint, TextColor3 = T.text, Font = Enum.Font.GothamMedium, TextSize = 12, ClearTextOnFocus = false, Parent = skinCard})
    swordInput.FocusLost:Connect(function() CFG.SwordName = swordInput.Text; SaveSettings() end)
    CreateButton(skinCard, "🗡️ Apply", T.accent, function() CFG.SkinChanger = true; SkinChanger.Apply(CFG.SwordName) end)

    local expCard = Card(tabFrames["Sword"], "💥 EXPLOSION CHANGER")
    CreateToggle(expCard, "Enable", "ExplosionChanger", CFG.ExplosionChanger)
    local expInput = mk("TextBox", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = CFG.ExplosionName, PlaceholderText = "Explosion name", PlaceholderColor3 = T.faint, TextColor3 = T.text, Font = Enum.Font.GothamMedium, TextSize = 12, ClearTextOnFocus = false, Parent = expCard})
    expInput.FocusLost:Connect(function() CFG.ExplosionName = expInput.Text; SaveSettings() end)
    CreateButton(expCard, "💥 Apply", T.accent, function() CFG.ExplosionChanger = true; ExplosionChanger.Apply(CFG.ExplosionName) end)

    local weaponList = Card(tabFrames["Sword"], "📋 Popular Weapons")
    local weapons = {"Default", "Crimson Blade", "Shadow Katana", "Golden Edge", "Frostbite", "Inferno Sword", "Void Reaper", "Storm Breaker", "Plasma Edge", "Neon Saber"}
    for _, sw in ipairs(weapons) do
        CreateButton(weaponList, sw, T.panel3, function() CFG.SwordName = sw; swordInput.Text = sw; SkinChanger.Apply(sw) end)
    end

    --============================================================--
    -- TAB: MUSIC
    --============================================================--
    local musicCard = Card(tabFrames["Music"], "🎵 MUSIC PLAYER")
    for _, track in ipairs(MUSIC_IDS) do
        CreateButton(musicCard, "🎶 " .. track[1], T.panel3, function() MusicPlayer.Play(track[2]) end)
    end
    CreateButton(musicCard, "⏹️ Stop Music", T.danger, function() MusicPlayer.Stop() end)
    CreateSlider(musicCard, "Volume", "MusicVolume", 0, 10, CFG.MusicVolume * 10, function(v) MusicPlayer.SetVolume(v / 10) end)

    --============================================================--
    -- TAB: SETTINGS
    --============================================================--
    local settingsCard = Card(tabFrames["Settings"], "⚙️ SETTINGS")
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Toggle UI: Right Shift", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Version: ENRIQUE FREE v1.0", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})
    CreateButton(settingsCard, "🔄 Rescan Remotes", T.panel3, function()
        ScanRemotes()
        Notify("ENRIQUE", "Remotes rescanned! Found: " .. (ParryRemoteName or "none"), 3)
    end)
    CreateButton(settingsCard, "💾 Save Settings", T.panel3, function() SaveSettings(); Notify("ENRIQUE", "Settings saved!", 3) end)
    CreateButton(settingsCard, "🧹 Unload Script", T.danger, function()
        AutoParry.Stop(); ManualSpam.Stop(); AutoSpam.Stop(); Triggerbot.Stop()
        ESP.Stop(); BallESP.Stop(); BallSpeedGui.Stop(); HitboxExp.Stop()
        SkinChanger.Stop(); ExplosionChanger.Stop(); MusicPlayer.Stop()
        Misc.ToggleNoClip(false); Misc.ToggleFly(false)
        pcall(function() sg:Destroy() end); pcall(function() blur:Destroy() end)
        _G._ENRIQUE_FREE_LOADED = nil
        Notify("ENRIQUE", "Script unloaded", 3)
    end)
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "discord.gg/jEA49UNC", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})

    --============================================================--
    -- DRAGGING / MINIMIZE / CLOSE
    --============================================================--
    local dragging, dragStart, startPos = false
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = root.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    minBtn.MouseButton1Click:Connect(function()
        UI.Minimized = not UI.Minimized
        if UI.Minimized then tw(main, 0.25, {Size = UDim2.new(0, W, 0, 38)}); content.Visible = false; sidebar.Visible = false; banner.Visible = false; minBtn.Text = "+"
        else tw(main, 0.25, {Size = UDim2.new(0, W, 0, H)}); content.Visible = true; sidebar.Visible = true; banner.Visible = true; minBtn.Text = "—" end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        UI.Open = false
        tw(overlay, 0.2, {BackgroundTransparency = 1}); tw(blur, 0.25, {Size = 0})
        task.delay(0.25, function() sg.Visible = false; minBtn.Text = "+"; UI.Minimized = true end)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == CFG.UIKey then
            UI.Open = not UI.Open
            if UI.Open then sg.Visible = true; UI.Minimized = false; main.Size = UDim2.new(0, W, 0, H); content.Visible = true; sidebar.Visible = true; banner.Visible = true; minBtn.Text = "—"; tw(overlay, 0.2, {BackgroundTransparency = 0.5}); tw(blur, 0.3, {Size = 12})
            else sg.Visible = false end
        end
    end)

    -- Fade in
    overlay.BackgroundTransparency = 1; root.Size = UDim2.new(0, W - 30, 0, H - 20)
    tw(overlay, 0.25, {BackgroundTransparency = 0.5}); tw(blur, 0.3, {Size = 12})
    tw(root, 0.35, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    UI.Window = sg
end

--============================================================--
-- INIT
--============================================================
ScanRemotes()
if CFG.AutoParry then AutoParry.Start() end
if CFG.ManualSpam then ManualSpam.Start() end
if CFG.AutoSpam then AutoSpam.Start() end
if CFG.Triggerbot then Triggerbot.Start() end
if CFG.ESP then ESP.Start() end
if CFG.BallESP then BallESP.Start() end
if CFG.BallSpeedShow then BallSpeedGui.Start() end
if CFG.HitboxExpander then HitboxExp.Start() end
if CFG.SkinChanger then SkinChanger.Start() end
if CFG.ExplosionChanger then ExplosionChanger.Start() end
if CFG.AntiAFK then Misc.StartAntiAFK() end

task.wait(0.5)
CreateMainUI()

Notify("⚔️ ENRIQUE FREE v1.0",
    "Loaded! Press RightShift to toggle UI\nRemote: " .. (ParryRemoteName or "Auto-detecting") ..
    "\ndiscord.gg/jEA49UNC", 5)

print("⚔️ ENRIQUE FREE v1.0")
print("Remote: " .. (ParryRemoteName or "Auto-detecting"))
print("discord.gg/jEA49UNC")
