--=================================================================--
--  ⚔️  ENRIQUE — UNIFIED LOADER v1.0
--  ✅ ANGELI-Style Selection | ✅ FREE/PAID Choice
--  ✅ Key System | ✅ Anime UI | ✅ Anti-Dump
--  ✅ Mobile + PC
--=================================================================--

if _G.__ENRIQUE_LOADED then return end
_G.__ENRIQUE_LOADED = true

if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

--============================================================--
-- SERVICES
--============================================================--
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local LocalPlayer       = Players.LocalPlayer

--============================================================--
-- IMAGE ID
--============================================================--
local IMG_ANIME = "16014323157"

--============================================================--
-- COLOR THEME (ANGELI Style - Purple/Pink)
--============================================================--
local C = {
    bg        = Color3.fromRGB(12, 10, 20),
    panel     = Color3.fromRGB(22, 16, 36),
    panel2    = Color3.fromRGB(30, 22, 48),
    accent    = Color3.fromRGB(200, 70, 255),
    accentHi  = Color3.fromRGB(230, 110, 255),
    accentDim = Color3.fromRGB(140, 50, 190),
    stroke    = Color3.fromRGB(90, 40, 140),
    text      = Color3.fromRGB(240, 235, 255),
    dim       = Color3.fromRGB(160, 140, 190),
    faint     = Color3.fromRGB(110, 95, 140),
    danger    = Color3.fromRGB(255, 70, 90),
    success   = Color3.fromRGB(80, 255, 140),
    muted     = Color3.fromRGB(120, 100, 155),
}

--============================================================--
-- KEY SYSTEM
--============================================================--
local KEY_FILE = "enrique_key.dat"
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

local function mk(c, p, ch)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do pcall(function() o[k] = v end) end
    for _, child in ipairs(ch or {}) do child.Parent = o end
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

local function createParticles(parent, count)
    local particles = {}
    for i = 1, count do
        local p = mk("Frame", {
            Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4)),
            Position = UDim2.fromScale(math.random(), math.random()),
            BackgroundColor3 = C.accent,
            BackgroundTransparency = math.random(4, 9) / 10,
            BorderSizePixel = 0,
            Parent = parent,
        })
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        table.insert(particles, {
            frame = p,
            speedX = (math.random() - 0.5) * 0.002,
            speedY = (math.random() - 0.5) * 0.002,
            alpha = math.random(1, 3) / 1000,
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
            local trans = pt.frame.BackgroundTransparency + pt.alpha
            if trans > 0.9 then pt.alpha = -pt.alpha
            elseif trans < 0.3 then pt.alpha = -pt.alpha end
            pt.frame.BackgroundTransparency = trans
        end
    end)
end

local function typewriter(label, text, speed)
    task.spawn(function()
        label.Text = ""
        for i = 1, #text do
            label.Text = string.sub(text, 1, i)
            task.wait(speed or 0.03)
        end
    end)
end

local function shake(frame, intensity)
    local orig = frame.Position
    for i = 1, 6 do
        local off = Vector2.new(math.random(-intensity, intensity), math.random(-intensity, intensity))
        frame.Position = UDim2.new(orig.X.Scale, orig.X.Offset + off.X, orig.Y.Scale, orig.Y.Offset + off.Y)
        task.wait(0.03)
    end
    frame.Position = orig
end

--============================================================--
-- PHASE 1: ANGELI CINEMATIC LOADING SCREEN
--============================================================--
local function showLoading(callback)
    local gui = mk("ScreenGui", {Name = "ENQ_Loader", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 99999})
    safeParent(gui)

    local bg = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(3, 3, 8), BorderSizePixel = 0, Parent = gui})
    local bgGrad = mk("UIGradient", {Rotation = 160, Parent = bg})
    bgGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 5, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 3, 10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 2, 5)),
    }

    createParticles(bg, 30)

    local container = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(400, 320), BackgroundTransparency = 1, Parent = bg,
    })

    -- Anime banner
    local animeBg = mk("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 140), Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1, Image = "rbxassetid://" .. IMG_ANIME,
        ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.15, Parent = container,
    })
    Instance.new("UICorner", animeBg).CornerRadius = UDim.new(0, 12)
    mk("UIStroke", {Color = C.accent, Thickness = 1, Transparency = 0.4, Parent = animeBg})

    -- Gradient overlay on banner
    local bannerOv = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.35,
        BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = animeBg,
    })
    Instance.new("UICorner", bannerOv).CornerRadius = UDim.new(0, 12)

    -- Circle logo
    local logoFrame = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 80),
        Size = UDim2.fromOffset(70, 70), BackgroundTransparency = 1, Parent = container,
    })

    local glow = mk("ImageLabel", {
        Size = UDim2.fromScale(1.5, 1.5), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084", ImageColor3 = C.accent,
        ImageTransparency = 0.7, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276), Parent = logoFrame,
    })

    local logo = mk("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Image = "rbxassetid://" .. IMG_ANIME, Parent = logoFrame,
    })
    Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.3, Parent = logo})

    -- Ring spinner
    local ring = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(82, 82), BackgroundTransparency = 1, Parent = logoFrame,
    })
    Instance.new("UICorner", ring).CornerRadius = UDim.new(0.5, 0)
    mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.4, Parent = ring})

    -- Title
    local title = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 130),
        Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "",
        TextColor3 = Color3.new(1, 1, 1), TextSize = 24, Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.8, Parent = container,
    })

    local subtitle = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 165),
        Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "",
        TextColor3 = C.dim, TextSize = 12, Font = Enum.Font.Gotham, Parent = container,
    })

    local verBadge = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 185),
        Size = UDim2.new(0, 90, 0, 18), BackgroundColor3 = C.accent,
        BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Text = "v1.0 UNIFIED", TextColor3 = Color3.fromRGB(240, 200, 255),
        TextSize = 10, Font = Enum.Font.GothamBold, Parent = container,
    })
    Instance.new("UICorner", verBadge).CornerRadius = UDim.new(1, 0)

    -- Progress bar
    local barBg = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 218),
        Size = UDim2.fromOffset(280, 5), BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0, Parent = container,
    })
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = C.accent, Thickness = 1, Transparency = 0.7, Parent = barBg})

    local barFill = mk("Frame", {
        Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent,
        BorderSizePixel = 0, Parent = barBg,
    })
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    mk("UIGradient", {Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.accentDim),
        ColorSequenceKeypoint.new(1, C.accentHi),
    }, Parent = barFill})

    local pctText = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 228),
        Size = UDim2.new(0, 50, 0, 14), BackgroundTransparency = 1, Text = "0%",
        TextColor3 = C.dim, TextSize = 11, Font = Enum.Font.GothamBold, Parent = container,
    })

    -- Animations
    task.spawn(function()
        while gui.Parent do
            tw(glow, 1.2, {ImageTransparency = 0.85}, Enum.EasingStyle.Sine)
            task.wait(1.2)
            tw(glow, 1.2, {ImageTransparency = 0.55}, Enum.EasingStyle.Sine)
            task.wait(1.2)
        end
    end)
    task.spawn(function()
        while gui.Parent do
            ring.Rotation = (ring.Rotation + 2) % 360
            task.wait()
        end
    end)

    typewriter(title, "ENRIQUE", 0.07)
    task.delay(0.6, function() typewriter(subtitle, "Blade Ball Solution", 0.03) end)

    -- Loading
    task.spawn(function()
        local steps = {
            {"Initializing core...", 15}, {"Loading combat...", 35},
            {"Remote scanner...", 55}, {"Parry engine...", 75},
            {"Bypass patches...", 90}, {"Ready!", 100},
        }
        for _, step in ipairs(steps) do
            if subtitle and subtitle.Parent then subtitle.Text = step[1] end
            local target = step[2] / 100
            local start = tonumber(barFill.Size.X.Scale) or 0
            tw(barFill, 0.7, {Size = UDim2.fromScale(target, 1)}, Enum.EasingStyle.Quart)
            task.spawn(function()
                for t = 0, 1, 0.02 do
                    local cur = start + (target - start) * t
                    if pctText and pctText.Parent then pctText.Text = math.floor(cur * 100) .. "%" end
                    task.wait(0.016)
                end
                if pctText and pctText.Parent then pctText.Text = target * 100 .. "%" end
            end)
            task.wait(0.8)
        end
        task.wait(0.3)
        tw(container, 0.3, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.35)
        gui:Destroy()
        if callback then callback() end
    end)
end

--============================================================--
-- PHASE 2: FREE / PAID SELECTION (ANGELI Style)
--============================================================--
local function showSelection(onFree, onPaid)
    local gui = mk("ScreenGui", {Name = "ENQ_Select", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 99998})
    safeParent(gui)

    local overlay = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = gui})
    createParticles(overlay, 20)
    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})

    local W, H = 440, 360
    local root = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, W - 30, 0, H - 20), BackgroundTransparency = 1, Parent = gui})

    mk("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 60, 1, 60), BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.3, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Parent = root})

    local main = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = root})
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    local mainStroke = mk("UIStroke", {Color = C.accent, Thickness = 1.5, Transparency = 0.2, Parent = main})

    local bgGrad = mk("UIGradient", {Rotation = 145, Parent = main})
    bgGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 12, 32)),
        ColorSequenceKeypoint.new(0.5, C.bg),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 5, 14)),
    }

    -- Anime banner
    local banner = mk("ImageLabel", {
        Size = UDim2.new(1, -20, 0, 110), Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1, Image = "rbxassetid://" .. IMG_ANIME,
        ScaleType = Enum.ScaleType.Crop, Parent = main,
    })
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 10)
    mk("UIStroke", {Color = C.accent, Thickness = 1, Transparency = 0.3, Parent = banner})

    local bannerOv = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.3, BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = banner})
    Instance.new("UICorner", bannerOv).CornerRadius = UDim.new(0, 10)

    mk("TextLabel", {AnchorPoint = Vector2.new(0.5, 0.4), Position = UDim2.new(0.5, 0, 0.4, 0), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "⚔️ ENRIQUE", TextColor3 = Color3.new(1, 1, 1), TextSize = 26, Font = Enum.Font.GothamBold, TextStrokeTransparency = 0.5, Parent = bannerOv})
    mk("TextLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 16), Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "BLADE BALL SOLUTION", TextColor3 = C.dim, TextSize = 10, Font = Enum.Font.Gotham, Parent = bannerOv})

    -- Circle logo (ANGELI style)
    local circleLogo = mk("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 128),
        Size = UDim2.new(0, 40, 0, 40), BackgroundColor3 = C.accent,
        BorderSizePixel = 0, Image = "rbxassetid://" .. IMG_ANIME,
        ImageColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Parent = main,
    })
    Instance.new("UICorner", circleLogo).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = C.accentHi, Thickness = 2, Transparency = 0.3, Parent = circleLogo})

    mk("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 175), Size = UDim2.new(1, -30, 0, 18), BackgroundTransparency = 1, Text = "Choose your version", TextColor3 = C.dim, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Center, Parent = main})

    -- FREE button
    local freeBtn = mk("TextButton", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.35, 0, 0, 205), Size = UDim2.new(0.52, 0, 0, 48), BackgroundColor3 = C.panel2, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = main})
    Instance.new("UICorner", freeBtn).CornerRadius = UDim.new(0, 10)
    local freeStroke = mk("UIStroke", {Color = C.accent, Thickness = 1.5, Transparency = 0.3, Parent = freeBtn})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 4), BackgroundTransparency = 1, Text = "⚔️ FREE", TextColor3 = Color3.new(1, 1, 1), TextSize = 16, Font = Enum.Font.GothamBold, Parent = freeBtn})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1, Text = "No key required", TextColor3 = C.faint, TextSize = 10, Font = Enum.Font.Gotham, Parent = freeBtn})

    freeBtn.MouseEnter:Connect(function() tw(freeBtn, 0.15, {BackgroundColor3 = C.accentDim}); tw(freeStroke, 0.15, {Transparency = 0.1}) end)
    freeBtn.MouseLeave:Connect(function() tw(freeBtn, 0.15, {BackgroundColor3 = C.panel2}); tw(freeStroke, 0.15, {Transparency = 0.3}) end)

    -- PAID button
    local paidBtn = mk("TextButton", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.65, 0, 0, 205), Size = UDim2.new(0.52, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(40, 15, 30), BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = main})
    Instance.new("UICorner", paidBtn).CornerRadius = UDim.new(0, 10)
    local paidStroke = mk("UIStroke", {Color = C.danger, Thickness = 1.5, Transparency = 0.3, Parent = paidBtn})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 4), BackgroundTransparency = 1, Text = "💎 PAID", TextColor3 = Color3.new(1, 1, 1), TextSize = 16, Font = Enum.Font.GothamBold, Parent = paidBtn})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1, Text = "Key required", TextColor3 = C.faint, TextSize = 10, Font = Enum.Font.Gotham, Parent = paidBtn})

    paidBtn.MouseEnter:Connect(function() tw(paidBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(60, 20, 45)}); tw(paidStroke, 0.15, {Transparency = 0.1}) end)
    paidBtn.MouseLeave:Connect(function() tw(paidBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(40, 15, 30)}); tw(paidStroke, 0.15, {Transparency = 0.3}) end)

    -- Discord
    mk("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 270), Size = UDim2.new(1, -20, 0, 14), BackgroundTransparency = 1, Text = "discord.gg/jEA49UNC", TextColor3 = C.accent, TextSize = 10, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Center, Parent = main})

    -- Glow pulse
    task.spawn(function()
        while gui.Parent do
            tw(mainStroke, 1.5, {Transparency = 0.4}, Enum.EasingStyle.Sine)
            task.wait(1.5)
            tw(mainStroke, 1.5, {Transparency = 0.15}, Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)

    -- Enter animation
    root.Size = UDim2.new(0, W - 30, 0, H - 20)
    tw(overlay, 0.3, {BackgroundTransparency = 0.5})
    tw(blur, 0.3, {Size = 10})
    tw(root, 0.4, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    local function closeSelect(cb)
        tw(overlay, 0.2, {BackgroundTransparency = 1})
        tw(blur, 0.25, {Size = 0})
        tw(root, 0.2, {Size = UDim2.new(0, W - 30, 0, H - 20)})
        task.delay(0.25, function() gui:Destroy(); if cb then cb() end end)
    end

    freeBtn.MouseButton1Click:Connect(function() closeSelect(onFree) end)
    paidBtn.MouseButton1Click:Connect(function() closeSelect(onPaid) end)
end

--============================================================--
-- PHASE 3: PAID KEY UI (ANGELI Style)
--============================================================--
local function showPaidKeyUI(onSuccess)
    local gui = mk("ScreenGui", {Name = "ENQ_PaidKey", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 99997})
    safeParent(gui)

    local overlay = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = gui})
    createParticles(overlay, 18)
    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})

    local W, H = 380, 350
    local root = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, W - 30, 0, H - 20), BackgroundTransparency = 1, Parent = gui})
    mk("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 60, 1, 60), BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.3, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Parent = root})

    local card = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = root})
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local cardStroke = mk("UIStroke", {Color = C.accent, Thickness = 1.5, Transparency = 0.2, Parent = card})

    local accentLine = mk("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = C.accent, BorderSizePixel = 0, Parent = card})
    mk("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0, C.accent), ColorSequenceKeypoint.new(0.5, C.accentDim), ColorSequenceKeypoint.new(1, C.accent)}, Parent = accentLine})

    -- Banner
    local banner = mk("ImageLabel", {Size = UDim2.new(1, -20, 0, 80), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Image = "rbxassetid://" .. IMG_ANIME, ScaleType = Enum.ScaleType.Crop, Parent = card})
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 10)
    mk("UIStroke", {Color = C.accent, Thickness = 1, Transparency = 0.3, Parent = banner})

    -- Circle logo
    local logoFrame = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 96), Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 1, Parent = card})
    mk("ImageLabel", {Size = UDim2.fromScale(1.4, 1.4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageColor3 = C.accent, ImageTransparency = 0.7, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Parent = logoFrame})
    local logoImg = mk("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = "rbxassetid://" .. IMG_ANIME, Parent = logoFrame})
    Instance.new("UICorner", logoImg).CornerRadius = UDim.new(1, 0)
    mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.3, Parent = logoImg})

    -- Title
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 142), BackgroundTransparency = 1, Text = "💎 ENRIQUE PAID", TextColor3 = Color3.new(1, 1, 1), TextSize = 18, Font = Enum.Font.GothamBold, Parent = card})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 166), BackgroundTransparency = 1, Text = "Enter your key to unlock premium", TextColor3 = C.dim, TextSize = 11, Font = Enum.Font.Gotham, Parent = card})

    -- Key input
    local inputBg = mk("Frame", {Size = UDim2.new(1, -40, 0, 38), Position = UDim2.new(0, 20, 0, 192), BackgroundColor3 = C.panel, BorderSizePixel = 0, Parent = card})
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 10)
    local inputStroke = mk("UIStroke", {Color = C.faint, Thickness = 1, Parent = inputBg})
    mk("TextLabel", {Size = UDim2.fromOffset(30, 38), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "🔑", TextSize = 14, TextColor3 = C.accent, Font = Enum.Font.GothamBold, Parent = inputBg})
    local input = mk("TextBox", {Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, PlaceholderText = "ENRIQUE-PAID-XXXX-XXXX-XXXX-XXXX", PlaceholderColor3 = C.faint, Text = "", TextColor3 = Color3.new(1, 1, 1), TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = inputBg})

    -- Submit
    local submitBtn = mk("TextButton", {Size = UDim2.new(1, -40, 0, 38), Position = UDim2.new(0, 20, 0, 240), BackgroundColor3 = C.accent, BorderSizePixel = 0, Text = "🔑 AUTHENTICATE", TextColor3 = Color3.new(1, 1, 1), TextSize = 13, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = card})
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 10)
    mk("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0, C.accentHi), ColorSequenceKeypoint.new(1, C.accentDim)}, Rotation = 90, Parent = submitBtn})

    local status = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -20), BackgroundTransparency = 1, Text = "", TextColor3 = C.danger, TextSize = 10, Font = Enum.Font.Gotham, Parent = card})
    mk("TextLabel", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 286), BackgroundTransparency = 1, Text = "discord.gg/jEA49UNC", TextColor3 = C.accent, TextSize = 10, Font = Enum.Font.GothamMedium, Parent = card})

    -- Enter anim
    overlay.BackgroundTransparency = 1
    root.Size = UDim2.new(0, W - 30, 0, H - 20)
    tw(overlay, 0.3, {BackgroundTransparency = 0.5})
    tw(blur, 0.3, {Size = 12})
    tw(root, 0.4, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    task.spawn(function()
        while gui.Parent do
            tw(cardStroke, 1.5, {Transparency = 0.45}, Enum.EasingStyle.Sine)
            task.wait(1.5)
            tw(cardStroke, 1.5, {Transparency = 0.15}, Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)

    input.Focused:Connect(function() tw(inputStroke, 0.2, {Color = C.accent, Thickness = 1.5}) end)
    input.FocusLost:Connect(function() tw(inputStroke, 0.2, {Color = C.faint, Thickness = 1}) end)

    local verified = false
    local function attemptVerify()
        if verified then return end
        local key = input.Text:gsub("%s", "")
        if key == "" then status.Text = "⚠ Enter a key"; shake(card, 4); return end
        submitBtn.Text = "⏳ VERIFYING..."; submitBtn.BackgroundColor3 = C.faint; status.Text = ""
        task.wait(0.5)
        if KeySys.Validate(key) then
            verified = true
            KeySys.Save(key)
            submitBtn.Text = "✓ VERIFIED"; submitBtn.BackgroundColor3 = C.success
            status.Text = "Premium activated!"; status.TextColor3 = C.success
            task.wait(0.8)
            tw(overlay, 0.2, {BackgroundTransparency = 1}); tw(blur, 0.25, {Size = 0})
            tw(root, 0.2, {Size = UDim2.new(0, W - 30, 0, H - 20)})
            task.delay(0.25, function() gui:Destroy(); if onSuccess then onSuccess() end end)
        else
            submitBtn.Text = "🔑 AUTHENTICATE"; submitBtn.BackgroundColor3 = C.accent
            status.Text = "✗ Invalid key"; status.TextColor3 = C.danger; shake(card, 6)
        end
    end

    submitBtn.MouseEnter:Connect(function() if not verified then tw(submitBtn, 0.15, {BackgroundColor3 = C.accentHi}) end end)
    submitBtn.MouseLeave:Connect(function() if not verified then tw(submitBtn, 0.15, {BackgroundColor3 = C.accent}) end end)
    submitBtn.MouseButton1Click:Connect(attemptVerify)
    input.FocusLost:Connect(function(p) if p then attemptVerify() end end)
end

--============================================================--
-- PHASE 4: LOAD SCRIPTS
--============================================================--
local REPO = "https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/"

local function launchFree()
    Notify("⚔️ ENRIQUE", "Loading FREE...", 3)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO .. "ENRIQUE_FREE_FEATURES.lua", true))()
    end)
    if not ok then warn("[ENRIQUE] FREE load error: " .. tostring(err)) end
end

local function launchPaid()
    Notify("💎 ENRIQUE PAID", "Loading PAID...", 3)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(REPO .. "paid.lua", true))()
    end)
    if not ok then warn("[ENRIQUE] PAID load error: " .. tostring(err)) end
end

--============================================================--
-- MAIN FLOW
--============================================================
showLoading(function()
    if KeySys.Authenticated then
        launchPaid()
    else
        showSelection(
            function() launchFree() end,
            function()
                if KeySys.Authenticated then
                    launchPaid()
                else
                    showPaidKeyUI(function() launchPaid() end)
                end
            end
        )
    end
end)

print("⚔️ ENRIQUE v1.0 — Unified Loader")
print("discord.gg/jEA49UNC")
