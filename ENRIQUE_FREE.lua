--=================================================================--
--  ⚔️  ENRIQUE — UNIFIED LOADER v1.0
--  ✅ ANGELI-Style Selection | ✅ FREE/PAID Choice
--=================================================================--

if _G.__ENRIQUE_LOADED then return end
_G.__ENRIQUE_LOADED = true

pcall(function()
if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local IMG = "16014323157"
local C = {
    bg=Color3.fromRGB(18,14,30), panel=Color3.fromRGB(28,22,48), accent=Color3.fromRGB(210,80,255),
    accentHi=Color3.fromRGB(240,130,255), accentDim=Color3.fromRGB(150,60,200),
    text=Color3.fromRGB(245,240,255), dim=Color3.fromRGB(180,160,210), faint=Color3.fromRGB(130,110,170),
    danger=Color3.fromRGB(255,80,100), success=Color3.fromRGB(80,255,150),
}

local KEY_FILE="enrique_key_v2.dat"
local KeySys={Authenticated=false,Key=nil,ExpiresAt=0}
local VALID_KEYS={["ENRIQUE-PAID-75J83-5DCGH-NE99M-S9SSF"]=true}

function KeySys.Validate(key)
    if not key or #key<10 then return false end
    if VALID_KEYS[key] then return true end
    if key:match("^ENRIQUE%-PAID%-[%w]+%-[%w]+%-[%w]+%-[%w]+$") then return true end
    return false
end

function KeySys.CheckStored()
    local ok,data = pcall(readfile,KEY_FILE)
    if not ok or not data then return false end
    local t,k = data:match("^(%d+):(.+)$")
    if not t or not k then return false end
    t=tonumber(t)
    if not t or os.clock()-t>86400 then pcall(delfile,KEY_FILE); return false end
    if KeySys.Validate(k) then KeySys.Authenticated=true; KeySys.Key=k; KeySys.ExpiresAt=t+86400; return true end
    return false
end

function KeySys.Save(key)
    KeySys.Authenticated=true; KeySys.Key=key; KeySys.ExpiresAt=os.clock()+86400
    pcall(writefile,KEY_FILE,os.clock()..":"..key)
end

pcall(function() KeySys.CheckStored() end)

local function safeParent(gui)
    local ok = pcall(function()
        if type(gethui)=="function" then gui.Parent=gethui() else gui.Parent=CoreGui end
    end)
    if not ok or not gui.Parent then pcall(function() gui.Parent=LocalPlayer:WaitForChild("PlayerGui",5) end) end
end

local function mk(c,p,ch)
    local ok,o = pcall(Instance.new,c)
    if not ok or not o then return nil end
    if p then for k,v in pairs(p) do pcall(function() o[k]=v end) end end
    if ch then for _,child in ipairs(ch) do if child then pcall(function() child.Parent=o end) end end end
    return o
end

local function tw(inst,t,props,style,dir)
    if not inst then return nil end
    local ok,tween = pcall(function()
        return TweenService:Create(inst,TweenInfo.new(t or 0.2,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
    end)
    if ok and tween then pcall(function() tween:Play() end); return tween end
    return nil
end

local function Notify(title,text,dur)
    pcall(function() StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=dur or 3}) end)
end

local function createParticles(parent,count)
    local particles={}
    for i=1,count do
        local p=mk("Frame",{Size=UDim2.fromOffset(math.random(3,6),math.random(3,6)),Position=UDim2.fromScale(math.random(),math.random()),BackgroundColor3=C.accent,BackgroundTransparency=math.random(3,7)/10,BorderSizePixel=0,Parent=parent})
        if p then Instance.new("UICorner",p).CornerRadius=UDim.new(1,0); table.insert(particles,{frame=p,speedX=(math.random()-0.5)*0.003,speedY=(math.random()-0.5)*0.003,alpha=math.random(1,4)/1000}) end
    end
    if #particles==0 then return end
    local conn
    conn=RunService.Heartbeat:Connect(function()
        if not parent or not parent.Parent then pcall(function() conn:Disconnect() end) return end
        for _,pt in ipairs(particles) do
            if pt.frame and pt.frame.Parent then
                local pos=pt.frame.Position; local nx=pos.X.Scale+pt.speedX; local ny=pos.Y.Scale+pt.speedY
                if nx<0 or nx>1 then pt.speedX=-pt.speedX end; if ny<0 or ny>1 then pt.speedY=-pt.speedY end
                pt.frame.Position=UDim2.fromScale(math.clamp(nx,0,1),math.clamp(ny,0,1))
                local trans=pt.frame.BackgroundTransparency+pt.alpha
                if trans>0.9 then pt.alpha=-math.abs(pt.alpha) elseif trans<0.2 then pt.alpha=math.abs(pt.alpha) end
                pt.frame.BackgroundTransparency=math.clamp(trans,0.2,0.9)
            end
        end
    end)
end

local function typewriter(label,text,speed)
    if not label then return end
    task.spawn(function() pcall(function() label.Text="" for i=1,#text do label.Text=string.sub(text,1,i) task.wait(speed or 0.03) end end) end)
end

-- PHASE 1: Loading
local function showLoading(callback)
    local gui=mk("ScreenGui",{Name="ENQ_Loader",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=99999})
    if not gui then pcall(function() if callback then callback() end end) return end
    safeParent(gui)

    local bg=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(8,5,15),BorderSizePixel=0,Parent=gui})
    if not bg then gui:Destroy(); if callback then callback() end; return end

    local bgGrad=mk("UIGradient",{Rotation=160,Parent=bg})
    if bgGrad then bgGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(20,10,35)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(12,8,22)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,3,12))} end
    createParticles(bg,40)

    local container=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(420,340),BackgroundTransparency=1,Parent=bg})
    if not container then bg:Destroy(); if callback then callback() end; return end

    local animeBg=mk("ImageLabel",{Size=UDim2.new(1,0,0,150),Position=UDim2.new(0,0,0,5),BackgroundColor3=Color3.fromRGB(25,15,40),BackgroundTransparency=0.1,Image="rbxassetid://"..IMG,ScaleType=Enum.ScaleType.Crop,ImageTransparency=0.05,Parent=container})
    if animeBg then Instance.new("UICorner",animeBg).CornerRadius=UDim.new(0,14); mk("UIStroke",{Color=C.accent,Thickness=2,Transparency=0.3,Parent=animeBg}) end

    local logoFrame=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0,85),Size=UDim2.fromOffset(76,76),BackgroundTransparency=1,Parent=container})
    if logoFrame then
        mk("ImageLabel",{Size=UDim2.fromScale(1.6,1.6),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=C.accent,ImageTransparency=0.6,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Parent=logoFrame})
        local logo=mk("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,1,0),BackgroundColor3=C.panel,BackgroundTransparency=0.3,Image="rbxassetid://"..IMG,Parent=logoFrame})
        if logo then Instance.new("UICorner",logo).CornerRadius=UDim.new(1,0); mk("UIStroke",{Color=C.accent,Thickness=3,Transparency=0.2,Parent=logo}) end
    end

    local ring=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(90,90),BackgroundTransparency=1,Parent=logoFrame})
    if ring then Instance.new("UICorner",ring).CornerRadius=UDim.new(0.5,0); mk("UIStroke",{Color=C.accent,Thickness=2,Transparency=0.3,Parent=ring}) end

    local title=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,140),Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text="",TextColor3=C.text,TextSize=26,Font=Enum.Font.GothamBold,TextStrokeTransparency=0.7,Parent=container})
    local subtitle=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,176),Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="",TextColor3=C.dim,TextSize=13,Font=Enum.Font.Gotham,Parent=container})
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,200),Size=UDim2.new(0,100,0,20),BackgroundColor3=C.accent,BackgroundTransparency=0.1,BorderSizePixel=0,Text="v1.0 UNIFIED",TextColor3=Color3.fromRGB(245,210,255),TextSize=11,Font=Enum.Font.GothamBold,Parent=container})

    local barBg=mk("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,230),Size=UDim2.fromOffset(300,7),BackgroundColor3=Color3.fromRGB(30,25,45),BorderSizePixel=0,Parent=container})
    if barBg then Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0) end
    local barFill=mk("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=barBg})
    if barFill then Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0) end
    local pctText=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,242),Size=UDim2.new(0,60,0,16),BackgroundTransparency=1,Text="0%",TextColor3=C.accent,TextSize=13,Font=Enum.Font.GothamBold,Parent=container})
    local statusText=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,262),Size=UDim2.new(1,-20,0,14),BackgroundTransparency=1,Text="Initializing...",TextColor3=C.faint,TextSize=11,Font=Enum.Font.Gotham,Parent=container})
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,310),Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text="discord.gg/jEA49UNC",TextColor3=C.accent,TextSize=11,Font=Enum.Font.GothamMedium,Parent=container})

    task.spawn(function() pcall(function() while gui and gui.Parent do tw(ring,0.01,{Rotation=(ring.Rotation+2)%360}); task.wait() end end) end)
    typewriter(title,"ENRIQUE",0.06)
    task.delay(0.5,function() typewriter(subtitle,"Blade Ball Solution",0.025) end)

    task.spawn(function() pcall(function()
        local steps={{"Initializing core...",15},{"Loading combat engine...",35},{"Scanning remotes...",55},{"Building parry engine...",75},{"Applying bypass...",90},{"Ready!",100}}
        for _,step in ipairs(steps) do
            if statusText and statusText.Parent then statusText.Text=step[1] end
            local target=step[2]/100
            tw(barFill,0.7,{Size=UDim2.fromScale(target,1)},Enum.EasingStyle.Quart)
            task.spawn(function() for t=0,1,0.03 do if pctText and pctText.Parent then pctText.Text=math.floor((target*t)*100).."%" end; task.wait(0.02) end end)
            task.wait(0.75)
        end
        if pctText and pctText.Parent then pctText.Text="100%" end
        task.wait(0.4)
        tw(container,0.35,{Size=UDim2.fromOffset(0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(0.4)
        gui:Destroy()
        if callback then callback() end
    end) end)
end

-- PHASE 2: Selection
local function showSelection(onFree,onPaid)
    local gui=mk("ScreenGui",{Name="ENQ_Select",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=99998})
    if not gui then pcall(function() if onFree then onFree() end end) return end
    safeParent(gui)

    local overlay=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})
    if not overlay then gui:Destroy(); if onFree then onFree() end; return end
    createParticles(overlay,25)
    local blur=mk("BlurEffect",{Size=0,Parent=Lighting})

    local W,H=460,380
    local root=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(0,W-40,0,H-30),BackgroundTransparency=1,Parent=gui})

    local main=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,1,0),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Parent=root})
    if main then Instance.new("UICorner",main).CornerRadius=UDim.new(0,16) end
    local mainStroke=mk("UIStroke",{Color=C.accent,Thickness=2,Transparency=0.15,Parent=main})

    local banner=mk("ImageLabel",{Size=UDim2.new(1,-24,0,120),Position=UDim2.new(0,12,0,10),BackgroundColor3=Color3.fromRGB(30,18,50),BackgroundTransparency=0.1,Image="rbxassetid://"..IMG,ScaleType=Enum.ScaleType.Crop,Parent=main})
    if banner then Instance.new("UICorner",banner).CornerRadius=UDim.new(0,12); mk("UIStroke",{Color=C.accent,Thickness=1.5,Transparency=0.2,Parent=banner}) end
    if banner then
        local bOv=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=0.2,BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=banner})
        if bOv then Instance.new("UICorner",bOv).CornerRadius=UDim.new(0,12)
            mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.35),Position=UDim2.new(0.5,0,0.35,0),Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text="ENRIQUE",TextColor3=Color3.new(1,1,1),TextSize=28,Font=Enum.Font.GothamBold,TextStrokeTransparency=0.4,TextStrokeColor3=C.accent,Parent=bOv})
            mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,18),Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text="BLADE BALL SOLUTION",TextColor3=C.dim,TextSize=11,Font=Enum.Font.Gotham,Parent=bOv})
        end
    end

    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,192),Size=UDim2.new(1,-30,0,20),BackgroundTransparency=1,Text="Choose your version",TextColor3=C.dim,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,Parent=main})

    local freeBtn=mk("TextButton",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.33,0,0,220),Size=UDim2.new(0.48,0,0,52),BackgroundColor3=Color3.fromRGB(38,30,62),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=main})
    if freeBtn then
        Instance.new("UICorner",freeBtn).CornerRadius=UDim.new(0,12)
        mk("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,4),BackgroundTransparency=1,Text="FREE",TextColor3=Color3.new(1,1,1),TextSize=18,Font=Enum.Font.GothamBold,Parent=freeBtn})
        mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,Text="No key required",TextColor3=C.faint,TextSize=10,Font=Enum.Font.Gotham,Parent=freeBtn})
    end

    local paidBtn=mk("TextButton",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.67,0,0,220),Size=UDim2.new(0.48,0,0,52),BackgroundColor3=Color3.fromRGB(45,18,35),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=main})
    if paidBtn then
        Instance.new("UICorner",paidBtn).CornerRadius=UDim.new(0,12)
        mk("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,4),BackgroundTransparency=1,Text="PAID",TextColor3=Color3.new(1,1,1),TextSize=18,Font=Enum.Font.GothamBold,Parent=paidBtn})
        mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,Text="Key required",TextColor3=C.faint,TextSize=10,Font=Enum.Font.Gotham,Parent=paidBtn})
    end

    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,312),Size=UDim2.new(1,-20,0,16),BackgroundTransparency=1,Text="discord.gg/jEA49UNC",TextColor3=C.accent,TextSize=12,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Center,Parent=main})

    task.spawn(function() pcall(function() while gui and gui.Parent do if mainStroke then tw(mainStroke,1.5,{Transparency=0.4}) end; task.wait(1.5); if not gui or not gui.Parent then break end; if mainStroke then tw(mainStroke,1.5,{Transparency=0.1}) end; task.wait(1.5) end end) end)

    tw(overlay,0.35,{BackgroundTransparency=0.45})
    if blur then tw(blur,0.35,{Size=12}) end
    tw(root,0.45,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back)

    local function closeSelect(cb)
        tw(overlay,0.2,{BackgroundTransparency=1}); if blur then tw(blur,0.25,{Size=0}) end; tw(root,0.2,{Size=UDim2.new(0,W-40,0,H-30)})
        task.delay(0.25,function() gui:Destroy(); if blur then pcall(function() blur:Destroy() end) end; if cb then cb() end end)
    end

    if freeBtn then freeBtn.MouseButton1Click:Connect(function() closeSelect(onFree) end) end
    if paidBtn then paidBtn.MouseButton1Click:Connect(function() closeSelect(onPaid) end) end
end

-- PHASE 3: PAID Key UI
local function showPaidKeyUI(onSuccess)
    local gui=mk("ScreenGui",{Name="ENQ_PaidKey",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=99997})
    if not gui then pcall(function() if onSuccess then onSuccess() end end) return end
    safeParent(gui)

    local overlay=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})
    if not overlay then gui:Destroy(); if onSuccess then onSuccess() end; return end
    createParticles(overlay,20)
    local blur=mk("BlurEffect",{Size=0,Parent=Lighting})

    local W,H=400,380
    local root=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(0,W-40,0,H-30),BackgroundTransparency=1,Parent=gui})

    local card=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,1,0),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Parent=root})
    if card then Instance.new("UICorner",card).CornerRadius=UDim.new(0,16) end
    local cardStroke=mk("UIStroke",{Color=C.accent,Thickness=2,Transparency=0.15,Parent=card})

    local banner=mk("ImageLabel",{Size=UDim2.new(1,-24,0,90),Position=UDim2.new(0,12,0,10),BackgroundColor3=Color3.fromRGB(30,18,50),BackgroundTransparency=0.1,Image="rbxassetid://"..IMG,ScaleType=Enum.ScaleType.Crop,Parent=card})
    if banner then Instance.new("UICorner",banner).CornerRadius=UDim.new(0,12); mk("UIStroke",{Color=C.accent,Thickness=1,Transparency=0.2,Parent=banner}) end

    mk("TextLabel",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,156),BackgroundTransparency=1,Text="ENRIQUE PAID",TextColor3=Color3.new(1,1,1),TextSize=20,Font=Enum.Font.GothamBold,Parent=card})
    mk("TextLabel",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,182),BackgroundTransparency=1,Text="Enter your key to unlock premium",TextColor3=C.dim,TextSize=12,Font=Enum.Font.Gotham,Parent=card})

    local inputBg=mk("Frame",{Size=UDim2.new(1,-44,0,40),Position=UDim2.new(0,22,0,212),BackgroundColor3=C.panel,BorderSizePixel=0,Parent=card})
    if inputBg then Instance.new("UICorner",inputBg).CornerRadius=UDim.new(0,10) end
    local inputStroke=mk("UIStroke",{Color=C.faint,Thickness=1,Parent=inputBg})
    local input=mk("TextBox",{Position=UDim2.new(0,44,0,0),Size=UDim2.new(1,-54,1,0),BackgroundTransparency=1,PlaceholderText="ENRIQUE-PAID-XXXX-XXXX-XXXX-XXXX",PlaceholderColor3=C.faint,Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=inputBg})

    local submitBtn=mk("TextButton",{Size=UDim2.new(1,-44,0,40),Position=UDim2.new(0,22,0,262),BackgroundColor3=C.accent,BorderSizePixel=0,Text="AUTHENTICATE",TextColor3=Color3.new(1,1,1),TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false,Parent=card})
    if submitBtn then Instance.new("UICorner",submitBtn).CornerRadius=UDim.new(0,10) end

    local status=mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,308),BackgroundTransparency=1,Text="",TextColor3=C.danger,TextSize=10,Font=Enum.Font.Gotham,Parent=card})
    mk("TextLabel",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,330),BackgroundTransparency=1,Text="discord.gg/jEA49UNC",TextColor3=C.accent,TextSize=11,Font=Enum.Font.GothamMedium,Parent=card})

    tw(overlay,0.35,{BackgroundTransparency=0.45})
    if blur then tw(blur,0.35,{Size=14}) end
    tw(root,0.45,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back)

    task.spawn(function() pcall(function() while gui and gui.Parent do if cardStroke then tw(cardStroke,1.5,{Transparency=0.4}) end; task.wait(1.5); if not gui or not gui.Parent then break end; if cardStroke then tw(cardStroke,1.5,{Transparency=0.1}) end; task.wait(1.5) end end) end)

    local verified=false
    local function attemptVerify()
        if verified then return end
        local key=input and input.Text:gsub("%s","") or ""
        if key=="" then if status then status.Text="Enter a key" end; return end
        if submitBtn then submitBtn.Text="VERIFYING..."; submitBtn.BackgroundColor3=C.faint end
        task.wait(0.5)
        if KeySys.Validate(key) then
            verified=true; KeySys.Save(key)
            if submitBtn then submitBtn.Text="VERIFIED"; submitBtn.BackgroundColor3=C.success end
            if status then status.Text="Premium activated!"; status.TextColor3=C.success end
            task.wait(0.8); tw(overlay,0.2,{BackgroundTransparency=1}); if blur then tw(blur,0.25,{Size=0}) end
            tw(root,0.2,{Size=UDim2.new(0,W-40,0,H-30)})
            task.delay(0.25,function() gui:Destroy(); if blur then pcall(function() blur:Destroy() end) end; if onSuccess then onSuccess() end end)
        else
            if submitBtn then submitBtn.Text="AUTHENTICATE"; submitBtn.BackgroundColor3=C.accent end
            if status then status.Text="Invalid key"; status.TextColor3=C.danger end
        end
    end

    if submitBtn then submitBtn.MouseButton1Click:Connect(attemptVerify) end
    if input then input.FocusLost:Connect(function(p) if p then attemptVerify() end end) end
end

-- PHASE 4: Load Scripts
local REPO="https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/"

local function launchFree()
    Notify("ENRIQUE","Loading FREE version...",3)
    task.spawn(function()
        local ok,err=pcall(function()
            _G.__ENRIQUE_BYPASS_KEY=true
            print("[ENRIQUE] Downloading FREE features...")
            local code=game:HttpGet(REPO.."ENRIQUE_FREE_FEATURES.lua",true)
            print("[ENRIQUE] Downloaded: "..#code.." bytes")
            if code and code~="" and #code>1000 then
                print("[ENRIQUE] Compiling...")
                local fn,err2=loadstring(code)
                if fn then
                    print("[ENRIQUE] Running...")
                    local ok2,err3=pcall(fn)
                    if not ok2 then
                        print("[ENRIQUE] RUNTIME ERROR: "..tostring(err3))
                        Notify("FREE Error",tostring(err3),10)
                        -- Show error on screen
                        pcall(function()
                            local sg=Instance.new("ScreenGui"); sg.Name="ENQ_Error"; sg.Parent=gethui and gethui() or game:GetService("CoreGui")
                            local f=Instance.new("Frame"); f.Size=UDim2.new(0,500,0,200); f.Position=UDim2.new(0.5,-250,0.5,-100); f.BackgroundColor3=Color3.fromRGB(20,10,10); f.BorderSizePixel=0; f.Parent=sg; Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
                            local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-20,1,-10); t.Position=UDim2.new(0,10,0,5); t.BackgroundTransparency=1; t.Text="FREE ERROR:\n"..tostring(err3); t.TextColor3=Color3.fromRGB(255,100,100); t.TextSize=12; t.Font=Enum.Font.Code; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Top; t.TextWrapped=true; t.Parent=f
                        end)
                    end
                else
                    print("[ENRIQUE] COMPILE ERROR: "..tostring(err2))
                    Notify("FREE Error","Compile: "..tostring(err2),10)
                    pcall(function()
                        local sg=Instance.new("ScreenGui"); sg.Name="ENQ_Error"; sg.Parent=gethui and gethui() or game:GetService("CoreGui")
                        local f=Instance.new("Frame"); f.Size=UDim2.new(0,500,0,200); f.Position=UDim2.new(0.5,-250,0.5,-100); f.BackgroundColor3=Color3.fromRGB(20,10,10); f.BorderSizePixel=0; f.Parent=sg; Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
                        local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-20,1,-10); t.Position=UDim2.new(0,10,0,5); t.BackgroundTransparency=1; t.Text="FREE COMPILE ERROR:\n"..tostring(err2); t.TextColor3=Color3.fromRGB(255,100,100); t.TextSize=12; t.Font=Enum.Font.Code; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Top; t.TextWrapped=true; t.Parent=f
                    end)
                end
            else
                print("[ENRIQUE] Download failed or too small: "..(code and #code or 0).." bytes")
                Notify("Error","Download failed",5)
            end
        end)
        if not ok then
            print("[ENRIQUE] HTTP ERROR: "..tostring(err))
            Notify("HTTP Error",tostring(err),10)
        end
    end)
end

local function launchPaid()
    Notify("ENRIQUE PAID","Loading PAID version...",3)
    task.spawn(function()
        local ok,err=pcall(function()
            _G.__ENRIQUE_BYPASS_KEY=true
            print("[ENRIQUE] Downloading PAID features...")
            local code=game:HttpGet(REPO.."paid.lua",true)
            print("[ENRIQUE] Downloaded: "..#code.." bytes")
            if code and code~="" and #code>1000 then
                local fn,err2=loadstring(code)
                if fn then
                    local ok2,err3=pcall(fn)
                    if not ok2 then
                        print("[ENRIQUE] PAID RUNTIME ERROR: "..tostring(err3))
                        Notify("PAID Error",tostring(err3),10)
                        pcall(function()
                            local sg=Instance.new("ScreenGui"); sg.Name="ENQ_Error2"; sg.Parent=gethui and gethui() or game:GetService("CoreGui")
                            local f=Instance.new("Frame"); f.Size=UDim2.new(0,500,0,200); f.Position=UDim2.new(0.5,-250,0.5,-100); f.BackgroundColor3=Color3.fromRGB(20,10,10); f.BorderSizePixel=0; f.Parent=sg; Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
                            local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-20,1,-10); t.Position=UDim2.new(0,10,0,5); t.BackgroundTransparency=1; t.Text="PAID ERROR:\n"..tostring(err3); t.TextColor3=Color3.fromRGB(255,100,100); t.TextSize=12; t.Font=Enum.Font.Code; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Top; t.TextWrapped=true; t.Parent=f
                        end)
                    end
                else
                    print("[ENRIQUE] PAID COMPILE ERROR: "..tostring(err2))
                    Notify("PAID Error","Compile: "..tostring(err2),10)
                    pcall(function()
                        local sg=Instance.new("ScreenGui"); sg.Name="ENQ_Error2"; sg.Parent=gethui and gethui() or game:GetService("CoreGui")
                        local f=Instance.new("Frame"); f.Size=UDim2.new(0,500,0,200); f.Position=UDim2.new(0.5,-250,0.5,-100); f.BackgroundColor3=Color3.fromRGB(20,10,10); f.BorderSizePixel=0; f.Parent=sg; Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
                        local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-20,1,-10); t.Position=UDim2.new(0,10,0,5); t.BackgroundTransparency=1; t.Text="PAID COMPILE ERROR:\n"..tostring(err2); t.TextColor3=Color3.fromRGB(255,100,100); t.TextSize=12; t.Font=Enum.Font.Code; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Top; t.TextWrapped=true; t.Parent=f
                    end)
                end
            else
                print("[ENRIQUE] PAID Download failed: "..(code and #code or 0).." bytes")
                Notify("Error","Download failed",5)
            end
        end)
        if not ok then print("[ENRIQUE] PAID HTTP ERROR: "..tostring(err)); Notify("HTTP Error",tostring(err),10) end
    end)
end

-- MAIN
showLoading(function()
    if KeySys.Authenticated then
        launchPaid()
    else
        showSelection(
            function() launchFree() end,
            function()
                if KeySys.Authenticated then launchPaid()
                else showPaidKeyUI(function() launchPaid() end) end
            end
        )
    end
end)

print("ENRIQUE v1.0 - Loaded")
print("discord.gg/jEA49UNC")
