--=================================================================--
--  ⚔️  ENRIQUE — UNIFIED v1.0 (One Loadstring)
--  ✅ ANGELI-Style Loading | ✅ FREE/PAID Selection
--  ✅ Key System | ✅ Anime UI | ✅ Anti-Dump
--=================================================================--

if _G.__ENRIQUE_LOADED then return end
_G.__ENRIQUE_LOADED = true

if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local IMG = "16014323157"

local C = {
    bg=Color3.fromRGB(12,10,20), panel=Color3.fromRGB(22,16,36), panel2=Color3.fromRGB(30,22,48),
    accent=Color3.fromRGB(200,70,255), accentHi=Color3.fromRGB(230,110,255), accentDim=Color3.fromRGB(140,50,190),
    stroke=Color3.fromRGB(90,40,140), text=Color3.fromRGB(240,235,255), dim=Color3.fromRGB(160,140,190),
    faint=Color3.fromRGB(110,95,140), danger=Color3.fromRGB(255,70,90), success=Color3.fromRGB(80,255,140),
    muted=Color3.fromRGB(120,100,155), subtext=Color3.fromRGB(140,120,170),
}

local function safeParent(gui)
    pcall(function() if type(gethui)=="function" then gui.Parent=gethui() else gui.Parent=CoreGui end end)
    if not gui.Parent then pcall(function() gui.Parent=LocalPlayer:WaitForChild("PlayerGui",3) end) end
end

local function mk(c,p,ch) local o=Instance.new(c) for k,v in pairs(p or{}) do pcall(function() o[k]=v end) end for _,child in ipairs(ch or{}) do child.Parent=o end return o end
local function tw(i,t,p,s,d) local tw2=TweenService:Create(i,TweenInfo.new(t or 0.2,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p) tw2:Play() return tw2 end
local function Notify(t,x,d) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 3}) end) end

local function createParticles(parent,count)
    for i=1,count do
        local p=mk("Frame",{Size=UDim2.fromOffset(math.random(2,4),math.random(2,4)),Position=UDim2.fromScale(math.random(),math.random()),BackgroundColor3=C.accent,BackgroundTransparency=math.random(4,9)/10,BorderSizePixel=0,Parent=parent})
        Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
    end
    local conn
    local frames={}
    for _,child in ipairs(parent:GetChildren()) do if child:IsA("Frame") then table.insert(frames,{f=child,sx=(math.random()-0.5)*0.002,sy=(math.random()-0.5)*0.002,a=math.random(1,3)/1000}) end end
    conn=RunService.Heartbeat:Connect(function()
        if not parent.Parent then conn:Disconnect() return end
        for _,pt in ipairs(frames) do
            local pos=pt.f.Position
            local nx,ny=pos.X.Scale+pt.sx,pos.Y.Scale+pt.sy
            if nx<0 or nx>1 then pt.sx=-pt.sx end
            if ny<0 or ny>1 then pt.sy=-pt.sy end
            pt.f.Position=UDim2.fromScale(nx,ny)
            local trans=pt.f.BackgroundTransparency+pt.a
            if trans>0.9 then pt.a=-pt.a elseif trans<0.3 then pt.a=-pt.a end
            pt.f.BackgroundTransparency=trans
        end
    end)
end

local function typewriter(label,text,speed)
    task.spawn(function() label.Text="" for i=1,#text do label.Text=string.sub(text,1,i) task.wait(speed or 0.03) end end)
end

-- LOADING SCREEN
local function showLoading(cb)
    local gui=mk("ScreenGui",{Name="ENQ_Load",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=99999})
    safeParent(gui)
    local bg=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(3,3,8),BorderSizePixel=0,Parent=gui})
    mk("UIGradient",{Rotation=160,Parent=bg,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(12,5,20)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(5,3,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(2,2,5))}})
    createParticles(bg,30)
    local ct=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(400,320),BackgroundTransparency=1,Parent=bg})
    local ab=mk("ImageLabel",{Size=UDim2.new(1,0,0,140),Position=UDim2.new(0,0,0,10),BackgroundTransparency=1,Image="rbxassetid://"..IMG,ScaleType=Enum.ScaleType.Crop,ImageTransparency=0.15,Parent=ct})
    Instance.new("UICorner",ab).CornerRadius=UDim.new(0,12)
    mk("UIStroke",{Color=C.accent,Thickness=1,Transparency=0.4,Parent=ab})
    local bOv=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=0.35,BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=ab})
    Instance.new("UICorner",bOv).CornerRadius=UDim.new(0,12)
    local lf=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0,80),Size=UDim2.fromOffset(70,70),BackgroundTransparency=1,Parent=ct})
    local gl=mk("ImageLabel",{Size=UDim2.fromScale(1.5,1.5),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=C.accent,ImageTransparency=0.7,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Parent=lf})
    local lg=mk("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image="rbxassetid://"..IMG,Parent=lf})
    Instance.new("UICorner",lg).CornerRadius=UDim.new(1,0)
    mk("UIStroke",{Color=C.accent,Thickness=2,Transparency=0.3,Parent=lg})
    local ri=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(82,82),BackgroundTransparency=1,Parent=lf})
    Instance.new("UICorner",ri).CornerRadius=UDim.new(0.5,0)
    mk("UIStroke",{Color=C.accent,Thickness=2,Transparency=0.4,Parent=ri})
    local ti=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,130),Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text="",TextColor3=Color3.new(1,1,1),TextSize=24,Font=Enum.Font.GothamBold,TextStrokeTransparency=0.8,Parent=ct})
    local su=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,165),Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text="",TextColor3=C.dim,TextSize=12,Font=Enum.Font.Gotham,Parent=ct})
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,185),Size=UDim2.new(0,90,0,18),BackgroundTransparency=1,BackgroundTransparency=0.15,BorderSizePixel=0,BackgroundColor3=C.accent,Text="v1.0 UNIFIED",TextColor3=Color3.fromRGB(240,200,255),TextSize=10,Font=Enum.Font.GothamBold,Parent=ct}).Parent=ct
    local bBg=mk("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,218),Size=UDim2.fromOffset(280,5),BackgroundColor3=Color3.fromRGB(25,25,35),BorderSizePixel=0,Parent=ct})
    Instance.new("UICorner",bBg).CornerRadius=UDim.new(1,0)
    mk("UIStroke",{Color=C.accent,Thickness=1,Transparency=0.7,Parent=bBg})
    local bF=mk("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=bBg})
    Instance.new("UICorner",bF).CornerRadius=UDim.new(1,0)
    mk("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.accentDim),ColorSequenceKeypoint.new(1,C.accentHi)},Parent=bF})
    local pc=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,228),Size=UDim2.new(0,50,0,14),BackgroundTransparency=1,Text="0%",TextColor3=C.dim,TextSize=11,Font=Enum.Font.GothamBold,Parent=ct})
    task.spawn(function() while gui.Parent do tw(gl,1.2,{ImageTransparency=0.85},Enum.EasingStyle.Sine) task.wait(1.2) tw(gl,1.2,{ImageTransparency=0.55},Enum.EasingStyle.Sine) task.wait(1.2) end end)
    task.spawn(function() while gui.Parent do ri.Rotation=(ri.Rotation+2)%360 task.wait() end end)
    typewriter(ti,"ENRIQUE",0.07)
    task.delay(0.6,function() typewriter(su,"Blade Ball Solution",0.03) end)
    task.spawn(function()
        local steps={{"Initializing core...",15},{"Loading combat...",35},{"Remote scanner...",55},{"Parry engine...",75},{"Bypass patches...",90},{"Ready!",100}}
        for _,step in ipairs(steps) do
            if su and su.Parent then su.Text=step[1] end
            local target=step[2]/100
            local start=tonumber(bF.Size.X.Scale) or 0
            tw(bF,0.7,{Size=UDim2.fromScale(target,1)},Enum.EasingStyle.Quart)
            task.spawn(function() for t=0,1,0.02 do local cur=start+(target-start)*t if pc and pc.Parent then pc.Text=math.floor(cur*100).."%" end task.wait(0.016) end if pc and pc.Parent then pc.Text=target*100.."%" end end)
            task.wait(0.8)
        end
        task.wait(0.3)
        tw(ct,0.3,{Size=UDim2.fromOffset(0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(0.35)
        gui:Destroy()
        if cb then cb() end
    end)
end

-- SELECTION SCREEN
local function showSelection(onFree,onPaid)
    local gui=mk("ScreenGui",{Name="ENQ_Sel",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=99998})
    safeParent(gui)
    local ov=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})
    createParticles(ov,20)
    local bl=mk("BlurEffect",{Size=0,Parent=Lighting})
    local W,H=440,360
    local root=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(0,W-30,0,H-20),BackgroundTransparency=1,Parent=gui})
    mk("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,60,1,60),BackgroundTransparency=1,Image="rbxassetid://5028857084",ImageColor3=Color3.new(0,0,0),ImageTransparency=0.3,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),Parent=root})
    local main=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,0,1,0),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Parent=root})
    Instance.new("UICorner",main).CornerRadius=UDim.new(0,14)
    local ms=mk("UIStroke",{Color=C.accent,Thickness=1.5,Transparency=0.2,Parent=main})
    mk("UIGradient",{Rotation=145,Parent=main,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(22,12,32)),ColorSequenceKeypoint.new(0.5,C.bg),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,5,14))}})
    local bn=mk("ImageLabel",{Size=UDim2.new(1,-20,0,110),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Image="rbxassetid://"..IMG,ScaleType=Enum.ScaleType.Crop,Parent=main})
    Instance.new("UICorner",bn).CornerRadius=UDim.new(0,10)
    mk("UIStroke",{Color=C.accent,Thickness=1,Transparency=0.3,Parent=bn})
    local bO=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=0.3,BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=bn})
    Instance.new("UICorner",bO).CornerRadius=UDim.new(0,10)
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.4),Position=UDim2.new(0.5,0,0.4,0),Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text="⚔️ ENRIQUE",TextColor3=Color3.new(1,1,1),TextSize=26,Font=Enum.Font.GothamBold,TextStrokeTransparency=0.5,Parent=bO})
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,16),Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text="BLADE BALL SOLUTION",TextColor3=C.dim,TextSize=10,Font=Enum.Font.Gotham,Parent=bO})
    local cl=mk("ImageButton",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,128),Size=UDim2.new(0,40,0,40),BackgroundColor3=C.accent,BorderSizePixel=0,Image="rbxassetid://"..IMG,ImageColor3=Color3.new(1,1,1),AutoButtonColor=false,Parent=main})
    Instance.new("UICorner",cl).CornerRadius=UDim.new(1,0)
    mk("UIStroke",{Color=C.accentHi,Thickness=2,Transparency=0.3,Parent=cl})
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,175),Size=UDim2.new(1,-30,0,18),BackgroundTransparency=1,Text="Choose your version",TextColor3=C.dim,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,Parent=main})
    local fb=mk("TextButton",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.35,0,0,205),Size=UDim2.new(0.52,0,0,48),BackgroundColor3=C.panel2,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=main})
    Instance.new("UICorner",fb).CornerRadius=UDim.new(0,10)
    local fs=mk("UIStroke",{Color=C.accent,Thickness=1.5,Transparency=0.3,Parent=fb})
    mk("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,4),BackgroundTransparency=1,Text="⚔️ FREE",TextColor3=Color3.new(1,1,1),TextSize=16,Font=Enum.Font.GothamBold,Parent=fb})
    mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1,Text="36K lines",TextColor3=C.faint,TextSize=10,Font=Enum.Font.Gotham,Parent=fb})
    local pb=mk("TextButton",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.65,0,0,205),Size=UDim2.new(0.52,0,0,48),BackgroundColor3=Color3.fromRGB(40,15,30),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=main})
    Instance.new("UICorner",pb).CornerRadius=UDim.new(0,10)
    local ps=mk("UIStroke",{Color=C.danger,Thickness=1.5,Transparency=0.3,Parent=pb})
    mk("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,4),BackgroundTransparency=1,Text="💎 PAID",TextColor3=Color3.new(1,1,1),TextSize=16,Font=Enum.Font.GothamBold,Parent=pb})
    mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1,Text="70K lines",TextColor3=C.faint,TextSize=10,Font=Enum.Font.Gotham,Parent=pb})
    mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,270),Size=UDim2.new(1,-20,0,14),BackgroundTransparency=1,Text="discord.gg/jEA49UNC",TextColor3=C.accent,TextSize=10,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Center,Parent=main})
    task.spawn(function() while gui.Parent do tw(ms,1.5,{Transparency=0.4},Enum.EasingStyle.Sine) task.wait(1.5) tw(ms,1.5,{Transparency=0.15},Enum.EasingStyle.Sine) task.wait(1.5) end end)
    root.Size=UDim2.new(0,W-30,0,H-20)
    tw(ov,0.3,{BackgroundTransparency=0.5}); tw(bl,0.3,{Size=10})
    tw(root,0.4,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back)
    fb.MouseEnter:Connect(function() tw(fb,0.15,{BackgroundColor3=C.accentDim}); tw(fs,0.15,{Transparency=0.1}) end)
    fb.MouseLeave:Connect(function() tw(fb,0.15,{BackgroundColor3=C.panel2}); tw(fs,0.15,{Transparency=0.3}) end)
    pb.MouseEnter:Connect(function() tw(pb,0.15,{BackgroundColor3=Color3.fromRGB(60,20,45)}); tw(ps,0.15,{Transparency=0.1}) end)
    pb.MouseLeave:Connect(function() tw(pb,0.15,{BackgroundColor3=Color3.fromRGB(40,15,30)}); tw(ps,0.15,{Transparency=0.3}) end)
    local function closeSel(cb) tw(ov,0.2,{BackgroundTransparency=1}); tw(bl,0.25,{Size=0}); tw(root,0.2,{Size=UDim2.new(0,W-30,0,H-20)}); task.delay(0.25,function() gui:Destroy(); if cb then cb() end end) end
    fb.MouseButton1Click:Connect(function() closeSel(onFree) end)
    pb.MouseButton1Click:Connect(function() closeSel(onPaid) end)
end

-- LOADING FUNCTIONS
local REPO = "https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/"

-- FREE: load from GitHub (the 18K line script)
local function launchFree()
    Notify("⚔️ ENRIQUE", "Loading FREE (36K lines)...", 3)
    local ok, err = pcall(function()
        -- The full FREE script is at a separate URL
        loadstring(game:HttpGet(REPO .. "ENRIQUE_FREE_FEATURES.lua", true))()
    end)
    if not ok then warn("[ENRIQUE] " .. tostring(err)) end
end

-- PAID: load from GitHub (the 36K line script)
local function launchPaid()
    Notify("💎 ENRIQUE PAID", "Loading PAID (70K lines)...", 3)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO .. "paid.lua", true))()
    end)
    if not ok then warn("[ENRIQUE] " .. tostring(err)) end
end

-- MAIN
showLoading(function()
    showSelection(
        function() launchFree() end,
        function() launchPaid() end
    )
end)

print("⚔️ ENRIQUE v1.0 — One Loadstring")
print("discord.gg/jEA49UNC")
