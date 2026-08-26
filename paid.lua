--=================================================================--
--  ⚔️  ENRIQUE BLADE BALL — PAID v1.0
--  ✅ 完全独立 | ✅ 不依赖任何外部脚本 | ✅ 自动检测 Remote
--  ✅ 24小时 Key 验证 | ✅ 全部付费功能 | ✅ 手机+电脑
--=================================================================--

if _G._ENRIQUE_PAID_LOADED then return end
_G._ENRIQUE_PAID_LOADED = true

if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

--============================================================--
-- 服务
--============================================================--
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local LocalPlayer       = Players.LocalPlayer

--============================================================--
-- KEY SYSTEM — 24小时验证
--============================================================--
local KEY_STORAGE = "enrique_paid_key.txt"
local KEY_EXPIRY  = 86400  -- 24小时 = 86400秒

local KeySystem = {}
KeySystem.Authenticated = false

-- 验证 key 的 digest
local VALID_DIGESTS = {
    ["658B1BB833311B32"] = true,  -- Owner key
    ["A7F3C91D2E8B4506"] = true,
    ["B82E4F6A1C3D9750"] = true,
    ["D456E89A0F2B7C31"] = true,
    ["E91A3B5C8D2F0647"] = true,
}

function KeySystem.GenerateDigest(key)
    local h = 0
    for i = 1, #key do
        h = (h * 31 + string.byte(key, i)) % 4294967296
    end
    return string.format("%08X", h):sub(1, 16)
end

function KeySystem.Validate(key)
    if not key or #key < 10 then return false end
    -- Owner key bypass
    if key == "ENRIQUE-PAID-75J83-5DCGH-NE99M-S9SSF" then
        return true
    end
    -- Digest check
    local digest = KeySystem.GenerateDigest(key)
    if VALID_DIGESTS[digest] then
        return true
    end
    -- Format check: ENRIQUE-XXXX-XXXX-XXXX-XXXX
    if key:match("^ENRIQUE%-PAID%-[%w]+%-[%w]+%-[%w]+%-[%w]+$") then
        return true
    end
    return false
end

function KeySystem.CheckStored()
    local ok, data = pcall(readfile, KEY_STORAGE)
    if not ok or not data then return false end
    
    local savedTime, savedKey = data:match("^(%d+):(.+)$")
    if not savedTime or not savedKey then return false end
    
    savedTime = tonumber(savedTime)
    if not savedTime then return false end
    
    -- 检查是否过期
    if os.clock() - savedTime > KEY_EXPIRY then
        pcall(delfile, KEY_STORAGE)
        return false
    end
    
    -- 验证 key
    if KeySystem.Validate(savedKey) then
        KeySystem.Authenticated = true
        KeySystem.Key = savedKey
        KeySystem.ExpiresAt = savedTime + KEY_EXPIRY
        return true
    end
    
    return false
end

function KeySystem.Save(key)
    KeySystem.Authenticated = true
    KeySystem.Key = key
    KeySystem.ExpiresAt = os.clock() + KEY_EXPIRY
    pcall(writefile, KEY_STORAGE, os.clock() .. ":" .. key)
end

function KeySystem.GetTimeLeft()
    if not KeySystem.ExpiresAt then return 0 end
    return math.max(0, KeySystem.ExpiresAt - os.clock())
end

function KeySystem.FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- 尝试用存储的 key
KeySystem.CheckStored()

--============================================================--
-- 工具函数
--============================================================--
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    return ok, err
end

local function GetPing()
    return LocalPlayer:GetNetworkPing() * 1000
end

--============================================================--
-- 配置
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
    RetryStrength       = "Maximum",
    NoStun              = true,
    -- Manual Spam
    ManualSpam          = false,
    ManualSpamCPS       = 50,
    ManualSpamMode      = "Ball Speed",
    -- Auto Spam
    AutoSpam            = false,
    AutoSpamMode        = "Closest",
    AutoSpamDelay       = 0.015,
    -- Triggerbot
    Triggerbot          = false,
    TriggerbotDelay     = 0.05,
    -- ESP
    ESP                 = false,
    ESPShowHealth      = true,
    ESPShowDistance     = true,
    ESPShowTarget       = true,
    BallESP             = false,
    Tracers             = false,
    -- Player
    WalkSpeed          = 16,
    JumpPower          = 50,
    NoClip             = false,
    Fly                = false,
    FlySpeed           = 50,
    -- Skin Changer
    SkinChanger        = false,
    SwordName           = "Default",
    SlashName           = "Default",
    -- Name Spoof
    NameSpoof          = false,
    SpoofName          = "",
    -- Misc
    AntiAFK            = true,
    AntiKick           = true,
    FPSBoost           = false,
    AutoRespawn        = true,
    -- Ball
    BallSpeed          = false,
    BallSpeedShow      = false,
    -- Hitbox
    HitboxExpander     = false,
    HitboxSize         = 5,
    -- UI
    UIKey              = Enum.KeyCode.RightShift,
    UIScale            = 1,
}

--============================================================--
-- 🔍 REMOTE 扫描器 — 完全自动检测
--============================================================--
local Remotes = {}
local RemoteScanner = {}

function RemoteScanner.Scan()
    Remotes = {}
    
    -- 方法1: ReplicatedStorage.Remotes（标准结构）
    local rsRemotes = ReplicatedStorage:FindFirstChild("Remotes")
    if rsRemotes then
        for _, child in ipairs(rsRemotes:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                Remotes[child.Name] = child
            end
        end
    end
    
    -- 方法2: 直接扫描 ReplicatedStorage
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            if not Remotes[child.Name] then
                Remotes[child.Name] = child
            end
        end
    end
    
    -- 方法3: 扫描子文件夹（某些版本的BB）
    for _, folder in ipairs(ReplicatedStorage:GetChildren()) do
        if folder:IsA("Folder") then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local key = folder.Name .. "/" .. child.Name
                    Remotes[key] = child
                    if not Remotes[child.Name] then
                        Remotes[child.Name] = child
                    end
                end
            end
        end
    end
    
    return Remotes
end

-- 已知的 Remote 名称
local KNOWN_REMOTE_NAMES = {
    "ParrySuccessAll", "ParrySuccess", "ParryAttempt",
    "AbilityButtonPress", "DeathSlashShootActivation",
    "FireSwordInfo", "PlaySound", "PlayVisuals",
    "Block", "Parry", "BlockButton",
    "RemoteEvent", "Server", "CombatClientRemoteEvent",
    "SwordInfo", "EquipSword",
}

function RemoteScanner.FindParryRemote()
    -- 优先: 精确名称
    for _, name in ipairs(KNOWN_REMOTE_NAMES) do
        if Remotes[name] and Remotes[name]:IsA("RemoteEvent") then
            return Remotes[name], name
        end
    end
    -- 备选: 模式匹配
    for name, remote in pairs(Remotes) do
        if remote:IsA("RemoteEvent") and type(name) == "string" then
            local lower = name:lower()
            if lower:find("parry") or lower:find("block") or lower:find("sword") then
                return remote, name
            end
        end
    end
    return nil, nil
end

function RemoteScanner.FindAbilityRemote()
    for _, name in ipairs({"AbilityButtonPress", "Ability", "AbilityRemote"}) do
        if Remotes[name] then return Remotes[name] end
    end
    for name, remote in pairs(Remotes) do
        if type(name) == "string" and name:lower():find("ability") then
            return remote
        end
    end
    return nil
end

function RemoteScanner.FindSwordRemote()
    for _, name in ipairs({"FireSwordInfo", "SwordInfo", "EquipSword", "ToolEquip"}) do
        if Remotes[name] then return Remotes[name] end
    end
    for name, remote in pairs(Remotes) do
        if type(name) == "string" and name:lower():find("sword") then
            return remote
        end
    end
    return nil
end

RemoteScanner.Scan()
local ParryRemote, ParryRemoteName = RemoteScanner.FindParryRemote()
local AbilityRemote = RemoteScanner.FindAbilityRemote()
local SwordRemote = RemoteScanner.FindSwordRemote()

--============================================================--
-- 🪝 HOOK 系统 — 捕获真实 Remote
--============================================================--
local Hook = {
    remote = nil,
    f_raw = nil,
    args = {},
    hooked = false,
    PF = nil,
}

local function InitHook()
    -- 从 ParrySuccessAll 连接捕获 PF
    task.spawn(function()
        while task.wait(5) do
            if not Hook.PF then
                SafeCall(function()
                    for name, remote in pairs(Remotes) do
                        if remote:IsA("RemoteEvent") and type(name) == "string" then
                            if name:lower():find("parrysuccess") then
                                local ok, conns = pcall(getconnections, remote.OnClientEvent)
                                if ok and conns then
                                    for _, conn in ipairs(conns) do
                                        if conn.Function then
                                            local fnOk, isLua
                                            if islclosure then
                                                fnOk, isLua = pcall(islclosure, conn.Function)
                                            elseif isluaclosure then
                                                fnOk, isLua = pcall(isluaclosure, conn.Function)
                                            end
                                            if fnOk and isLua then
                                                Hook.PF = conn.Function
                                                break
                                            end
                                        end
                                    end
                                end
                                if Hook.PF then break end
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    -- Hookfunction
    SafeCall(function()
        local hookfn = hookfunction or (getgenv and getgenv().hookfunction) or (getgenv and getgenv().hookfunc)
        local newcc = newcclosure or (getgenv and getgenv().newcclosure) or function(f) return f end
        if hookfn and newcc then
            local dummy = Instance.new("RemoteEvent")
            local origFS
            origFS = hookfn(dummy.FireServer, newcc(function(self, ...)
                local args = {...}
                if #args >= 4 and typeof(args[4]) == "CFrame" then
                    Hook.hooked = true
                    Hook.remote = self
                    Hook.f_raw = origFS
                    for i = 1, math.min(7, #args) do Hook.args[i] = args[i] end
                end
                return origFS(self, ...)
            end))
        end
    end)
    
    -- Metatable hook
    SafeCall(function()
        local mt = getrawmetatable(game)
        local old = mt.__index
        setreadonly(mt, false)
        mt.__index = function(self, key)
            if key == "FireServer" or key == "InvokeServer" then
                return function(instance, ...)
                    local args = {...}
                    if #args >= 4 and typeof(args[4]) == "CFrame" then
                        Hook.hooked = true
                        Hook.remote = instance
                        Hook.f_raw = old(instance, key)
                        for i = 1, math.min(7, #args) do Hook.args[i] = args[i] end
                    end
                    return old(self, key)(instance, ...)
                end
            end
            return old(self, key)
        end
        setreadonly(mt, true)
    end)
end

--============================================================--
-- 🎱 球追踪器 — 预测轨迹
--============================================================--
local BallTracker = { track = {} }

function BallTracker.GetBall()
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then return nil end
    for _, ball in ipairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            return ball
        end
    end
    return nil
end

function BallTracker.GetAllBalls()
    local result = {}
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then return result end
    for _, ball in ipairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            table.insert(result, ball)
        end
    end
    return result
end

function BallTracker.GetTrainingBall()
    local tb = Workspace:FindFirstChild("TrainingBalls")
    if not tb then return nil end
    for _, ball in ipairs(tb:GetChildren()) do
        if ball:GetAttribute("realBall") then return ball end
    end
    return nil
end

function BallTracker.GetVelocity(ball)
    local velocity = Vector3.zero
    SafeCall(function()
        local zoomies = ball:FindFirstChild("zoomies")
        if zoomies then
            local vv = zoomies:FindFirstChild("VectorVelocity")
            if vv and vv:IsA("Vector3Value") then
                velocity = vv.Value
            end
        end
    end)
    if velocity.Magnitude < 1 then
        SafeCall(function()
            local bv = ball:FindFirstChildOfClass("BodyVelocity")
            if bv then velocity = bv.Velocity end
        end)
    end
    if velocity.Magnitude < 1 then
        SafeCall(function() velocity = ball.Velocity end)
    end
    return velocity
end

function BallTracker.GetPrediction(ball, root)
    local ok, result = pcall(function()
        local zoomies = ball:FindFirstChild("zoomies")
        if not zoomies then return nil end
        
        local now = tick()
        local position = ball.Position
        local rawVelocity = BallTracker.GetVelocity(ball)
        local rawAcceleration = Vector3.zero
        local track = BallTracker.track[ball]
        local hitRadius = 12
        
        if track and track.position and track.time and now > track.time then
            local delta = math.clamp(now - track.time, 0.001, 0.20)
            local observedVelocity = (position - track.position) / delta
            if observedVelocity.Magnitude > 1 and observedVelocity.Magnitude < 5000 then
                rawVelocity = rawVelocity:Lerp(observedVelocity, 0.35)
                if track.velocity then
                    local obsAccel = (observedVelocity - track.velocity) / delta
                    if obsAccel.Magnitude < 6500 then
                        rawAcceleration = (track.acceleration or Vector3.zero):Lerp(obsAccel, 0.22)
                    end
                end
            end
        end
        
        local segmentDistance = math.huge
        local crossedHitSphere = false
        if track and track.position then
            local motion = position - track.position
            local travel = motion.Magnitude
            if travel > 0.001 then
                local toPrev = track.position - root.Position
                local segTime = math.clamp(-toPrev:Dot(motion) / (travel * travel), 0, 1)
                local nearestPoint = track.position + motion * segTime
                segmentDistance = (nearestPoint - root.Position).Magnitude
                crossedHitSphere = segmentDistance <= hitRadius * 1.5
            end
        end
        
        BallTracker.track[ball] = {
            position = position, time = now,
            velocity = rawVelocity, acceleration = rawAcceleration,
        }
        
        local toPlayer = root.Position - position
        local distance = toPlayer.Magnitude
        local approaching = false
        local eta = math.huge
        
        if rawVelocity.Magnitude > 1 then
            local dot = toPlayer.Unit:Dot(rawVelocity.Unit)
            approaching = dot < -0.15
            if approaching and distance > 1 then
                local closingSpeed = rawVelocity.Magnitude * math.abs(dot)
                if closingSpeed > 1 then
                    eta = (distance - hitRadius) / closingSpeed
                end
            end
        end
        
        if rawAcceleration.Magnitude > 10 then
            eta = eta - rawAcceleration.Magnitude * 0.001
        end
        
        return {
            velocity = rawVelocity, speed = rawVelocity.Magnitude,
            distance = distance, approaching = approaching,
            eta = math.max(eta, 0), closestDistance = segmentDistance,
            crossed = crossedHitSphere, position = position,
        }
    end)
    if ok then return result end
    return nil
end

--============================================================--
-- ⚔️ 格挡引擎
--============================================================--
local ParryEngine = {
    parries = 0, lastSuccess = 0, lastAction = 0,
    cooldowns = {}, armed = {}, retries = {}, ballWatchers = {},
}

local function FireParry(args)
    -- 方法1: Hook 捕获的 Remote
    if Hook.hooked and Hook.remote and Hook.f_raw then
        local a = {}
        for i = 1, 7 do a[i] = Hook.args[i] end
        if args then for k, v in pairs(args) do a[k] = v end end
        SafeCall(function() Hook.f_raw(Hook.remote, unpack(a)) end)
        return true
    end
    
    -- 方法2: 已知 Remote
    if ParryRemote and ParryRemote:IsA("RemoteEvent") then
        SafeCall(function()
            if args and args.cframe then
                ParryRemote:FireServer(
                    args.sword or "Default", args.target or "", args.mode or 0,
                    args.cframe, args.screenPos or Vector2.zero, args.mousePos or Vector2.new(0.5, 0.5)
                )
            else
                ParryRemote:FireServer()
            end
        end)
        return true
    end
    
    -- 方法3: PF（按键模式）
    if Hook.PF then
        SafeCall(function() pcall(Hook.PF) end)
        return true
    end
    
    -- 方法4: 尝试所有 Remote（最后手段）
    SafeCall(function()
        local rs = ReplicatedStorage:FindFirstChild("Remotes")
        if rs then
            for _, child in ipairs(rs:GetChildren()) do
                if child:IsA("RemoteEvent") then
                    pcall(function() child:FireServer() end)
                end
            end
        end
    end)
    
    return false
end

function ParryEngine.Execute()
    local now = tick()
    if now - ParryEngine.lastAction < 0.004 then return end
    ParryEngine.lastAction = now
    FireParry(nil)
    ParryEngine.parries = ParryEngine.parries + 1
    task.delay(0.5, function()
        if ParryEngine.parries > 0 then ParryEngine.parries = ParryEngine.parries - 1 end
    end)
end

--============================================================--
-- 🎯 自动格挡
--============================================================--
local AutoParry = { connection = nil, smoothFrameDelta = 1/60 }

function AutoParry.Start()
    if AutoParry.connection then AutoParry.connection:Disconnect() end
    for ball, conn in pairs(ParryEngine.ballWatchers) do
        SafeCall(function() conn:Disconnect() end)
    end
    ParryEngine.ballWatchers = {}
    ParryEngine.cooldowns = {}
    ParryEngine.armed = {}
    ParryEngine.retries = {}
    
    AutoParry.connection = RunService.PreSimulation:Connect(function(dt)
        AutoParry.smoothFrameDelta = AutoParry.smoothFrameDelta +
            (math.clamp(dt or 1/60, 1/240, 1/12) - AutoParry.smoothFrameDelta) * 0.18
        
        if not CFG.AutoParry then return end
        if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
        
        local now = tick()
        local balls = BallTracker.GetAllBalls()
        local trainingBall = BallTracker.GetTrainingBall()
        
        for _, ball in ipairs(balls) do
            if not ball or not ball.Parent then continue end
            if not ball:FindFirstChild("zoomies") then continue end
            
            -- 设置目标监控
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
            
            -- 重试逻辑
            local retryState = ParryEngine.retries[ball]
            if retryState and now - (ParryEngine.lastSuccess or 0) < 0.40 then
                ParryEngine.retries[ball] = nil
                retryState = nil
            end
            
            if retryState then
                local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                local vel = BallTracker.GetVelocity(ball)
                if root and vel.Magnitude > 1 then
                    local toLocal = root.Position - ball.Position
                    if toLocal.Magnitude > 1 and vel.Unit:Dot(toLocal.Unit) < -0.18 then
                        ParryEngine.retries[ball] = nil
                        retryState = nil
                    end
                end
            end
            
            if retryState then
                if ballTarget ~= LocalPlayer.Name then
                    ParryEngine.retries[ball] = nil
                elseif now >= retryState.nextTime then
                    ParryEngine.Execute()
                    retryState.remaining = retryState.remaining - 1
                    retryState.nextTime = now + math.max(0.016, AutoParry.smoothFrameDelta * 0.65)
                    if retryState.remaining <= 0 then
                        ParryEngine.retries[ball] = nil
                    end
                end
                continue
            end
            
            -- 核心格挡计算
            local root = LocalPlayer.Character.PrimaryPart
            local velocity = BallTracker.GetVelocity(ball)
            local speed = velocity.Magnitude
            local distance = (root.Position - ball.Position).Magnitude
            local pingMs = GetPing()
            local latency = math.clamp((pingMs / 1000) * math.clamp(CFG.AutoParryStrength, 0.75, 2.25), 0.004, 0.58)
            local prediction = BallTracker.GetPrediction(ball, root)
            
            if ball:FindFirstChild("ComboCounter") then continue end
            if root:FindFirstChild("SingularityCape") then continue end
            
            -- 龙卷风检测
            if Workspace:FindFirstChild("Runtime") and Workspace.Runtime:FindFirstChild("Tornado") then
                local tornadoTime = Workspace.Runtime.Tornado:GetAttribute("TornadoTime") or 1
                if (tick() - (ParryEngine._tornadoTime or 0)) < tornadoTime + 0.3 then continue end
            end
            
            -- 加速球检测
            if ball:GetAttribute("warping") or ball:GetAttribute("bouncing") then
                local warpSpeed = ball:GetAttribute("warpSpeed") or speed
                if warpSpeed > speed * 1.5 then speed = warpSpeed end
            end
            
            -- 触发窗口计算
            local autoBest = CFG.PredictionMode == "Auto Best"
            local timingBias = math.clamp(CFG.PredictionOffset, -1, 1) * 0.075
            local triggerWindow
            
            if autoBest then
                local speedUncertainty = speed >= 250
                    and 0.010 + math.min((speed - 250) / 6500, 0.032)
                    or 0.003 + math.min(speed / 30000, 0.008)
                local processingMargin = 0.118 + AutoParry.smoothFrameDelta * 0.98 + speedUncertainty
                triggerWindow = latency * 2.45 + processingMargin
                if CFG.EmergencyShield then triggerWindow = triggerWindow + 0.052 end
                
                -- 速度档位
                if speed >= 250 then triggerWindow = triggerWindow + 0.022 end
                if speed >= 340 then triggerWindow = triggerWindow + 0.028 end
                if speed >= 450 then triggerWindow = triggerWindow + 0.026 end
                if speed >= 600 then triggerWindow = triggerWindow + 0.031 end
                if speed >= 800 then triggerWindow = triggerWindow + 0.028 end
                if speed >= 1000 then triggerWindow = triggerWindow + 0.035 end
                if speed >= 1500 then triggerWindow = triggerWindow + 0.045 end
                if speed >= 2000 then triggerWindow = triggerWindow + 0.055 end
                
                if CFG.RetryStrength == "Maximum" or CFG.RetryStrength == "Legendary" then
                    triggerWindow = triggerWindow + 0.014
                end
            else
                triggerWindow = latency + 0.075 + timingBias
            end
            
            triggerWindow = math.clamp(triggerWindow, 0.020, autoBest and 0.56 or 0.42)
            local parryStr = math.clamp(CFG.AutoParryStrength, 0.5, 2)
            local maxTriggerDist = math.min(speed * triggerWindow * parryStr + 35, 400)
            local shouldFire = false
            
            -- 预测触发
            if prediction and speed >= 45 then
                local hitRadius = math.max(26, 15 + speed * 0.022)
                if CFG.EmergencyShield then hitRadius = hitRadius + 5 end
                shouldFire = prediction.approaching
                    and prediction.eta <= triggerWindow
                    and (prediction.closestDistance <= hitRadius or prediction.crossed)
                    and distance <= maxTriggerDist + (prediction.crossed and 25 or 0)
            else
                local closeRange = math.clamp((26 + pingMs * 0.045 + speed * 0.062) * parryStr, 24, 160)
                shouldFire = distance <= closeRange
            end
            
            -- 朝向检查
            local headingToPlayer = true
            if speed > 1 then
                local toPlayer = root.Position - ball.Position
                headingToPlayer = toPlayer.Magnitude <= 1 or (toPlayer.Unit):Dot(velocity.Unit) > -0.20
            end
            
            -- 紧急盾牌
            if CFG.EmergencyShield and not shouldFire then
                local emergencyRange = math.max(32, speed * (latency + AutoParry.smoothFrameDelta * 0.5) + 35) * parryStr
                shouldFire = distance <= emergencyRange
                if not shouldFire and distance < 18 then shouldFire = true end
            end
            
            -- 开火！
            if ballTarget == LocalPlayer.Name and shouldFire and headingToPlayer then
                -- 冷却保护
                if CFG.CooldownProtection then
                    SafeCall(function()
                        local hotbar = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                        if hotbar then
                            local block = hotbar:FindFirstChild("Block")
                            if block and block:FindFirstChild("UIGradient") and block.UIGradient.Offset.Y < 0.4 then
                                if AbilityRemote then SafeCall(function() AbilityRemote:Fire() end) end
                                ParryEngine.cooldowns[ball] = now + 0.06
                                continue
                            end
                        end
                    end)
                end
                
                -- 自动技能
                if CFG.AutoAbility then
                    SafeCall(function()
                        local hotbar = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                        if hotbar then
                            local ability = hotbar:FindFirstChild("Ability")
                            if ability and ability:FindFirstChild("UIGradient") and ability.UIGradient.Offset.Y == 0.5 then
                                local abilities = LocalPlayer.Character:FindFirstChild("Abilities")
                                if abilities then
                                    local hasUsable = false
                                    for _, ab in ipairs(abilities:GetChildren()) do
                                        if ab:IsA("BoolValue") and ab.Enabled then hasUsable = true; break end
                                    end
                                    if hasUsable and AbilityRemote then
                                        AbilityRemote:Fire()
                                        task.delay(2.4, function()
                                            SafeCall(function()
                                                local dsr = Remotes["DeathSlashShootActivation"]
                                                if dsr then dsr:FireServer(true) end
                                            end)
                                        end)
                                        ParryEngine.armed[ball] = false
                                        ParryEngine.cooldowns[ball] = now + 0.08
                                        continue
                                    end
                                end
                            end
                        end
                    end)
                end
                
                ParryEngine.Execute()
                ParryEngine.armed[ball] = false
                ParryEngine.cooldowns[ball] = now + 0.12
                
                -- 重试调度
                local retryThreshold = 150
                if CFG.RetryStrength == "Safe" then retryThreshold = 260
                elseif CFG.RetryStrength == "Balanced" then retryThreshold = 220
                elseif CFG.RetryStrength == "Aggressive" then retryThreshold = 180
                elseif CFG.RetryStrength == "Maximum" then retryThreshold = 150
                elseif CFG.RetryStrength == "Legendary" then retryThreshold = 120 end
                
                if speed >= retryThreshold then
                    local remaining = 5
                    if CFG.RetryStrength == "Safe" then remaining = 2
                    elseif CFG.RetryStrength == "Balanced" then remaining = speed >= 290 and 3 or 2
                    elseif CFG.RetryStrength == "Aggressive" then remaining = speed >= 260 and 4 or 3
                    elseif CFG.RetryStrength == "Legendary" then remaining = speed >= 200 and 15 or 10 end
                    
                    ParryEngine.retries[ball] = {
                        remaining = remaining,
                        nextTime = now + math.max(0.016, AutoParry.smoothFrameDelta * 0.58),
                    }
                end
            end
        end
        
        -- 训练球
        if trainingBall and trainingBall:FindFirstChild("zoomies") then
            local cd = ParryEngine.cooldowns["training"] or 0
            if now >= cd then
                local bt = trainingBall:GetAttribute("target")
                local vel = BallTracker.GetVelocity(trainingBall)
                local spd = vel.Magnitude
                local dist = LocalPlayer:DistanceFromCharacter(trainingBall.Position)
                local ping = GetPing()
                local lat = math.clamp(ping / 1000, 0.005, 0.45)
                local cappedDiff = math.min(math.max(spd - 9.5, 0), 650)
                local speedDiv = (2.4 + cappedDiff * 0.002) * (0.7 + (CFG.ParryAccuracy - 1) * 0.0035)
                local str = math.clamp(CFG.AutoParryStrength, 0.5, 2)
                local baseRange = math.clamp((ping / 10) / 10, 4, 18) + math.max(spd / speedDiv, 12.5)
                local pred = spd * lat
                local strBonus = (str - 1) * math.min(baseRange * 0.25 + pred * 0.35, 18)
                local threshold = math.max(12, baseRange + pred + strBonus)
                if (bt == LocalPlayer.Name or dist < 20) and dist <= threshold then
                    ParryEngine.Execute()
                    ParryEngine.cooldowns["training"] = tick() + 0.20
                end
            end
        end
    end)
end

function AutoParry.Stop()
    if AutoParry.connection then AutoParry.connection:Disconnect(); AutoParry.connection = nil end
    for _, conn in pairs(ParryEngine.ballWatchers) do SafeCall(function() conn:Disconnect() end) end
    ParryEngine.ballWatchers = {}
end

--============================================================--
-- ⚡ 手动连发
--============================================================--
local ManualSpam = { connection = nil, accumulator = 0, lastFrame = 0 }

function ManualSpam.Start()
    if ManualSpam.connection then ManualSpam.connection:Disconnect() end
    ManualSpam.accumulator = 0
    ManualSpam.lastFrame = tick()
    
    ManualSpam.connection = RunService.PreSimulation:Connect(function(dt)
        if not CFG.ManualSpam then return end
        local now = tick()
        local frameDelta = now - ManualSpam.lastFrame
        ManualSpam.lastFrame = now
        
        local quota = CFG.ManualSpamCPS * frameDelta
        
        if CFG.ManualSpamMode == "Ball Speed" then
            local ball = BallTracker.GetBall()
            if ball then
                local vel = BallTracker.GetVelocity(ball)
                if vel.Magnitude > 200 then
                    quota = quota * (1 + vel.Magnitude / 1000)
                end
            end
        end
        
        ManualSpam.accumulator = ManualSpam.accumulator + quota
        local count = math.min(math.floor(ManualSpam.accumulator), 512)
        if count < 1 then return end
        ManualSpam.accumulator = ManualSpam.accumulator - count
        
        for _ = 1, count do FireParry(nil) end
    end)
end

function ManualSpam.Stop()
    if ManualSpam.connection then ManualSpam.connection:Disconnect(); ManualSpam.connection = nil end
    ManualSpam.accumulator = 0
end

--============================================================--
-- 🔄 自动连发
--============================================================--
local AutoSpam = { connection = nil, accumulator = 0, lastFrame = 0 }

function AutoSpam.Start()
    if AutoSpam.connection then AutoSpam.connection:Disconnect() end
    AutoSpam.accumulator = 0
    AutoSpam.lastFrame = tick()
    
    AutoSpam.connection = RunService.PreSimulation:Connect(function(dt)
        if not CFG.AutoSpam or not CFG.ManualSpam then return end
        local now = tick()
        local frameDelta = now - AutoSpam.lastFrame
        AutoSpam.lastFrame = now
        
        local ball = BallTracker.GetBall()
        if not ball then return end
        local target = ball:GetAttribute("target")
        if target ~= LocalPlayer.Name then return end
        
        local vel = BallTracker.GetVelocity(ball)
        local speed = vel.Magnitude
        local baseCPS = CFG.ManualSpamCPS
        if speed > 300 then baseCPS = baseCPS * 1.5
        elseif speed > 600 then baseCPS = baseCPS * 2.0 end
        
        local quota = baseCPS * frameDelta
        
        local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if root then
            local dist = (root.Position - ball.Position).Magnitude
            if dist < 30 then quota = quota + quota * 0.5 end
        end
        
        AutoSpam.accumulator = AutoSpam.accumulator + quota
        local count = math.min(math.floor(AutoSpam.accumulator), 512)
        if count < 1 then return end
        AutoSpam.accumulator = AutoSpam.accumulator - count
        
        for _ = 1, count do FireParry(nil) end
    end)
end

function AutoSpam.Stop()
    if AutoSpam.connection then AutoSpam.connection:Disconnect(); AutoSpam.connection = nil end
    AutoSpam.accumulator = 0
end

--============================================================--
-- 🎯 触发器
--============================================================--
local Triggerbot = { connection = nil }

function Triggerbot.Start()
    if Triggerbot.connection then Triggerbot.connection:Disconnect() end
    Triggerbot.connection = RunService.PreSimulation:Connect(function()
        if not CFG.Triggerbot then return end
        local ball = BallTracker.GetBall()
        if not ball then return end
        if ball:GetAttribute("target") ~= LocalPlayer.Name then return end
        local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if not root then return end
        local dist = (root.Position - ball.Position).Magnitude
        if dist < 25 then FireParry(nil) end
    end)
end

function Triggerbot.Stop()
    if Triggerbot.connection then Triggerbot.connection:Disconnect(); Triggerbot.connection = nil end
end

--============================================================--
-- 👁️ ESP
--============================================================--
local ESP = { enabled = false, objects = {}, connection = nil }

function ESP.Start()
    if ESP.connection then ESP.connection:Disconnect() end
    ESP.enabled = true
    
    ESP.connection = RunService.RenderStepped:Connect(function()
        if not CFG.ESP then ESP.Stop(); return end
        for _, obj in pairs(ESP.objects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        ESP.objects = {}
        
        local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if not root then return end
        
        local espBall = BallTracker.GetBall()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
                local hrp = player.Character.PrimaryPart
                local dist = (root.Position - hrp.Position).Magnitude
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                
                if onScreen then
                    local text = player.Name
                    if CFG.ESPShowDistance then text = text .. " [" .. math.floor(dist) .. "m]" end
                    if CFG.ESPShowHealth and player.Character:FindFirstChild("Humanoid") then
                        text = text .. " [" .. math.floor(player.Character.Humanoid.Health) .. " HP]"
                    end
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ENRIQUE_ESP"
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.AlwaysOnTop = true
                    billboard.Adornee = hrp
                    billboard.Parent = game:GetService("CoreGui")
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 0.5
                    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.Text = text
                    label.Parent = billboard
                    
                    if CFG.ESPShowTarget and espBall then
                        local ballTarget = espBall:GetAttribute("target")
                        if ballTarget == player.Name then
                            label.TextColor3 = Color3.fromRGB(255, 50, 50)
                            label.Text = "🎯 " .. text
                        end
                    end
                    
                    table.insert(ESP.objects, billboard)
                end
            end
        end
    end)
end

function ESP.Stop()
    if ESP.connection then ESP.connection:Disconnect(); ESP.connection = nil end
    for _, obj in pairs(ESP.objects) do if obj and obj.Parent then obj:Destroy() end end
    ESP.objects = {}
    ESP.enabled = false
end

--============================================================--
-- 🎨 SKIN CHANGER（付费功能）
--============================================================--
local SkinChanger = { connection = nil }

function SkinChanger.Apply(swordName)
    if not SwordRemote then
        Notify("❌ Skin Changer", "Sword remote not found", 3)
        return
    end
    
    SafeCall(function()
        -- 尝试多种方式装备武器
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local fireSword = remotes:FindFirstChild("FireSwordInfo")
            if fireSword then
                fireSword:FireServer(swordName)
                Notify("✅ Skin Changer", "Sword: " .. swordName, 3)
                return
            end
        end
        
        -- 备选: 直接用 SwordRemote
        SwordRemote:FireServer(swordName)
        Notify("✅ Skin Changer", "Sword: " .. swordName, 3)
    end)
    
    -- 重生自动恢复
    if SkinChanger.connection then SkinChanger.connection:Disconnect() end
    SkinChanger.connection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if CFG.SkinChanger and CFG.SwordName ~= "" then
            SkinChanger.Apply(CFG.SwordName)
        end
    end)
end

function SkinChanger.Stop()
    if SkinChanger.connection then SkinChanger.connection:Disconnect(); SkinChanger.connection = nil end
end

--============================================================--
-- 🔧 杂项功能
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
                    
                    if vel.Magnitude > 0 then
                        hrp.Velocity = vel.Unit * CFG.FlySpeed
                    else
                        hrp.Velocity = Vector3.zero
                    end
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

-- 自动重生
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

-- 重生后恢复设置
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    Misc.SetWalkSpeed(CFG.WalkSpeed)
    Misc.SetJumpPower(CFG.JumpPower)
    if CFG.AutoParry then AutoParry.Start() end
    if CFG.SkinChanger and CFG.SwordName ~= "" then
        task.wait(2)
        SkinChanger.Apply(CFG.SwordName)
    end
end)

-- 防踢
if CFG.AntiKick then
    task.spawn(function()
        while task.wait(30) do
            pcall(function() game:GetService("VirtualUser"):CaptureController() end)
        end
    end)
end

-- FPS 加速
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

-- 球速显示
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
        
        local vel = BallTracker.GetVelocity(ball)
        local speed = math.floor(vel.Magnitude)
        
        if not BallSpeedGui.billboard then
            BallSpeedGui.billboard = Instance.new("BillboardGui")
            BallSpeedGui.billboard.Name = "ENRIQUE_BallSpeed"
            BallSpeedGui.billboard.Size = UDim2.new(0, 150, 0, 40)
            BallSpeedGui.billboard.AlwaysOnTop = true
            BallSpeedGui.billboard.Adornee = ball
            BallSpeedGui.billboard.Parent = game:GetService("CoreGui")
            
            local label = Instance.new("TextLabel")
            label.Name = "SpeedLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 0.6
            label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            label.TextColor3 = Color3.fromRGB(255, 200, 60)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = BallSpeedGui.billboard
        end
        
        local label = BallSpeedGui.billboard:FindFirstChild("SpeedLabel")
        if label then
            label.Text = "⚡ " .. speed .. " SP"
            if speed > 500 then
                label.TextColor3 = Color3.fromRGB(255, 50, 50)
            elseif speed > 250 then
                label.TextColor3 = Color3.fromRGB(255, 200, 60)
            else
                label.TextColor3 = Color3.fromRGB(80, 255, 140)
            end
        end
    end)
end

function BallSpeedGui.Stop()
    if BallSpeedGui.connection then BallSpeedGui.connection:Disconnect(); BallSpeedGui.connection = nil end
    if BallSpeedGui.billboard then BallSpeedGui.billboard:Destroy(); BallSpeedGui.billboard = nil end
end

-- 碰撞箱扩大
local HitboxExpander = { connection = nil }

function HitboxExpander.Start()
    HitboxExpander.Stop()
    HitboxExpander.connection = RunService.RenderStepped:Connect(function()
        if not CFG.HitboxExpander then HitboxExpander.Stop(); return end
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

function HitboxExpander.Stop()
    if HitboxExpander.connection then HitboxExpander.connection:Disconnect(); HitboxExpander.connection = nil end
end

--============================================================--
-- KEY SYSTEM UI — 高级动画验证界面
--============================================================--
local function ShowKeyUI(callback)
    local sg = Instance.new("ScreenGui")
    sg.Name = "ENRIQUE_PAID_KEY"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 10000
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    pcall(function() local hui = gethui and gethui(); if hui then sg.Parent = hui end end)
    
    local W, H = 380, 300
    
    local overlay = Instance.new("Frame", sg)
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local root = Instance.new("Frame", sg)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.new(0, W, 0, H)
    root.BackgroundTransparency = 1
    
    local shadow = Instance.new("ImageLabel", root)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    
    local main = Instance.new("Frame", root)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(180, 60, 255)
    main.UIStroke.Transparency = 0.3
    
    -- 动漫横幅
    local banner = Instance.new("ImageLabel", main)
    banner.Size = UDim2.new(1, -30, 0, 80)
    banner.Position = UDim2.new(0, 15, 0, 15)
    banner.BackgroundTransparency = 1
    banner.Image = "rbxassetid://133575691569801"
    banner.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)
    local bannerStroke = Instance.new("UIStroke", banner)
    bannerStroke.Color = Color3.fromRGB(180, 60, 255)
    bannerStroke.Transparency = 0.4
    
    -- 标题
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 102)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ ENRIQUE PAID"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(180, 60, 255)
    
    local subtitle = Instance.new("TextLabel", main)
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Position = UDim2.new(0, 0, 0, 128)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "输入 Key 激活付费功能 (24小时有效)"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextColor3 = Color3.fromRGB(160, 145, 185)
    
    -- Key 输入框
    local inputBg = Instance.new("Frame", main)
    inputBg.Size = UDim2.new(1, -40, 0, 38)
    inputBg.Position = UDim2.new(0, 20, 0, 154)
    inputBg.BackgroundColor3 = Color3.fromRGB(26, 22, 38)
    inputBg.BorderSizePixel = 0
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", inputBg).Color = Color3.fromRGB(80, 40, 120)
    
    local input = Instance.new("TextBox", inputBg)
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "ENRIQUE-PAID-XXXX-XXXX-XXXX-XXXX"
    input.PlaceholderColor3 = Color3.fromRGB(100, 90, 120)
    input.Text = ""
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamMedium
    input.TextSize = 13
    input.ClearTextOnFocus = false
    
    -- 激活按钮
    local activateBtn = Instance.new("TextButton", main)
    activateBtn.Size = UDim2.new(1, -40, 0, 38)
    activateBtn.Position = UDim2.new(0, 20, 0, 202)
    activateBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 255)
    activateBtn.BorderSizePixel = 0
    activateBtn.Text = "🔑 激活"
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.TextSize = 15
    activateBtn.TextColor3 = Color3.new(1, 1, 1)
    activateBtn.AutoButtonColor = false
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)
    
    -- 状态文本
    local statusLabel = Instance.new("TextLabel", main)
    statusLabel.Size = UDim2.new(1, 0, 0, 16)
    statusLabel.Position = UDim2.new(0, 0, 0, 248)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "discord.gg/hZhwszmP"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.fromRGB(100, 90, 120)
    
    -- 点击事件
    activateBtn.MouseButton1Click:Connect(function()
        local key = input.Text
        if key == "" then
            statusLabel.Text = "❌ 请输入 Key"
            statusLabel.TextColor3 = Color3.fromRGB(255, 70, 90)
            return
        end
        
        activateBtn.Text = "验证中..."
        
        task.delay(0.5, function()
            if KeySystem.Validate(key) then
                KeySystem.Save(key)
                statusLabel.Text = "✅ 激活成功！24小时有效"
                statusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
                
                task.delay(1, function()
                    -- 关闭 Key UI
                    tween(overlay, 0.2, {BackgroundTransparency = 1})
                    tween(blur, 0.25, {Size = 0})
                    tween(root, 0.22, {Size = UDim2.new(0, W-30, 0, H-20)})
                    task.delay(0.25, function()
                        sg:Destroy()
                        blur:Destroy()
                        callback()
                    end)
                end)
            else
                statusLabel.Text = "❌ Key 无效或已过期"
                statusLabel.TextColor3 = Color3.fromRGB(255, 70, 90)
                activateBtn.Text = "🔑 激活"
                tween(inputBg, 0.1, {Position = UDim2.new(0, 24, 0, 154)})
                task.delay(0.05, function() tween(inputBg, 0.1, {Position = UDim2.new(0, 16, 0, 154)}) end)
                task.delay(0.15, function() tween(inputBg, 0.1, {Position = UDim2.new(0, 22, 0, 154)}) end)
                task.delay(0.25, function() tween(inputBg, 0.1, {Position = UDim2.new(0, 20, 0, 154)}) end)
            end
        end)
    end)
    
    -- 入场动画
    root.Size = UDim2.new(0, W-30, 0, H-20)
    tween(overlay, 0.25, {BackgroundTransparency = 0.5})
    tween(blur, 0.3, {Size = 12})
    tween(root, 0.35, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)
end

--============================================================--
-- 主 UI
--============================================================--
local UI = {}
UI.Window = nil
UI.Minimized = false
UI.Open = true

local T = {
    bg = Color3.fromRGB(12, 10, 20), panel = Color3.fromRGB(18, 16, 28),
    panel2 = Color3.fromRGB(26, 22, 38), panel3 = Color3.fromRGB(34, 28, 48),
    stroke = Color3.fromRGB(80, 40, 120), strokeHi = Color3.fromRGB(180, 60, 255),
    text = Color3.fromRGB(240, 235, 255), subtext = Color3.fromRGB(160, 145, 185),
    muted = Color3.fromRGB(100, 90, 120), accent = Color3.fromRGB(180, 60, 255),
    accentHi = Color3.fromRGB(210, 100, 255), accentDim = Color3.fromRGB(120, 40, 170),
    danger = Color3.fromRGB(255, 70, 90), success = Color3.fromRGB(80, 255, 140),
    toggleOn = Color3.fromRGB(180, 60, 255), toggleOff = Color3.fromRGB(50, 45, 65),
    cardBg = Color3.fromRGB(22, 18, 34),
}

local function mk(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function tw(inst, t, props, style, dir)
    local tw2 = TweenService:Create(inst, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw2:Play()
    return tw2
end

-- 控件
local function CreateToggle(parent, label, flag, default, callback)
    local frame = mk("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = parent})
    mk("TextLabel", {Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
    local state = default or false
    local toggleBg = mk("Frame", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -42, 0.5, -10), BackgroundColor3 = state and T.toggleOn or T.toggleOff, Parent = frame})
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    local dot = mk("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = state and Color3.new(1, 1, 1) or T.muted, Parent = toggleBg})
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local function Update()
        tw(toggleBg, 0.15, {BackgroundColor3 = state and T.toggleOn or T.toggleOff})
        tw(dot, 0.15, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = state and Color3.new(1, 1, 1) or T.muted})
    end
    local clickArea = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = frame})
    clickArea.MouseButton1Click:Connect(function()
        state = not state; CFG[flag] = state; Update()
        if callback then callback(state) end
    end)
    return {SetState = function(s) state = s; CFG[flag] = s; Update() end}
end

local function CreateSlider(parent, label, flag, min, max, default, callback)
    local frame = mk("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Parent = parent})
    mk("TextLabel", {Size = UDim2.new(0.65, 0, 0, 16), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = T.subtext, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
    local valueLabel = mk("TextLabel", {Size = UDim2.new(0.35, 0, 0, 16), BackgroundTransparency = 1, Text = tostring(default), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = frame})
    local trackBg = mk("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = T.panel3, Parent = frame})
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)
    local fill = mk("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = T.accent, Parent = trackBg})
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = mk("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1), Parent = trackBg})
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local currentVal = default
    local function updateSlider(x)
        local pct = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        currentVal = min + (max - min) * pct
        if max <= 10 then currentVal = math.floor(currentVal * 10) / 10 end
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        valueLabel.Text = tostring(currentVal)
        CFG[flag] = currentVal
        if callback then callback(currentVal) end
    end
    trackBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local function CreateDropdown(parent, label, flag, options, default, callback)
    local frame = mk("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = parent})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = label, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = T.subtext, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
    local current = default or options[1]
    local dropBtn = mk("TextButton", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = T.panel3, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = frame})
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
    local dropLabel = mk("TextLabel", {Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = current, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, Parent = dropBtn})
    local arrow = mk("TextLabel", {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0), BackgroundTransparency = 1, Text = "▼", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = T.muted, Parent = dropBtn})
    local listFrame = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 0, math.min(#options * 28, 140)), Position = UDim2.new(0, 0, 0, 52), BackgroundColor3 = T.panel2, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = T.accent, CanvasSize = UDim2.new(0, 0, 0, #options * 28), Visible = false, ZIndex = 10, Parent = frame})
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 2)
    for _, opt in ipairs(options) do
        local optBtn = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = T.panel3, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "  " .. opt, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 11, Parent = listFrame})
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
        optBtn.MouseButton1Click:Connect(function()
            current = opt; dropLabel.Text = opt; CFG[flag] = opt
            listFrame.Visible = false; arrow.Text = "▼"
            if callback then callback(opt) end
        end)
    end
    dropBtn.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible; arrow.Text = listFrame.Visible and "▲" or "▼" end)
end

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
    return btn
end

--============================================================--
-- 创建主窗口
--============================================================--
function UI.Create()
    if UI.Window and UI.Window.Parent then UI.Window:Destroy() end
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name == "ENRIQUE_PAID_BB" then gui:Destroy() end
    end
    pcall(function() local cg = game:GetService("CoreGui"):FindFirstChild("ENRIQUE_PAID_BB"); if cg then cg:Destroy() end end)
    
    local W, H = 480, 420
    local sg = mk("ScreenGui", {Name = "ENRIQUE_PAID_BB", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = LocalPlayer:WaitForChild("PlayerGui")})
    pcall(function() local hui = gethui and gethui(); if hui then sg.Parent = hui end end)
    
    local overlay = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = sg})
    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})
    local root = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 1, Parent = sg})
    
    local shadow = mk("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 60, 1, 60), BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.3, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Parent = root})
    
    local main = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = T.bg, BorderSizePixel = 0, Parent = root})
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = T.stroke; mainStroke.Transparency = 0.3
    
    -- 标题栏
    local titleBar = mk("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = main})
    mk("Frame", {Size = UDim2.new(0, 4, 0, 14), Position = UDim2.new(0, 14, 0.5, -7), BackgroundColor3 = T.accent, Parent = titleBar}).Parent.UICorner.CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner", titleBar:FindFirstChild("Frame") or titleBar).CornerRadius = UDim.new(1, 0)
    
    mk("TextLabel", {Size = UDim2.new(0, 260, 1, 0), Position = UDim2.new(0, 24, 0, 0), BackgroundTransparency = 1, Text = "⚔️ ENRIQUE PAID BLADE BALL", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar})
    
    -- 剩余时间
    local timeLabel = mk("TextLabel", {Size = UDim2.new(0, 100, 0, 14), Position = UDim2.new(0, 24, 0, 20), BackgroundTransparency = 1, Text = "🔑 " .. KeySystem.FormatTime(KeySystem.GetTimeLeft()), Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar})
    
    mk("Frame", {Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, 0), BackgroundColor3 = T.stroke, BackgroundTransparency = 0.6, Parent = titleBar})
    
    local minBtn = mk("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -70, 0, 5), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.subtext, AutoButtonColor = false, Parent = titleBar})
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    
    local closeBtn = mk("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0, 5), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "×", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.subtext, AutoButtonColor = false, Parent = titleBar})
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    -- 动漫横幅
    local banner = mk("ImageLabel", {Size = UDim2.new(1, -24, 0, 45), Position = UDim2.new(0, 12, 0, 42), BackgroundTransparency = 1, Image = "rbxassetid://133575691569801", ScaleType = Enum.ScaleType.Crop, Parent = main})
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)
    local bannerStroke = Instance.new("UIStroke", banner)
    bannerStroke.Color = T.accent; bannerStroke.Transparency = 0.4
    
    -- 侧边栏
    local sidebar = mk("Frame", {Size = UDim2.new(0, 140, 1, -100), Position = UDim2.new(0, 0, 0, 94), BackgroundTransparency = 1, Parent = main})
    
    -- 内容区
    local content = mk("ScrollingFrame", {Size = UDim2.new(1, -154, 1, -100), Position = UDim2.new(0, 148, 0, 94), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = T.accent, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = main})
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 6)
    Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 4)
    content.UIPadding.PaddingRight = UDim.new(0, 4)
    
    -- 标签
    local TABS = {
        {name = "Combat", icon = "⚔️"},
        {name = "Spam", icon = "⚡"},
        {name = "Visuals", icon = "👁️"},
        {name = "Player", icon = "🏃"},
        {name = "Sword", icon = "🗡️"},
        {name = "Settings", icon = "⚙️"},
    }
    
    local tabButtons, tabFrames = {}, {}
    
    for i, tab in ipairs(TABS) do
        local tabBtn = mk("TextButton", {Size = UDim2.new(1, -8, 0, 28), Position = UDim2.new(0, 4, 0, (i-1)*32), BackgroundColor3 = T.panel2, BorderSizePixel = 0, Text = "  " .. tab.icon .. " " .. tab.name, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.subtext, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = sidebar})
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        local tabFrame = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Visible = (tab.name == "Combat"), Parent = content})
        Instance.new("UIListLayout", tabFrame).Padding = UDim.new(0, 4)
        tabButtons[tab.name] = tabBtn
        tabFrames[tab.name] = tabFrame
        tabBtn.MouseButton1Click:Connect(function()
            for name, btn in pairs(tabButtons) do
                if name == tab.name then tw(btn, 0.12, {BackgroundColor3 = T.accentDim}); btn.TextColor3 = Color3.new(1, 1, 1)
                else tw(btn, 0.12, {BackgroundColor3 = T.panel2}); btn.TextColor3 = T.subtext end
            end
            for name, frame in pairs(tabFrames) do frame.Visible = (name == tab.name) end
        end)
    end
    tw(tabButtons["Combat"], 0, {BackgroundColor3 = T.accentDim})
    tabButtons["Combat"].TextColor3 = Color3.new(1, 1, 1)
    
    local function Card(parent, title)
        local card = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.cardBg, BorderSizePixel = 0, Parent = parent})
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color = T.stroke; cardStroke.Transparency = 0.5; cardStroke.Thickness = 0.5
        Instance.new("UIPadding", card).PaddingTop = UDim.new(0, 8)
        card.UIPadding.PaddingBottom = UDim.new(0, 8)
        card.UIPadding.PaddingLeft = UDim.new(0, 10)
        card.UIPadding.PaddingRight = UDim.new(0, 10)
        Instance.new("UIListLayout", card).Padding = UDim.new(0, 4)
        if title then
            mk("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = card})
        end
        return card
    end
    
    -- COMBAT
    local combatCard = Card(tabFrames["Combat"], "🛡️ AUTO PARRY")
    CreateToggle(combatCard, "Auto Parry", "AutoParry", CFG.AutoParry, function(s) if s then AutoParry.Start() else AutoParry.Stop() end end)
    CreateDropdown(combatCard, "Mode", "AutoParryMode", {"Remote", "Keypress"}, CFG.AutoParryMode)
    CreateDropdown(combatCard, "Retry Strength", "RetryStrength", {"Safe", "Balanced", "Aggressive", "Maximum", "Legendary"}, CFG.RetryStrength)
    CreateSlider(combatCard, "Parry Strength", "AutoParryStrength", 0.5, 2.0, CFG.AutoParryStrength)
    CreateSlider(combatCard, "Accuracy", "ParryAccuracy", 1, 100, CFG.ParryAccuracy)
    CreateDropdown(combatCard, "Prediction", "PredictionMode", {"Auto Best", "Manual"}, CFG.PredictionMode)
    CreateSlider(combatCard, "Prediction Offset", "PredictionOffset", -1, 1, CFG.PredictionOffset)
    CreateToggle(combatCard, "Emergency Shield", "EmergencyShield", CFG.EmergencyShield)
    CreateToggle(combatCard, "Cooldown Protection", "CooldownProtection", CFG.CooldownProtection)
    CreateToggle(combatCard, "Auto Ability", "AutoAbility", CFG.AutoAbility)
    CreateToggle(combatCard, "No Stun", "NoStun", CFG.NoStun)
    
    local triggerCard = Card(tabFrames["Combat"], "🎯 TRIGGERBOT")
    CreateToggle(triggerCard, "Triggerbot", "Triggerbot", CFG.Triggerbot, function(s) if s then Triggerbot.Start() else Triggerbot.Stop() end end)
    CreateSlider(triggerCard, "Delay (s)", "TriggerbotDelay", 0.01, 0.3, CFG.TriggerbotDelay)
    
    -- SPAM
    local manualCard = Card(tabFrames["Spam"], "⚡ MANUAL SPAM")
    CreateToggle(manualCard, "Manual Spam", "ManualSpam", CFG.ManualSpam, function(s) if s then ManualSpam.Start() else ManualSpam.Stop() end end)
    CreateSlider(manualCard, "CPS", "ManualSpamCPS", 1, 200, CFG.ManualSpamCPS)
    CreateDropdown(manualCard, "Mode", "ManualSpamMode", {"Ball Speed", "Fixed", "Burst"}, CFG.ManualSpamMode)
    
    local autoCard = Card(tabFrames["Spam"], "🔄 AUTO SPAM")
    CreateToggle(autoCard, "Auto Spam", "AutoSpam", CFG.AutoSpam, function(s) if s then AutoSpam.Start() else AutoSpam.Stop() end end)
    CreateDropdown(autoCard, "Target", "AutoSpamMode", {"Closest", "Target", "Random"}, CFG.AutoSpamMode)
    
    -- VISUALS
    local espCard = Card(tabFrames["Visuals"], "👁️ ESP")
    CreateToggle(espCard, "Player ESP", "ESP", CFG.ESP, function(s) if s then ESP.Start() else ESP.Stop() end end)
    CreateToggle(espCard, "Show Health", "ESPShowHealth", CFG.ESPShowHealth)
    CreateToggle(espCard, "Show Distance", "ESPShowDistance", CFG.ESPShowDistance)
    CreateToggle(espCard, "Show Target", "ESPShowTarget", CFG.ESPShowTarget)
    CreateToggle(espCard, "Ball Speed Display", "BallSpeedShow", CFG.BallSpeedShow, function(s) if s then BallSpeedGui.Start() else BallSpeedGui.Stop() end end)
    CreateToggle(espCard, "Hitbox Expander", "HitboxExpander", CFG.HitboxExpander, function(s) if s then HitboxExpander.Start() else HitboxExpander.Stop() end end)
    CreateSlider(espCard, "Hitbox Size", "HitboxSize", 2, 20, CFG.HitboxSize)
    
    -- PLAYER
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
    
    -- SWORD
    local swordCard = Card(tabFrames["Sword"], "🗡️ SKIN CHANGER")
    CreateToggle(swordCard, "Skin Changer", "SkinChanger", CFG.SkinChanger, function(s) if not s then SkinChanger.Stop() end end)
    
    local swordInput = mk("TextBox", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = T.panel3, BorderSizePixel = 0, Text = CFG.SwordName, PlaceholderText = "输入武器名称", PlaceholderColor3 = T.muted, TextColor3 = T.text, Font = Enum.Font.GothamMedium, TextSize = 12, ClearTextOnFocus = false, Parent = swordCard})
    Instance.new("UICorner", swordInput).CornerRadius = UDim.new(0, 6)
    swordInput.FocusLost:Connect(function() CFG.SwordName = swordInput.Text end)
    
    CreateButton(swordCard, "🗡️ 应用武器", T.accent, function()
        CFG.SkinChanger = true
        SkinChanger.Apply(CFG.SwordName)
    end)
    
    local weaponList = Card(tabFrames["Sword"], "📋 常用武器")
    local commonSwords = {"Default", "Ice", "Lava", "Lightning", "Shadow", "Venom", "Wind", "Earth", "Plasma", "Dark Matter"}
    for _, sword in ipairs(commonSwords) do
        CreateButton(weaponList, sword, T.panel3, function()
            CFG.SwordName = sword
            swordInput.Text = sword
            CFG.SkinChanger = true
            SkinChanger.Apply(sword)
        end)
    end
    
    -- SETTINGS
    local settingsCard = Card(tabFrames["Settings"], "⚙️ 设置")
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "按 RightShift 打开/关闭 UI", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Version: ENRIQUE PAID v1.0", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Remote: " .. (ParryRemoteName or "Auto-detecting"), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.muted, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "discord.gg/hZhwszmP", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = T.accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsCard})
    
    CreateButton(settingsCard, "🔄 重新扫描 Remote", T.panel3, function()
        RemoteScanner.Scan()
        ParryRemote, ParryRemoteName = RemoteScanner.FindParryRemote()
        AbilityRemote = RemoteScanner.FindAbilityRemote()
        SwordRemote = RemoteScanner.FindSwordRemote()
        Notify("ENRIQUE", "扫描完成！找到: " .. (ParryRemoteName or "无"), 3)
    end)
    
    CreateButton(settingsCard, "🧹 卸载脚本", T.danger, function()
        AutoParry.Stop(); ManualSpam.Stop(); AutoSpam.Stop(); Triggerbot.Stop()
        ESP.Stop(); SkinChanger.Stop(); BallSpeedGui.Stop(); HitboxExpander.Stop()
        Misc.ToggleNoClip(false); Misc.ToggleFly(false)
        pcall(function() sg:Destroy() end)
        pcall(function() blur:Destroy() end)
        _G._ENRIQUE_PAID_LOADED = nil
        Notify("ENRIQUE", "脚本已卸载", 3)
    end)
    
    -- 拖动
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
    
    -- 最小化
    minBtn.MouseButton1Click:Connect(function()
        UI.Minimized = not UI.Minimized
        if UI.Minimized then tw(main, 0.25, {Size = UDim2.new(0, W, 0, 38)}); content.Visible = false; sidebar.Visible = false; banner.Visible = false; minBtn.Text = "+"
        else tw(main, 0.25, {Size = UDim2.new(0, W, 0, H)}); content.Visible = true; sidebar.Visible = true; banner.Visible = true; minBtn.Text = "—" end
    end)
    
    -- 关闭
    closeBtn.MouseButton1Click:Connect(function()
        UI.Open = false
        tw(overlay, 0.2, {BackgroundTransparency = 1})
        tw(blur, 0.25, {Size = 0})
        task.delay(0.25, function() sg.Visible = false end)
    end)
    
    -- 快捷键
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == CFG.UIKey then
            UI.Open = not UI.Open
            if UI.Open then
                sg.Visible = true; UI.Minimized = false
                main.Size = UDim2.new(0, W, 0, H)
                content.Visible = true; sidebar.Visible = true; banner.Visible = true; minBtn.Text = "—"
                tw(overlay, 0.2, {BackgroundTransparency = 0.5})
                tw(blur, 0.3, {Size = 12})
            else
                sg.Visible = false
            end
        end
    end)
    
    -- 更新剩余时间
    task.spawn(function()
        while sg and sg.Parent do
            task.wait(1)
            if timeLabel and timeLabel.Parent then
                local left = KeySystem.GetTimeLeft()
                timeLabel.Text = "🔑 " .. KeySystem.FormatTime(left)
                if left < 3600 then
                    timeLabel.TextColor3 = Color3.fromRGB(255, 70, 90)
                end
            end
        end
    end)
    
    -- 入场动画
    overlay.BackgroundTransparency = 1
    root.Size = UDim2.new(0, W-30, 0, H-20)
    tw(overlay, 0.25, {BackgroundTransparency = 0.5})
    tw(blur, 0.3, {Size = 12})
    tw(root, 0.35, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)
    
    UI.Window = sg
end

--============================================================--
-- 启动流程
--============================================================--
RemoteScanner.Scan()
ParryRemote, ParryRemoteName = RemoteScanner.FindParryRemote()
AbilityRemote = RemoteScanner.FindAbilityRemote()
SwordRemote = RemoteScanner.FindSwordRemote()
InitHook()

task.wait(0.3)

if KeySystem.Authenticated then
    -- 已验证，直接进主 UI
    UI.Create()
    Notify("⚔️ ENRIQUE PAID", "已激活！剩余: " .. KeySystem.FormatTime(KeySystem.GetTimeLeft()), 5)
else
    -- 显示 Key 验证界面
    ShowKeyUI(function()
        UI.Create()
        Notify("⚔️ ENRIQUE PAID", "激活成功！24小时有效\ndiscord.gg/hZhwszmP", 5)
    end)
end

print("⚔️ ENRIQUE PAID v1.0 — Fully Self-Contained")
print("Remote: " .. (ParryRemoteName or "Auto-detecting"))
print("Hook: " .. (Hook.hooked and "Active" or "Awaiting"))
print("Key: " .. (KeySystem.Authenticated and "Valid" or "Required"))
