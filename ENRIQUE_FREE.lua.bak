--=================================================================--
--  ⚔️  ENRIQUE BLADE BALL — FULLY SELF-CONTAINED v1.0
--  ✅ Auto Remote Scanner | ✅ Own Auto Parry | ✅ Own Manual Spam
--  ✅ No External Dependencies | ✅ Mobile + PC | ✅ Anti-Detection
--=================================================================--

-- Anti-reload
if _G._ENRIQUE_BB_LOADED then return end
_G._ENRIQUE_BB_LOADED = true

-- Wait for game
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
local LocalPlayer       = Players.LocalPlayer

--============================================================--
-- CONFIG
--============================================================--
local CFG = {
    -- Auto Parry
    AutoParry           = false,
    AutoParryMode       = "Remote",    -- Remote | Keypress
    AutoParryStrength   = 1.0,         -- 0.5 - 2.0
    ParryAccuracy       = 50,          -- 1-100
    PredictionMode      = "Auto Best", -- Auto Best | Manual
    PredictionOffset    = 0,           -- -1 to 1
    EmergencyShield     = true,
    CooldownProtection  = true,
    AutoAbility         = true,
    RetryStrength       = "Aggressive",-- Safe | Balanced | Aggressive | Maximum | Legendary
    NoStun              = true,
    -- Manual Spam
    ManualSpam          = false,
    ManualSpamCPS       = 30,          -- clicks per second
    ManualSpamMode      = "Ball Speed",-- Ball Speed | Fixed | Burst
    -- Auto Spam
    AutoSpam            = false,
    AutoSpamMode        = "Closest",   -- Closest | Target | Random
    AutoSpamDelay       = 0.02,
    -- Triggerbot
    Triggerbot          = false,
    TriggerbotDelay     = 0.08,
    -- Visuals
    ESP                 = false,
    ESPShowHealth      = true,
    ESPShowDistance     = true,
    ESPShowTarget       = true,
    BallESP             = false,
    -- Player
    WalkSpeed          = 16,
    JumpPower          = 50,
    NoClip             = false,
    AntiAFK            = true,
    -- Misc
    AntiKick           = true,
    FPSBoost           = false,
    -- UI
    UIKey              = Enum.KeyCode.RightShift,
    UIScale            = 1,
}

--============================================================--
-- UTILITY
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

local function WaitFor(obj, name, timeout)
    if obj:FindFirstChild(name) then return obj[name] end
    return obj:WaitForChild(name, timeout or 10)
end

local function GetPing()
    return LocalPlayer:GetNetworkPing() * 1000
end

--============================================================--
-- 🔍 REMOTE SCANNER — Auto-detects all Blade Ball remotes
--============================================================--
local Remotes = {}
local RemoteScanner = {}

function RemoteScanner.Scan()
    Remotes = {}
    
    -- Method 1: Check ReplicatedStorage.Remotes (standard BB structure)
    local rsRemotes = ReplicatedStorage:FindFirstChild("Remotes")
    if rsRemotes then
        for _, child in ipairs(rsRemotes:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                Remotes[child.Name] = child
            end
        end
    end
    
    -- Method 2: Scan ReplicatedStorage directly
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            if not Remotes[child.Name] then
                Remotes[child.Name] = child
            end
        end
    end
    
    -- Method 3: Check nested folders (some BB versions)
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
    
    -- Method 4: Hook-based discovery (captures real remote from gameplay)
    Remotes._hooked = {}
    
    return Remotes
end

-- Known Blade Ball remote names (try these first)
local KNOWN_REMOTE_NAMES = {
    "ParrySuccessAll", "ParrySuccess", "ParryAttempt",
    "AbilityButtonPress", "DeathSlashShootActivation",
    "FireSwordInfo", "PlaySound", "PlayVisuals",
    "Block", "Parry", "BlockButton",
    "RemoteEvent", "Server", "CombatClientRemoteEvent",
}

function RemoteScanner.FindParryRemote()
    -- Priority 1: Exact known names
    for _, name in ipairs(KNOWN_REMOTE_NAMES) do
        if Remotes[name] and Remotes[name]:IsA("RemoteEvent") then
            return Remotes[name], name
        end
    end
    -- Priority 2: Name pattern matching
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

-- Initial scan
RemoteScanner.Scan()
local ParryRemote, ParryRemoteName = RemoteScanner.FindParryRemote()
local AbilityRemote = RemoteScanner.FindAbilityRemote()

--============================================================--
-- 🪝 REMOTE HOOK — Captures real remote from gameplay
--============================================================--
local Hook = {
    remote = nil,
    f_raw = nil,
    args = {},
    hooked = false,
    PF = nil,  -- parry function from connections
}

local function InitHook()
    -- Capture PF from ParrySuccessAll connections
    task.spawn(function()
        while task.wait(5) do
            if not Hook.PF then
                SafeCall(function()
                    local rsRemotes = Remotes
                    for name, remote in pairs(rsRemotes) do
                        if remote:IsA("RemoteEvent") and type(name) == "string" then
                            local lower = name:lower()
                            if lower:find("parrysuccess") then
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
    
    -- Hookfunction approach
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
                    for i = 1, math.min(7, #args) do
                        Hook.args[i] = args[i]
                    end
                end
                return origFS(self, ...)
            end))
        end
    end)
    
    -- Metatable hook (backup)
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
                        for i = 1, math.min(7, #args) do
                            Hook.args[i] = args[i]
                        end
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
-- ⚔️ BALL TRACKER — Predicts ball trajectory
--============================================================--
local BallTracker = {
    track = {},
    currentBall = nil,
}

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
        if ball:GetAttribute("realBall") then
            return ball
        end
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
        
        -- Velocity smoothing via tracking
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
        
        -- Segment crossing detection
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
            position = position,
            time = now,
            velocity = rawVelocity,
            acceleration = rawAcceleration,
        }
        
        -- Ball approaching?
        local toPlayer = root.Position - position
        local distance = toPlayer.Magnitude
        local approaching = false
        local eta = math.huge
        
        if rawVelocity.Magnitude > 1 then
            local dirToPlayer = toPlayer.Unit
            local velDir = rawVelocity.Unit
            local dot = dirToPlayer:Dot(velDir)
            approaching = dot < -0.15
            
            if approaching and distance > 1 then
                local closingSpeed = rawVelocity.Magnitude * math.abs(dot)
                if closingSpeed > 1 then
                    eta = (distance - hitRadius) / closingSpeed
                end
            end
        end
        
        -- Acceleration correction
        if rawAcceleration.Magnitude > 10 then
            local accelCorrection = rawAcceleration.Magnitude * 0.001
            eta = eta - accelCorrection
        end
        
        return {
            velocity = rawVelocity,
            speed = rawVelocity.Magnitude,
            distance = distance,
            approaching = approaching,
            eta = math.max(eta, 0),
            closestDistance = segmentDistance,
            crossed = crossedHitSphere,
            position = position,
        }
    end)
    
    if ok then return result end
    return nil
end

--============================================================--
-- 🛡️ PARRY ENGINE — Core parry logic
--============================================================--
local ParryEngine = {
    parries = 0,
    lastSuccess = 0,
    lastAction = 0,
    cooldowns = {},
    armed = {},
    retries = {},
    ballWatchers = {},
}

local function FireParry(args)
    -- Method 1: Hooked remote
    if Hook.hooked and Hook.remote and Hook.f_raw then
        local a = {}
        for i = 1, 7 do a[i] = Hook.args[i] end
        if args then
            for k, v in pairs(args) do a[k] = v end
        end
        SafeCall(function() Hook.f_raw(Hook.remote, unpack(a)) end)
        return true
    end
    
    -- Method 2: Known remote
    if ParryRemote and ParryRemote:IsA("RemoteEvent") then
        SafeCall(function()
            if args and args.cframe then
                ParryRemote:FireServer(
                    args.sword or "Default",
                    args.target or "",
                    args.mode or 0,
                    args.cframe,
                    args.screenPos or Vector2.zero,
                    args.mousePos or Vector2.new(0.5, 0.5)
                )
            else
                ParryRemote:FireServer()
            end
        end)
        return true
    end
    
    -- Method 3: Keypress (PF)
    if Hook.PF then
        SafeCall(function() pcall(Hook.PF) end)
        return true
    end
    
    -- Method 4: SendButtonPress (last resort)
    SafeCall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            for _, child in ipairs(remotes:GetChildren()) do
                if child:IsA("RemoteEvent") then
                    local ok = pcall(function() child:FireServer() end)
                    if ok then return end
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
        if ParryEngine.parries > 0 then
            ParryEngine.parries = ParryEngine.parries - 1
        end
    end)
end

function ParryEngine.ExecuteAction()
    local now = tick()
    if now - ParryEngine.lastAction < 0.004 then return end
    ParryEngine.lastAction = now
    FireParry(nil)
end

--============================================================--
-- 🎯 AUTO PARRY — Main loop
--============================================================--
local AutoParry = {
    connection = nil,
    smoothFrameDelta = 1/60,
    frameDelta = 1/60,
}

function AutoParry.Start()
    if AutoParry.connection then
        AutoParry.connection:Disconnect()
    end
    
    -- Clear old watchers
    for ball, conn in pairs(ParryEngine.ballWatchers) do
        SafeCall(function() conn:Disconnect() end)
    end
    ParryEngine.ballWatchers = {}
    ParryEngine.cooldowns = {}
    ParryEngine.armed = {}
    ParryEngine.retries = {}
    
    AutoParry.connection = RunService.PreSimulation:Connect(function(deltaTime)
        AutoParry.frameDelta = deltaTime or 1/60
        AutoParry.smoothFrameDelta = AutoParry.smoothFrameDelta + 
            (math.clamp(AutoParry.frameDelta, 1/240, 1/12) - AutoParry.smoothFrameDelta) * 0.18
        
        if not CFG.AutoParry then return end
        if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
        
        local now = tick()
        local balls = BallTracker.GetAllBalls()
        
        -- Also check training balls
        local trainingBall = BallTracker.GetTrainingBall()
        
        for _, ball in ipairs(balls) do
            if not ball or not ball.Parent then continue end
            if not ball:FindFirstChild("zoomies") then continue end
            
            -- Set up target watcher
            if not ParryEngine.ballWatchers[ball] then
                ParryEngine.ballWatchers[ball] = ball:GetAttributeChangedSignal("target"):Connect(function()
                    local isTargeting = ball:GetAttribute("target") == LocalPlayer.Name
                    ParryEngine.armed[ball] = isTargeting
                    if isTargeting then
                        ParryEngine.cooldowns[ball] = 0
                    end
                end)
            end
            
            local ballTarget = ball:GetAttribute("target")
            if ParryEngine.armed[ball] == nil then
                ParryEngine.armed[ball] = (ballTarget == LocalPlayer.Name)
            end
            if not ParryEngine.armed[ball] then continue end
            
            -- Cooldown check
            if now < (ParryEngine.cooldowns[ball] or 0) then continue end
            
            -- Retry logic
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
            
            -- Core parry calculation
            local root = LocalPlayer.Character.PrimaryPart
            local velocity = BallTracker.GetVelocity(ball)
            local speed = velocity.Magnitude
            local distance = (root.Position - ball.Position).Magnitude
            local pingMs = GetPing()
            local latency = math.clamp(
                (pingMs / 1000) * math.clamp(CFG.AutoParryStrength, 0.75, 2.25),
                0.004, 0.58
            )
            local prediction = BallTracker.GetPrediction(ball, root)
            
            -- Skip special states
            if ball:FindFirstChild("ComboCounter") then continue end
            if root:FindFirstChild("SingularityCape") then continue end
            
            -- Tornado check
            if Workspace:FindFirstChild("Runtime") and Workspace.Runtime:FindFirstChild("Tornado") then
                local tornadoTime = Workspace.Runtime.Tornado:GetAttribute("TornadoTime") or 1
                if (tick() - (ParryEngine._tornadoTime or 0)) < tornadoTime + 0.3 then
                    continue
                end
            end
            
            -- Warping/bouncing ball speed detection
            if ball:GetAttribute("warping") or ball:GetAttribute("bouncing") then
                local warpSpeed = ball:GetAttribute("warpSpeed") or speed
                if warpSpeed > speed * 1.5 then
                    speed = warpSpeed
                end
            end
            
            -- Trigger window calculation
            local autoBest = CFG.PredictionMode == "Auto Best"
            local timingBias = math.clamp(CFG.PredictionOffset, -1, 1) * 0.075
            local triggerWindow
            
            if autoBest then
                local speedUncertainty = speed >= 250
                    and 0.010 + math.min((speed - 250) / 6500, 0.032)
                    or 0.003 + math.min(speed / 30000, 0.008)
                local processingMargin = 0.118
                    + AutoParry.smoothFrameDelta * 0.98
                    + speedUncertainty
                
                triggerWindow = latency * 2.45 + processingMargin
                if CFG.EmergencyShield then
                    triggerWindow = triggerWindow + 0.052
                end
                
                -- Speed-based brackets
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
            
            -- Prediction-based firing
            if prediction and speed >= 45 then
                local hitRadius = math.max(26, 15 + speed * 0.022)
                if CFG.EmergencyShield then hitRadius = hitRadius + 5 end
                shouldFire = prediction.approaching
                    and prediction.eta <= triggerWindow
                    and (prediction.closestDistance <= hitRadius or prediction.crossed)
                    and distance <= maxTriggerDist + (prediction.crossed and 25 or 0)
            else
                -- Close range fallback
                local closeRange = math.clamp(
                    (26 + pingMs * 0.045 + speed * 0.062) * parryStr,
                    24, 160
                )
                shouldFire = distance <= closeRange
            end
            
            -- Heading check
            local headingToPlayer = true
            if speed > 1 then
                local toPlayer = root.Position - ball.Position
                headingToPlayer = toPlayer.Magnitude <= 1 or (toPlayer.Unit):Dot(velocity.Unit) > -0.20
            end
            
            -- Emergency shield (more aggressive)
            if CFG.EmergencyShield and not shouldFire then
                local emergencyRange = math.max(32,
                    speed * (latency + AutoParry.smoothFrameDelta * 0.5) + 35
                ) * parryStr
                shouldFire = distance <= emergencyRange
                if not shouldFire and distance < 18 then
                    shouldFire = true
                end
            end
            
            -- FIRE!
            if ballTarget == LocalPlayer.Name and shouldFire and headingToPlayer then
                -- Cooldown protection
                if CFG.CooldownProtection then
                    SafeCall(function()
                        local hotbar = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                        if hotbar then
                            local block = hotbar:FindFirstChild("Block")
                            if block and block:FindFirstChild("UIGradient") then
                                if block.UIGradient.Offset.Y < 0.4 then
                                    if AbilityRemote then
                                        SafeCall(function() AbilityRemote:Fire() end)
                                    end
                                    ParryEngine.cooldowns[ball] = now + 0.06
                                    continue
                                end
                            end
                        end
                    end)
                end
                
                -- Auto ability
                if CFG.AutoAbility then
                    SafeCall(function()
                        local hotbar = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                        if hotbar then
                            local ability = hotbar:FindFirstChild("Ability")
                            if ability and ability:FindFirstChild("UIGradient") then
                                if ability.UIGradient.Offset.Y == 0.5 then
                                    local abilities = LocalPlayer.Character:FindFirstChild("Abilities")
                                    if abilities then
                                        local hasUsable = false
                                        for _, ab in ipairs(abilities:GetChildren()) do
                                            if ab:IsA("BoolValue") and ab.Enabled then
                                                hasUsable = true
                                                break
                                            end
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
                        end
                    end)
                end
                
                -- Execute parry
                ParryEngine.Execute()
                ParryEngine.armed[ball] = false
                ParryEngine.cooldowns[ball] = now + 0.12
                
                -- Retry scheduling
                local retryThreshold = 210
                if CFG.RetryStrength == "Safe" then retryThreshold = 260
                elseif CFG.RetryStrength == "Balanced" then retryThreshold = 220
                elseif CFG.RetryStrength == "Aggressive" then retryThreshold = 180
                elseif CFG.RetryStrength == "Maximum" then retryThreshold = 150
                elseif CFG.RetryStrength == "Legendary" then retryThreshold = 120
                end
                
                if speed >= retryThreshold then
                    local remaining = 2
                    if CFG.RetryStrength == "Balanced" then remaining = speed >= 290 and 3 or 2
                    elseif CFG.RetryStrength == "Aggressive" then remaining = speed >= 260 and 4 or 3
                    elseif CFG.RetryStrength == "Maximum" then remaining = speed >= 330 and 6 or 5
                    elseif CFG.RetryStrength == "Legendary" then remaining = speed >= 200 and 15 or 10
                    end
                    
                    ParryEngine.retries[ball] = {
                        remaining = remaining,
                        nextTime = now + math.max(0.016, AutoParry.smoothFrameDelta * 0.58),
                    }
                end
            end
        end
        
        -- Training ball handling
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
    if AutoParry.connection then
        AutoParry.connection:Disconnect()
        AutoParry.connection = nil
    end
    for ball, conn in pairs(ParryEngine.ballWatchers) do
        SafeCall(function() conn:Disconnect() end)
    end
    ParryEngine.ballWatchers = {}
end

--============================================================--
-- ⚡ MANUAL SPAM — Rapid fire
--============================================================--
local ManualSpam = {
    connection = nil,
    accumulator = 0,
    lastFrame = 0,
}

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
        ManualSpam.accumulator = ManualSpam.accumulator + quota
        
        local interval = 1 / math.max(CFG.ManualSpamCPS, 1)
        local ball = BallTracker.GetBall()
        
        -- Ball speed adaptive
        if CFG.ManualSpamMode == "Ball Speed" and ball then
            local vel = BallTracker.GetVelocity(ball)
            local speed = vel.Magnitude
            if speed > 200 then
                quota = quota * (1 + speed / 1000)
            end
        end
        
        local count = math.min(math.floor(ManualSpam.accumulator), 512)
        if count < 1 then return end
        
        ManualSpam.accumulator = ManualSpam.accumulator - count
        
        for i = 1, count do
            FireParry(nil)
        end
    end)
end

function ManualSpam.Stop()
    if ManualSpam.connection then
        ManualSpam.connection:Disconnect()
        ManualSpam.connection = nil
    end
    ManualSpam.accumulator = 0
end

--============================================================--
-- 🔄 AUTO SPAM — Automatic spam targeting
--============================================================--
local AutoSpam = {
    connection = nil,
    accumulator = 0,
    lastFrame = 0,
}

function AutoSpam.GetClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
    if not root then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
            local dist = (root.Position - player.Character.PrimaryPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end
    return closest
end

function AutoSpam.Start()
    if AutoSpam.connection then AutoSpam.connection:Disconnect() end
    AutoSpam.accumulator = 0
    AutoSpam.lastFrame = tick()
    
    AutoSpam.connection = RunService.PreSimulation:Connect(function(dt)
        if not CFG.AutoSpam then return end
        if not CFG.ManualSpam then return end  -- Needs manual spam enabled
        
        local now = tick()
        local frameDelta = now - AutoSpam.lastFrame
        AutoSpam.lastFrame = now
        
        -- Check if ball is targeting us
        local ball = BallTracker.GetBall()
        if not ball then return end
        local target = ball:GetAttribute("target")
        if target ~= LocalPlayer.Name then return end
        
        -- Get ball speed for adaptive spam
        local vel = BallTracker.GetVelocity(ball)
        local speed = vel.Magnitude
        local baseCPS = CFG.ManualSpamCPS
        
        -- Adaptive CPS based on ball speed
        if speed > 300 then
            baseCPS = baseCPS * 1.5
        elseif speed > 600 then
            baseCPS = baseCPS * 2.0
        end
        
        local quota = baseCPS * frameDelta
        AutoSpam.accumulator = AutoSpam.accumulator + quota
        
        -- Burst mode when ball is close
        local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if root then
            local dist = (root.Position - ball.Position).Magnitude
            if dist < 30 then
                AutoSpam.accumulator = AutoSpam.accumulator + quota * 0.5
            end
        end
        
        local count = math.min(math.floor(AutoSpam.accumulator), 512)
        if count < 1 then return end
        AutoSpam.accumulator = AutoSpam.accumulator - count
        
        for i = 1, count do
            FireParry(nil)
        end
    end)
end

function AutoSpam.Stop()
    if AutoSpam.connection then
        AutoSpam.connection:Disconnect()
        AutoSpam.connection = nil
    end
    AutoSpam.accumulator = 0
end

--============================================================--
-- 🎯 TRIGGERBOT
--============================================================--
local Triggerbot = {
    connection = nil,
}

function Triggerbot.Start()
    if Triggerbot.connection then Triggerbot.connection:Disconnect() end
    
    Triggerbot.connection = RunService.PreSimulation:Connect(function()
        if not CFG.Triggerbot then return end
        local ball = BallTracker.GetBall()
        if not ball then return end
        local target = ball:GetAttribute("target")
        if target ~= LocalPlayer.Name then return end
        
        local vel = BallTracker.GetVelocity(ball)
        local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if not root then return end
        local dist = (root.Position - ball.Position).Magnitude
        
        if dist < 25 then
            FireParry(nil)
        end
    end)
end

function Triggerbot.Stop()
    if Triggerbot.connection then
        Triggerbot.connection:Disconnect()
        Triggerbot.connection = nil
    end
end

--============================================================--
-- 👁️ ESP
--============================================================--
local ESP = {
    enabled = false,
    objects = {},
    connection = nil,
}

function ESP.Start()
    if ESP.connection then ESP.connection:Disconnect() end
    ESP.enabled = true
    
    ESP.connection = RunService.RenderStepped:Connect(function()
        if not CFG.ESP then
            ESP.Stop()
            return
        end
        
        -- Clean old objects
        for _, obj in pairs(ESP.objects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        ESP.objects = {}
        
        local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if not root then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
                local char = player.Character
                local hrp = char.PrimaryPart
                if hrp then
                    local dist = (root.Position - hrp.Position).Magnitude
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    
                    if onScreen then
                        -- Name + distance
                        local text = player.Name
                        if CFG.ESPShowDistance then
                            text = text .. " [" .. math.floor(dist) .. "m]"
                        end
                        if CFG.ESPShowHealth and char:FindFirstChild("Humanoid") then
                            text = text .. " [" .. math.floor(char.Humanoid.Health) .. " HP]"
                        end
                        
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ENRIQUE_ESP"
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Adornee = hrp
                        billboard.Parent = game:GetService("CoreGui")
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 0.5
                        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextScaled = true
                        label.Font = Enum.Font.GothamBold
                        label.Text = text
                        label.Parent = billboard
                        
                        -- Highlight target
                        local espBall = BallTracker.GetBall()
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
        end
    end)
end

function ESP.Stop()
    if ESP.connection then
        ESP.connection:Disconnect()
        ESP.connection = nil
    end
    for _, obj in pairs(ESP.objects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    ESP.objects = {}
    ESP.enabled = false
end

--============================================================--
-- 🔧 MISC FEATURES
--============================================================--
local Misc = {
    noClipConn = nil,
    afkConn = nil,
}

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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
    end
end

function Misc.StartAntiAFK()
    if Misc.afkConn then return end
    Misc.afkConn = game:GetService("VirtualUser").Button2Down:Connect(function()
        -- Anti AFK
    end)
    SafeCall(function()
        LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end)
end

-- Auto-respawn on death
task.spawn(function()
    while task.wait(2) do
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
end)

-- Apply walkspeed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    Misc.SetWalkSpeed(CFG.WalkSpeed)
    Misc.SetJumpPower(CFG.JumpPower)
    
    -- Re-arm auto parry
    if CFG.AutoParry then
        AutoParry.Start()
    end
end)

-- Anti-kick (virtual user spam)
if CFG.AntiKick then
    task.spawn(function()
        while task.wait(30) do
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
            end)
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
            if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end
    end)
end

--============================================================--
-- 🎨 FULL UI — ENRIQUE BRANDED
--============================================================--
local UI = {}
UI.Window = nil
UI.CurrentTab = "Combat"
UI.Minimized = false
UI.Open = true

-- Theme
local T = {
    bg          = Color3.fromRGB(12, 10, 20),
    panel       = Color3.fromRGB(18, 16, 28),
    panel2      = Color3.fromRGB(26, 22, 38),
    panel3      = Color3.fromRGB(34, 28, 48),
    stroke      = Color3.fromRGB(80, 40, 120),
    strokeHi    = Color3.fromRGB(180, 60, 255),
    text        = Color3.fromRGB(240, 235, 255),
    subtext     = Color3.fromRGB(160, 145, 185),
    muted       = Color3.fromRGB(100, 90, 120),
    accent      = Color3.fromRGB(180, 60, 255),
    accentHi    = Color3.fromRGB(210, 100, 255),
    accentDim   = Color3.fromRGB(120, 40, 170),
    danger      = Color3.fromRGB(255, 70, 90),
    success     = Color3.fromRGB(80, 255, 140),
    warning     = Color3.fromRGB(255, 200, 60),
    toggleOn    = Color3.fromRGB(180, 60, 255),
    toggleOff   = Color3.fromRGB(50, 45, 65),
    cardBg      = Color3.fromRGB(22, 18, 34),
}

-- Anime image IDs for decoration
local ANIME_IDS = {
    "133575691569801",  -- Header banner
    "105587462408321",  -- Sidebar icon
    "11642789352",      -- Alt banner
}

-- Helpers
local function mk(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function tween(inst, t, props, style, dir)
    local tw = TweenService:Create(inst, TweenInfo.new(
        t or 0.2,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    ), props)
    tw:Play()
    return tw
end

--============================================================--
-- TOGGLE WIDGET
--============================================================--
local function CreateToggle(parent, label, flag, default, callback)
    local frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    
    local labelText = mk("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    
    local state = default or false
    
    local toggleBg = mk("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -42, 0.5, -10),
        BackgroundColor3 = state and T.toggleOn or T.toggleOff,
        Parent = frame,
    })
    mk("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleBg})
    
    local dot = mk("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = state and Color3.new(1, 1, 1) or T.muted,
        Parent = toggleBg,
    })
    mk("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dot})
    
    local function UpdateVisual()
        tween(toggleBg, 0.15, {BackgroundColor3 = state and T.toggleOn or T.toggleOff})
        tween(dot, 0.15, {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = state and Color3.new(1, 1, 1) or T.muted,
        })
    end
    
    -- Click area
    local clickArea = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame,
    })
    
    clickArea.MouseButton1Click:Connect(function()
        state = not state
        CFG[flag] = state
        UpdateVisual()
        if callback then callback(state) end
    end)
    
    return {SetState = function(s) state = s; CFG[flag] = s; UpdateVisual() end, GetState = function() return state end}
end

--============================================================--
-- SLIDER WIDGET
--============================================================--
local function CreateSlider(parent, label, flag, min, max, default, callback)
    local frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    
    mk("TextLabel", {
        Size = UDim2.new(0.65, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = T.subtext,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    
    local valueLabel = mk("TextLabel", {
        Size = UDim2.new(0.35, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = T.accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })
    
    local trackBg = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = T.panel3,
        Parent = frame,
    })
    mk("UICorner", {CornerRadius = UDim.new(1, 0), Parent = trackBg})
    
    local fill = mk("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = T.accent,
        Parent = trackBg,
    })
    mk("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
    
    local knob = mk("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = trackBg,
    })
    mk("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    
    local dragging = false
    local currentVal = default
    
    local function updateSlider(inputX)
        local absPos = trackBg.AbsolutePosition.X
        local absSize = trackBg.AbsoluteSize.X
        local pct = math.clamp((inputX - absPos) / absSize, 0, 1)
        currentVal = min + (max - min) * pct
        if max <= 10 then currentVal = math.floor(currentVal * 10) / 10 end
        
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        valueLabel.Text = tostring(currentVal)
        CFG[flag] = currentVal
        if callback then callback(currentVal) end
    end
    
    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return {SetValue = function(v) currentVal = v; CFG[flag] = v end}
end

--============================================================--
-- DROPDOWN WIDGET
--============================================================--
local function CreateDropdown(parent, label, flag, options, default, callback)
    local frame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = T.subtext,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    
    local current = default or options[1]
    
    local dropBtn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = T.panel3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 6), Parent = dropBtn})
    
    local dropLabel = mk("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = current,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropBtn,
    })
    
    local arrow = mk("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = T.muted,
        Parent = dropBtn,
    })
    
    local listFrame = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, #options * 28),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = T.panel2,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.accent,
        CanvasSize = UDim2.new(0, 0, 0, #options * 28),
        Visible = false,
        ZIndex = 10,
        Parent = frame,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 6), Parent = listFrame})
    mk("UIListLayout", {Padding = UDim.new(0, 2), Parent = listFrame})
    
    for _, opt in ipairs(options) do
        local optBtn = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = T.panel3,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Text = "  " .. opt,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = T.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 11,
            Parent = listFrame,
        })
        mk("UICorner", {CornerRadius = UDim.new(0, 4), Parent = optBtn})
        
        optBtn.MouseButton1Click:Connect(function()
            current = opt
            dropLabel.Text = opt
            CFG[flag] = opt
            listFrame.Visible = false
            arrow.Text = "▼"
            if callback then callback(opt) end
        end)
    end
    
    dropBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        arrow.Text = listFrame.Visible and "▲" or "▼"
    end)
    
    return {SetValue = function(v) current = v; dropLabel.Text = v; CFG[flag] = v end}
end

--============================================================--
-- BUTTON WIDGET
--============================================================--
local function CreateButton(parent, label, color, callback)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = color or T.accent,
        BorderSizePixel = 0,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Parent = parent,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    
    btn.MouseEnter:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = T.accentHi})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = color or T.accent})
    end)
    btn.MouseButton1Click:Connect(function()
        tween(btn, 0.06, {Size = UDim2.new(0.98, 0, 0, 30)})
        task.delay(0.06, function()
            tween(btn, 0.1, {Size = UDim2.new(1, 0, 0, 32)})
        end)
        if callback then callback() end
    end)
    
    return btn
end

--============================================================--
-- MAIN WINDOW
--============================================================--
function UI.Create()
    -- Cleanup old
    if UI.Window and UI.Window.Parent then UI.Window:Destroy() end
    -- Remove screen guis with same name
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name == "ENRIQUE_BB" then gui:Destroy() end
    end
    pcall(function()
        local cg = game:GetService("CoreGui"):FindFirstChild("ENRIQUE_BB")
        if cg then cg:Destroy() end
    end)
    
    local W, H = 440, 380
    
    local sg = mk("ScreenGui", {
        Name = "ENRIQUE_BB",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 9999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
    })
    pcall(function()
        local hui = gethui and gethui()
        if hui then sg.Parent = hui end
    end)
    
    -- Overlay
    local overlay = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = sg,
    })
    
    -- Blur
    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})
    
    -- Root
    local root = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, W, 0, H),
        BackgroundTransparency = 1,
        Parent = sg,
    })
    
    -- Shadow
    local shadow = mk("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = root,
    })
    
    -- Main panel
    local main = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.bg,
        BorderSizePixel = 0,
        Parent = root,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 12), Parent = main})
    mk("UIStroke", {Color = T.stroke, Thickness = 1, Transparency = 0.3, Parent = main})
    mk("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 16, 32)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 20)),
        }),
        Parent = main,
    })
    
    -- Title bar
    local titleBar = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = main,
    })
    
    local titleAccent = mk("Frame", {
        Size = UDim2.new(0, 4, 0, 14),
        Position = UDim2.new(0, 14, 0.5, -7),
        BackgroundColor3 = T.accent,
        Parent = titleBar,
    })
    mk("UICorner", {CornerRadius = UDim.new(1, 0), Parent = titleAccent})
    
    mk("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "⚔️ ENRIQUE BLADE BALL",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = T.accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })
    
    mk("Frame", {
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.new(0, 14, 1, 0),
        BackgroundColor3 = T.stroke,
        BackgroundTransparency = 0.6,
        Parent = titleBar,
    })
    
    -- Minimize button
    local minBtn = mk("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0, 5),
        BackgroundColor3 = T.panel2,
        BorderSizePixel = 0,
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = T.subtext,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minBtn})
    
    -- Close button
    local closeBtn = mk("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundColor3 = T.panel2,
        BorderSizePixel = 0,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = T.subtext,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 6), Parent = closeBtn})
    
    -- Anime banner
    local banner = mk("ImageLabel", {
        Size = UDim2.new(1, -24, 0, 50),
        Position = UDim2.new(0, 12, 0, 42),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. ANIME_IDS[1],
        ScaleType = Enum.ScaleType.Crop,
        Parent = main,
    })
    mk("UICorner", {CornerRadius = UDim.new(0, 8), Parent = banner})
    mk("UIStroke", {Color = T.accent, Thickness = 1, Transparency = 0.4, Parent = banner})
    
    -- Sidebar
    local sidebar = mk("Frame", {
        Size = UDim2.new(0, 130, 1, -104),
        Position = UDim2.new(0, 0, 0, 98),
        BackgroundTransparency = 1,
        Parent = main,
    })
    
    -- Content area
    local content = mk("ScrollingFrame", {
        Size = UDim2.new(1, -144, 1, -104),
        Position = UDim2.new(0, 138, 0, 98),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.accent,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = main,
    })
    mk("UIListLayout", {Padding = UDim.new(0, 6), Parent = content})
    mk("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = content})
    
    -- Tab definitions
    local TABS = {
        {name = "Combat",   icon = "⚔️"},
        {name = "Spam",     icon = "⚡"},
        {name = "Visuals",  icon = "👁️"},
        {name = "Player",   icon = "🏃"},
        {name = "Settings", icon = "⚙️"},
    }
    
    local tabButtons = {}
    local tabFrames = {}
    local currentTab = "Combat"
    
    -- Create tab buttons and content frames
    for i, tab in ipairs(TABS) do
        local tabBtn = mk("TextButton", {
            Size = UDim2.new(1, -8, 0, 30),
            Position = UDim2.new(0, 4, 0, (i - 1) * 34),
            BackgroundColor3 = T.panel2,
            BorderSizePixel = 0,
            Text = "  " .. tab.icon .. " " .. tab.name,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = T.subtext,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = sidebar,
        })
        mk("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})
        
        local tabFrame = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = (tab.name == "Combat"),
            Parent = content,
        })
        mk("UIListLayout", {Padding = UDim.new(0, 4), Parent = tabFrame})
        
        tabButtons[tab.name] = tabBtn
        tabFrames[tab.name] = tabFrame
        
        tabBtn.MouseButton1Click:Connect(function()
            currentTab = tab.name
            for name, btn in pairs(tabButtons) do
                if name == tab.name then
                    tween(btn, 0.12, {BackgroundColor3 = T.accentDim})
                    btn.TextColor3 = Color3.new(1, 1, 1)
                else
                    tween(btn, 0.12, {BackgroundColor3 = T.panel2})
                    btn.TextColor3 = T.subtext
                end
            end
            for name, frame in pairs(tabFrames) do
                frame.Visible = (name == tab.name)
            end
        end)
    end
    
    -- Highlight first tab
    tween(tabButtons["Combat"], 0, {BackgroundColor3 = T.accentDim})
    tabButtons["Combat"].TextColor3 = Color3.new(1, 1, 1)
    
    -- Card helper
    local function Card(parent, title)
        local card = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.cardBg,
            BorderSizePixel = 0,
            Parent = parent,
        })
        mk("UICorner", {CornerRadius = UDim.new(0, 8), Parent = card})
        mk("UIStroke", {Color = T.stroke, Thickness = 0.5, Transparency = 0.5, Parent = card})
        mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = card})
        mk("UIListLayout", {Padding = UDim.new(0, 4), Parent = card})
        
        if title then
            mk("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = T.accent,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card,
            })
        end
        
        return card
    end
    
    --============================================================--
    -- TAB: COMBAT
    --============================================================--
    local combatCard = Card(tabFrames["Combat"], "🛡️ AUTO PARRY")
    CreateToggle(combatCard, "Auto Parry", "AutoParry", CFG.AutoParry, function(state)
        if state then AutoParry.Start() else AutoParry.Stop() end
    end)
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
    CreateToggle(triggerCard, "Triggerbot", "Triggerbot", CFG.Triggerbot, function(state)
        if state then Triggerbot.Start() else Triggerbot.Stop() end
    end)
    CreateSlider(triggerCard, "Delay (s)", "TriggerbotDelay", 0.01, 0.3, CFG.TriggerbotDelay)
    
    --============================================================--
    -- TAB: SPAM
    --============================================================--
    local manualCard = Card(tabFrames["Spam"], "⚡ MANUAL SPAM")
    CreateToggle(manualCard, "Manual Spam", "ManualSpam", CFG.ManualSpam, function(state)
        if state then ManualSpam.Start() else ManualSpam.Stop() end
    end)
    CreateSlider(manualCard, "CPS", "ManualSpamCPS", 1, 200, CFG.ManualSpamCPS)
    CreateDropdown(manualCard, "Mode", "ManualSpamMode", {"Ball Speed", "Fixed", "Burst"}, CFG.ManualSpamMode)
    
    local autoCard = Card(tabFrames["Spam"], "🔄 AUTO SPAM")
    CreateToggle(autoCard, "Auto Spam", "AutoSpam", CFG.AutoSpam, function(state)
        if state then AutoSpam.Start() else AutoSpam.Stop() end
    end)
    CreateDropdown(autoCard, "Target", "AutoSpamMode", {"Closest", "Target", "Random"}, CFG.AutoSpamMode)
    CreateSlider(autoCard, "Delay (s)", "AutoSpamDelay", 0.005, 0.1, CFG.AutoSpamDelay)
    
    --============================================================--
    -- TAB: VISUALS
    --============================================================--
    local espCard = Card(tabFrames["Visuals"], "👁️ ESP")
    CreateToggle(espCard, "Player ESP", "ESP", CFG.ESP, function(state)
        if state then ESP.Start() else ESP.Stop() end
    end)
    CreateToggle(espCard, "Show Health", "ESPShowHealth", CFG.ESPShowHealth)
    CreateToggle(espCard, "Show Distance", "ESPShowDistance", CFG.ESPShowDistance)
    CreateToggle(espCard, "Show Target", "ESPShowTarget", CFG.ESPShowTarget)
    CreateToggle(espCard, "Ball ESP", "BallESP", CFG.BallESP)
    
    --============================================================--
    -- TAB: PLAYER
    --============================================================--
    local moveCard = Card(tabFrames["Player"], "🏃 MOVEMENT")
    CreateSlider(moveCard, "Walk Speed", "WalkSpeed", 16, 200, CFG.WalkSpeed, function(v)
        Misc.SetWalkSpeed(v)
    end)
    CreateSlider(moveCard, "Jump Power", "JumpPower", 50, 200, CFG.JumpPower, function(v)
        Misc.SetJumpPower(v)
    end)
    CreateToggle(moveCard, "No Clip", "NoClip", CFG.NoClip, function(state)
        Misc.ToggleNoClip(state)
    end)
    
    local miscCard = Card(tabFrames["Player"], "🔧 MISC")
    CreateToggle(miscCard, "Anti AFK", "AntiAFK", CFG.AntiAFK, function(state)
        if state then Misc.StartAntiAFK() end
    end)
    CreateToggle(miscCard, "Anti Kick", "AntiKick", CFG.AntiKick)
    CreateToggle(miscCard, "FPS Boost", "FPSBoost", CFG.FPSBoost)
    
    --============================================================--
    -- TAB: SETTINGS
    --============================================================--
    local settingsCard = Card(tabFrames["Settings"], "⚙️ SETTINGS")
    
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "Toggle UI: Right Shift",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = T.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = settingsCard,
    })
    
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "Version: ENRIQUE BB v1.0",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = T.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = settingsCard,
    })
    
    CreateButton(settingsCard, "🔄 Rescan Remotes", T.panel3, function()
        RemoteScanner.Scan()
        ParryRemote, ParryRemoteName = RemoteScanner.FindParryRemote()
        AbilityRemote = RemoteScanner.FindAbilityRemote()
        Notify("ENRIQUE", "Remotes rescanned! Found: " .. (ParryRemoteName or "none"), 3)
    end)
    
    CreateButton(settingsCard, "📋 Show Remotes", T.panel3, function()
        local list = {}
        for name, remote in pairs(Remotes) do
            if type(name) == "string" and not name:find("_") then
                table.insert(list, name)
            end
        end
        table.sort(list)
        Notify("ENRIQUE", "Remotes: " .. table.concat(list, ", "), 10)
    end)
    
    CreateButton(settingsCard, "🧹 Unload Script", T.danger, function()
        AutoParry.Stop()
        ManualSpam.Stop()
        AutoSpam.Stop()
        Triggerbot.Stop()
        ESP.Stop()
        pcall(function() sg:Destroy() end)
        pcall(function() blur:Destroy() end)
        _G._ENRIQUE_BB_LOADED = nil
        Notify("ENRIQUE", "Script unloaded", 3)
    end)
    
    -- Discord
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "discord.gg/hZhwszmP",
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = T.accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = settingsCard,
    })
    
    --============================================================--
    -- DRAGGING
    --============================================================--
    local dragging, dragStart, startPos = false
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Minimize
    minBtn.MouseButton1Click:Connect(function()
        UI.Minimized = not UI.Minimized
        if UI.Minimized then
            tween(main, 0.25, {Size = UDim2.new(0, W, 0, 38)})
            content.Visible = false
            sidebar.Visible = false
            banner.Visible = false
            minBtn.Text = "+"
        else
            tween(main, 0.25, {Size = UDim2.new(0, W, 0, H)})
            content.Visible = true
            sidebar.Visible = true
            banner.Visible = true
            minBtn.Text = "—"
        end
    end)
    
    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        UI.Open = false
        tween(overlay, 0.2, {BackgroundTransparency = 1})
        tween(blur, 0.25, {Size = 0})
        tween(root, 0.22, {
            Size = UDim2.new(0, W - 30, 0, H - 20),
            -- We don't change GroupTransparency since it's a Frame
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.25, function()
            sg.Visible = false
            minBtn.Text = "+"
            UI.Minimized = true
        end)
    end)
    
    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == CFG.UIKey then
            UI.Open = not UI.Open
            if UI.Open then
                sg.Visible = true
                UI.Minimized = false
                main.Size = UDim2.new(0, W, 0, H)
                content.Visible = true
                sidebar.Visible = true
                banner.Visible = true
                minBtn.Text = "—"
                tween(overlay, 0.2, {BackgroundTransparency = 0.5})
                tween(blur, 0.3, {Size = 12})
                root.Size = UDim2.new(0, W - 30, 0, H - 20)
                tween(root, 0.3, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)
            else
                sg.Visible = false
            end
        end
    end)
    
    -- Fade in
    overlay.BackgroundTransparency = 1
    root.Size = UDim2.new(0, W - 30, 0, H - 20)
    tween(overlay, 0.25, {BackgroundTransparency = 0.5})
    tween(blur, 0.3, {Size = 12})
    tween(root, 0.35, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)
    
    UI.Window = sg
    return sg
end

--============================================================--
-- INIT
--============================================================--
RemoteScanner.Scan()
ParryRemote, ParryRemoteName = RemoteScanner.FindParryRemote()
AbilityRemote = RemoteScanner.FindAbilityRemote()
InitHook()

task.wait(0.5)
UI.Create()

Notify("⚔️ ENRIQUE BB v1.0", 
    "Loaded! Press RightShift to toggle UI\nRemote: " .. (ParryRemoteName or "Auto-detecting") .. 
    "\ndiscord.gg/hZhwszmP", 5)

print("⚔️ ENRIQUE BLADE BALL v1.0 — Fully Self-Contained")
print("Remote: " .. (ParryRemoteName or "Auto-detecting"))
print("Hook: " .. (Hook.hooked and "Active" or "Awaiting"))
print("PF: " .. (Hook.PF and "Captured" or "Awaiting"))
