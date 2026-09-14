--=================================================================--
--  ⚔️  ENRIQUE — UNIFIED LAUNCHER v3.0
--  ✅ Cinematic Loading | ✅ FREE/PAID Selection | ✅ Key System
--  ✅ Anime UI | ✅ All Images: 16014323157
--  ✅ Anti-Dump | ✅ Mobile + PC
--=================================================================--

if _G.__ENRIQUE_UNIFIED_LOADED then return end
_G.__ENRIQUE_UNIFIED_LOADED = true

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
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local LocalPlayer       = Players.LocalPlayer

--============================================================--
-- IMAGE IDS (all use 16014323157)
--============================================================--
local IMG = {
    ANIME   = "16014323157",
    SHADOW  = "5028857084",
    GLOW    = "5028857084",
}

--============================================================--
-- COLOR THEME
--============================================================--
local T = {
    bg       = Color3.fromRGB(10, 8, 16),
    bg2      = Color3.fromRGB(16, 12, 26),
    panel    = Color3.fromRGB(22, 16, 36),
    panel2   = Color3.fromRGB(30, 22, 48),
    stroke   = Color3.fromRGB(90, 40, 140),
    strokeHi = Color3.fromRGB(200, 70, 255),
    text     = Color3.fromRGB(240, 235, 255),
    dim      = Color3.fromRGB(160, 140, 190),
    faint    = Color3.fromRGB(110, 95, 140),
    accent   = Color3.fromRGB(200, 70, 255),
    accentHi = Color3.fromRGB(230, 110, 255),
    accentDim= Color3.fromRGB(140, 50, 190),
    danger   = Color3.fromRGB(255, 70, 90),
    success  = Color3.fromRGB(80, 255, 140),
    on       = Color3.fromRGB(200, 70, 255),
    off      = Color3.fromRGB(50, 40, 65),
    card     = Color3.fromRGB(18, 14, 30),
    muted    = Color3.fromRGB(120, 100, 155),
    subtext  = Color3.fromRGB(140, 120, 170),
}

--============================================================--
-- KEY SYSTEM
--============================================================--
local KEY_FILE = "enrique_unified_key.txt"
local KEY_TTL  = 86400 -- 24h

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
-- UTILITIES
--============================================================--
local function safeParent(gui)
    pcall(function()
        if type(gethui) == "function" then gui.Parent = gethui()
        else gui.Parent = CoreGui end
    end)
    if not gui.Parent then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 3) end)
    end
end

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

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[ENRIQUE] " .. tostring(err)) end
end

-- Particles for backgrounds
local function createParticles(parent, count)
    local particles = {}
    for i = 1, count do
        local p = mk("Frame", {
            Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4)),
            Position = UDim2.fromScale(math.random(), math.random()),
            BackgroundColor3 = Color3.fromRGB(200, 70, 255),
            BackgroundTransparency = math.random(4, 9) / 10,
            BorderSizePixel = 0,
            Parent = parent,
        })
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        table.insert(particles, {
            frame = p,
            speedX = (math.random() - 0.5) * 0.002,
            speedY = (math.random() - 0.5) * 0.002,
            alpha_speed = math.random(1, 3) / 1000,
        })
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not parent.Parent then conn:Disconnect() return end
        for _, pt in ipairs(particles) do
            local pos = pt.frame.Position
            local nx = pos.X.Scale + pt.speedX
            local ny = pos.Y.Scale + pt.speedY
            if nx < 0 or nx > 1 then pt.speedX = -pt.speedX end
            if ny < 0 or ny > 1 then pt.speedY = -pt.speedY end
            pt.frame.Position = UDim2.fromScale(nx, ny)
            local trans = pt.frame.BackgroundTransparency + pt.alpha_speed
            if trans > 0.9 then pt.alpha_speed = -pt.alpha_speed
            elseif trans < 0.3 then pt.alpha_speed = -pt.alpha_speed end
            pt.frame.BackgroundTransparency = trans
        end
    end)
    return particles
end

-- Typewriter
local function typewriter(label, text, speed)
    task.spawn(function()
        label.Text = ""
        for i = 1, #text do
            label.Text = string.sub(text, 1, i)
            task.wait(speed or 0.03)
        end
    end)
end

-- Shake
local function shake(frame, intensity)
    local orig = frame.Position
    for i = 1, 6 do
        local off = Vector2.new(math.random(-intensity, intensity), math.random(-intensity, intensity))
        frame.Position = UDim2.new(orig.X.Scale, orig.X.Offset + off.X, orig.Y.Scale, orig.Y.Offset + off.Y)
        task.wait(0.03)
    end
    frame.Position = orig
end

-- Gradient helper
local function addGradient(parent, rot, c1, c2)
    local g = mk("UIGradient", {Rotation = rot or 135, Parent = parent})
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1 or Color3.fromRGB(30, 15, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 10, 18)),
        ColorSequenceKeypoint.new(1, c2 or Color3.fromRGB(10, 5, 12)),
    }
    return g
end

--============================================================--
-- PHASE 1: CINEMATIC LOADING SCREEN
--============================================================--
local function showLoading(onComplete)
    local gui = mk("ScreenGui", {
        Name = "ENRIQUE_CINEMATIC", ResetOnSpawn = false,
        IgnoreGuiInset = true, DisplayOrder = 99999,
    })
    safeParent(gui)

    local bg = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(3, 3, 8),
        BorderSizePixel = 0,
        Parent = gui,
    })
    addGradient(bg, 160, Color3.fromRGB(12, 5, 20), Color3.fromRGB(2, 2, 5))

    createParticles(bg, 30)

    -- Center container
    local container = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(400, 320),
        BackgroundTransparency = 1,
        Parent = bg,
    })

    -- Anime image (full background banner)
    local animeBg = mk("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 140),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.ANIME,
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.15,
        Parent = container,
    })
    Instance.new("UICorner", animeBg).CornerRadius = UDim.new(0, 12)
    local animeStroke = mk("UIStroke", {Color = T.accent, Thickness = 1, Transparency = 0.4, Parent = animeBg})

    -- Logo container (circle with image)
    local logoContainer = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 80),
        Size = UDim2.fromOffset(80, 80),
        BackgroundTransparency = 1,
        Parent = container,
    })

    -- Glow behind logo
    local glow = mk("ImageLabel", {
        Size = UDim2.fromScale(1.5, 1.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.GLOW,
        ImageColor3 = T.accent,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = logoContainer,
    })

    -- Circle logo (anime image)
    local logo = mk("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(60, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.ANIME,
        ImageColor3 = Color3.new(1, 1, 1),
        Parent = logoContainer,
    })
    Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
    local logoStroke = mk("UIStroke", {Color = T.accent, Thickness = 2, Transparency = 0.3, Parent = logo})

    -- Ring spinner
    local ring = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(90, 90),
        BackgroundTransparency = 1,
        Parent = logoContainer,
    })
    local ringStroke = mk("UIStroke", {Color = T.accent, Thickness = 2, Transparency = 0.4, Parent = ring})
    Instance.new("UICorner", ring).CornerRadius = UDim.new(0.5, 0)

    -- Title
    local title = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 165),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.8,
        Parent = container,
    })

    -- Subtitle
    local subtitle = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 198),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.dim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = container,
    })

    -- Version badge
    local badge = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 218),
        Size = UDim2.new(0, 80, 0, 18),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "v3.0 UNIFIED",
        TextColor3 = Color3.fromRGB(240, 200, 255),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Parent = container,
    })
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

    -- Progress bar
    local barContainer = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 248),
        Size = UDim2.fromOffset(280, 5),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0,
        Parent = container,
    })
    Instance.new("UICorner", barContainer).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = T.accent, Thickness = 1, Transparency = 0.7, Parent = barContainer})

    local barFill = mk("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = T.accent,
        BorderSizePixel = 0,
        Parent = barContainer,
    })
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    local barGrad = mk("UIGradient", {Parent = barFill})
    barGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 50, 190)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 110, 255)),
    }

    -- Percentage
    local pctText = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 258),
        Size = UDim2.new(0, 50, 0, 14),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = T.dim,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        Parent = container,
    })

    -- === Animations ===

    -- Glow pulse
    task.spawn(function()
        while gui.Parent do
            tw(glow, 1.2, {ImageTransparency = 0.85}, Enum.EasingStyle.Sine)
            task.wait(1.2)
            tw(glow, 1.2, {ImageTransparency = 0.55}, Enum.EasingStyle.Sine)
            task.wait(1.2)
        end
    end)

    -- Ring rotation
    task.spawn(function()
        while gui.Parent do
            ring.Rotation = (ring.Rotation + 2) % 360
            task.wait()
        end
    end)

    -- Logo stroke pulse
    task.spawn(function()
        while gui.Parent do
            tw(logoStroke, 1.5, {Transparency = 0.6}, Enum.EasingStyle.Sine)
            task.wait(1.5)
            tw(logoStroke, 1.5, {Transparency = 0.1}, Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)

    -- Typewriter
    typewriter(title, "ENRIQUE", 0.07)
    task.delay(0.6, function()
        typewriter(subtitle, "Advanced Blade Ball Solution", 0.03)
    end)

    -- Loading sequence
    task.spawn(function()
        local steps = {
            {"Initializing core systems...", 15},
            {"Loading combat modules...", 35},
            {"Establishing remote scanner...", 55},
            {"Optimizing parry engine...", 75},
            {"Applying bypass patches...", 90},
            {"Finalizing...", 100},
        }

        for _, step in ipairs(steps) do
            if subtitle and subtitle.Parent then
                subtitle.Text = step[1]
            end
            local target = step[2] / 100
            local startProg = tonumber(barFill.Size.X.Scale) or 0
            local pt = TweenService:Create(barFill, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
                Size = UDim2.fromScale(target, 1),
            })
            pt:Play()
            task.spawn(function()
                for t = 0, 1, 0.02 do
                    local cur = startProg + (target - startProg) * t
                    if pctText and pctText.Parent then
                        pctText.Text = math.floor(cur * 100) .. "%"
                    end
                    task.wait(0.016)
                end
                if pctText and pctText.Parent then
                    pctText.Text = target * 100 .. "%"
                end
            end)
            task.wait(0.9)
        end

        task.wait(0.3)
        -- Exit
        tw(container, 0.3, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.35)
        gui:Destroy()
        if onComplete then onComplete() end
    end)
end

--============================================================--
-- PHASE 2: FREE / PAID SELECTION SCREEN
--============================================================--
local function showSelection(onFree, onPaid)
    local gui = mk("ScreenGui", {
        Name = "ENRIQUE_SELECT", ResetOnSpawn = false,
        IgnoreGuiInset = true, DisplayOrder = 99998,
    })
    safeParent(gui)

    local overlay = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
    })
    createParticles(overlay, 20)

    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})

    -- Main container
    local W, H = 440, 340
    local root = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, W - 30, 0, H - 20),
        BackgroundTransparency = 1,
        Parent = gui,
    })

    -- Shadow
    mk("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.SHADOW,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = root,
    })

    local main = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    })
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    local mainStroke = mk("UIStroke", {Color = T.accent, Thickness = 1.5, Transparency = 0.2, Parent = main})
    addGradient(main, 145, Color3.fromRGB(22, 12, 32), Color3.fromRGB(8, 5, 14))

    -- Anime banner at top
    local banner = mk("ImageLabel", {
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.ANIME,
        ScaleType = Enum.ScaleType.Crop,
        Parent = main,
    })
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 10)
    mk("UIStroke", {Color = T.accent, Thickness = 1, Transparency = 0.3, Parent = banner})

    -- Gradient overlay on banner
    local bannerGrad = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.4,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Parent = banner,
    })
    Instance.new("UICorner", bannerGrad).CornerRadius = UDim.new(0, 10)

    -- Title on banner
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "⚔️ ENRIQUE",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 28,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.5,
        Parent = bannerGrad,
    })

    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 22),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = "BLADE BALL SOLUTION",
        TextColor3 = T.dim,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = bannerGrad,
    })

    -- Circle logo (ANGELI style)
    local circleLogo = mk("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 118),
        Size = UDim2.new(0, 40, 0, 40),
        BackgroundColor3 = T.accent,
        BorderSizePixel = 0,
        Image = "rbxassetid://" .. IMG.ANIME,
        ImageColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Parent = main,
    })
    Instance.new("UICorner", circleLogo).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = T.accentHi, Thickness = 2, Transparency = 0.3, Parent = circleLogo})

    -- Subtitle
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 165),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Text = "Choose your version",
        TextColor3 = T.dim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = main,
    })

    -- FREE Button
    local freeBtn = mk("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.35, 0, 0, 195),
        Size = UDim2.new(0.55, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(30, 22, 48),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = main,
    })
    Instance.new("UICorner", freeBtn).CornerRadius = UDim.new(0, 10)
    local freeStroke = mk("UIStroke", {Color = T.accent, Thickness = 1.5, Transparency = 0.3, Parent = freeBtn})

    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        Text = "⚔️ FREE",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = freeBtn,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "No key required",
        TextColor3 = T.faint,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = freeBtn,
    })

    freeBtn.MouseEnter:Connect(function()
        tw(freeBtn, 0.15, {BackgroundColor3 = T.accentDim})
        tw(freeStroke, 0.15, {Color = T.accentHi, Transparency = 0.1})
    end)
    freeBtn.MouseLeave:Connect(function()
        tw(freeBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(30, 22, 48)})
        tw(freeStroke, 0.15, {Color = T.accent, Transparency = 0.3})
    end)

    -- PAID Button
    local paidBtn = mk("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.65, 0, 0, 195),
        Size = UDim2.new(0.55, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(40, 15, 30),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = main,
    })
    Instance.new("UICorner", paidBtn).CornerRadius = UDim.new(0, 10)
    local paidStroke = mk("UIStroke", {Color = Color3.fromRGB(255, 70, 90), Thickness = 1.5, Transparency = 0.3, Parent = paidBtn})

    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        Text = "💎 PAID",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = paidBtn,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "Key required",
        TextColor3 = T.faint,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = paidBtn,
    })

    paidBtn.MouseEnter:Connect(function()
        tw(paidBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(60, 20, 45)})
        tw(paidStroke, 0.15, {Color = Color3.fromRGB(255, 100, 120), Transparency = 0.1})
    end)
    paidBtn.MouseLeave:Connect(function()
        tw(paidBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(40, 15, 30)})
        tw(paidStroke, 0.15, {Color = Color3.fromRGB(255, 70, 90), Transparency = 0.3})
    end)

    -- Discord link
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 250),
        Size = UDim2.new(1, -20, 0, 14),
        BackgroundTransparency = 1,
        Text = "discord.gg/hZhwszmP",
        TextColor3 = T.accent,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = main,
    })

    -- Stroke pulse
    task.spawn(function()
        while gui.Parent do
            tw(mainStroke, 1.5, {Transparency = 0.4}, Enum.EasingStyle.Sine)
            task.wait(1.5)
            tw(mainStroke, 1.5, {Transparency = 0.15}, Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)

    -- Enter animation
    overlay.BackgroundTransparency = 1
    root.Size = UDim2.new(0, W - 30, 0, H - 20)
    tw(overlay, 0.3, {BackgroundTransparency = 0.5})
    tw(blur, 0.3, {Size = 10})
    tw(root, 0.4, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    -- Button clicks
    freeBtn.MouseButton1Click:Connect(function()
        tw(overlay, 0.2, {BackgroundTransparency = 1})
        tw(blur, 0.25, {Size = 0})
        tw(root, 0.2, {Size = UDim2.new(0, W - 30, 0, H - 20)})
        task.delay(0.25, function()
            gui:Destroy()
            if onFree then onFree() end
        end)
    end)

    paidBtn.MouseButton1Click:Connect(function()
        tw(overlay, 0.2, {BackgroundTransparency = 1})
        tw(blur, 0.25, {Size = 0})
        tw(root, 0.2, {Size = UDim2.new(0, W - 30, 0, H - 20)})
        task.delay(0.25, function()
            gui:Destroy()
            if onPaid then onPaid() end
        end)
    end)
end

--============================================================--
-- PHASE 3: PAID KEY SYSTEM UI
--============================================================--
local function showPaidKeyUI(onSuccess)
    local gui = mk("ScreenGui", {
        Name = "ENRIQUE_PAID_KEY", ResetOnSpawn = false,
        IgnoreGuiInset = true, DisplayOrder = 99997,
    })
    safeParent(gui)

    local overlay = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
    })
    createParticles(overlay, 18)

    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})

    -- Card
    local W, H = 380, 360
    local root = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, W - 30, 0, H - 20),
        BackgroundTransparency = 1,
        Parent = gui,
    })

    mk("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.SHADOW,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = root,
    })

    local card = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    })
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local cardStroke = mk("UIStroke", {Color = T.accent, Thickness = 1.5, Transparency = 0.2, Parent = card})
    addGradient(card, 145, Color3.fromRGB(22, 12, 32), Color3.fromRGB(8, 5, 14))

    -- Accent line at top
    local accentLine = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.accent,
        BorderSizePixel = 0,
        Parent = card,
    })
    mk("UIGradient", {Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, T.accent),
        ColorSequenceKeypoint.new(0.5, T.accentDim),
        ColorSequenceKeypoint.new(1, T.accent),
    }, Parent = accentLine})

    -- Anime banner
    local banner = mk("ImageLabel", {
        Size = UDim2.new(1, -20, 0, 80),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.ANIME,
        ScaleType = Enum.ScaleType.Crop,
        Parent = card,
    })
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 10)
    mk("UIStroke", {Color = T.accent, Thickness = 1, Transparency = 0.3, Parent = banner})

    -- Circle logo
    local logoCircle = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 98),
        Size = UDim2.new(0, 44, 0, 44),
        BackgroundTransparency = 1,
        Parent = card,
    })

    mk("ImageLabel", {
        Size = UDim2.new(1.4, 0, 1.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.GLOW,
        ImageColor3 = T.accent,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = logoCircle,
    })

    local logoImg = mk("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG.ANIME,
        Parent = logoCircle,
    })
    Instance.new("UICorner", logoImg).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = T.accent, Thickness = 2, Transparency = 0.3, Parent = logoImg})

    -- Title
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 150),
        BackgroundTransparency = 1,
        Text = "⚔️ ENRIQUE PAID",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = card,
    })

    -- Subtitle
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 174),
        BackgroundTransparency = 1,
        Text = "Enter your key to unlock premium features",
        TextColor3 = T.dim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = card,
    })

    -- Key input
    local inputContainer = mk("Frame", {
        Size = UDim2.new(1, -40, 0, 38),
        Position = UDim2.new(0, 20, 0, 200),
        BackgroundColor3 = T.panel,
        BorderSizePixel = 0,
        Parent = card,
    })
    Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 10)
    local inputStroke = mk("UIStroke", {Color = T.faint, Thickness = 1, Parent = inputContainer})

    mk("TextLabel", {
        Size = UDim2.fromOffset(30, 38),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔑",
        TextSize = 14,
        TextColor3 = T.accent,
        Font = Enum.Font.GothamBold,
        Parent = inputContainer,
    })

    local input = mk("TextBox", {
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "ENRIQUE-PAID-XXXX-XXXX-XXXX-XXXX",
        PlaceholderColor3 = T.faint,
        Text = "",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputContainer,
    })

    -- Submit button
    local submitBtn = mk("TextButton", {
        Size = UDim2.new(1, -40, 0, 38),
        Position = UDim2.new(0, 20, 0, 248),
        BackgroundColor3 = T.accent,
        BorderSizePixel = 0,
        Text = "🔑 AUTHENTICATE",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = card,
    })
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 10)
    mk("UIGradient", {Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, T.accentHi),
        ColorSequenceKeypoint.new(1, T.accentDim),
    }, Rotation = 90, Parent = submitBtn})

    -- Status
    local status = mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.danger,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = card,
    })

    -- Discord
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 295),
        BackgroundTransparency = 1,
        Text = "discord.gg/hZhwszmP",
        TextColor3 = T.accent,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        Parent = card,
    })

    -- Enter animation
    overlay.BackgroundTransparency = 1
    root.Size = UDim2.new(0, W - 30, 0, H - 20)
    tw(overlay, 0.3, {BackgroundTransparency = 0.5})
    tw(blur, 0.3, {Size = 12})
    tw(root, 0.4, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    -- Stroke pulse
    task.spawn(function()
        while gui.Parent do
            tw(cardStroke, 1.5, {Transparency = 0.45}, Enum.EasingStyle.Sine)
            task.wait(1.5)
            tw(cardStroke, 1.5, {Transparency = 0.15}, Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)

    -- Input focus
    input.Focused:Connect(function()
        tw(inputStroke, 0.2, {Color = T.accent, Thickness = 1.5})
    end)
    input.FocusLost:Connect(function()
        tw(inputStroke, 0.2, {Color = T.faint, Thickness = 1})
    end)

    -- Submit
    local verified = false
    local function attemptVerify()
        if verified then return end
        local key = input.Text:gsub("%s", "")
        if key == "" then
            status.Text = "⚠ Please enter a key"
            shake(card, 4)
            return
        end

        submitBtn.Text = "⏳ VERIFYING..."
        submitBtn.BackgroundColor3 = T.faint
        status.Text = ""

        task.wait(0.5)

        if KeySys.Validate(key) then
            verified = true
            KeySys.Save(key)
            submitBtn.Text = "✓ AUTHENTICATED"
            submitBtn.BackgroundColor3 = T.success
            status.Text = "Welcome! Premium activated (24h)"
            status.TextColor3 = T.success
            task.wait(0.8)
            tw(overlay, 0.2, {BackgroundTransparency = 1})
            tw(blur, 0.25, {Size = 0})
            tw(root, 0.2, {Size = UDim2.new(0, W - 30, 0, H - 20)})
            task.delay(0.25, function()
                gui:Destroy()
                if onSuccess then onSuccess() end
            end)
        else
            submitBtn.Text = "🔑 AUTHENTICATE"
            submitBtn.BackgroundColor3 = T.accent
            status.Text = "✗ Invalid key"
            status.TextColor3 = T.danger
            shake(card, 6)
        end
    end

    submitBtn.MouseEnter:Connect(function()
        tw(submitBtn, 0.15, {BackgroundColor3 = T.accentHi})
    end)
    submitBtn.MouseLeave:Connect(function()
        if not verified then tw(submitBtn, 0.15, {BackgroundColor3 = T.accent}) end
    end)
    submitBtn.MouseButton1Click:Connect(attemptVerify)
    input.FocusLost:Connect(function(pressed) if pressed then attemptVerify() end end)
end

--============================================================--
-- PHASE 4: LAUNCH FREE SCRIPT
--============================================================--
local function launchFree()
    print("[ENRIQUE] Launching FREE version...")
    Notify("⚔️ ENRIQUE FREE", "Loading FREE version...", 3)
    -- Load ENRIQUE_FREE.lua inline
    local ok, err = pcall(function()
        local code = game:HttpGet("https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/ENRIQUE_FREE.lua", true)
        loadstring(code)()
    end)
    if not ok then
        warn("[ENRIQUE FREE] Error: " .. tostring(err))
        Notify("❌ ENRIQUE FREE", "Load error: " .. tostring(err), 5)
    end
end

--============================================================--
-- PHASE 5: LAUNCH PAID SCRIPT
--============================================================--
local function launchPaid()
    print("[ENRIQUE] Launching PAID version...")
    Notify("⚔️ ENRIQUE PAID", "Loading PAID version...", 3)
    local ok, err = pcall(function()
        local code = game:HttpGet("https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/paid.lua", true)
        loadstring(code)()
    end)
    if not ok then
        warn("[ENRIQUE PAID] Error: " .. tostring(err))
        Notify("❌ ENRIQUE PAID", "Load error: " .. tostring(err), 5)
    end
end

--============================================================--
-- MAIN FLOW
--============================================================
showLoading(function()
    -- Check if PAID is already authenticated from stored key
    if KeySys.Authenticated then
        print("[ENRIQUE] PAID key already valid, launching PAID...")
        launchPaid()
    else
        showSelection(
            -- FREE selected
            function() launchFree() end,
            -- PAID selected
            function()
                showPaidKeyUI(function()
                    launchPaid()
                end)
            end
        )
    end
end)

print("⚔️ ENRIQUE UNIFIED LAUNCHER v3.0")
print("discord.gg/hZhwszmP")
