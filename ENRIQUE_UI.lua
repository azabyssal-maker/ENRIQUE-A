-- ENRIQUE FREE UI Library
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local run = game:GetService("RunService")

local Library = {}
Library.__index = Library
Library._current = nil

local ANIME_BG = "rbxassetid://15452092090"
local ACCENT = Color3.fromRGB(255, 105, 180)      -- hot pink
local ACCENT2 = Color3.fromRGB(147, 112, 219)     -- purple
local BG = Color3.fromRGB(18, 18, 22)
local PANEL = Color3.fromRGB(24, 24, 30)
local TEXT = Color3.fromRGB(235, 235, 245)
local DIM = Color3.fromRGB(140, 140, 155)

local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function round(inst, r)
    new("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = inst})
end

local function stroke(inst, color, t, tr)
    new("UIStroke", {Color = color or ACCENT, Thickness = t or 1, Transparency = tr or 0.6, Parent = inst})
end

local function shadow(inst)
    new("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 3, Transparency = 0.8, Parent = inst})
end

local colors = {}
local hue = 0
task.spawn(function()
    while true do
        hue = (hue + 0.004) % 1
        task.wait(0.05)
    end
end)

-- Animation
local function anim(inst, prop, goal, time, style)
    TweenService:Create(inst, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = goal}):Play()
end

-- ========== LIBRARY ==========
function Library._new(title)
    local self = setmetatable({}, Library)
    self._tabs = {}
    self._tab_btns = {}
    self._tab_contents = {}
    self._active = nil
    self._drag_pos = nil
    self._dragging = false
    self._min = false

    -- Main GUI
    self.gui = new("ScreenGui", {
        Name = "ENRIQUE_FREE",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (gethui and gethui()) or CoreGui,
    })
    if syn and syn.protect_gui then pcall(syn.protect_gui, self.gui) end

    -- Window
    self.window = new("Frame", {
        Size = UDim2.new(0, 620, 0, 420),
        Position = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = BG,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Parent = self.gui,
    })
    round(self.window, 14)
    stroke(self.window, ACCENT, 1.5, 0.2)
    shadow(self.window)

    -- Anime background
    self.bg = new("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = ANIME_BG,
        ImageTransparency = 0.88,
        ScaleType = Enum.ScaleType.Stretch,
        Parent = self.window,
    })
    new("UICorner", {CornerRadius = UDim.new(0, 14), Parent = self.bg})

    -- Rainbow border on background
    local bgStroke = new("UIStroke", {Thickness = 1, Transparency = 0.5, Parent = self.bg})
    task.spawn(function()
        while bgStroke and bgStroke.Parent do
            bgStroke.Color = Color3.fromHSV(hue, 0.7, 1)
            task.wait(0.08)
        end
    end)

    -- Topbar
    self.topbar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = self.window,
    })
    round(self.topbar, 14)
    new("UICorner", {CornerRadius = UDim.new(0, 14), Parent = self.topbar})

    local title = new("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "  ⬛  " .. (title or "ENRIQUE FREE"),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.topbar,
    })
    self._title = title

    -- Sub (compatible with kittylua's create_category)
    self._cats = {}
    function self:create_category(name)
        local cat = {name = name, _tabs = {}}
        self._cats[#self._cats + 1] = cat
        function cat:create_tab(tabName, iconAsset)
            local tab = {name = tabName, _groups = {}}
            cat._tabs[#cat._tabs + 1] = tab
            function tab:create_group(groupName, side)
                local g = {name = groupName, side = side or "left", _items = {}}
                tab._groups[#tab._groups + 1] = g
                function g:create_toggle(flag, data)
                    data.value = data.default or false
                    local item = {type = "toggle", flag = flag, data = data}
                    g._items[#g._items + 1] = item
                    return item
                end
                function g:create_slider(flag, data)
                    data.value = data.default or data.minimum or 0
                    local item = {type = "slider", flag = flag, data = data}
                    g._items[#g._items + 1] = item
                    return item
                end
                function g:create_dropdown(flag, data)
                    data.value = data.default or data.options[1]
                    local item = {type = "dropdown", flag = flag, data = data}
                    g._items[#g._items + 1] = item
                    return item
                end
                function g:create_button(data)
                    local item = {type = "button", data = data}
                    g._items[#g._items + 1] = item
                    return item
                end
                return g
            end
            return tab
        end
        return cat
    end

    self._render = function()
        -- Build sidebar
        local sidebar = new("ScrollingFrame", {
            Size = UDim2.new(0, 140, 1, -48),
            Position = UDim2.new(0, 0, 0, 44),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, math.max(self:count_tabs() * 38, 100)),
            Parent = self.window,
        })

        local y = 4
        for ci, cat in ipairs(self._cats) do
            -- Category header
            local catLabel = new("TextLabel", {
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 6, 0, y),
                BackgroundTransparency = 1,
                Text = "  " .. cat.name:upper(),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = ACCENT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sidebar,
            })
            y = y + 22
            for _, tab in ipairs(cat._tabs) do
                local btn = new("TextButton", {
                    Size = UDim2.new(1, -10, 0, 30),
                    Position = UDim2.new(0, 6, 0, y),
                    BackgroundColor3 = PANEL,
                    BackgroundTransparency = 0.4,
                    Text = "  " .. tab.name,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = TEXT,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = sidebar,
                })
                round(btn, 7)
                stroke(btn, Color3.fromRGB(40, 40, 50), 1, 0.3)
                self._tab_btns[tab] = {btn = btn, label = btn}

                btn.MouseButton1Click:Connect(function()
                    self:set_tab(tab)
                end)
                y = y + 36
            end
        end

        -- Toggle button (square block, anime)
        local toggleBtn = new("TextButton", {
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = ACCENT,
            BackgroundTransparency = 0.15,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = self.gui,
        })
        round(toggleBtn, 6)
        stroke(toggleBtn, Color3.fromHSV(hue, 0.8, 1), 2, 0)
        local toggIcon = new("ImageLabel", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0.5, -14, 0.5, -14),
            BackgroundTransparency = 1,
            Image = ANIME_BG,
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = toggleBtn,
        })
        round(toggIcon, 5)

        viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        toggleBtn.Position = UDim2.new(0, 10, 1, -50)
        toggleBtn.MouseButton1Click:Connect(function()
            self._min = not self._min
            if self._min then
                self.window.Visible = false
                toggleBtn.Visible = true
            else
                self.window.Visible = true
                toggleBtn.Visible = false
            end
        end)
        toggleBtn.Visible = false

        -- Content area
        self._content = new("Frame", {
            Size = UDim2.new(0, 480, 1, -48),
            Position = UDim2.new(0, 140, 0, 44),
            BackgroundTransparency = 1,
            Parent = self.window,
        })
    end

    self:count_tabs = function()
        local n = 0
        for _, cat in ipairs(self._cats) do
            for _ in ipairs(cat._tabs) do n = n + 1 end
        end
        return n
    end

    function self:set_tab(tab)
        if self._active then
            for _, v in ipairs(self._tab_btns) do
                -- reset styling handled below
            end
        end
        -- Reset all buttons
        for t, v in pairs(self._tab_btns) do
            v.btn.BackgroundColor3 = PANEL
            v.btn.BackgroundTransparency = 0.4
            v.label.TextColor3 = TEXT
            stroke(v.btn, Color3.fromRGB(40, 40, 50), 1, 0.3)
        end
        -- Highlight active
        local tabdata = self._tab_btns[tab]
        if tabdata then
            tabdata.btn.BackgroundColor3 = ACCENT
            tabdata.btn.BackgroundTransparency = 0.2
            tabdata.label.TextColor3 = Color3.new(1, 1, 1)
            stroke(tabdata.btn, ACCENT2, 1, 0.1)
        end
        self._active = tab
        -- Render content
        if self._content then
            self._content:ClearAllChildren()
        end
        self:render_groups(tab)
    end

    self.render_groups = function(_, tab)
        local c = self._content
        if not c then return end
        -- Tabs for groups
        local leftY = 6
        local rightY = 6
        local leftW = 230
        local rightW = 230
        for _, g in ipairs(tab._groups) do
            local w = g.side == "right" and rightW or leftW
            local x = g.side == "right" and (240 + 6) or 4
            local y = g.side == "right" and rightY or leftY
            local header = new("TextLabel", {
                Size = UDim2.new(0, w, 0, 22),
                Position = UDim2.new(0, x, 0, y),
                BackgroundTransparency = 1,
                Text = g.name,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = TEXT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = c,
            })
            y = y + 26
            for _, item in ipairs(g._items) do
                if item.type == "toggle" then
                    local itemFrame = new("Frame", {
                        Size = UDim2.new(0, w, 0, 28),
                        Position = UDim2.new(0, x, 0, y),
                        BackgroundColor3 = PANEL,
                        BackgroundTransparency = 0.5,
                        Parent = c,
                    })
                    round(itemFrame, 6)
                    local label = new("TextLabel", {
                        Size = UDim2.new(1, -38, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = item.data.title or item.flag,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = TEXT,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = itemFrame,
                    })
                    local box = new("Frame", {
                        Size = UDim2.new(0, 26, 0, 16),
                        Position = UDim2.new(1, -36, 0.5, -8),
                        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                        Parent = itemFrame,
                    })
                    round(box, 8)
                    local knob = new("Frame", {
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new(0, 2, 0.5, -6),
                        BackgroundColor3 = Color3.fromRGB(160, 160, 170),
                        Parent = box,
                    })
                    round(knob, 6)
                    local update = function()
                        item.data.value = not item.data.value
                        if item.data.value then
                            box.BackgroundColor3 = ACCENT
                            knob.Position = UDim2.new(0, 12, 0.5, -6)
                            knob.BackgroundColor3 = Color3.new(1, 1, 1)
                        else
                            box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                            knob.Position = UDim2.new(0, 2, 0.5, -6)
                            knob.BackgroundColor3 = Color3.fromRGB(160, 160, 170)
                        end
                        if item.data.callback then item.data.callback(item.data.value) end
                    end
                    local btn = new("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = itemFrame,
                    })
                    btn.MouseButton1Click:Connect(update)
                    item._update = update
                    item._frame = itemFrame
                    item._box = box
                    item._knob = knob
                elseif item.type == "slider" then
                    local itemFrame = new("Frame", {
                        Size = UDim2.new(0, w, 0, 40),
                        Position = UDim2.new(0, x, 0, y),
                        BackgroundColor3 = PANEL,
                        BackgroundTransparency = 0.5,
                        Parent = c,
                    })
                    round(itemFrame, 6)
                    local label = new("TextLabel", {
                        Size = UDim2.new(1, -10, 0, 14),
                        Position = UDim2.new(0, 8, 0, 3),
                        BackgroundTransparency = 1,
                        Text = item.data.title,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = TEXT,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = itemFrame,
                    })
                    local val = new("TextLabel", {
                        Size = UDim2.new(0, 40, 0, 14),
                        Position = UDim2.new(1, -48, 0, 3),
                        BackgroundTransparency = 1,
                        Text = tostring(item.data.value),
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = ACCENT,
                        Parent = itemFrame,
                    })
                    local bar = new("Frame", {
                        Size = UDim2.new(1, -16, 0, 4),
                        Position = UDim2.new(0, 8, 1, -10),
                        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                        Parent = itemFrame,
                    })
                    round(bar, 2)
                    local fill = new("Frame", {
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundColor3 = ACCENT,
                        Parent = bar,
                    })
                    round(fill, 2)
                    local knobSlider = new("Frame", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 0, 0.5, -5),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Parent = bar,
                    })
                    round(knobSlider, 5)
                    item._value = val
                    item._fill = fill
                    item._knob = knobSlider
                    local dragging = false
                    local function setFromX(x)
                        local rel = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                        rel = math.clamp(rel, 0, 1)
                        local min = item.data.minimum
                        local max = item.data.maximum
                        local v = min + (max - min) * rel
                        if item.data.rounding then v = math.round(v) end
                        item.data.value = v
                        val.Text = tostring(v)
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        knobSlider.Position = UDim2.new(rel, -5, 0.5, -5)
                        if item.data.callback then item.data.callback(v) end
                    end
                    bar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            setFromX(input.Position.X)
                        end
                    end)
                    UIS.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            setFromX(input.Position.X)
                        end
                    end)
                    UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)
                elseif item.type == "dropdown" then
                    local itemFrame = new("Frame", {
                        Size = UDim2.new(0, w, 0, 32),
                        Position = UDim2.new(0, x, 0, y),
                        BackgroundColor3 = PANEL,
                        BackgroundTransparency = 0.5,
                        Parent = c,
                    })
                    round(itemFrame, 6)
                    local btn = new("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = item.data.title .. "  ▾  " .. tostring(item.data.value),
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = TEXT,
                        Parent = itemFrame,
                    })
                    local open = false
                    local list = nil
                    btn.MouseButton1Click:Connect(function()
                        open = not open
                        if open then
                            list = new("Frame", {
                                Size = UDim2.new(0, w, 0, math.min(#item.data.options * 22, 132)),
                                Position = UDim2.new(0, 0, 1, 2),
                                BackgroundColor3 = Color3.fromRGB(30, 30, 38),
                                BorderSizePixel = 0,
                                ZIndex = 5,
                                Parent = itemFrame,
                            })
                            round(list, 6)
                            stroke(list, ACCENT, 1, 0.2)
                            local ly = 0
                            for _, opt in ipairs(item.data.options) do
                                local optBtn = new("TextButton", {
                                    Size = UDim2.new(1, 0, 0, 22),
                                    Position = UDim2.new(0, 0, 0, ly),
                                    BackgroundTransparency = 1,
                                    Text = tostring(opt),
                                    Font = Enum.Font.Gotham,
                                    TextSize = 11,
                                    TextColor3 = opt == item.data.value and ACCENT or TEXT,
                                    Parent = list,
                                })
                                optBtn.MouseButton1Click:Connect(function()
                                    item.data.value = opt
                                    btn.Text = item.data.title .. "  ▾  " .. tostring(opt)
                                    if item.data.callback then item.data.callback(opt) end
                                    if list then list:Destroy() list = nil end
                                    open = false
                                end)
                                ly = ly + 22
                            end
                        else
                            if list then list:Destroy() list = nil end
                        end
                    end)
                elseif item.type == "button" then
                    local itemFrame = new("Frame", {
                        Size = UDim2.new(0, w, 0, 30),
                        Position = UDim2.new(0, x, 0, y),
                        BackgroundColor3 = PANEL,
                        BackgroundTransparency = 0.5,
                        Parent = c,
                    })
                    round(itemFrame, 6)
                    local btn = new("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = ACCENT,
                        BackgroundTransparency = 0.15,
                        Text = item.data.title or "Button",
                        Font = Enum.Font.GothamBold,
                        TextSize = 12,
                        TextColor3 = Color3.new(1, 1, 1),
                        AutoButtonColor = false,
                        Parent = itemFrame,
                    })
                    round(btn, 5)
                    if item.data.callback then
                        btn.MouseButton1Click:Connect(item.data.callback)
                    end
                end
                y = y + (item.type == "slider" and 44 or 34)
            end
            if g.side == "right" then rightY = y else leftY = y end
        end
    end

    self._render()
    return self
end

return Library
