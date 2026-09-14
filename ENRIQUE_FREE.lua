--=================================================================--
--  ENRIQUE v1.0 — Quick Hub + Script Loader
--  Copy Loadstring | Close | Run Scripts
--=================================================================--

if _G.__ENRIQUE_LOADED then return end
_G.__ENRIQUE_LOADED = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local REPO = "https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/"

local function safeParent(gui)
    pcall(function()
        if type(gethui) == "function" then gui.Parent = gethui()
        else gui.Parent = game:GetService("CoreGui") end
    end)
    if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end) end
end

local function Notify(title, text, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3}) end)
end

-- Create Main UI
local gui = Instance.new("ScreenGui")
gui.Name = "ENQ_Hub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
safeParent(gui)

-- Background overlay
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.Parent = gui

-- Main card
local W, H = 440, 500
local root = Instance.new("Frame")
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0, W, 0, H)
root.BackgroundColor3 = Color3.fromRGB(18, 14, 30)
root.BorderSizePixel = 0
root.Parent = overlay
Instance.new("UICorner", root).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(210, 80, 255)
stroke.Thickness = 2
stroke.Transparency = 0.2
stroke.Parent = root

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
header.BorderSizePixel = 0
header.Parent = root
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ENRIQUE v1.0"
title.TextColor3 = Color3.fromRGB(245, 240, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local versionBadge = Instance.new("TextLabel")
versionBadge.Size = UDim2.new(0, 60, 0, 20)
versionBadge.Position = UDim2.new(1, -70, 0.5, -10)
versionBadge.BackgroundColor3 = Color3.fromRGB(210, 80, 255)
versionBadge.BackgroundTransparency = 0.1
versionBadge.BorderSizePixel = 0
versionBadge.Text = "v1.0"
versionBadge.TextColor3 = Color3.fromRGB(245, 210, 255)
versionBadge.TextSize = 10
versionBadge.Font = Enum.Font.GothamBold
versionBadge.Parent = header
Instance.new("UICorner", versionBadge).CornerRadius = UDim.new(1, 0)

-- Scrollable content
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 55)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(210, 80, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = root

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- Helper to make buttons
local function makeButton(text, desc, color, parent, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 48)
    btn.BackgroundColor3 = color or Color3.fromRGB(28, 22, 48)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order or 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(100, 60, 160)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, 0.5, 0)
    label.Position = UDim2.new(0.05, 0, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 240, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    if desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
        descLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc
        descLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
        descLabel.TextSize = 10
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = btn
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 30, 62)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(28, 22, 48)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
    end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)

    return btn
end

-- Helper to make section header
local function makeSection(text, parent, order)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, 0, 0, 24)
    sec.BackgroundTransparency = 1
    sec.Text = text
    sec.TextColor3 = Color3.fromRGB(210, 80, 255)
    sec.TextSize = 13
    sec.Font = Enum.Font.GothamBold
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.LayoutOrder = order or 0
    sec.Parent = parent
    return sec
end

-- ============ SECTION 1: Loadstring ============
makeSection("LOADSTRING", scroll, 1)

local loadstringText = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/ENRIQUE_FREE.lua", true))()'

makeButton("Copy Loadstring", "Click to copy the ENRIQUE loadstring", Color3.fromRGB(30, 50, 30), scroll, 2, function()
    if setclipboard then
        pcall(setclipboard, loadstringText)
        Notify("Copied!", "Loadstring copied to clipboard", 3)
    else
        Notify("Error", "setclipboard not available on this executor", 3)
    end
end)

makeButton("Copy Discord Link", "discord.gg/jEA49UNC", Color3.fromRGB(30, 40, 60), scroll, 3, function()
    if setclipboard then
        pcall(setclipboard, "https://discord.gg/jEA49UNC")
        Notify("Copied!", "Discord link copied", 3)
    end
end)

-- ============ SECTION 2: Quick Scripts ============
makeSection("QUICK SCRIPTS", scroll, 10)

makeButton("Load ENRIQUE FREE Features", "Full ENRIQUE FREE features (Auto Parry, TB, Spam, etc)", Color3.fromRGB(40, 25, 60), scroll, 11, function()
    Notify("Loading...", "ENRIQUE FREE features", 3)
    pcall(function()
        _G.__ENRIQUE_BYPASS_KEY = true
        local code = game:HttpGet(REPO .. "ENRIQUE_FREE_FEATURES.lua", true)
        if code and #code > 1000 then
            local fn = loadstring(code)
            if fn then fn() end
        else
            Notify("Error", "Download failed", 3)
        end
    end)
end)

makeButton("Load ENRIQUE PAID Features", "Premium features (Key: ENRIQUE-PAID-75J83-5DCGH-NE99M-S9SSF)", Color3.fromRGB(60, 15, 30), scroll, 12, function()
    Notify("Loading...", "ENRIQUE PAID features", 3)
    pcall(function()
        _G.__ENRIQUE_BYPASS_KEY = true
        local code = game:HttpGet(REPO .. "paid.lua", true)
        if code and #code > 1000 then
            local fn = loadstring(code)
            if fn then fn() end
        else
            Notify("Error", "Download failed", 3)
        end
    end)
end)

-- ============ SECTION 3: Utility Scripts ============
makeSection("UTILITY SCRIPTS", scroll, 20)

makeButton("Infinite Yield", "Classic admin commands", Color3.fromRGB(25, 25, 40), scroll, 21, function()
    Notify("Loading", "Infinite Yield...", 3)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
    end)
end)

makeButton("Dex Explorer", "Explore game objects", Color3.fromRGB(25, 25, 40), scroll, 22, function()
    Notify("Loading", "Dex Explorer...", 3)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", true))()
    end)
end)

makeButton("Remote Spy", "View remote events", Color3.fromRGB(25, 25, 40), scroll, 23, function()
    Notify("Loading", "Remote Spy...", 3)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/master/SimpleSpySource.lua", true))()
    end)
end)

makeButton("ESP", "Universal ESP", Color3.fromRGB(25, 25, 40), scroll, 24, function()
    Notify("Loading", "ESP...", 3)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Liam0205/ESP/main/ESP.lua", true))()
    end)
end)

makeButton("Fly Script", "Universal fly", Color3.fromRGB(25, 25, 40), scroll, 25, function()
    Notify("Loading", "Fly...", 3)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Bothhaider62/Scripts/main/Fly.lua", true))()
    end)
end)

makeButton("Speed Hack", "Change walk speed", Color3.fromRGB(25, 25, 40), scroll, 26, function()
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 100 end
    end)
end)

makeButton("Jump Hack", "Change jump power", Color3.fromRGB(25, 25, 40), scroll, 27, function()
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = 200 end
    end)
end)

makeButton("NoClip", "Walk through walls", Color3.fromRGB(25, 25, 40), scroll, 28, function()
    _G.noclip = not _G.noclip
    if _G.noclip then
        _G.noclipConn = game:GetService("RunService").Stepped:Connect(function()
            pcall(function()
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end)
    else
        if _G.noclipConn then _G.noclipConn:Disconnect() end
    end
end)

makeButton("Fullbright", "Max brightness", Color3.fromRGB(25, 25, 40), scroll, 29, function()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end)
end)

makeButton("Anti-AFK", "Never get kicked", Color3.fromRGB(25, 25, 40), scroll, 30, function()
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end)
    Notify("Active", "Anti-AFK enabled", 3)
end)

-- ============ SECTION 4: Actions ============
makeSection("ACTIONS", scroll, 40)

makeButton("Rejoin Server", "Rejoin current server", Color3.fromRGB(30, 25, 40), scroll, 41, function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
end)

makeButton("Server Hop", "Join different server", Color3.fromRGB(30, 25, 40), scroll, 42, function()
    pcall(function()
        local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, sv in ipairs(s.data) do
            if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                break
            end
        end
    end)
end)

makeButton("Close Hub", "Close this UI", Color3.fromRGB(50, 20, 20), scroll, 50, function()
    gui:Destroy()
end)

-- Close with RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        if gui and gui.Parent then gui:Destroy() end
    end
end)

-- Update canvas size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Glow pulse on stroke
task.spawn(function()
    while gui and gui.Parent do
        TweenService:Create(stroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.4}):Play()
        task.wait(1.5)
        if not gui or not gui.Parent then break end
        TweenService:Create(stroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.1}):Play()
        task.wait(1.5)
    end
end)

print("ENRIQUE v1.0 Hub loaded - RightShift to close")
print("discord.gg/jEA49UNC")
