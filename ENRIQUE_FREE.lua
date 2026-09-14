--=================================================================--
--  ⚔️  ENRIQUE — UNIFIED LOADER v2.0
--  ✅ ANGELI-Style Selection | ✅ FREE/PAID Choice
--  ✅ Key System | ✅ Anime UI | ✅ Anti-Dump
--  ✅ Mobile + PC | ✅ Strong Encryption
--=================================================================--

if _G.__ENRIQUE_LOADED then return end
_G.__ENRIQUE_LOADED = true

pcall(function()
if not game:IsLoaded() then game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
end)

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
-- COLOR THEME (ANGELI Style - Purple/Pink - BRIGHT)
--============================================================--
local C = {
    bg        = Color3.fromRGB(18, 14, 30),
    panel     = Color3.fromRGB(28, 22, 48),
    panel2    = Color3.fromRGB(38, 30, 62),
    accent    = Color3.fromRGB(210, 80, 255),
    accentHi  = Color3.fromRGB(240, 130, 255),
    accentDim = Color3.fromRGB(150, 60, 200),
    stroke    = Color3.fromRGB(100, 50, 160),
    text      = Color3.fromRGB(245, 240, 255),
    dim       = Color3.fromRGB(180, 160, 210),
    faint     = Color3.fromRGB(130, 110, 170),
    danger    = Color3.fromRGB(255, 80, 100),
    success   = Color3.fromRGB(80, 255, 150),
    muted     = Color3.fromRGB(140, 120, 175),
    glow      = Color3.fromRGB(180, 100, 255),
}

--============================================================--
-- KEY SYSTEM
--============================================================--
local KEY_FILE = "enrique_key_v2.dat"
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

pcall(function() KeySys.CheckStored() end)

--============================================================--
-- UTILITIES
--============================================================--
local function safeParent(gui)
    local ok = pcall(function()
        if type(gethui) == "function" then gui.Parent = gethui()
        else gui.Parent = CoreGui end
    end)
    if not ok or not gui.Parent then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    end
end

local function mk(c, p, ch)
    local ok, o = pcall(Instance.new, c)
    if not ok or not o then return nil end
    if p then
        for k, v in pairs(p) do pcall(function() o[k] = v end) end
    end
    if ch then
        for _, child in ipairs(ch) do
            if child then pcall(function() child.Parent = o end) end
        end
    end
    return o
end

local function tw(inst, t, props, style, dir)
    if not inst then return nil end
    local ok, tween = pcall(function()
        return TweenService:Create(inst, TweenInfo.new(
            t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out
        ), props)
    end)
    if ok and tween then pcall(function() tween:Play() end); return tween end
    return nil
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
            Size = UDim2.fromOffset(math.random(3, 6), math.random(3, 6)),
            Position = UDim2.fromScale(math.random(), math.random()),
            BackgroundColor3 = C.accent,
            BackgroundTransparency = math.random(3, 7) / 10,
            BorderSizePixel = 0,
            Parent = parent,
        })
        if p then
            Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
            table.insert(particles, {
                frame = p,
                speedX = (math.random() - 0.5) * 0.003,
                speedY = (math.random() - 0.5) * 0.003,
                alpha = math.random(1, 4) / 1000,
            })
        end
    end
    if #particles == 0 then return end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not parent or not parent.Parent then pcall(function() conn:Disconnect() end) return end
        for _, pt in ipairs(particles) do
            if pt.frame and pt.frame.Parent then
                local pos = pt.frame.Position
                local nx = pos.X.Scale + pt.speedX
                local ny = pos.Y.Scale + pt.speedY
                if nx < 0 or nx > 1 then pt.speedX = -pt.speedX end
                if ny < 0 or ny > 1 then pt.speedY = -pt.speedY end
                pt.frame.Position = UDim2.fromScale(math.clamp(nx, 0, 1), math.clamp(ny, 0, 1))
                local trans = pt.frame.BackgroundTransparency + pt.alpha
                if trans > 0.9 then pt.alpha = -math.abs(pt.alpha)
                elseif trans < 0.2 then pt.alpha = math.abs(pt.alpha) end
                pt.frame.BackgroundTransparency = math.clamp(trans, 0.2, 0.9)
            end
        end
    end)
end

local function typewriter(label, text, speed)
    if not label then return end
    task.spawn(function()
        pcall(function()
            label.Text = ""
            for i = 1, #text do
                label.Text = string.sub(text, 1, i)
                task.wait(speed or 0.03)
            end
        end)
    end)
end

local function shake(frame, intensity)
    if not frame then return end
    local orig = frame.Position
    for i = 1, 6 do
        local off = Vector2.new(math.random(-intensity, intensity), math.random(-intensity, intensity))
        pcall(function()
            frame.Position = UDim2.new(orig.X.Scale, orig.X.Offset + off.X, orig.Y.Scale, orig.Y.Offset + off.Y)
        end)
        task.wait(0.03)
    end
    pcall(function() frame.Position = orig end)
end

--============================================================--
-- PHASE 1: ANGELI CINEMATIC LOADING SCREEN
--============================================================--
local function showLoading(callback)
    local gui = mk("ScreenGui", {
        Name = "ENQ_Loader",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 99999,
    })
    if not gui then pcall(function() if callback then callback() end end) return end
    safeParent(gui)

    -- Full screen dark background
    local bg = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(8, 5, 15),
        BorderSizePixel = 0,
        Parent = gui,
    })
    if not bg then gui:Destroy(); if callback then callback() end; return end

    local bgGrad = mk("UIGradient", {Rotation = 160, Parent = bg})
    if bgGrad then
        bgGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 35)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 8, 22)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 3, 12)),
        }
    end

    createParticles(bg, 40)

    -- Container
    local container = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(420, 340),
        BackgroundTransparency = 1,
        Parent = bg,
    })
    if not container then bg:Destroy(); if callback then callback() end; return end

    -- Anime banner (large, visible)
    local animeBg = mk("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 150),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundColor3 = Color3.fromRGB(25, 15, 40),
        BackgroundTransparency = 0.1,
        Image = "rbxassetid://" .. IMG_ANIME,
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.05,
        Parent = container,
    })
    if animeBg then
        Instance.new("UICorner", animeBg).CornerRadius = UDim.new(0, 14)
        mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.3, Parent = animeBg})
    end

    -- Gradient overlay on banner
    if animeBg then
        local bannerOv = mk("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.25,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Parent = animeBg,
        })
        if bannerOv then Instance.new("UICorner", bannerOv).CornerRadius = UDim.new(0, 14) end
    end

    -- Circle logo
    local logoFrame = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 85),
        Size = UDim2.fromOffset(76, 76),
        BackgroundTransparency = 1,
        Parent = container,
    })
    if logoFrame then
        local glow = mk("ImageLabel", {
            Size = UDim2.fromScale(1.6, 1.6),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084",
            ImageColor3 = C.glow,
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276),
            Parent = logoFrame,
        })
        local logo = mk("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = C.panel,
            BackgroundTransparency = 0.3,
            Image = "rbxassetid://" .. IMG_ANIME,
            Parent = logoFrame,
        })
        if logo then
            Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
            mk("UIStroke", {Color = C.accent, Thickness = 3, Transparency = 0.2, Parent = logo})
        end
    end

    -- Ring spinner
    local ring = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(90, 90),
        BackgroundTransparency = 1,
        Parent = logoFrame,
    })
    if ring then
        Instance.new("UICorner", ring).CornerRadius = UDim.new(0.5, 0)
        mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.3, Parent = ring})
    end

    -- Title
    local title = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 140),
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.text,
        TextSize = 26,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.7,
        TextStrokeColor3 = C.accentDim,
        Parent = container,
    })

    local subtitle = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 176),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.dim,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Parent = container,
    })

    local verBadge = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 200),
        Size = UDim2.new(0, 100, 0, 20),
        BackgroundColor3 = C.accent,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "v2.0 UNIFIED",
        TextColor3 = Color3.fromRGB(245, 210, 255),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        Parent = container,
    })
    if verBadge then Instance.new("UICorner", verBadge).CornerRadius = UDim.new(1, 0) end

    -- Progress bar background
    local barBg = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 230),
        Size = UDim2.fromOffset(300, 7),
        BackgroundColor3 = Color3.fromRGB(30, 25, 45),
        BorderSizePixel = 0,
        Parent = container,
    })
    if barBg then
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        mk("UIStroke", {Color = C.accent, Thickness = 1, Transparency = 0.6, Parent = barBg})
    end

    -- Progress bar fill
    local barFill = mk("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = barBg,
    })
    if barFill then
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
        mk("UIGradient", {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, C.accentDim),
            ColorSequenceKeypoint.new(1, C.accentHi),
        }, Rotation = 0, Parent = barFill})
    end

    -- Percentage text
    local pctText = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 242),
        Size = UDim2.new(0, 60, 0, 16),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = C.accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = container,
    })

    -- Status text
    local statusText = mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 262),
        Size = UDim2.new(1, -20, 0, 14),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = C.faint,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = container,
    })

    -- Discord link
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 310),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = "discord.gg/jEA49UNC",
        TextColor3 = C.accent,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = container,
    })

    -- Glow pulse animation
    task.spawn(function()
        pcall(function()
            while gui and gui.Parent do
                tw(glow, 1.5, {ImageTransparency = 0.8}, Enum.EasingStyle.Sine)
                task.wait(1.5)
                if not gui or not gui.Parent then break end
                tw(glow, 1.5, {ImageTransparency = 0.45}, Enum.EasingStyle.Sine)
                task.wait(1.5)
            end
        end)
    end)

    -- Ring rotation
    task.spawn(function()
        pcall(function()
            while gui and gui.Parent do
                ring.Rotation = (ring.Rotation + 2) % 360
                task.wait()
            end
        end)
    end)

    -- Typewriter texts
    typewriter(title, "ENRIQUE", 0.06)
    task.delay(0.5, function() typewriter(subtitle, "Blade Ball Solution", 0.025) end)

    -- Loading progress
    task.spawn(function()
        pcall(function()
            local steps = {
                {"Initializing core...", 15},
                {"Loading combat engine...", 35},
                {"Scanning remotes...", 55},
                {"Building parry engine...", 75},
                {"Applying bypass patches...", 90},
                {"Ready!", 100},
            }
            for _, step in ipairs(steps) do
                if statusText and statusText.Parent then statusText.Text = step[1] end
                local target = step[2] / 100
                local startVal = 0
                pcall(function() startVal = tonumber(barFill.Size.X.Scale) or 0 end)
                tw(barFill, 0.7, {Size = UDim2.fromScale(target, 1)}, Enum.EasingStyle.Quart)
                task.spawn(function()
                    for t = 0, 1, 0.03 do
                        local cur = startVal + (target - startVal) * t
                        if pctText and pctText.Parent then pctText.Text = math.floor(cur * 100) .. "%" end
                        task.wait(0.02)
                    end
                    if pctText and pctText.Parent then pctText.Text = (target * 100) .. "%" end
                end)
                task.wait(0.75)
            end
            task.wait(0.4)
            -- Fade out
            tw(container, 0.35, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.4)
            gui:Destroy()
            if callback then callback() end
        end)
    end)
end

--============================================================--
-- PHASE 2: FREE / PAID SELECTION (ANGELI Style)
--============================================================--
local function showSelection(onFree, onPaid)
    local gui = mk("ScreenGui", {
        Name = "ENQ_Select",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 99998,
    })
    if not gui then pcall(function() if onFree then onFree() end end) return end
    safeParent(gui)

    -- Overlay
    local overlay = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
    })
    if not overlay then gui:Destroy(); if onFree then onFree() end; return end

    createParticles(overlay, 25)

    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})

    -- Main card
    local W, H = 460, 380
    local root = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, W - 40, 0, H - 30),
        BackgroundTransparency = 1,
        Parent = gui,
    })

    -- Shadow
    mk("ImageLabel", {
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

    -- Main frame
    local main = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    })
    if main then
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    end

    local mainStroke = mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.15, Parent = main})

    local bgGrad = mk("UIGradient", {Rotation = 145, Parent = main})
    if bgGrad then
        bgGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 16, 42)),
            ColorSequenceKeypoint.new(0.5, C.bg),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 7, 18)),
        }
    end

    -- Anime banner
    local banner = mk("ImageLabel", {
        Size = UDim2.new(1, -24, 0, 120),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundColor3 = Color3.fromRGB(30, 18, 50),
        BackgroundTransparency = 0.1,
        Image = "rbxassetid://" .. IMG_ANIME,
        ScaleType = Enum.ScaleType.Crop,
        Parent = main,
    })
    if banner then
        Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 12)
        mk("UIStroke", {Color = C.accent, Thickness = 1.5, Transparency = 0.2, Parent = banner})
    end

    -- Banner overlay
    if banner then
        local bannerOv = mk("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.2,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Parent = banner,
        })
        if bannerOv then
            Instance.new("UICorner", bannerOv).CornerRadius = UDim.new(0, 12)
            mk("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.35),
                Position = UDim2.new(0.5, 0, 0.35, 0),
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Text = "⚔️ ENRIQUE",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 28,
                Font = Enum.Font.GothamBold,
                TextStrokeTransparency = 0.4,
                TextStrokeColor3 = C.accent,
                Parent = bannerOv,
            })
            mk("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 18),
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = "BLADE BALL SOLUTION",
                TextColor3 = C.dim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                Parent = bannerOv,
            })
        end
    end

    -- Circle logo
    local circleLogo = mk("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 138),
        Size = UDim2.new(0, 44, 0, 44),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Image = "rbxassetid://" .. IMG_ANIME,
        ImageColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Parent = main,
    })
    if circleLogo then
        Instance.new("UICorner", circleLogo).CornerRadius = UDim.new(1, 0)
        mk("UIStroke", {Color = C.accentHi, Thickness = 2, Transparency = 0.2, Parent = circleLogo})
    end

    -- "Choose your version"
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 192),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Text = "Choose your version",
        TextColor3 = C.dim,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = main,
    })

    -- FREE button
    local freeBtn = mk("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.33, 0, 0, 220),
        Size = UDim2.new(0.48, 0, 0, 52),
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = main,
    })
    if freeBtn then
        Instance.new("UICorner", freeBtn).CornerRadius = UDim.new(0, 12)
        local freeStroke = mk("UIStroke", {Color = C.accent, Thickness = 1.5, Transparency = 0.25, Parent = freeBtn})
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, 4),
            BackgroundTransparency = 1,
            Text = "⚔️ FREE",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = freeBtn,
        })
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = "No key required",
            TextColor3 = C.faint,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            Parent = freeBtn,
        })
        freeBtn.MouseEnter:Connect(function() tw(freeBtn, 0.15, {BackgroundColor3 = C.accentDim}); if freeStroke then tw(freeStroke, 0.15, {Transparency = 0.05}) end end)
        freeBtn.MouseLeave:Connect(function() tw(freeBtn, 0.15, {BackgroundColor3 = C.panel2}); if freeStroke then tw(freeStroke, 0.15, {Transparency = 0.25}) end end)
    end

    -- PAID button
    local paidBtn = mk("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.67, 0, 0, 220),
        Size = UDim2.new(0.48, 0, 0, 52),
        BackgroundColor3 = Color3.fromRGB(45, 18, 35),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = main,
    })
    if paidBtn then
        Instance.new("UICorner", paidBtn).CornerRadius = UDim.new(0, 12)
        local paidStroke = mk("UIStroke", {Color = C.danger, Thickness = 1.5, Transparency = 0.25, Parent = paidBtn})
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, 4),
            BackgroundTransparency = 1,
            Text = "💎 PAID",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = paidBtn,
        })
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = "Key required",
            TextColor3 = C.faint,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            Parent = paidBtn,
        })
        paidBtn.MouseEnter:Connect(function() tw(paidBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(65, 25, 50)}); if paidStroke then tw(paidStroke, 0.15, {Transparency = 0.05}) end end)
        paidBtn.MouseLeave:Connect(function() tw(paidBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(45, 18, 35)}); if paidStroke then tw(paidStroke, 0.15, {Transparency = 0.25}) end end)
    end

    -- Version badge
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 284),
        Size = UDim2.new(0, 110, 0, 18),
        BackgroundColor3 = C.accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "v2.0 ENRIQUE",
        TextColor3 = Color3.fromRGB(245, 210, 255),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Parent = main,
    })

    -- Discord
    mk("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 312),
        Size = UDim2.new(1, -20, 0, 16),
        BackgroundTransparency = 1,
        Text = "discord.gg/jEA49UNC",
        TextColor3 = C.accent,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = main,
    })

    -- Glow pulse
    task.spawn(function()
        pcall(function()
            while gui and gui.Parent do
                if mainStroke then tw(mainStroke, 1.5, {Transparency = 0.4}, Enum.EasingStyle.Sine) end
                task.wait(1.5)
                if not gui or not gui.Parent then break end
                if mainStroke then tw(mainStroke, 1.5, {Transparency = 0.1}, Enum.EasingStyle.Sine) end
                task.wait(1.5)
            end
        end)
    end)

    -- Enter animation
    if root then root.Size = UDim2.new(0, W - 40, 0, H - 30) end
    tw(overlay, 0.35, {BackgroundTransparency = 0.45})
    if blur then tw(blur, 0.35, {Size = 12}) end
    tw(root, 0.45, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    local function closeSelect(cb)
        tw(overlay, 0.2, {BackgroundTransparency = 1})
        if blur then tw(blur, 0.25, {Size = 0}) end
        tw(root, 0.2, {Size = UDim2.new(0, W - 40, 0, H - 30)})
        task.delay(0.25, function()
            gui:Destroy()
            if blur then pcall(function() blur:Destroy() end) end
            if cb then cb() end
        end)
    end

    if freeBtn then freeBtn.MouseButton1Click:Connect(function() closeSelect(onFree) end) end
    if paidBtn then paidBtn.MouseButton1Click:Connect(function() closeSelect(onPaid) end) end
end

--============================================================--
-- PHASE 3: PAID KEY UI (ANGELI Style)
--============================================================--
local function showPaidKeyUI(onSuccess)
    local gui = mk("ScreenGui", {
        Name = "ENQ_PaidKey",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 99997,
    })
    if not gui then pcall(function() if onSuccess then onSuccess() end end) return end
    safeParent(gui)

    local overlay = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
    })
    if not overlay then gui:Destroy(); if onSuccess then onSuccess() end; return end

    createParticles(overlay, 20)
    local blur = mk("BlurEffect", {Size = 0, Parent = Lighting})

    local W, H = 400, 380
    local root = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, W - 40, 0, H - 30),
        BackgroundTransparency = 1,
        Parent = gui,
    })

    mk("ImageLabel", {
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

    local card = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    })
    if card then Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16) end
    local cardStroke = mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.15, Parent = card})

    -- Accent line
    local accentLine = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = card,
    })
    if accentLine then
        mk("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0, C.accent), ColorSequenceKeypoint.new(0.5, C.accentDim), ColorSequenceKeypoint.new(1, C.accent)}, Parent = accentLine})
    end

    -- Banner
    local banner = mk("ImageLabel", {
        Size = UDim2.new(1, -24, 0, 90),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundColor3 = Color3.fromRGB(30, 18, 50),
        BackgroundTransparency = 0.1,
        Image = "rbxassetid://" .. IMG_ANIME,
        ScaleType = Enum.ScaleType.Crop,
        Parent = card,
    })
    if banner then
        Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 12)
        mk("UIStroke", {Color = C.accent, Thickness = 1, Transparency = 0.2, Parent = banner})
    end

    -- Circle logo
    local logoFrame = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 106),
        Size = UDim2.new(0, 44, 0, 44),
        BackgroundTransparency = 1,
        Parent = card,
    })
    if logoFrame then
        mk("ImageLabel", {
            Size = UDim2.fromScale(1.4, 1.4),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://5028857084",
            ImageColor3 = C.accent,
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276),
            Parent = logoFrame,
        })
        local logoImg = mk("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = C.panel,
            BackgroundTransparency = 0.3,
            Image = "rbxassetid://" .. IMG_ANIME,
            Parent = logoFrame,
        })
        if logoImg then
            Instance.new("UICorner", logoImg).CornerRadius = UDim.new(1, 0)
            mk("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.2, Parent = logoImg})
        end
    end

    -- Title
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 156),
        BackgroundTransparency = 1,
        Text = "💎 ENRIQUE PAID",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = card,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 182),
        BackgroundTransparency = 1,
        Text = "Enter your key to unlock premium",
        TextColor3 = C.dim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = card,
    })

    -- Key input
    local inputBg = mk("Frame", {
        Size = UDim2.new(1, -44, 0, 40),
        Position = UDim2.new(0, 22, 0, 212),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        Parent = card,
    })
    if inputBg then Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 10) end
    local inputStroke = mk("UIStroke", {Color = C.faint, Thickness = 1, Parent = inputBg})

    mk("TextLabel", {
        Size = UDim2.fromOffset(34, 40),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔑",
        TextSize = 16,
        TextColor3 = C.accent,
        Font = Enum.Font.GothamBold,
        Parent = inputBg,
    })

    local input = mk("TextBox", {
        Position = UDim2.new(0, 44, 0, 0),
        Size = UDim2.new(1, -54, 1, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "ENRIQUE-PAID-XXXX-XXXX-XXXX-XXXX",
        PlaceholderColor3 = C.faint,
        Text = "",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputBg,
    })

    -- Submit button
    local submitBtn = mk("TextButton", {
        Size = UDim2.new(1, -44, 0, 40),
        Position = UDim2.new(0, 22, 0, 262),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Text = "🔑 AUTHENTICATE",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = card,
    })
    if submitBtn then
        Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 10)
        mk("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0, C.accentHi), ColorSequenceKeypoint.new(1, C.accentDim)}, Rotation = 90, Parent = submitBtn})
    end

    -- Status
    local status = mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 308),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.danger,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = card,
    })

    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 330),
        BackgroundTransparency = 1,
        Text = "discord.gg/jEA49UNC",
        TextColor3 = C.accent,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = card,
    })

    -- Enter animation
    tw(overlay, 0.35, {BackgroundTransparency = 0.45})
    if blur then tw(blur, 0.35, {Size = 14}) end
    tw(root, 0.45, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back)

    -- Glow pulse
    task.spawn(function()
        pcall(function()
            while gui and gui.Parent do
                if cardStroke then tw(cardStroke, 1.5, {Transparency = 0.4}, Enum.EasingStyle.Sine) end
                task.wait(1.5)
                if not gui or not gui.Parent then break end
                if cardStroke then tw(cardStroke, 1.5, {Transparency = 0.1}, Enum.EasingStyle.Sine) end
                task.wait(1.5)
            end
        end)
    end)

    -- Input focus effects
    if input and inputStroke then
        input.Focused:Connect(function() tw(inputStroke, 0.2, {Color = C.accent, Thickness = 1.5}) end)
        input.FocusLost:Connect(function() tw(inputStroke, 0.2, {Color = C.faint, Thickness = 1}) end)
    end

    -- Verify logic
    local verified = false
    local function attemptVerify()
        if verified then return end
        local key = ""
        if input then key = input.Text:gsub("%s", "") end
        if key == "" then
            if status then status.Text = "⚠ Enter a key" end
            if card then shake(card, 4) end
            return
        end
        if submitBtn then submitBtn.Text = "⏳ VERIFYING..."; submitBtn.BackgroundColor3 = C.faint end
        if status then status.Text = "" end
        task.wait(0.5)
        if KeySys.Validate(key) then
            verified = true
            KeySys.Save(key)
            if submitBtn then submitBtn.Text = "✓ VERIFIED"; submitBtn.BackgroundColor3 = C.success end
            if status then status.Text = "Premium activated!"; status.TextColor3 = C.success end
            task.wait(0.8)
            tw(overlay, 0.2, {BackgroundTransparency = 1})
            if blur then tw(blur, 0.25, {Size = 0}) end
            tw(root, 0.2, {Size = UDim2.new(0, W - 40, 0, H - 30)})
            task.delay(0.25, function()
                gui:Destroy()
                if blur then pcall(function() blur:Destroy() end) end
                if onSuccess then onSuccess() end
            end)
        else
            if submitBtn then submitBtn.Text = "🔑 AUTHENTICATE"; submitBtn.BackgroundColor3 = C.accent end
            if status then status.Text = "✗ Invalid key"; status.TextColor3 = C.danger end
            if card then shake(card, 6) end
        end
    end

    if submitBtn then
        submitBtn.MouseEnter:Connect(function() if not verified then tw(submitBtn, 0.15, {BackgroundColor3 = C.accentHi}) end end)
        submitBtn.MouseLeave:Connect(function() if not verified then tw(submitBtn, 0.15, {BackgroundColor3 = C.accent}) end end)
        submitBtn.MouseButton1Click:Connect(attemptVerify)
    end
    if input then
        input.FocusLost:Connect(function(p) if p then attemptVerify() end end)
    end
end

--============================================================--
-- PHASE 4: LOAD SCRIPTS
--============================================================--
local REPO = "https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/"

local function launchFree()
    Notify("⚔️ ENRIQUE", "Loading FREE version...", 3)
    task.spawn(function()
        pcall(function()
            local code = game:HttpGet(REPO .. "ENRIQUE_FREE_FEATURES.lua", true)
            if code and code ~= "" then
                loadstring(code)()
            else
                Notify("❌ Error", "Failed to download FREE script", 5)
            end
        end)
    end)
end

local function launchPaid()
    Notify("💎 ENRIQUE PAID", "Loading PAID version...", 3)
    task.spawn(function()
        pcall(function()
            local code = game:HttpGet(REPO .. "paid.lua", true)
            if code and code ~= "" then
                loadstring(code)()
            else
                Notify("❌ Error", "Failed to download PAID script", 5)
            end
        end)
    end)
end

--============================================================--
-- MAIN FLOW
--============================================================--
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

print("⚔️ ENRIQUE v2.0 — Unified Loader")
print("discord.gg/jEA49UNC")
