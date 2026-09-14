--=================================================================--
--  ⚔️  ENRIQUE BLADE BALL — PAID v2.0 (动漫 UI + PRY 检测)
--  ✅ PRY 模块自动发现真正的 Remote | ✅ 动漫界面
--  ✅ 完全独立 | ✅ 24小时 Key | ✅ 手机+电脑
--=================================================================--

if _G._ENRIQUE_PAID_V2 then return end
_G._ENRIQUE_PAID_V2 = true

if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

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
local LocalPlayer       = Players.LocalPlayer

--============================================================--
-- KEY SYSTEM
--============================================================--
local KEY_FILE = "enrique_paid_v2_key.txt"
local KEY_TTL  = 86400

local KeySys = { Authenticated = false, Key = nil, ExpiresAt = 0 }

local VALID_KEYS = {
    ["ENRIQUE-PAID-75J83-5DCGH-NE99M-S9SSF"] = true,
}

function KeySys.Validate(key)
    if not key or #key < 10 then return false end
    if VALID_KEYS[key] then return true end
    if key:match("^ENRIQUE%-PAID%-[%w]+%-[%w]+%-[%w]+%-[%w]+$") then return true end
    return false
end

function KeySys.CheckStored()
    local ok, data = pcall(readfile, KEY_FILE)
    if not ok or not data then return false end
    local t, k = data:match("^(%d+):(.+)$")
    if not t or not k then return false end
    t = tonumber(t)
    if not t or os.clock() - t > KEY_TTL then pcall(delfile, KEY_FILE); return false end
    if KeySys.Validate(k) then
        KeySys.Authenticated = true
        KeySys.Key = k
        KeySys.ExpiresAt = t + KEY_TTL
        return true
    end
    return false
end

function KeySys.Save(key)
    KeySys.Authenticated = true
    KeySys.Key = key
    KeySys.ExpiresAt = os.clock() + KEY_TTL
    pcall(writefile, KEY_FILE, os.clock() .. ":" .. key)
end

function KeySys.TimeLeft()
    return math.max(0, (KeySys.ExpiresAt or 0) - os.clock())
end

function KeySys.FormatTime(s)
    return string.format("%02d:%02d:%02d", math.floor(s/3600), math.floor((s%3600)/60), math.floor(s%60))
end

KeySys.CheckStored()

--============================================================--
-- 工具
--============================================================--
local function Notify(t, txt, d)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=t, Text=txt, Duration=d or 3}) end)
end
local function SC(fn, ...) local ok, err = pcall(fn, ...); return ok, err end
local function Ping() return LocalPlayer:GetNetworkPing() * 1000 end

--============================================================--
-- 配置
--============================================================--
local CFG = {
    AutoParry = false, AutoParryMode = "Remote", AutoParryStrength = 1.0,
    ParryAccuracy = 50, PredictionMode = "Auto Best", PredictionOffset = 0,
    EmergencyShield = true, CooldownProtection = true, AutoAbility = true,
    RetryStrength = "Maximum", NoStun = true,
    ManualSpam = false, ManualSpamCPS = 50, ManualSpamMode = "Ball Speed",
    AutoSpam = false, AutoSpamMode = "Closest",
    Triggerbot = false, ESP = false, ESPHealth = true, ESPDist = true, ESPTarget = true,
    BallSpeed = false, HitboxExpand = false, HitboxSize = 5,
    WalkSpeed = 16, JumpPower = 50, NoClip = false, Fly = false, FlySpeed = 50,
    SkinChanger = false, SwordName = "Default",
    AntiAFK = true, AntiKick = true, FPSBoost = false,
    UIKey = Enum.KeyCode.RightShift,
}

--============================================================--
-- 🔍 PRY 模块发现 — 真正找到正确的 Remote
--============================================================--
local PRY_PATCH = {
    ready = false,
    parryRemote = nil,
    keyTable = nil,
    transformFn = nil,
    netModule = nil,
    remoteId = nil,
    parryHash = nil,
}

local function InitPRY()
    task.spawn(function()
        SC(function()
            -- 步骤1: 找 SwordsController
            local controllers = ReplicatedStorage:WaitForChild("Controllers", 15)
            if not controllers then warn("[ENRIQUE] Controllers not found"); return end
            
            local SC_folder = nil
            for _, child in ipairs(controllers:GetChildren()) do
                if child.Name:sub(1, 15) == "SwordsController" then
                    SC_folder = child
                    break
                end
            end
            if not SC_folder then warn("[ENRIQUE] SwordsController not found"); return end
            
            -- 步骤2: 找 PRY 模块
            local PRY = SC_folder:FindFirstChild("PRY") or SC_folder:WaitForChild("PRY", 5)
            if not PRY then warn("[ENRIQUE] PRY module not found"); return end
            
            -- 步骤3: require PRY 获取 parry 函数
            local ParryFn = require(PRY)
            local getupvals = debug.getupvalues or getupvalues
            if not getupvals then warn("[ENRIQUE] getupvalues missing"); return end
            
            local ups = getupvals(ParryFn)
            if not ups or #ups < 8 then warn("[ENRIQUE] upvalues unexpected: " .. tostring(#ups)); return end
            
            -- 步骤4: 提取关键数据
            PRY_PATCH.keyTable    = ups[3]
            PRY_PATCH.transformFn = ups[4]
            PRY_PATCH.netModule   = ups[6]
            PRY_PATCH.remoteId    = ups[7]
            PRY_PATCH.parryHash   = ups[8]
            
            -- 步骤5: 解析真正的 Remote
            local rok = pcall(function()
                PRY_PATCH.parryRemote = PRY_PATCH.netModule:RemoteEvent(PRY_PATCH.remoteId)
            end)
            if not rok or not PRY_PATCH.parryRemote then
                warn("[ENRIQUE] Remote resolution failed")
                return
            end
            
            PRY_PATCH.ready = true
            print("[ENRIQUE] PRY patch ready! Remote: " .. PRY_PATCH.parryRemote:GetFullName())
        end)
    end)
end

--============================================================--
-- PRY 格挡函数 — 使用真正的 remote
--============================================================--
local function FireParryPRY(curveCF, screenPos, mousePos)
    if not PRY_PATCH.ready then return false end
    
    local kt = PRY_PATCH.keyTable
    if not kt then return false end
    
    local keyIndex = kt[3]
    local currentKey = kt[1] and kt[1][keyIndex]
    if not currentKey then return false end
    
    -- 变换 key
    local ok, transformed = SC(function()
        local r1 = {pcall(PRY_PATCH.transformFn, currentKey, "TIME")}
        if r1[1] then return r1[2] end
        local r2 = {pcall(PRY_PATCH.transformFn, currentKey)}
        if r2[1] then return r2[2] end
        return nil
    end)
    if not ok or not transformed then return false end
    
    -- 生成 token
    local serverTime = workspace:GetServerTimeNow() * 100
    local timeStr = tostring(math.floor(serverTime))
    local tc = {}
    for i = 1, #timeStr do
        local ki = (i - 1) % #transformed + 1
        local kb = string.byte(transformed, ki)
        local tb = (string.byte(timeStr, i) + i) % 256
        tc[i] = string.char(bit32.bxor(tb, kb))
    end
    local token = table.concat(tc)
    
    -- 发送
    SC(function()
        PRY_PATCH.parryRemote:FireServer(
            PRY_PATCH.parryHash,
            currentKey,
            token,
            0.5,
            curveCF or CFrame.new(),
            screenPos or Vector2.zero,
            mousePos or Vector2.new(0.5, 0.5)
        )
    end)
    
    return true
end

-- 备用: hookfunction 捕获
local Hook = { remote = nil, f_raw = nil, args = {}, hooked = false, PF = nil }

local function InitHook()
    -- 捕获 PF
    task.spawn(function()
        while task.wait(5) do
            if not Hook.PF then
                SC(function()
                    local rs = ReplicatedStorage:FindFirstChild("Remotes")
                    if rs then
                        for _, name in ipairs({"ParrySuccessAll", "ParrySuccess"}) do
                            local remote = rs:FindFirstChild(name)
                            if remote and remote:IsA("RemoteEvent") then
                                local ok, conns = pcall(getconnections, remote.OnClientEvent)
                                if ok and conns then
                                    for _, conn in ipairs(conns) do
                                        if conn.Function then
                                            local fnOk, isLua
                                            if islclosure then fnOk, isLua = pcall(islclosure, conn.Function)
                                            elseif isluaclosure then fnOk, isLua = pcall(isluaclosure, conn.Function) end
                                            if fnOk and isLua then Hook.PF = conn.Function; break end
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
    SC(function()
        local hookfn = hookfunction or (getgenv and getgenv().hookfunction)
        local newcc = newcclosure or function(f) return f end
        if hookfn and newcc then
            local dummy = Instance.new("RemoteEvent")
            local orig
            orig = hookfn(dummy.FireServer, newcc(function(self, ...)
                local a = {...}
                if #a >= 4 and typeof(a[4]) == "CFrame" then
                    Hook.hooked = true; Hook.remote = self; Hook.f_raw = orig
                    for i = 1, math.min(7, #a) do Hook.args[i] = a[i] end
                end
                return orig(self, ...)
            end))
        end
    end)
end

-- 发送函数: PRY → Hook → PF → 尝试所有
local function FireParry(curveCF, screenPos, mousePos)
    -- 优先: PRY
    if PRY_PATCH.ready then
        if FireParryPRY(curveCF, screenPos, mousePos) then return true end
    end
    
    -- 备用: Hook
    if Hook.hooked and Hook.remote and Hook.f_raw then
        local a = {}
        for i = 1, 7 do a[i] = Hook.args[i] end
        if curveCF then a[4] = curveCF end
        if screenPos then a[5] = screenPos end
        if mousePos then a[6] = mousePos end
        SC(function() Hook.f_raw(Hook.remote, unpack(a)) end)
        return true
    end
    
    -- 备用: PF
    if Hook.PF then
        SC(function() pcall(Hook.PF) end)
        return true
    end
    
    -- 最后手段: 尝试 ParrySuccessAll
    SC(function()
        local rs = ReplicatedStorage:FindFirstChild("Remotes")
        if rs then
            local remote = rs:FindFirstChild("ParrySuccessAll")
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
            end
        end
    end)
    
    return false
end

--============================================================--
-- 🎱 球追踪器
--============================================================--
local BallTracker = { track = {} }

function BallTracker.GetBall()
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then return nil end
    for _, b in ipairs(balls:GetChildren()) do
        if b:GetAttribute("realBall") then b.CanCollide = false; return b end
    end
    return nil
end

function BallTracker.GetAllBalls()
    local r = {}
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then return r end
    for _, b in ipairs(balls:GetChildren()) do
        if b:GetAttribute("realBall") then b.CanCollide = false; table.insert(r, b) end
    end
    return r
end

function BallTracker.GetTrainingBall()
    local tb = Workspace:FindFirstChild("TrainingBalls")
    if not tb then return nil end
    for _, b in ipairs(tb:GetChildren()) do
        if b:GetAttribute("realBall") then return b end
    end
    return nil
end

function BallTracker.GetVelocity(ball)
    local v = Vector3.zero
    SC(function()
        local z = ball:FindFirstChild("zoomies")
        if z then
            local vv = z:FindFirstChild("VectorVelocity")
            if vv and vv:IsA("Vector3Value") then v = vv.Value end
        end
    end)
    if v.Magnitude < 1 then SC(function() local bv = ball:FindFirstChildOfClass("BodyVelocity"); if bv then v = bv.Velocity end end) end
    if v.Magnitude < 1 then SC(function() v = ball.Velocity end) end
    return v
end

function BallTracker.GetPrediction(ball, root)
    local ok, res = pcall(function()
        if not ball:FindFirstChild("zoomies") then return nil end
        local now = tick()
        local pos = ball.Position
        local vel = BallTracker.GetVelocity(ball)
        local accel = Vector3.zero
        local trk = BallTracker.track[ball]
        local hitR = 12
        
        if trk and trk.position and trk.time and now > trk.time then
            local dt = math.clamp(now - trk.time, 0.001, 0.20)
            local obsVel = (pos - trk.position) / dt
            if obsVel.Magnitude > 1 and obsVel.Magnitude < 5000 then
                vel = vel:Lerp(obsVel, 0.35)
                if trk.velocity then
                    local obsA = (obsVel - trk.velocity) / dt
                    if obsA.Magnitude < 6500 then accel = (trk.acceleration or Vector3.zero):Lerp(obsA, 0.22) end
                end
            end
        end
        
        local segDist = math.huge
        local crossed = false
        if trk and trk.position then
            local motion = pos - trk.position
            local travel = motion.Magnitude
            if travel > 0.001 then
                local toP = trk.position - root.Position
                local segT = math.clamp(-toP:Dot(motion) / (travel * travel), 0, 1)
                local near = trk.position + motion * segT
                segDist = (near - root.Position).Magnitude
                crossed = segDist <= hitR * 1.5
            end
        end
        
        BallTracker.track[ball] = { position = pos, time = now, velocity = vel, acceleration = accel }
        
        local toPlr = root.Position - pos
        local dist = toPlr.Magnitude
        local approaching = false
        local eta = math.huge
        if vel.Magnitude > 1 then
            local dot = toPlr.Unit:Dot(vel.Unit)
            approaching = dot < -0.15
            if approaching and dist > 1 then
                local cs = vel.Magnitude * math.abs(dot)
                if cs > 1 then eta = (dist - hitR) / cs end
            end
        end
        if accel.Magnitude > 10 then eta = eta - accel.Magnitude * 0.001 end
        
        return { velocity = vel, speed = vel.Magnitude, distance = dist, approaching = approaching,
                 eta = math.max(eta, 0), closestDistance = segDist, crossed = crossed, position = pos }
    end)
    return ok and res or nil
end

--============================================================--
-- ⚔️ 格挡引擎
--============================================================--
local Parry = { last = 0, cd = {}, armed = {}, retry = {}, watchers = {} }

local function DoParry(cf, sp, mp)
    local now = tick()
    if now - Parry.last < 0.004 then return end
    Parry.last = now
    FireParry(cf, sp, mp)
end

--============================================================--
-- 🎯 自动格挡
--============================================================--
local AP = { conn = nil, sfd = 1/60 }

function AP.Start()
    if AP.conn then AP.conn:Disconnect() end
    for _, c in pairs(Parry.watchers) do SC(function() c:Disconnect() end) end
    Parry.watchers = {}; Parry.cd = {}; Parry.armed = {}; Parry.retry = {}
    
    AP.conn = RunService.PreSimulation:Connect(function(dt)
        AP.sfd = AP.sfd + (math.clamp(dt or 1/60, 1/240, 1/12) - AP.sfd) * 0.18
        if not CFG.AutoParry then return end
        if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
        
        local now = tick()
        for _, ball in ipairs(BallTracker.GetAllBalls()) do
            if not ball or not ball.Parent or not ball:FindFirstChild("zoomies") then continue end
            
            if not Parry.watchers[ball] then
                Parry.watchers[ball] = ball:GetAttributeChangedSignal("target"):Connect(function()
                    local t = ball:GetAttribute("target") == LocalPlayer.Name
                    Parry.armed[ball] = t
                    if t then Parry.cd[ball] = 0 end
                end)
            end
            
            local bt = ball:GetAttribute("target")
            if Parry.armed[ball] == nil then Parry.armed[ball] = (bt == LocalPlayer.Name) end
            if not Parry.armed[ball] then continue end
            if now < (Parry.cd[ball] or 0) then continue end
            
            -- 重试
            local rs = Parry.retry[ball]
            if rs and now - (Parry._lastOk or 0) < 0.40 then Parry.retry[ball] = nil; rs = nil end
            if rs then
                local root = LocalPlayer.Character.PrimaryPart
                local vel = BallTracker.GetVelocity(ball)
                if root and vel.Magnitude > 1 then
                    local tl = root.Position - ball.Position
                    if tl.Magnitude > 1 and vel.Unit:Dot(tl.Unit) < -0.18 then Parry.retry[ball] = nil; rs = nil end
                end
            end
            if rs then
                if bt ~= LocalPlayer.Name then Parry.retry[ball] = nil
                elseif now >= rs.next then
                    DoParry()
                    rs.left = rs.left - 1
                    rs.next = now + math.max(0.016, AP.sfd * 0.65)
                    if rs.left <= 0 then Parry.retry[ball] = nil end
                end
                continue
            end
            
            -- 核心计算
            local root = LocalPlayer.Character.PrimaryPart
            local vel = BallTracker.GetVelocity(ball)
            local spd = vel.Magnitude
            local dist = (root.Position - ball.Position).Magnitude
            local ping = Ping()
            local lat = math.clamp((ping/1000) * math.clamp(CFG.AutoParryStrength, 0.75, 2.25), 0.004, 0.58)
            local pred = BallTracker.GetPrediction(ball, root)
            
            if ball:FindFirstChild("ComboCounter") then continue end
            if root:FindFirstChild("SingularityCape") then continue end
            
            -- 加速球
            if ball:GetAttribute("warping") or ball:GetAttribute("bouncing") then
                local ws = ball:GetAttribute("warpSpeed") or spd
                if ws > spd * 1.5 then spd = ws end
            end
            
            -- 触发窗口
            local autoBest = CFG.PredictionMode == "Auto Best"
            local tw2
            if autoBest then
                local su = spd >= 250 and 0.010 + math.min((spd-250)/6500, 0.032) or 0.003 + math.min(spd/30000, 0.008)
                tw2 = lat * 2.45 + 0.118 + AP.sfd * 0.98 + su
                if CFG.EmergencyShield then tw2 = tw2 + 0.052 end
                if spd >= 250 then tw2 = tw2 + 0.022 end
                if spd >= 340 then tw2 = tw2 + 0.028 end
                if spd >= 450 then tw2 = tw2 + 0.026 end
                if spd >= 600 then tw2 = tw2 + 0.031 end
                if spd >= 800 then tw2 = tw2 + 0.028 end
                if spd >= 1000 then tw2 = tw2 + 0.035 end
                if spd >= 1500 then tw2 = tw2 + 0.045 end
                if spd >= 2000 then tw2 = tw2 + 0.055 end
                if CFG.RetryStrength == "Maximum" or CFG.RetryStrength == "Legendary" then tw2 = tw2 + 0.014 end
            else
                tw2 = lat + 0.075 + math.clamp(CFG.PredictionOffset, -1, 1) * 0.075
            end
            tw2 = math.clamp(tw2, 0.020, autoBest and 0.56 or 0.42)
            local ps = math.clamp(CFG.AutoParryStrength, 0.5, 2)
            local mtd = math.min(spd * tw2 * ps + 35, 400)
            local fire = false
            
            if pred and spd >= 45 then
                local hr = math.max(26, 15 + spd * 0.022)
                if CFG.EmergencyShield then hr = hr + 5 end
                fire = pred.approaching and pred.eta <= tw2 and (pred.closestDistance <= hr or pred.crossed)
                    and dist <= mtd + (pred.crossed and 25 or 0)
            else
                fire = dist <= math.clamp((26 + ping*0.045 + spd*0.062) * ps, 24, 160)
            end
            
            local head = true
            if spd > 1 then
                local tp = root.Position - ball.Position
                head = tp.Magnitude <= 1 or (tp.Unit):Dot(vel.Unit) > -0.20
            end
            
            if CFG.EmergencyShield and not fire then
                local er = math.max(32, spd * (lat + AP.sfd * 0.5) + 35) * ps
                fire = dist <= er
                if not fire and dist < 18 then fire = true end
            end
            
            if bt == LocalPlayer.Name and fire and head then
                -- 冷却保护
                if CFG.CooldownProtection then
                    SC(function()
                        local hb = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                        if hb then
                            local bl = hb:FindFirstChild("Block")
                            if bl and bl:FindFirstChild("UIGradient") and bl.UIGradient.Offset.Y < 0.4 then
                                local ar = ReplicatedStorage:FindFirstChild("Remotes")
                                if ar and ar:FindFirstChild("AbilityButtonPress") then ar.AbilityButtonPress:Fire() end
                                Parry.cd[ball] = now + 0.06; continue
                            end
                        end
                    end)
                end
                
                -- 自动技能
                if CFG.AutoAbility then
                    SC(function()
                        local hb = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                        if hb then
                            local ab = hb:FindFirstChild("Ability")
                            if ab and ab:FindFirstChild("UIGradient") and ab.UIGradient.Offset.Y == 0.5 then
                                local abs = LocalPlayer.Character:FindFirstChild("Abilities")
                                if abs then
                                    local has = false
                                    for _, a in ipairs(abs:GetChildren()) do
                                        if a:IsA("BoolValue") and a.Enabled then has = true; break end
                                    end
                                    if has then
                                        local ar = ReplicatedStorage:FindFirstChild("Remotes")
                                        if ar and ar:FindFirstChild("AbilityButtonPress") then ar.AbilityButtonPress:Fire() end
                                        Parry.armed[ball] = false; Parry.cd[ball] = now + 0.08; continue
                                    end
                                end
                            end
                        end
                    end)
                end
                
                DoParry()
                Parry.armed[ball] = false
                Parry.cd[ball] = now + 0.12
                Parry._lastOk = now
                
                local rt = 150
                if CFG.RetryStrength == "Safe" then rt = 260
                elseif CFG.RetryStrength == "Balanced" then rt = 220
                elseif CFG.RetryStrength == "Aggressive" then rt = 180
                elseif CFG.RetryStrength == "Legendary" then rt = 120 end
                
                if spd >= rt then
                    local rem = 5
                    if CFG.RetryStrength == "Safe" then rem = 2
                    elseif CFG.RetryStrength == "Balanced" then rem = spd >= 290 and 3 or 2
                    elseif CFG.RetryStrength == "Aggressive" then rem = spd >= 260 and 4 or 3
                    elseif CFG.RetryStrength == "Legendary" then rem = spd >= 200 and 15 or 10 end
                    Parry.retry[ball] = { left = rem, next = now + math.max(0.016, AP.sfd * 0.58) }
                end
            end
        end
        
        -- 训练球
        local tb = BallTracker.GetTrainingBall()
        if tb and tb:FindFirstChild("zoomies") then
            if now >= (Parry.cd["t"] or 0) then
                local bt = tb:GetAttribute("target")
                local vel = BallTracker.GetVelocity(tb)
                local spd = vel.Magnitude
                local d = LocalPlayer:DistanceFromCharacter(tb.Position)
                local cd = math.clamp(Ping()/1000, 0.005, 0.45)
                local cDiff = math.min(math.max(spd-9.5, 0), 650)
                local sDiv = (2.4 + cDiff*0.002) * (0.7 + (CFG.ParryAccuracy-1)*0.0035)
                local s = math.clamp(CFG.AutoParryStrength, 0.5, 2)
                local br = math.clamp((Ping()/10)/10, 4, 18) + math.max(spd/sDiv, 12.5)
                local pr = spd * cd
                local sb = (s-1) * math.min(br*0.25+pr*0.35, 18)
                if (bt == LocalPlayer.Name or d < 20) and d <= math.max(12, br+pr+sb) then
                    DoParry(); Parry.cd["t"] = tick() + 0.20
                end
            end
        end
    end)
end

function AP.Stop()
    if AP.conn then AP.conn:Disconnect(); AP.conn = nil end
    for _, c in pairs(Parry.watchers) do SC(function() c:Disconnect() end) end
    Parry.watchers = {}
end

--============================================================--
-- ⚡ 手动连发 / 自动连发 / 触发器 / ESP
--============================================================--
local MS = { conn = nil, acc = 0, lf = 0 }
function MS.Start()
    if MS.conn then MS.conn:Disconnect() end
    MS.acc = 0; MS.lf = tick()
    MS.conn = RunService.PreSimulation:Connect(function(dt)
        if not CFG.ManualSpam then return end
        local now = tick(); local fd = now - MS.lf; MS.lf = now
        local q = CFG.ManualSpamCPS * fd
        if CFG.ManualSpamMode == "Ball Speed" then
            local b = BallTracker.GetBall()
            if b then local v = BallTracker.GetVelocity(b); if v.Magnitude > 200 then q = q * (1 + v.Magnitude/1000) end end
        end
        MS.acc = MS.acc + q
        local c = math.min(math.floor(MS.acc), 512)
        if c < 1 then return end
        MS.acc = MS.acc - c
        for _ = 1, c do FireParry() end
    end)
end
function MS.Stop() if MS.conn then MS.conn:Disconnect(); MS.conn = nil end; MS.acc = 0 end

local AS = { conn = nil, acc = 0, lf = 0 }
function AS.Start()
    if AS.conn then AS.conn:Disconnect() end
    AS.acc = 0; AS.lf = tick()
    AS.conn = RunService.PreSimulation:Connect(function(dt)
        if not CFG.AutoSpam or not CFG.ManualSpam then return end
        local now = tick(); local fd = now - AS.lf; AS.lf = now
        local b = BallTracker.GetBall()
        if not b then return end
        if b:GetAttribute("target") ~= LocalPlayer.Name then return end
        local v = BallTracker.GetVelocity(b); local spd = v.Magnitude
        local base = CFG.ManualSpamCPS
        if spd > 300 then base = base * 1.5 elseif spd > 600 then base = base * 2.0 end
        local q = base * fd
        local r = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if r then local d = (r.Position - b.Position).Magnitude; if d < 30 then q = q * 1.5 end end
        AS.acc = AS.acc + q
        local c = math.min(math.floor(AS.acc), 512)
        if c < 1 then return end
        AS.acc = AS.acc - c
        for _ = 1, c do FireParry() end
    end)
end
function AS.Stop() if AS.conn then AS.conn:Disconnect(); AS.conn = nil end; AS.acc = 0 end

local TB = { conn = nil }
function TB.Start()
    if TB.conn then TB.conn:Disconnect() end
    TB.conn = RunService.PreSimulation:Connect(function()
        if not CFG.Triggerbot then return end
        local b = BallTracker.GetBall()
        if not b or b:GetAttribute("target") ~= LocalPlayer.Name then return end
        local r = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if r and (r.Position - b.Position).Magnitude < 25 then FireParry() end
    end)
end
function TB.Stop() if TB.conn then TB.conn:Disconnect(); TB.conn = nil end end

local ESP = { conn = nil, objs = {} }
function ESP.Start()
    if ESP.conn then ESP.conn:Disconnect() end
    ESP.conn = RunService.RenderStepped:Connect(function()
        if not CFG.ESP then ESP.Stop(); return end
        for _, o in pairs(ESP.objs) do if o and o.Parent then o:Destroy() end end
        ESP.objs = {}
        local r = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
        if not r then return end
        local eb = BallTracker.GetBall()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character.PrimaryPart then
                local hrp = p.Character.PrimaryPart
                local d = (r.Position - hrp.Position).Magnitude
                local pos, on = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                if on then
                    local txt = p.Name
                    if CFG.ESPDist then txt = txt .. " [" .. math.floor(d) .. "m]" end
                    if CFG.ESPHealth and p.Character:FindFirstChild("Humanoid") then txt = txt .. " [" .. math.floor(p.Character.Humanoid.Health) .. "HP]" end
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ENRIQUE_ESP"; bb.Size = UDim2.new(0, 200, 0, 40); bb.AlwaysOnTop = true; bb.Adornee = hrp; bb.Parent = CoreGui
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 0.5; lbl.BackgroundColor3 = Color3.new(0,0,0)
                    lbl.TextColor3 = Color3.new(1,1,1); lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBold; lbl.Text = txt; lbl.Parent = bb
                    if CFG.ESPTarget and eb and eb:GetAttribute("target") == p.Name then
                        lbl.TextColor3 = Color3.fromRGB(255, 50, 50); lbl.Text = "🎯 " .. txt
                    end
                    table.insert(ESP.objs, bb)
                end
            end
        end
    end)
end
function ESP.Stop() if ESP.conn then ESP.conn:Disconnect(); ESP.conn = nil end; for _, o in pairs(ESP.objs) do if o and o.Parent then o:Destroy() end end; ESP.objs = {} end

--============================================================--
-- 杂项
--============================================================--
local Misc = { nc = nil, afk = nil, fl = nil }
function Misc.SetSpeed(v) CFG.WalkSpeed = v; SC(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end) end
function Misc.SetJump(v) CFG.JumpPower = v; SC(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end) end
function Misc.ToggleNoClip(s)
    CFG.NoClip = s; if Misc.nc then Misc.nc:Disconnect() end
    if s then Misc.nc = RunService.Stepped:Connect(function() SC(function() if LocalPlayer.Character then for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end) end
end
function Misc.ToggleFly(s)
    CFG.Fly = s; if Misc.fl then Misc.fl:Disconnect() end
    if s then Misc.fl = RunService.RenderStepped:Connect(function() SC(function()
        local c = LocalPlayer.Character; if c and c:FindFirstChild("HumanoidRootPart") then
            local hrp = c.HumanoidRootPart; local v = Vector3.zero; local cam = workspace.CurrentCamera; local cf = cam.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0,1,0) end
            hrp.Velocity = v.Magnitude > 0 and v.Unit * CFG.FlySpeed or Vector3.zero
        end end) end) end
end
function Misc.StartAntiAFK() if Misc.afk then return end; Misc.afk = LocalPlayer.Idled:Connect(function() SC(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end) end) end

-- Skin Changer
local SC2 = { conn = nil }
function SC2.Apply(name)
    SC(function()
        local rs = ReplicatedStorage:FindFirstChild("Remotes")
        if rs and rs:FindFirstChild("FireSwordInfo") then rs.FireSwordInfo:FireServer(name); Notify("✅ Skin", name, 3) end
    end)
    if SC2.conn then SC2.conn:Disconnect() end
    SC2.conn = LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if CFG.SkinChanger then SC2.Apply(CFG.SwordName) end end)
end
function SC2.Stop() if SC2.conn then SC2.conn:Disconnect(); SC2.conn = nil end end

-- 球速显示
local BSD = { conn = nil, bb = nil }
function BSD.Start()
    BSD.Stop()
    BSD.conn = RunService.RenderStepped:Connect(function()
        if not CFG.BallSpeed then BSD.Stop(); return end
        local b = BallTracker.GetBall()
        if not b then if BSD.bb then BSD.bb:Destroy(); BSD.bb = nil end; return end
        local spd = math.floor(BallTracker.GetVelocity(b).Magnitude)
        if not BSD.bb then
            BSD.bb = Instance.new("BillboardGui"); BSD.bb.Name = "ENRIQUE_SPD"; BSD.bb.Size = UDim2.new(0,120,0,30); BSD.bb.AlwaysOnTop = true; BSD.bb.Adornee = b; BSD.bb.Parent = CoreGui
            local lbl = Instance.new("TextLabel"); lbl.Name = "L"; lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 0.6; lbl.BackgroundColor3 = Color3.new(0,0,0)
            lbl.TextColor3 = Color3.fromRGB(255,200,60); lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBold; lbl.Parent = BSD.bb
        end
        local lbl = BSD.bb:FindFirstChild("L")
        if lbl then
            lbl.Text = "⚡ " .. spd .. " SP"
            if spd > 500 then lbl.TextColor3 = Color3.fromRGB(255,50,50)
            elseif spd > 250 then lbl.TextColor3 = Color3.fromRGB(255,200,60)
            else lbl.TextColor3 = Color3.fromRGB(80,255,140) end
        end
    end)
end
function BSD.Stop() if BSD.conn then BSD.conn:Disconnect(); BSD.conn = nil end; if BSD.bb then BSD.bb:Destroy(); BSD.bb = nil end end

-- 自动重生
task.spawn(function() while task.wait(2) do SC(function() if LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h and h.Health <= 0 then task.wait(3); LocalPlayer:LoadCharacter() end end end) end end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); Misc.SetSpeed(CFG.WalkSpeed); Misc.SetJump(CFG.JumpPower); if CFG.AutoParry then AP.Start() end end)
if CFG.AntiKick then task.spawn(function() while task.wait(30) do SC(function() game:GetService("VirtualUser"):CaptureController() end) end end) end
if CFG.FPSBoost then pcall(function() setfpscap(9999) end); SC(function() Lighting.FogEnd = 999999; Lighting.GlobalShadows = false end) end

--============================================================--
-- 动漫 UI — 参考结构 + 动漫图片
--============================================================--

-- 动漫图片 ID（确保这些 ID 是有效的）
local ANIME = {
    banner = "133575691569801",    -- 横幅
    icon   = "105587462408321",    -- 侧边栏图标
    orb    = "11642789352",        -- 装饰
}

local T = {
    bg = Color3.fromRGB(10, 8, 16), bg2 = Color3.fromRGB(16, 12, 26),
    panel = Color3.fromRGB(22, 16, 36), panel2 = Color3.fromRGB(30, 22, 48),
    stroke = Color3.fromRGB(90, 40, 140), strokeHi = Color3.fromRGB(200, 70, 255),
    text = Color3.fromRGB(240, 235, 255), dim = Color3.fromRGB(160, 140, 190),
    faint = Color3.fromRGB(110, 95, 140), accent = Color3.fromRGB(200, 70, 255),
    accentHi = Color3.fromRGB(230, 110, 255), accentDim = Color3.fromRGB(140, 50, 190),
    danger = Color3.fromRGB(255, 70, 90), success = Color3.fromRGB(80, 255, 140),
    on = Color3.fromRGB(200, 70, 255), off = Color3.fromRGB(50, 40, 65),
    card = Color3.fromRGB(18, 14, 30),
}

local function mk(c, p, ch) local o = Instance.new(c); for k,v in pairs(p or{}) do o[k]=v end; for _,c2 in ipairs(ch or{}) do c2.Parent=o end; return o end
local function tw(i, t, p, s, d) local tw2 = TweenService:Create(i, TweenInfo.new(t or 0.2, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p); tw2:Play(); return tw2 end

-- KEY UI
local function ShowKeyUI(cb)
    local old = CoreGui:FindFirstChild("ENRIQUE_KEY2"); if old then old:Destroy() end
    local sg = mk("ScreenGui", {Name="ENRIQUE_KEY2", IgnoreGuiInset=true, ResetOnSpawn=false, DisplayOrder=10000, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=CoreGui})
    local W, H = 400, 340
    local ov = mk("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=1, BorderSizePixel=0, Parent=sg})
    local blur = mk("BlurEffect", {Size=0, Parent=Lighting})
    local root = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(0,W-30,0,H-20), BackgroundTransparency=1, Parent=sg})
    
    -- 阴影
    mk("ImageLabel", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,60,1,60), BackgroundTransparency=1, Image="rbxassetid://5028857084", ImageColor3=Color3.new(0,0,0), ImageTransparency=0.3, ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(24,24,276,276), Parent=root})
    
    local main = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,0,1,0), BackgroundColor3=T.bg, BorderSizePixel=0, Parent=root})
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local ms = Instance.new("UIStroke", main); ms.Color = T.stroke; ms.Transparency = 0.3
    
    -- 渐变边条
    local sideBar = mk("Frame", {Size=UDim2.new(0, 6, 1, 0), BackgroundTransparency=1, Parent=main})
    local sg2 = Instance.new("UIGradient", sideBar)
    sg2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(200,70,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100,30,160)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60,20,100))})
    sg2.Rotation = 90
    
    -- 动漫横幅
    local banner = mk("ImageLabel", {Size=UDim2.new(1,-30,0,100), Position=UDim2.new(0,15,0,12), BackgroundTransparency=1, Image="rbxassetid://"..ANIME.banner, ScaleType=Enum.ScaleType.Crop, Parent=main})
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", banner); bs.Color = T.accent; bs.Transparency = 0.4
    
    -- 标题
    mk("TextLabel", {Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,0,120), BackgroundTransparency=1, Text="⚔️ ENRIQUE PAID", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=T.accent, Parent=main})
    mk("TextLabel", {Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,146), BackgroundTransparency=1, Text="输入 Key 激活 (24小时有效)", Font=Enum.Font.Gotham, TextSize=11, TextColor3=T.dim, Parent=main})
    
    -- 输入框
    local ibg = mk("Frame", {Size=UDim2.new(1,-40,0,38), Position=UDim2.new(0,20,0,174), BackgroundColor3=T.panel, BorderSizePixel=0, Parent=main})
    Instance.new("UICorner", ibg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ibg).Color = T.stroke
    local inp = mk("TextBox", {Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, PlaceholderText="ENRIQUE-PAID-XXXX-XXXX-XXXX-XXXX", PlaceholderColor3=T.faint, Text="", TextColor3=T.text, Font=Enum.Font.GothamMedium, TextSize=13, ClearTextOnFocus=false, Parent=ibg})
    
    -- 按钮
    local btn = mk("TextButton", {Size=UDim2.new(1,-40,0,38), Position=UDim2.new(0,20,0,222), BackgroundColor3=T.accent, BorderSizePixel=0, Text="🔑 激活", Font=Enum.Font.GothamBold, TextSize=15, TextColor3=Color3.new(1,1,1), AutoButtonColor=false, Parent=main})
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local st = mk("TextLabel", {Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,270), BackgroundTransparency=1, Text="discord.gg/hZhwszmP", Font=Enum.Font.Gotham, TextSize=11, TextColor3=T.faint, Parent=main})
    
    btn.MouseButton1Click:Connect(function()
        local k = inp.Text
        if k == "" then st.Text = "❌ 请输入 Key"; st.TextColor3 = T.danger; return end
        btn.Text = "验证中..."
        task.delay(0.5, function()
            if KeySys.Validate(k) then
                KeySys.Save(k)
                st.Text = "✅ 激活成功！"; st.TextColor3 = T.success
                task.delay(1, function()
                    tw(ov, 0.2, {BackgroundTransparency=1}); tw(blur, 0.25, {Size=0})
                    tw(root, 0.22, {Size=UDim2.new(0,W-30,0,H-20)})
                    task.delay(0.25, function() sg:Destroy(); blur:Destroy(); cb() end)
                end)
            else
                st.Text = "❌ Key 无效"; st.TextColor3 = T.danger; btn.Text = "🔑 激活"
                tw(ibg, 0.05, {Position=UDim2.new(0,24,0,174)})
                task.delay(0.05, function() tw(ibg, 0.05, {Position=UDim2.new(0,16,0,174)}) end)
                task.delay(0.12, function() tw(ibg, 0.05, {Position=UDim2.new(0,22,0,174)}) end)
                task.delay(0.18, function() tw(ibg, 0.05, {Position=UDim2.new(0,20,0,174)}) end)
            end
        end)
    end)
    
    root.Size = UDim2.new(0,W-30,0,H-20)
    tw(ov, 0.25, {BackgroundTransparency=0.5}); tw(blur, 0.3, {Size=12})
    tw(root, 0.35, {Size=UDim2.new(0,W,0,H)}, Enum.EasingStyle.Back)
end

-- 主 UI
local UI = { Minimized = false, Open = true }

local function CreateMainUI()
    local old = CoreGui:FindFirstChild("ENRIQUE_V2"); if old then old:Destroy() end
    local W, H = 540, 440
    local sg = mk("ScreenGui", {Name="ENRIQUE_V2", IgnoreGuiInset=true, ResetOnSpawn=false, DisplayOrder=9999, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=CoreGui})
    
    local ov = mk("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=1, BorderSizePixel=0, Parent=sg})
    local blur = mk("BlurEffect", {Size=0, Parent=Lighting})
    local root = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(0,W,0,H), BackgroundTransparency=1, Parent=sg})
    
    mk("ImageLabel", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,60,1,60), BackgroundTransparency=1, Image="rbxassetid://5028857084", ImageColor3=Color3.new(0,0,0), ImageTransparency=0.3, ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(24,24,276,276), Parent=root})
    
    local main = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,0,1,0), BackgroundColor3=T.bg, BorderSizePixel=0, ClipsDescendants=true, Parent=root})
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local mStroke = Instance.new("UIStroke", main); mStroke.Color = T.stroke; mStroke.Transparency = 0.28
    
    -- 渐变边条（像参考脚本那样）
    local sideGlow = mk("Frame", {Size=UDim2.new(0, 4, 1, 0), BackgroundTransparency=1, Parent=main})
    local sg3 = Instance.new("UIGradient", sideGlow)
    sg3.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(30,15,50)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,70,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(30,15,50))})
    sg3.Rotation = 90
    
    -- 容器渐变
    local cg = Instance.new("UIGradient", main)
    cg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(25,20,35)), ColorSequenceKeypoint.new(0.12, Color3.fromRGB(10,8,16)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10,8,16))})
    cg.Rotation = 135
    
    -- Handler（内部容器）
    local handler = mk("Frame", {Size=UDim2.new(0, 520, 0, 410), Position=UDim2.new(0, 10, 0, 15), BackgroundTransparency=1, Parent=main})
    
    -- 左侧栏
    local tabs = mk("ScrollingFrame", {Name="Tabs", Size=UDim2.new(0, 130, 0, 390), BackgroundTransparency=1, ScrollBarThickness=0, AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=handler})
    Instance.new("UIListLayout", tabs).Padding = UDim.new(0, 4)
    tabs.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- 侧边栏图标（动漫）
    local icon = mk("ImageLabel", {Name="Icon", BackgroundTransparency=1, Size=UDim2.new(0, 25, 0, 25), Position=UDim2.new(0, 2, 0, 2), Image="rbxassetid://"..ANIME.icon, ScaleType=Enum.ScaleType.Fit, Parent=handler})
    
    -- 名字
    mk("TextLabel", {Name="Name", Font=Enum.Font.GothamBold, TextColor3=T.accent, Text="ENRIQUE", Size=UDim2.new(0, 80, 0, 14), Position=UDim2.new(0, 32, 0, 5), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left, TextSize=12, Parent=handler})
    
    -- 分割线
    local div = mk("Frame", {Name="Divider", Size=UDim2.new(0, 1, 0, 370), Position=UDim2.new(0, 138, 0, 30), BackgroundTransparency=0.5, BackgroundColor3=T.accent, BorderSizePixel=0, Parent=handler})
    local dg = Instance.new("UIGradient", div)
    dg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.faint), ColorSequenceKeypoint.new(0.5, T.accent), ColorSequenceKeypoint.new(1, T.faint)})
    dg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.4), NumberSequenceKeypoint.new(0.85, 0.4), NumberSequenceKeypoint.new(1, 1)})
    dg.Rotation = 90
    
    -- 内容区
    local content = mk("ScrollingFrame", {Name="Content", Size=UDim2.new(0, 370, 0, 390), Position=UDim2.new(0, 148, 0, 0), BackgroundTransparency=1, ScrollBarThickness=3, ScrollBarImageColor3=T.accent, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=handler})
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)
    Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 4)
    content.UIPadding.PaddingRight = UDim.new(0, 4)
    
    -- 标签定义
    local TABS = {
        {n="Combat", i="⚔️"}, {n="Spam", i="⚡"}, {n="Visuals", i="👁️"},
        {n="Player", i="🏃"}, {n="Sword", i="🗡️"}, {n="Settings", i="⚙️"},
    }
    
    local tabBtns, tabFrames = {}, {}
    for i, tab in ipairs(TABS) do
        local btn = mk("TextButton", {Size=UDim2.new(1,-8,0,28), BackgroundColor3=T.panel, BorderSizePixel=0, Text="  "..tab.i.." "..tab.n, Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=T.dim, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, LayoutOrder=i, Parent=tabs})
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local fr = mk("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, Visible=(tab.n=="Combat"), LayoutOrder=i, Parent=content})
        Instance.new("UIListLayout", fr).Padding = UDim.new(0, 4)
        tabBtns[tab.n] = btn; tabFrames[tab.n] = fr
        btn.MouseButton1Click:Connect(function()
            for n, b in pairs(tabBtns) do
                if n == tab.n then tw(b, 0.12, {BackgroundColor3=T.accentDim}); b.TextColor3=Color3.new(1,1,1)
                else tw(b, 0.12, {BackgroundColor3=T.panel}); b.TextColor3=T.dim end
            end
            for n, f in pairs(tabFrames) do f.Visible=(n==tab.n) end
        end)
    end
    tw(tabBtns["Combat"], 0, {BackgroundColor3=T.accentDim}); tabBtns["Combat"].TextColor3=Color3.new(1,1,1)
    
    -- 控件
    local function Card(p, title)
        local c = mk("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=T.card, BorderSizePixel=0, Parent=p})
        Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
        local cs = Instance.new("UIStroke", c); cs.Color=T.stroke; cs.Transparency=0.5; cs.Thickness=0.5
        Instance.new("UIPadding", c).PaddingTop = UDim.new(0, 8)
        c.UIPadding.PaddingBottom = UDim.new(0, 8)
        c.UIPadding.PaddingLeft = UDim.new(0, 10)
        c.UIPadding.PaddingRight = UDim.new(0, 10)
        Instance.new("UIListLayout", c).Padding = UDim.new(0, 4)
        if title then mk("TextLabel", {Size=UDim2.new(1,0,0,18), BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamBold, TextSize=13, TextColor3=T.accent, TextXAlignment=Enum.TextXAlignment.Left, Parent=c}) end
        return c
    end
    
    local function Toggle(p, label, flag, def, cb)
        local f = mk("Frame", {Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=p})
        mk("TextLabel", {Size=UDim2.new(0.7,0,1,0), BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=T.text, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
        local s = def or false
        local bg = mk("Frame", {Size=UDim2.new(0,38,0,18), Position=UDim2.new(1,-40,0.5,-9), BackgroundColor3=s and T.on or T.off, Parent=f})
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
        local dot = mk("Frame", {Size=UDim2.new(0,14,0,14), Position=s and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=s and Color3.new(1,1,1) or T.faint, Parent=bg})
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        local function Upd() tw(bg, 0.15, {BackgroundColor3=s and T.on or T.off}); tw(dot, 0.15, {Position=s and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=s and Color3.new(1,1,1) or T.faint}) end
        mk("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=f}).MouseButton1Click:Connect(function() s=not s; CFG[flag]=s; Upd(); if cb then cb(s) end end)
    end
    
    local function Slider(p, label, flag, min, max, def, cb)
        local f = mk("Frame", {Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, Parent=p})
        mk("TextLabel", {Size=UDim2.new(0.65,0,0,14), BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=T.dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
        local vl = mk("TextLabel", {Size=UDim2.new(0.35,0,0,14), BackgroundTransparency=1, Text=tostring(def), Font=Enum.Font.GothamBold, TextSize=12, TextColor3=T.accent, TextXAlignment=Enum.TextXAlignment.Right, Parent=f})
        local tb = mk("Frame", {Size=UDim2.new(1,0,0,5), Position=UDim2.new(0,0,0,22), BackgroundColor3=T.panel2, Parent=f})
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)
        local fi = mk("Frame", {Size=UDim2.new((def-min)/(max-min),0,1,0), BackgroundColor3=T.accent, Parent=tb})
        Instance.new("UICorner", fi).CornerRadius = UDim.new(1,0)
        local kn = mk("Frame", {Size=UDim2.new(0,12,0,12), Position=UDim2.new((def-min)/(max-min),-6,0.5,-6), BackgroundColor3=Color3.new(1,1,1), Parent=tb})
        Instance.new("UICorner", kn).CornerRadius = UDim.new(1,0)
        local drag = false; local cv = def
        local function upd(x) local p2=math.clamp((x-tb.AbsolutePosition.X)/tb.AbsoluteSize.X,0,1); cv=min+(max-min)*p2; if max<=10 then cv=math.floor(cv*10)/10 end; fi.Size=UDim2.new(p2,0,1,0); kn.Position=UDim2.new(p2,-6,0.5,-6); vl.Text=tostring(cv); CFG[flag]=cv; if cb then cb(cv) end end
        tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i.Position.X) end end)
        UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    end
    
    local function Drop(p, label, flag, opts, def, cb)
        local f = mk("Frame", {Size=UDim2.new(1,0,0,48), BackgroundTransparency=1, Parent=p})
        mk("TextLabel", {Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=T.dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
        local cur = def or opts[1]
        local bb = mk("TextButton", {Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,16), BackgroundColor3=T.panel2, BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=f})
        Instance.new("UICorner", bb).CornerRadius = UDim.new(0, 6)
        local dl = mk("TextLabel", {Size=UDim2.new(1,-22,1,0), Position=UDim2.new(0,8,0,0), BackgroundTransparency=1, Text=cur, Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=T.text, TextXAlignment=Enum.TextXAlignment.Left, Parent=bb})
        local ar = mk("TextLabel", {Size=UDim2.new(0,18,1,0), Position=UDim2.new(1,-20,0,0), BackgroundTransparency=1, Text="▼", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=T.faint, Parent=bb})
        local lf = mk("ScrollingFrame", {Size=UDim2.new(1,0,0,math.min(#opts*26,130)), Position=UDim2.new(0,0,0,46), BackgroundColor3=T.panel, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=T.accent, CanvasSize=UDim2.new(0,0,0,#opts*26), Visible=false, ZIndex=10, Parent=f})
        Instance.new("UICorner", lf).CornerRadius = UDim.new(0, 6)
        Instance.new("UIListLayout", lf).Padding = UDim.new(0, 2)
        for _, o in ipairs(opts) do
            local ob = mk("TextButton", {Size=UDim2.new(1,0,0,24), BackgroundColor3=T.panel2, BackgroundTransparency=0.5, BorderSizePixel=0, Text="  "..o, Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=T.text, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=11, Parent=lf})
            Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
            ob.MouseButton1Click:Connect(function() cur=o; dl.Text=o; CFG[flag]=o; lf.Visible=false; ar.Text="▼"; if cb then cb(o) end end)
        end
        bb.MouseButton1Click:Connect(function() lf.Visible=not lf.Visible; ar.Text=lf.Visible and "▲" or "▼" end)
    end
    
    local function Btn(p, label, color, cb)
        local b = mk("TextButton", {Size=UDim2.new(1,0,0,30), BackgroundColor3=color or T.accent, BorderSizePixel=0, Text=label, Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.new(1,1,1), AutoButtonColor=false, Parent=p})
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=T.accentHi}) end)
        b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=color or T.accent}) end)
        b.MouseButton1Click:Connect(function() tw(b,0.06,{Size=UDim2.new(0.98,0,0,28)}); task.delay(0.06,function() tw(b,0.1,{Size=UDim2.new(1,0,0,30)}) end); if cb then cb() end end)
    end
    
    -- COMBAT
    local cc = Card(tabFrames["Combat"], "🛡️ AUTO PARRY")
    Toggle(cc, "Auto Parry", "AutoParry", CFG.AutoParry, function(s) if s then AP.Start() else AP.Stop() end end)
    Drop(cc, "Mode", "AutoParryMode", {"Remote", "Keypress"}, CFG.AutoParryMode)
    Drop(cc, "Retry", "RetryStrength", {"Safe","Balanced","Aggressive","Maximum","Legendary"}, CFG.RetryStrength)
    Slider(cc, "Strength", "AutoParryStrength", 0.5, 2.0, CFG.AutoParryStrength)
    Slider(cc, "Accuracy", "ParryAccuracy", 1, 100, CFG.ParryAccuracy)
    Drop(cc, "Prediction", "PredictionMode", {"Auto Best","Manual"}, CFG.PredictionMode)
    Slider(cc, "Pred Offset", "PredictionOffset", -1, 1, CFG.PredictionOffset)
    Toggle(cc, "Emergency Shield", "EmergencyShield", CFG.EmergencyShield)
    Toggle(cc, "Cooldown Protect", "CooldownProtection", CFG.CooldownProtection)
    Toggle(cc, "Auto Ability", "AutoAbility", CFG.AutoAbility)
    Toggle(cc, "No Stun", "NoStun", CFG.NoStun)
    
    local tc = Card(tabFrames["Combat"], "🎯 TRIGGERBOT")
    Toggle(tc, "Triggerbot", "Triggerbot", CFG.Triggerbot, function(s) if s then TB.Start() else TB.Stop() end end)
    
    -- SPAM
    local mc = Card(tabFrames["Spam"], "⚡ MANUAL SPAM")
    Toggle(mc, "Manual Spam", "ManualSpam", CFG.ManualSpam, function(s) if s then MS.Start() else MS.Stop() end end)
    Slider(mc, "CPS", "ManualSpamCPS", 1, 200, CFG.ManualSpamCPS)
    Drop(mc, "Mode", "ManualSpamMode", {"Ball Speed","Fixed","Burst"}, CFG.ManualSpamMode)
    
    local ac = Card(tabFrames["Spam"], "🔄 AUTO SPAM")
    Toggle(ac, "Auto Spam", "AutoSpam", CFG.AutoSpam, function(s) if s then AS.Start() else AS.Stop() end end)
    Drop(ac, "Target", "AutoSpamMode", {"Closest","Target","Random"}, CFG.AutoSpamMode)
    
    -- VISUALS
    local ec = Card(tabFrames["Visuals"], "👁️ ESP")
    Toggle(ec, "Player ESP", "ESP", CFG.ESP, function(s) if s then ESP.Start() else ESP.Stop() end end)
    Toggle(ec, "Health", "ESPHealth", CFG.ESPHealth)
    Toggle(ec, "Distance", "ESPDist", CFG.ESPDist)
    Toggle(ec, "Target", "ESPTarget", CFG.ESPTarget)
    Toggle(ec, "Ball Speed", "BallSpeed", CFG.BallSpeed, function(s) if s then BSD.Start() else BSD.Stop() end end)
    
    -- PLAYER
    local pc = Card(tabFrames["Player"], "🏃 MOVEMENT")
    Slider(pc, "Walk Speed", "WalkSpeed", 16, 200, CFG.WalkSpeed, function(v) Misc.SetSpeed(v) end)
    Slider(pc, "Jump Power", "JumpPower", 50, 200, CFG.JumpPower, function(v) Misc.SetJump(v) end)
    Toggle(pc, "No Clip", "NoClip", CFG.NoClip, function(s) Misc.ToggleNoClip(s) end)
    Toggle(pc, "Fly", "Fly", CFG.Fly, function(s) Misc.ToggleFly(s) end)
    Slider(pc, "Fly Speed", "FlySpeed", 10, 200, CFG.FlySpeed)
    
    -- SWORD
    local sc = Card(tabFrames["Sword"], "🗡️ SKIN CHANGER")
    Toggle(sc, "Enable", "SkinChanger", CFG.SkinChanger)
    local si = mk("TextBox", {Size=UDim2.new(1,0,0,28), BackgroundColor3=T.panel2, BorderSizePixel=0, Text=CFG.SwordName, PlaceholderText="武器名称", PlaceholderColor3=T.faint, TextColor3=T.text, Font=Enum.Font.GothamMedium, TextSize=12, ClearTextOnFocus=false, Parent=sc})
    Instance.new("UICorner", si).CornerRadius = UDim.new(0, 6)
    si.FocusLost:Connect(function() CFG.SwordName = si.Text end)
    Btn(sc, "🗡️ 应用", T.accent, function() CFG.SkinChanger=true; SC2.Apply(CFG.SwordName) end)
    
    local wl = Card(tabFrames["Sword"], "📋 常用武器")
    for _, sw in ipairs({"Default","Ice","Lava","Lightning","Shadow","Venom","Wind","Earth","Plasma","Dark Matter"}) do
        Btn(wl, sw, T.panel2, function() CFG.SwordName=sw; si.Text=sw; CFG.SkinChanger=true; SC2.Apply(sw) end)
    end
    
    -- SETTINGS
    local stc = Card(tabFrames["Settings"], "⚙️ 设置")
    mk("TextLabel", {Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, Text="RightShift 切换 UI | v2.0", Font=Enum.Font.Gotham, TextSize=10, TextColor3=T.faint, TextXAlignment=Enum.TextXAlignment.Left, Parent=stc})
    mk("TextLabel", {Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, Text="Remote: "..(PRY_PATCH.ready and "PRY ✓" or "检测中..."), Font=Enum.Font.Gotham, TextSize=10, TextColor3=PRY_PATCH.ready and T.success or T.faint, TextXAlignment=Enum.TextXAlignment.Left, Parent=stc})
    mk("TextLabel", {Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, Text="discord.gg/hZhwszmP", Font=Enum.Font.GothamMedium, TextSize=10, TextColor3=T.accent, TextXAlignment=Enum.TextXAlignment.Left, Parent=stc})
    Btn(stc, "🔄 重试 PRY 检测", T.panel2, function() PRY_PATCH.ready=false; InitPRY(); Notify("ENRIQUE","重新检测 PRY...",3) end)
    Btn(stc, "🧹 卸载", T.danger, function() AP.Stop(); MS.Stop(); AS.Stop(); TB.Stop(); ESP.Stop(); BSD.Stop(); SC2.Stop(); Misc.ToggleNoClip(false); Misc.ToggleFly(false); pcall(function() sg:Destroy() end); pcall(function() blur:Destroy() end); _G._ENRIQUE_PAID_V2=nil; Notify("ENRIQUE","已卸载",3) end)
    
    -- 拖动
    local dragging, ds, sp2 = false
    main.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; ds=i.Position; sp2=root.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds; root.Position=UDim2.new(sp2.X.Scale,sp2.X.Offset+d.X,sp2.Y.Scale,sp2.Y.Offset+d.Y) end end)
    
    -- 最小化
    local minBtn = mk("TextButton", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0,4), BackgroundColor3=T.panel, BorderSizePixel=0, Text="—", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=T.dim, AutoButtonColor=false, Parent=main})
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    minBtn.MouseButton1Click:Connect(function()
        UI.Minimized = not UI.Minimized
        if UI.Minimized then tw(main, 0.25, {Size=UDim2.new(0,W,0,36)}); handler.Visible=false; minBtn.Text="+"
        else tw(main, 0.25, {Size=UDim2.new(0,W,0,H)}); handler.Visible=true; minBtn.Text="—" end
    end)
    
    -- 关闭
    local closeBtn = mk("TextButton", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-62,0,4), BackgroundColor3=T.panel, BorderSizePixel=0, Text="×", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=T.dim, AutoButtonColor=false, Parent=main})
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() UI.Open=false; tw(ov,0.2,{BackgroundTransparency=1}); tw(blur,0.25,{Size=0}); task.delay(0.25,function() sg.Visible=false end) end)
    
    -- 快捷键
    UserInputService.InputBegan:Connect(function(i, p) if p then return end; if i.KeyCode==CFG.UIKey then UI.Open=not UI.Open; if UI.Open then sg.Visible=true; UI.Minimized=false; main.Size=UDim2.new(0,W,0,H); handler.Visible=true; minBtn.Text="—"; tw(ov,0.2,{BackgroundTransparency=0.5}); tw(blur,0.3,{Size=12}) else sg.Visible=false end end end)
    
    -- 入场
    root.Size=UDim2.new(0,W-30,0,H-20)
    tw(ov,0.25,{BackgroundTransparency=0.5}); tw(blur,0.3,{Size=12})
    tw(root,0.35,{Size=UDim2.new(0,W,0,H)}, Enum.EasingStyle.Back)
end

-- 启动
InitPRY()
InitHook()
task.wait(0.3)

if KeySys.Authenticated then
    CreateMainUI()
    Notify("⚔️ ENRIQUE PAID v2", "已激活！ "..KeySys.FormatTime(KeySys.TimeLeft()), 5)
else
    ShowKeyUI(function()
        CreateMainUI()
        Notify("⚔️ ENRIQUE PAID v2", "激活成功！\ndiscord.gg/hZhwszmP", 5)
    end)
end

print("⚔️ ENRIQUE PAID v2.0 — PRY + 动漫 UI")
print("PRY: "..(PRY_PATCH.ready and "Ready" or "Detecting..."))
print("Key: "..(KeySys.Authenticated and "Valid" or "Required"))
