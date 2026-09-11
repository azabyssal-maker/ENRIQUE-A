repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local SwordAPI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SwordAPI")
local player = Players.LocalPlayer

local function parryContextAllowed()
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local r=c and (c.PrimaryPart or c:FindFirstChild("HumanoidRootPart"))
 if not c or not h or h.Health<=0 or not r or c:GetAttribute("Stunned") or c:GetAttribute("DoNotParry") or c:GetAttribute("IsFrozen") then return false end
 if c.Parent==workspace:FindFirstChild("Alive") then return true end
 if player:GetAttribute("LobbyParry") and not player:GetAttribute("InLobbyParryCooldown") then return true end
 if player:GetAttribute("LobbyTraining") and c.Parent==workspace:FindFirstChild("Dead") then return true end
 local sp=workspace:FindFirstChild("Spawn") local lt=sp and sp:FindFirstChild("LobbyTraining") local area=lt and lt:FindFirstChild("TrainingArea")
 if area and area:IsA("BasePart") then local q=area.CFrame:PointToObjectSpace(r.Position) return math.abs(q.X)<=area.Size.X/2+2 and math.abs(q.Z)<=area.Size.Z/2+2 and math.abs(q.Y)<=area.Size.Y/2+20 end
 return false
end

do
 local env=getgenv() local host=(gethui and gethui()) or game:GetService("CoreGui") local protect=protect_gui or protectgui or syn and syn.protect_gui
 local function cloak(g) if not g then return end pcall(function() g.Name=game:GetService("HttpService"):GenerateGUID(false):gsub("-",""):sub(1,18) g.ResetOnSpawn=false end) if protect then pcall(protect,g) end if set_hidden_gui then pcall(set_hidden_gui,g,true) end if host and g.Parent~=host then pcall(function() g.Parent=host end) end end
 env.ENRIQUECloakGui=cloak
 env.ENRIQUEScrambleUI=function(instance) if instance then pcall(function() for _,v in ipairs(instance:GetDescendants()) do if v:IsA("GuiObject") then v.Name=game:GetService("HttpService"):GenerateGUID(false):gsub("-",""):sub(1,18) end end end) end end
 env.GameSecure=setmetatable({},{__index=function(_,k) if k=="GetService" then return function(_,n) return (cloneref or function(x)return x end)(game:GetService(n)) end end return game[k] end})
 if not env.ENRIQUESecurityProbe then env.ENRIQUESecurityProbe=true task.spawn(function() while true do local st=os.clock() local fin=false task.delay(2,function() fin=true end) while not fin and os.clock()-st<4 do RunService.RenderStepped:Wait() end if not fin then warn("[ENRIQUE Security] scheduler freeze") end task.wait(5) end end) end
end

local cfg = {
parry = true,
spam = false,
trigger = false,
cps = 200,
accuracy = 50,
randomPingAccuracy = false,
autoSpam = false,
spamThreshold = 0,
distanceMultiplier = 1.0,
targetChangeStop = false,
aiPatterns = true,
aiDetection = true,
abilityDetections = true,
animfix = true,
showStats = true,
showSpamUI = true,
showTriggerUI = true,
curveType = 'straight',
showBindWindow = false,
spamBindKey = "P"
}

cfg.spamThreshold = math.max(0, cfg.spamThreshold or 0)
cfg.distanceMultiplier = math.max(0.8, cfg.distanceMultiplier or 1.0)

local RuntimeAccuracy = math.clamp(tonumber(cfg.accuracy) or 50,1,100)
task.spawn(function() while task.wait(1) do SaveENRIQUEConfig() end end)
getgenv().SaveENRIQUEConfig=SaveENRIQUEConfig
getgenv().LoadENRIQUEConfig=LoadENRIQUEConfig
local spamBindKey = cfg.spamBindKey or "P"
local isWaitingForBind = false
local parried_balls = {}
local triggered_balls = {}
local AnimationCache = {}
local spamActive = cfg.spam == true
local lastSpamTime = 0

local Det = {
 infinity=false,
 deathslash=false,
 timehole=false,
 phantom=false,
 dribble=false,
 pull=false,
 singularity=false,
 forcefield=false,
 slashes=false,
 slashesCount=0,
 infinityEnabled=false,
 deathslashEnabled=false,
 timeholeEnabled=false,
 phantomEnabled=false,
 dribbleEnabled=false,
 pullEnabled=false,
 singularityEnabled=false,
 forcefieldEnabled=false,
 slashesEnabled=false,
 slashesParryDelay=0.05,
 slashesMaxCount=36,
 staffEnabled=false
}

local DetectionNet = ReplicatedStorage:FindFirstChild("Packages")
DetectionNet = DetectionNet and DetectionNet:FindFirstChild("_Index")
DetectionNet = DetectionNet and DetectionNet:FindFirstChild("sleitnick_net@0.1.0")
DetectionNet = DetectionNet and DetectionNet:FindFirstChild("net")

local function DetectionBlocked()
 if not cfg.abilityDetections then return false end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return (Det.infinityEnabled and Det.infinity)
 or (Det.deathslashEnabled and Det.deathslash)
 or (Det.timeholeEnabled and Det.timehole)

 or (Det.phantomEnabled and Det.phantom)
 or (Det.dribbleEnabled and Det.dribble)
 or (Det.pullEnabled and Det.pull)
 or (Det.slashesEnabled and Det.slashes)
 or (Det.singularityEnabled and (Det.singularity or (root and root:FindFirstChild("SingularityCape")~=nil)))
 or (Det.forcefieldEnabled and Det.forcefield)
end

local function AbilityBlocked()
 return DetectionBlocked()
end

pcall(function()
 local remote=ReplicatedStorage.Remotes:FindFirstChild("InfinityBall")
 if remote then remote.OnClientEvent:Connect(function(_,v) Det.infinity=v and true or false end) end
end)

pcall(function()
 local remote=ReplicatedStorage.Remotes:FindFirstChild("DeathBall")
 if remote then remote.OnClientEvent:Connect(function(_,v) Det.deathslash=v and true or false end) end
end)

pcall(function()
 local remotes=ReplicatedStorage:FindFirstChild("Remotes")
 local pull=remotes and (remotes:FindFirstChild("PlrPulled") or remotes:FindFirstChild("PlrPulsed"))
 if pull then
  pull.OnClientEvent:Connect(function(a,b)
   if type(a)=="boolean" then
    Det.pull=a
   elseif type(b)=="boolean" then
    Det.pull=b
   else
    Det.pull=true
    task.delay(1.5,function() Det.pull=false end)
   end
  end)
 end
end)

pcall(function()
 local remotes=ReplicatedStorage:FindFirstChild("Remotes")
 local pull=remotes and remotes:FindFirstChild("PlrPulsed")
 if pull then
  pull.OnClientEvent:Connect(function(a,b)
   if type(a)=="boolean" then
    Det.pull=a
   elseif type(b)=="boolean" then
    Det.pull=b
   else
    Det.pull=true
    task.delay(1.5,function() Det.pull=false end)
   end
  end)
 end
end)

pcall(function()
 local char=player.Character or player.CharacterAdded:Wait()
 local function watch(c)
  c.AttributeChanged:Connect(function(attr)
   if attr=="PassiveLock_ForceField" then
    Det.forcefield=c:GetAttribute("PassiveLock_ForceField")==true
   end
  end)
  Det.forcefield=c:GetAttribute("PassiveLock_ForceField")==true
 end
 watch(char)
 player.CharacterAdded:Connect(function(c)
  Det.forcefield=false
  watch(c)
 end)
end)

if DetectionNet then
 local TimeHoleActivate=DetectionNet:FindFirstChild("RE/TimeHoleActivate")
 local TimeHoleDeactivate=DetectionNet:FindFirstChild("RE/TimeHoleDeactivate")
 if TimeHoleActivate then
  TimeHoleActivate.OnClientEvent:Connect(function(p)
   if p==player or p==player.Name or p and p.Name==player.Name then Det.timehole=true end
  end)
 end
 if TimeHoleDeactivate then
  TimeHoleDeactivate.OnClientEvent:Connect(function() Det.timehole=false end)
 end
 local SlashesActivate=DetectionNet:FindFirstChild("RE/SlashesOfFuryActivate")
 local SlashesEnd=DetectionNet:FindFirstChild("RE/SlashesOfFuryEnd")
 local SlashesCatch=DetectionNet:FindFirstChild("RE/SlashesOfFuryCatch")
 local SlashesParry=DetectionNet:FindFirstChild("RE/SlashesOfFuryParry")
 if SlashesActivate then
  SlashesActivate.OnClientEvent:Connect(function(p)
   if not p or p==player or p==player.Name or p.Name==player.Name then
    Det.slashes=true
    Det.slashesCount=0
   end
  end)
 end
 if SlashesEnd then
  SlashesEnd.OnClientEvent:Connect(function()
   Det.slashes=false
   Det.slashesCount=0
  end)
 end
 if SlashesParry then
  SlashesParry.OnClientEvent:Connect(function()
   Det.slashesCount+=1
  end)
 end
 if SlashesCatch then
  SlashesCatch.OnClientEvent:Connect(function()
   if not Det.slashesEnabled then return end
   task.spawn(function()
    while Det.slashes and Det.slashesCount<Det.slashesMaxCount do
     local fn=getgenv().ENRIQUE_SendParry
     if type(fn)=="function" then fn() end
     task.wait(Det.slashesParryDelay)
    end
   end)
  end)
 end
end

task.spawn(function()
 while task.wait(0.15) do
  local ball
  local folder=workspace:FindFirstChild("Balls")
  if folder then
   for _,v in ipairs(folder:GetChildren()) do
    if v:GetAttribute("realBall") then ball=v break end
   end
  end
  Det.dribble=ball and (ball:GetAttribute("Dribble")==true or ball:GetAttribute("Dribbling")==true or ball:FindFirstChild("Dribble")~=nil or ball:FindFirstChild("Dribbling")~=nil) or false
 end
end)

task.spawn(function()
 local runtime=workspace:FindFirstChild("Runtime") or workspace:WaitForChild("Runtime",15)
 if runtime then
  runtime.ChildAdded:Connect(function(o)
   if o.Name~="maxTransmission" and o.Name~="transmissionpart" then return end
   local weld=o:FindFirstChildWhichIsA("WeldConstraint")
   local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if weld and root and weld.Part1==root then
    Det.phantom=true
    task.delay(1,function() Det.phantom=false end)
   end
  end)
 end
end)

getgenv().ENRIQUEDetectionState=Det
getgenv().ENRIQUEAbilityDetectionState=Det

local function GetPing()
local success, result = pcall(function()
return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
end)
return success and result or 100
end
task.spawn(function()
 while task.wait(1) do
  if cfg.randomPingAccuracy then
   local ping=GetPing()
   if ping>=90 then RuntimeAccuracy=4
   elseif ping<=50 then RuntimeAccuracy=math.random(70,100)
   else RuntimeAccuracy=math.clamp(tonumber(cfg.accuracy) or 50,1,100) end
  else RuntimeAccuracy=math.clamp(tonumber(cfg.accuracy) or 50,1,100) end
 end
end)

local AI={ping=100,frame=1/60,jitter=0,extra=0,last=0,motion=setmetatable({},{__mode="k"})}
RunService.Heartbeat:Connect(function(dt) local old=AI.frame AI.frame=old+((dt or 1/60)-old)*.12 AI.jitter=AI.jitter+(math.abs((dt or 1/60)-old)-AI.jitter)*.15 if os.clock()-AI.last>.25 then AI.last=os.clock() local p=GetPing() AI.ping=AI.ping+(p-AI.ping)*.22 end if not cfg.aiDetection then AI.extra=0 elseif AI.ping>=220 or AI.frame>=.065 then AI.extra=.05 elseif AI.ping>=140 or AI.frame>=.035 then AI.extra=.028 elseif AI.ping>=85 then AI.extra=.012 else AI.extra=0 end end)

local function ClosestOpponent() local root=player.Character and player.Character.PrimaryPart local alive=workspace:FindFirstChild("Alive") if not root or not alive then return end local best,res=math.huge,nil for _,c in ipairs(alive:GetChildren()) do if c~=player.Character and c.PrimaryPart then local d=(c.PrimaryPart.Position-root.Position).Magnitude if d<best then best,res=d,c end end end return res end

local function CalculateParryDistance(ball,velocity,root)
 local speed=velocity.Magnitude local ping=GetPing() local capped=math.min(math.max(speed-9.5,0),650) local div=(2.4+capped*.002)*(0.75+(math.clamp(RuntimeAccuracy,1,100)-1)*(3/99)) local modern=math.clamp(ping/100,5,17)+math.max(speed/div,9.5) local legacy=speed/math.max(2.4,RuntimeAccuracy/8)+ping/10 local result=math.max(modern,legacy)
 if cfg.aiDetection then result=result+math.clamp(speed*AI.extra,0,30) if speed>=750 then result=math.max(result,9.5+speed*.025) end end
 if cfg.aiPatterns then local now=os.clock() local h=AI.motion[ball] if h then local dt=math.clamp(now-h.time,1/240,.15) local acc=(velocity-h.velocity).Magnitude/dt local turn=velocity.Magnitude>0 and h.velocity.Magnitude>0 and math.acos(math.clamp(velocity.Unit:Dot(h.velocity.Unit),-1,1)) or 0 result=result+math.clamp(acc*.0015+speed*turn*.07,0,20) end AI.motion[ball]={velocity=velocity,time=now} local o=ClosestOpponent() if o and o.PrimaryPart then local to=root.Position-o.PrimaryPart.Position if to.Magnitude>0 then result=result+math.clamp(math.max(o.PrimaryPart.AssemblyLinearVelocity:Dot(to.Unit),0)*.1,0,12) end end end
 return result
end

local Lerp_Radians = 0
local Last_Warping = tick()
local function Is_Curved(ball)
local Zoomies = ball:FindFirstChild("zoomies")
if not Zoomies then return false end
local Velocity = Zoomies.VectorVelocity
local Character = player.Character
if not Character or not Character.PrimaryPart then return false end
local distanceToBall = (Character.PrimaryPart.Position - ball.Position).Magnitude
if distanceToBall <= 25 then return false end
local Speed = Velocity.Magnitude
local Direction = (Character.PrimaryPart.Position - ball.Position).Unit
local Dot = Direction:Dot(Velocity.Unit)
local Ping = GetPing() / 1000
local Distance = (Character.PrimaryPart.Position - ball.Position).Magnitude
local Reach_Time = Distance / Speed - Ping
local Radians = math.rad(math.asin(math.clamp(Dot, -1, 1)))
Lerp_Radians = Lerp_Radians + (Radians - Lerp_Radians) * 0.8
if Lerp_Radians < 0.018 then Last_Warping = tick() end
if (tick() - Last_Warping) < (Reach_Time / 1.5) then return true end
return Dot < (0.5 - Ping)
end

local function GetParryAnimation()
local char = player.Character
local currentSword = char and char:GetAttribute("CurrentlyEquippedSword")
if not currentSword then return SwordAPI.Collection.Default:FindFirstChild("GrabParry") end
if AnimationCache[currentSword] then return AnimationCache[currentSword] end
local success, swordData = pcall(function()
return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(currentSword)
end)
if success and type(swordData) == "table" then
for _, obj in pairs(SwordAPI.Collection:GetChildren()) do
if obj.Name == swordData.AnimationType then
local anim = obj:FindFirstChild("GrabParry") or obj:FindFirstChild("Grab")
if anim then AnimationCache[currentSword] = anim return anim end
end
end
end
return SwordAPI.Collection.Default:FindFirstChild("GrabParry")
end

local function PlayParryAnimation()
if not cfg.animfix then return end
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not hum or not hum:FindFirstChild("Animator") then return end
local animation = GetParryAnimation()
if not animation then return end
for _, track in pairs(hum.Animator:GetPlayingAnimationTracks()) do
if track.Name:find("Grab") or track.Name:find("Parry") then track:Stop(0.1) end
end
local track = hum.Animator:LoadAnimation(animation)
track:Play(0, 1, 1)
end

local function ApplyCurveToCFrame(baseCFrame)
if not cfg.curveType or cfg.curveType == 'straight' then return baseCFrame end
local rotation = CFrame.new()
if cfg.curveType == 'backwards' then rotation = CFrame.Angles(0, math.rad(180), 0)
elseif cfg.curveType == 'down' then rotation = CFrame.Angles(math.rad(-45), 0, 0)
elseif cfg.curveType == 'up' then rotation = CFrame.Angles(math.rad(45), 0, 0)
elseif cfg.curveType == 'left' then rotation = CFrame.Angles(0, math.rad(-90), 0)
elseif cfg.curveType == 'right' then rotation = CFrame.Angles(0, math.rad(90), 0)
elseif cfg.curveType == 'random' then rotation = CFrame.Angles(0, math.random() * math.pi * 2, 0)
end
return baseCFrame * rotation
end

local function GetParryData()
local viewportSize = Camera.ViewportSize
local centerPos = { viewportSize.X / 2, viewportSize.Y / 2 }
local events = {}
for _, v in pairs(workspace.Alive:GetChildren()) do
if v ~= player.Character and v:FindFirstChild("HumanoidRootPart") then
local screenPos, isOnScreen = Camera:WorldToScreenPoint(v.HumanoidRootPart.Position)
if isOnScreen then events[tostring(v)] = screenPos end
end
end
return Camera.CFrame, events, centerPos
end

local recentParries=0

local _token
for _, Function in getgc(true) do
    if type(Function) ~= 'function' then continue end
    local ok, src = pcall(debug.info, Function, 's')
    if not ok or type(src) ~= 'string' or not src:find('PRY', 1, true) then continue end
    for _, value in debug.getupvalues(Function) do
        if type(value) == 'function' then
            _token = value
            break
        end
    end
    if _token then break end
end

local function _tokenize(_remote_uid)
    local time = tostring(math.floor(workspace:GetServerTimeNow() * 100))
    local key = _token(_remote_uid, 'TIME')
    local characters = table.create(#time)
    for index = 1, #time do
        characters[index] = string.char(bit32.bxor(
            (string.byte(time, index) + index) % 256,
            string.byte(key, (index - 1) % #key + 1)
        ))
    end
    return table.concat(characters)
end

local _reverted = {}
local _originalMt = {}
local _captured = nil

local function _is_valid(args)
    return #args == 8
        and type(args[2]) == "string" and type(args[3]) == "string"
        and type(args[4]) == "number" and typeof(args[5]) == "CFrame"
        and type(args[6]) == "table" and type(args[7]) == "table"
        and type(args[8]) == "boolean"
end

local function _hook(remote)
    local mt = getrawmetatable(remote)
    if not mt or _originalMt[mt] then return end
    _originalMt[mt] = true
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = function(self, key)
        local isFire  = (key == 'FireServer'  and self:IsA('RemoteEvent'))
        local isInvok = (key == 'InvokeServer' and self:IsA('RemoteFunction'))
        if isFire or isInvok then
            return function(_, ...)
                local a = {...}
                if _is_valid(a) then
                    if not _reverted[self] then _reverted[self] = a end
                    if not _captured then
                        _captured = { remote = self, isInvoke = isInvok }
                        print("[ENRIQUE] CAPTURED parry remote -> ready:", self:GetFullName())
                    end
                end
                if isInvok then return old(self, key)(_, unpack(a)) end
                return old(self, key)(_, unpack(a))
            end
        end
        return old(self, key)
    end
    setreadonly(mt, true)
end

for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA('RemoteEvent') or remote:IsA('RemoteFunction') then
        pcall(_hook, remote)
    end
end
ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA('RemoteEvent') or child:IsA('RemoteFunction') then
        pcall(_hook, child)
    end
end)

local function RemoteReady()
    return _captured ~= nil and _token ~= nil
end

local function SendParry()
    if not RemoteReady() or not parryContextAllowed() or AbilityBlocked() then return false end
    local remote = _captured.remote
    local cap = _reverted[remote] or (_captured.args)
    if not cap then return false end

    local okTok, token = pcall(_tokenize, cap[2])
    if not (okTok and token) then return false end

    local cf, events, mouse = GetParryData()
    cf = ApplyCurveToCFrame(cf)

    local packet = { cap[1], cap[2], token, cap[4] or 0.5, cf, events, mouse, false }

    local fired
    if _captured.isInvoke then
        fired = pcall(function() remote:InvokeServer(unpack(packet)) end)
    else
        fired = pcall(function() remote:FireServer(unpack(packet)) end)
    end

    if fired then
        recentParries = (recentParries or 0) + 1
        task.delay(.5, function() recentParries = math.max((recentParries or 1) - 1, 0) end)
    end
    if fired and cfg.animfix then task.spawn(PlayParryAnimation) end
    return fired
end

getgenv().ENRIQUE_SendParry=SendParry

local function ProcessAutoParry(ball)
if not cfg.parry or spamActive then return end
local bID = ball:GetDebugId()
if ball:GetAttribute("target") ~= player.Name or parried_balls[bID] then return end
if Is_Curved(ball) then return end
local charPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if not charPart then return end
local velocity = ball.zoomies.VectorVelocity
local ballPos = ball.Position
local playerPos = charPart.Position
local dist = (playerPos - ballPos).Magnitude
local threshold = CalculateParryDistance(ball, velocity, charPart)
if dist <= threshold or dist <= 20 then
parried_balls[bID] = true
SendParry()
ball:GetAttributeChangedSignal("target"):Once(function() parried_balls[bID] = nil end)
end
end

local function ProcessTriggerBot(ball)
if not cfg.trigger or spamActive then return end
local bID = ball:GetDebugId()
if ball:GetAttribute("target") == player.Name and not triggered_balls[bID] then
triggered_balls[bID] = true
SendParry()
ball:GetAttributeChangedSignal("target"):Once(function() triggered_balls[bID] = nil end)
end
end

local AS={target=nil,targetTime=0,lastCheck=0,lastFire=0,trackedBall=nil,targetConn=nil,engagedTarget=nil,abortCycle=false}
local function ResetAutoSpamTargetGuard()
 if AS.targetConn then AS.targetConn:Disconnect() AS.targetConn=nil end
 AS.trackedBall=nil
 AS.engagedTarget=nil
 AS.abortCycle=false
end
local function TrackAutoSpamTarget(ball)
 if AS.trackedBall==ball then return end
 ResetAutoSpamTargetGuard()
 AS.trackedBall=ball
 AS.engagedTarget=ball:GetAttribute("target")
 AS.targetConn=ball:GetAttributeChangedSignal("target"):Connect(function()
  if AS.trackedBall~=ball then return end
  local liveTarget=ball:GetAttribute("target")
  if cfg.targetChangeStop then
   if not AS.engagedTarget then AS.engagedTarget=liveTarget
   elseif liveTarget and liveTarget~=AS.engagedTarget then AS.engagedTarget=liveTarget AS.abortCycle=true end
  else AS.engagedTarget=liveTarget AS.abortCycle=false end
 end)
end

local function ProcessAutoSpam(ball)
 if not cfg.autoSpam or not parryContextAllowed() then ResetAutoSpamTargetGuard() return end
 local root=player.Character and player.Character.PrimaryPart local z=ball:FindFirstChild("zoomies")
 if not root or not z then return end

 TrackAutoSpamTarget(ball)
 local now=tick() if now-AS.lastFire<0.015 then return end AS.lastFire=now
 local target=ball:GetAttribute("target")

 if cfg.targetChangeStop and AS.abortCycle then AS.abortCycle=false return end

 if now-AS.lastCheck>.1 then AS.target=ClosestOpponent() AS.lastCheck=now AS.targetTime=now end
 local enemy=AS.target if not enemy or not enemy.PrimaryPart or not target then return end

 local speed=z.VectorVelocity.Magnitude if speed<.001 then return end
 local ping=math.clamp(GetPing()/10,1,16)

 local distMult = math.max(cfg.distanceMultiplier or 1.0, 0.8)
 local max=(ping+math.min(speed/6,255)+math.clamp(speed*AI.extra,0,35))*distMult
 local bd=(root.Position-ball.Position).Magnitude local ed=(root.Position-enemy.PrimaryPart.Position).Magnitude
 if bd>max or ed>max then return end

 local dot=(root.Position-ball.Position).Unit:Dot(z.VectorVelocity.Unit)
 local acc=max-math.clamp(dot,-1,0)*(5-math.min(speed/5,5))

 local spamGate = math.max(cfg.spamThreshold or 0, 0)
 if (target==enemy.Name or target==player.Name) and bd<=acc and ed<=acc
    and recentParries>=spamGate then
   SendParry()
 end
end

task.spawn(function()
while true do
if spamActive and RemoteReady() then
local delay = 1 / math.max(cfg.cps or 200, 1)
if tick() - lastSpamTime >= delay then SendParry() lastSpamTime = tick() end
end
task.wait(0.001)
end
end)

RunService.Heartbeat:Connect(function()
if not RemoteReady() then return end
local ball=nil
local balls=workspace:FindFirstChild("Balls")
if balls then for _,v in pairs(balls:GetChildren()) do if v:GetAttribute("realBall") then ball=v break end end end
if ball then
 if cfg.trigger then ProcessTriggerBot(ball)
 elseif cfg.parry and not spamActive then ProcessAutoParry(ball) end
 ProcessAutoSpam(ball)
end
local training=workspace:FindFirstChild("TrainingBalls")
if training and parryContextAllowed() then
 for _,v in ipairs(training:GetChildren()) do
  if v:GetAttribute("realBall") then
   if cfg.parry then ProcessAutoParry(v) end
   ProcessAutoSpam(v)
   break
  end
 end
end
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if not hum or not hum:FindFirstChild("Animator") then return end
for _, track in pairs(hum.Animator:GetPlayingAnimationTracks()) do
if track.Name:find("Grab") or track.Name:find("Parry") then track:Stop(0.1) end
end
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ffgringoxp123-code/Code/refs/heads/main/Uikitty_with_ColorPicker.lua.txt"))()

local UI = Library._new("ENRIQUE FREE")
-- ENRIQUE FREE Anime Background
task.spawn(function()
    task.wait(3)
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, frame in ipairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame.Size and frame.Size.X.Scale > 0.3 then
                        local bg = Instance.new("ImageLabel")
                        bg.Size = UDim2.new(1,0,1,0)
                        bg.BackgroundTransparency = 1
                        bg.Image = "rbxassetid://15452092090"
                        bg.ImageTransparency = 0.85
                        bg.ScaleType = Enum.ScaleType.Stretch
                        bg.ZIndex = 0
                        bg.Parent = frame
                        gui.Name = "ENRIQUE_FREE_UI"
                        return
                    end
                end
            end
        end
    end)
end)


local MainCat = UI:create_category("Main")
local Parry = MainCat:create_tab("Parry", "rbxassetid://swords")


local ParryLeft = Parry:create_group("Auto Parry", "left")

ParryLeft:create_toggle("auto_parry", {
    title = "Auto Parry",
    default = cfg.parry == true,
    callback = function(value) cfg.parry = value end,
})

ParryLeft:create_slider("parry_accuracy", {
    title = "Parry Accuracy",
    minimum = 1,
    maximum = 100,
    default = RuntimeAccuracy,
    rounding = true,
    callback = function(value)
        cfg.accuracy = value
        if not cfg.randomPingAccuracy then RuntimeAccuracy = value end
    end,
})

ParryLeft:create_toggle("humanizer", {
    title = "Humanizer",
    default = cfg.randomPingAccuracy == true,
    callback = function(value)
        cfg.randomPingAccuracy = value
        if not value then RuntimeAccuracy = math.clamp(tonumber(cfg.accuracy) or 50, 1, 100) end
    end,
})

ParryLeft:create_slider("humanizer_accuracy", {
    title = "Humanizer Accuracy",
    minimum = 1,
    maximum = 100,
    default = RuntimeAccuracy,
    rounding = true,
    callback = function(value)
        if cfg.randomPingAccuracy then RuntimeAccuracy = math.clamp(value, 1, 100) end
    end,
})

ParryLeft:create_dropdown("curve_type", {
    title = "Curve Type",
    options = { "straight", "backwards", "up", "down", "left", "right", "random" },
    default = cfg.curveType or "straight",
    callback = function(value) cfg.curveType = value end,
})

local ParryRight = Parry:create_group("Auto Spam", "right")

ParryRight:create_toggle("auto_spam", {
    title = "Auto Spam",
    default = cfg.autoSpam == true,
    callback = function(value)
        cfg.autoSpam = value
        if not value then ResetAutoSpamTargetGuard() end
    end,
})

ParryRight:create_toggle("target_change_stop", {
    title = "Target Change Stop",
    default = cfg.targetChangeStop == true,
    callback = function(value)
        cfg.targetChangeStop = value
        ResetAutoSpamTargetGuard()
    end,
})

ParryRight:create_toggle("animation_fix", {
    title = "Animation Fix",
    default = cfg.animfix == true,
    callback = function(value) cfg.animfix = value end,
})

ParryRight:create_slider("parry_threshold", {
    title = "Parry Threshold",
    minimum = 0,
    maximum = 10,
    default = math.max(0, cfg.spamThreshold or 0),
    rounding = true,
    callback = function(value) cfg.spamThreshold = value end,
})

ParryRight:create_slider("distance_multiplier", {
    title = "Distance Multiplier",
    minimum = 1,
    maximum = 300,
    default = math.round(math.max(cfg.distanceMultiplier or 1.0, 0.8) * 100),
    rounding = true,
    callback = function(value) cfg.distanceMultiplier = math.max(value / 100, 0.8) end,
})


local __unlockAllInit = false
local __unlockAllEnable = nil

local
function CreateSpamUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SpamUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.fromOffset(200, 66)
    Main.Position = UDim2.new(0.5, -100, 0.5, -33)
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = gui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.5

    local Gradient = Instance.new("UIGradient", Main)
    Gradient.Rotation = 90
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(170, 170, 170)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
    })

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = "SPAM"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 20
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = Main

    local RING = 16
    local dragging = false
    local dragStart, startPos

    local function isInRing(input)
        local p = input.Position
        local ax, ay = Main.AbsolutePosition.X, Main.AbsolutePosition.Y
        local w, h = Main.AbsoluteSize.X, Main.AbsoluteSize.Y
        local lx, ly = p.X - ax, p.Y - ay
        return lx < RING or ly < RING or lx > w - RING or ly > h - RING
    end

    Button.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if isInRing(input) then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = false
    end)

    Button.MouseButton1Click:Connect(function()
        manualSpamEnabled = not manualSpamEnabled
        if manualSpamEnabled then
            Button.Text = "OFF"
            Button.TextColor3 = Color3.fromRGB(255, 90, 90)
            Stroke.Color = Color3.fromRGB(255, 90, 90)
            
            manualSpamLoop = task.spawn(function()
                while manualSpamEnabled do
                    if type(getgenv().CSKR_SendParry) == "function" then
                        local success = getgenv().CSKR_SendParry()
                        if not success then
                            print("[Manual Spam] CSKR_SendParry thất bại, kiểm tra đã capture packet chưa")
                        end
                    else
                        print("[Manual Spam] CSKR_SendParry chưa sẵn sàng, hãy parry 1 lần để capture")
                        break
                    end
                    task.wait(1 / manualSpamRate)
                end
            end)
        else
            Button.Text = "SPAM"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Stroke.Color = Color3.fromRGB(255, 255, 255)
            if manualSpamLoop then
                task.cancel(manualSpamLoop)
                manualSpamLoop = nil
            end
        end
    end)

    return gui
end

local spamUI = CreateSpamUI()
spamUI.Enabled = false

ParryRight:create_toggle("manual_spam", {
    title = "Manual Spam",
    default = false,
    callback = function(value)
        if value then
            if type(getgenv().CSKR_SendParry) ~= "function" then
                print("[Manual Spam] Hãy parry 1 lần để capture packet!")
                return
            end
            spamUI.Enabled = true
        else
            spamUI.Enabled = false
            if manualSpamEnabled then
                manualSpamEnabled = false
                if manualSpamLoop then
                    task.cancel(manualSpamLoop)
                    manualSpamLoop = nil
                end
                for _, btn in ipairs(spamUI:GetDescendants()) do
                    if btn:IsA("TextButton") and btn.Text == "OFF" then
                        btn.Text = "SPAM"
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        local parent = btn.Parent
                        if parent then
                            local stroke = parent:FindFirstChild("UIStroke")
                            if stroke then
                                stroke.Color = Color3.fromRGB(255, 255, 255)
                            end
                        end
                        break
                    end
                end
            end
        end
    end,
}# ENRIQUE FREE V55 - Core (33KB)
