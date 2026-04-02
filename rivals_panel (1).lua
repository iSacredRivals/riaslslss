-- ============================================================
--   RIVALS PANEL v1.0 | by iSacredRivals
--   Juego: Blox Fruits | Ejecutor: Delta
-- ============================================================
-- COMO USAR EN DELTA:
--   Pega este script completo directamente en Delta y ejecuta.
--   O subelo a GitHub como .lua, abre Raw y ejecuta:
--   loadstring(game:HttpGet("URL_RAW_DE_GITHUB"))()
-- ============================================================

-- SERVICIOS
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local LP   = Players.LocalPlayer
local pgui = LP:WaitForChild("PlayerGui")

-- LIMPIAR INSTANCIAS ANTERIORES
for _, name in pairs({"RivalsIntro","RivalsPanel"}) do
    local old = pgui:FindFirstChild(name) or CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end
local wp = workspace:FindFirstChild("RivalsWaterSolid")
if wp then wp:Destroy() end

-- ESTADO GLOBAL
local State = {
    FastAttack = false, FastRange = 5000,
    ESP = false, Hitbox = false,
    Speed = false, SpeedVal = 16,
    InfJump = false, NoClip = false,
    WalkWater = false, AutoV4 = false,
    TweenTP = false, InstaTP = false, Spectate = false,
    SelectedPl = nil, YOffset = 0,
}

-- COLORES
local BG     = Color3.fromRGB(13,11,6)
local SIDE   = Color3.fromRGB(9,7,0)
local ITEM   = Color3.fromRGB(17,14,2)
local DARK   = Color3.fromRGB(22,17,3)
local G1     = Color3.fromRGB(100,63,5)
local G2     = Color3.fromRGB(180,138,35)
local G3     = Color3.fromRGB(212,170,80)
local TEXT   = Color3.fromRGB(240,225,185)
local MUTED  = Color3.fromRGB(80,56,12)
local TOGOFF = Color3.fromRGB(25,18,2)
local DISC   = Color3.fromRGB(88,101,242)
local WHITE  = Color3.new(1,1,1)
local BLACK  = Color3.new(0,0,0)

-- HELPERS
local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
end

local function stroke(obj, col, thick)
    local s = Instance.new("UIStroke", obj)
    s.Color = col or G1
    s.Thickness = thick or 1
end

local function newFrame(parent, size, pos, color, clip)
    local f = Instance.new("Frame", parent)
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or BG
    f.BorderSizePixel = 0
    if clip then f.ClipsDescendants = true end
    return f
end

local function newLabel(parent, text, size, color, font, xalign)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextSize = size or 12
    l.TextColor3 = color or TEXT
    l.Font = font or Enum.Font.GothamBold
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    return l
end

local function newBtn(parent, text, size, pos, bgColor, textColor)
    local b = Instance.new("TextButton", parent)
    b.Size = size or UDim2.new(1,0,0,36)
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bgColor or ITEM
    b.Text = text or ""
    b.TextSize = 12
    b.TextColor3 = textColor or TEXT
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    return b
end

-- ──────────────────────────────────────────────────────────
-- [0] INTRO — RIVALS PANEL EXCLUSIVE
-- ──────────────────────────────────────────────────────────
local introGui = Instance.new("ScreenGui")
introGui.Name = "RivalsIntro"
introGui.ResetOnSpawn = false
introGui.IgnoreGuiInset = true
introGui.DisplayOrder = 999
pcall(function() introGui.Parent = CoreGui end)
if not introGui.Parent then introGui.Parent = pgui end

local introBg = newFrame(introGui, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), BLACK)

-- Matrix rain (letras cayendo en dorado)
local matrixOn = true
task.spawn(function()
    local vp = workspace.CurrentCamera.ViewportSize
    local cols = math.floor(vp.X / 22)
    local chars = {"0","1","R","I","V","A","L","S","*","+","#","!","0","1"}
    local goldColors = {
        Color3.fromRGB(100,63,5), Color3.fromRGB(180,138,35),
        Color3.fromRGB(212,170,80), Color3.fromRGB(240,200,96),
        Color3.fromRGB(155,110,25),
    }
    local drops = {}
    for i=1,cols do drops[i] = math.random(1, math.floor(vp.Y/22)) end

    while matrixOn do
        task.wait(0.07)
        if not introBg.Parent then break end
        for i=1,cols do
            local lbl = Instance.new("TextLabel", introBg)
            lbl.Size = UDim2.new(0,20,0,22)
            lbl.Position = UDim2.new(0,(i-1)*22,0,drops[i]*22)
            lbl.BackgroundTransparency = 1
            lbl.Text = chars[math.random(#chars)]
            lbl.TextSize = math.random(11,16)
            lbl.Font = Enum.Font.Code
            lbl.TextColor3 = goldColors[math.random(#goldColors)]
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            lbl.ZIndex = 2
            game:GetService("Debris"):AddItem(lbl, 0.5)
            drops[i] = drops[i] + 1
            if drops[i]*22 > vp.Y then drops[i] = 0 end
        end
    end
end)

-- Logo circular
local introLogo = newFrame(introBg, UDim2.new(0,78,0,78), UDim2.new(0.5,-39,0.2,0), BG)
introLogo.ZIndex = 5
corner(introLogo, 39)
stroke(introLogo, G2, 2)
local introLogoTxt = Instance.new("TextLabel", introLogo)
introLogoTxt.Size = UDim2.new(1,0,1,0)
introLogoTxt.BackgroundTransparency = 1
introLogoTxt.Text = "R"
introLogoTxt.TextSize = 38
introLogoTxt.Font = Enum.Font.GothamBlack
introLogoTxt.TextColor3 = G3
introLogoTxt.TextXAlignment = Enum.TextXAlignment.Center
introLogoTxt.ZIndex = 6

-- Titulo
local introTitle = Instance.new("TextLabel", introBg)
introTitle.Size = UDim2.new(1,0,0,52)
introTitle.Position = UDim2.new(0,0,0.2,88)
introTitle.BackgroundTransparency = 1
introTitle.Text = "RIVALS PANEL"
introTitle.TextSize = 44
introTitle.Font = Enum.Font.GothamBlack
introTitle.TextColor3 = G3
introTitle.TextXAlignment = Enum.TextXAlignment.Center
introTitle.TextStrokeTransparency = 0.5
introTitle.TextStrokeColor3 = G1
introTitle.ZIndex = 5

-- Exclusive
local introExcl = Instance.new("TextLabel", introBg)
introExcl.Size = UDim2.new(1,0,0,28)
introExcl.Position = UDim2.new(0,0,0.2,142)
introExcl.BackgroundTransparency = 1
introExcl.Text = "~ Rivals Panel Exclusive ~"
introExcl.TextSize = 13
introExcl.Font = Enum.Font.GothamBold
introExcl.TextColor3 = G2
introExcl.TextXAlignment = Enum.TextXAlignment.Center
introExcl.ZIndex = 5

-- By
local introBy = Instance.new("TextLabel", introBg)
introBy.Size = UDim2.new(1,0,0,22)
introBy.Position = UDim2.new(0,0,0.2,172)
introBy.BackgroundTransparency = 1
introBy.Text = "by iSacredRivals"
introBy.TextSize = 12
introBy.Font = Enum.Font.Gotham
introBy.TextColor3 = G2
introBy.TextXAlignment = Enum.TextXAlignment.Center
introBy.ZIndex = 5

-- Sub
local introSub = Instance.new("TextLabel", introBg)
introSub.Size = UDim2.new(1,0,0,22)
introSub.Position = UDim2.new(0,0,0.2,202)
introSub.BackgroundTransparency = 1
introSub.Text = "Cargando modulos..."
introSub.TextSize = 12
introSub.Font = Enum.Font.Code
introSub.TextColor3 = Color3.fromRGB(60,44,8)
introSub.ZIndex = 5

-- Barra de carga
local barBg = newFrame(introBg, UDim2.new(0,300,0,3),
    UDim2.new(0.5,-150,0.2,234), Color3.fromRGB(20,15,2))
barBg.ZIndex = 5
corner(barBg, 2)
local barFill = newFrame(barBg, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), G2)
barFill.ZIndex = 6
corner(barFill, 2)
TweenService:Create(barFill, TweenInfo.new(4.2, Enum.EasingStyle.Linear),
    {Size = UDim2.new(1,0,1,0)}):Play()

-- Pulso del titulo
task.spawn(function()
    local up = true
    while introTitle and introTitle.Parent do
        task.wait(0.8)
        TweenService:Create(introTitle, TweenInfo.new(0.8),
            {TextColor3 = up and G3 or G2}):Play()
        up = not up
    end
end)

-- Fade out de la intro
task.delay(4.6, function()
    matrixOn = false
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Linear)
    TweenService:Create(introBg, fadeInfo, {BackgroundTransparency = 1}):Play()
    for _, obj in pairs({introLogo,introTitle,introExcl,introBy,introSub,barBg}) do
        pcall(function()
            TweenService:Create(obj, fadeInfo, {BackgroundTransparency=1}):Play()
            if obj:IsA("TextLabel") then
                TweenService:Create(obj, fadeInfo, {TextTransparency=1}):Play()
            end
        end)
    end
    task.wait(0.9)
    if introGui and introGui.Parent then introGui:Destroy() end
end)

task.wait(5.6)

-- ──────────────────────────────────────────────────────────
-- LOGICA DE FEATURES
-- ──────────────────────────────────────────────────────────
local Net, RegisterHit, RegisterAttack
pcall(function()
    Net = ReplicatedStorage:WaitForChild("Modules",3)
          :WaitForChild("Net",3)
    RegisterHit    = Net["RE/RegisterHit"]
    RegisterAttack = Net["RE/RegisterAttack"]
end)

local function AttackTargets(targets)
    if not RegisterHit or not RegisterAttack then return end
    pcall(function()
        if #targets == 0 then return end
        local all = {}
        for _, ch in pairs(targets) do
            local h = ch:FindFirstChild("Head")
            if h then table.insert(all, {ch, h}) end
        end
        if #all == 0 then return end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(all[1][2], all)
    end)
end

-- Fast Attack loop
task.spawn(function()
    while true do
        task.wait(0.005)
        if not State.FastAttack then task.wait(0.1) continue end
        local myChar = LP.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end
        local targets = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hum = p.Character:FindFirstChild("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 and
                   (hrp.Position-myHRP.Position).Magnitude <= State.FastRange then
                    table.insert(targets, p.Character)
                end
            end
        end
        local en = workspace:FindFirstChild("Enemies")
        if en then
            for _, npc in pairs(en:GetChildren()) do
                local hum = npc:FindFirstChild("Humanoid")
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 and
                   (hrp.Position-myHRP.Position).Magnitude <= State.FastRange then
                    table.insert(targets, npc)
                end
            end
        end
        if #targets > 0 then AttackTargets(targets) end
    end
end)

-- ESP
local ESPObjects = {}
local function ClearESP()
    for _, o in pairs(ESPObjects) do pcall(function() o:Destroy() end) end
    ESPObjects = {}
end
local function UpdateESP()
    ClearESP()
    if not State.ESP then return end
    local function mkESP(char)
        local head = char:FindFirstChild("Head")
        if not head then return end
        local bb = Instance.new("BillboardGui", head)
        bb.Name = "RivalsESP"; bb.Adornee = head
        bb.Size = UDim2.new(0,120,0,40)
        bb.StudsOffset = Vector3.new(0,2.5,0)
        bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = char.Name
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = G3
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = BLACK
        table.insert(ESPObjects, bb)
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then mkESP(p.Character) end
    end
    local en = workspace:FindFirstChild("Enemies")
    if en then for _, n in pairs(en:GetChildren()) do mkESP(n) end end
end

task.spawn(function()
    while true do task.wait(5) if State.ESP then UpdateESP() end end
end)

-- Hitbox
task.spawn(function()
    while true do
        task.wait(0.15)
        if not State.Hitbox then continue end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(30,30,30)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if not State.Speed then return end
    local ch  = LP.Character; if not ch then return end
    local hum = ch:FindFirstChild("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.MoveDirection.Magnitude > 0 then
        hrp:TranslateBy(hum.MoveDirection * (State.SpeedVal / 55))
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not State.InfJump then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- No Clip
RunService.Stepped:Connect(function()
    if not State.NoClip then return end
    local ch = LP.Character; if not ch then return end
    for _, v in pairs(ch:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

-- Walk on Water
RunService.RenderStepped:Connect(function()
    local ch  = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if State.WalkWater and hrp then
        if hrp.Position.Y >= 9.5 and hrp.Velocity.Y <= 0 then
            local ww = workspace:FindFirstChild("RivalsWaterSolid")
            if not ww then
                ww = Instance.new("Part", workspace)
                ww.Name = "RivalsWaterSolid"
                ww.Size = Vector3.new(20,1,20)
                ww.Transparency = 1; ww.Anchored = true
                ww.CanCollide = true
                pcall(function() ww.CanQuery = false end)
            end
            ww.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            local ww = workspace:FindFirstChild("RivalsWaterSolid")
            if ww then ww:Destroy() end
        end
    else
        local ww = workspace:FindFirstChild("RivalsWaterSolid")
        if ww then ww:Destroy() end
    end
end)

-- Auto V4
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoV4 then
            pcall(function()
                LP.Backpack.Awakening.RemoteFunction:InvokeServer(true)
            end)
        end
    end
end)

-- Player Lock helpers
local function SetCollide(val)
    local ch = LP.Character; if not ch then return end
    for _, v in pairs(ch:GetChildren()) do
        if v:IsA("BasePart") then v.CanCollide = val end
    end
end

local ActiveTween = nil
local function TweenTP(targetHRP)
    local ch  = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHRP then return end
    local tf = CFrame.new(targetHRP.Position + Vector3.new(0, State.YOffset, 0))
    local d  = (tf.Position - hrp.Position).Magnitude
    if ActiveTween then ActiveTween:Cancel() end
    ActiveTween = TweenService:Create(hrp,
        TweenInfo.new(d/350, Enum.EasingStyle.Linear), {CFrame=tf})
    ActiveTween:Play()
end

RunService.Heartbeat:Connect(function()
    if not State.TweenTP or not State.SelectedPl then return end
    local t = Players:FindFirstChild(State.SelectedPl)
    if t and t.Character then
        local hrp = t.Character:FindFirstChild("HumanoidRootPart")
        if hrp then TweenTP(hrp); SetCollide(false) end
    end
end)

RunService.Stepped:Connect(function()
    if not State.InstaTP or not State.SelectedPl then return end
    pcall(function()
        local t = Players:FindFirstChild(State.SelectedPl)
        if t and t.Character then
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local tHRP  = t.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                myHRP.CFrame   = tHRP.CFrame * CFrame.new(0, State.YOffset, 0)
                myHRP.Velocity = Vector3.new(0,0,0)
            end
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    if not State.Spectate or not State.SelectedPl then return end
    local t = Players:FindFirstChild(State.SelectedPl)
    if t and t.Character then
        local hum = t.Character:FindFirstChildOfClass("Humanoid")
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end
end)

-- ──────────────────────────────────────────────────────────
-- GUI PRINCIPAL
-- ──────────────────────────────────────────────────────────
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RivalsPanel"
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.DisplayOrder = 10
pcall(function() mainGui.Parent = CoreGui end)
if not mainGui.Parent then mainGui.Parent = pgui end

local main = newFrame(mainGui,
    UDim2.new(0,680,0,480), UDim2.new(0.5,-340,0.5,-240), BG, true)
corner(main, 14)
stroke(main, G1)

-- Top accent line
local accentTop = newFrame(main, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), G2)
accentTop.ZIndex = 3

-- TITLEBAR con drag
local tbar = newFrame(main, UDim2.new(1,0,0,48), UDim2.new(0,0,0,2),
    Color3.fromRGB(18,14,2))

local dragging, dragStart, startPos = false, nil, nil
tbar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        startPos  = main.Position
    end
end)
tbar.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
tbar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Logo
local tLogo = newFrame(tbar, UDim2.new(0,30,0,30), UDim2.new(0,12,0.5,-15), G2)
corner(tLogo, 9)
local tLogoTxt = Instance.new("TextLabel", tLogo)
tLogoTxt.Size = UDim2.new(1,0,1,0)
tLogoTxt.BackgroundTransparency = 1
tLogoTxt.Text = "R"
tLogoTxt.TextSize = 16
tLogoTxt.Font = Enum.Font.GothamBlack
tLogoTxt.TextColor3 = BG
tLogoTxt.TextXAlignment = Enum.TextXAlignment.Center

-- Titulo
local tTitle = newLabel(tbar, "RIVALS PANEL", 13, TEXT, Enum.Font.GothamBlack)
tTitle.Size = UDim2.new(0,180,1,0)
tTitle.Position = UDim2.new(0,52,0,0)
tTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Badge PRO
local tBadge = newFrame(tbar, UDim2.new(0,36,0,16), UDim2.new(0,200,0.5,-8), DARK)
corner(tBadge, 4); stroke(tBadge, G1)
local tBadgeTxt = newLabel(tBadge, "PRO", 9, G2, Enum.Font.GothamBold, Enum.TextXAlignment.Center)

-- Botones min/close
local function mkTBtn(txt, xOff)
    local b = newBtn(tbar, txt,
        UDim2.new(0,26,0,26), UDim2.new(1,xOff,0.5,-13), DARK, MUTED)
    b.TextSize = 14; b.Font = Enum.Font.GothamBold
    corner(b, 7); stroke(b, G1)
    return b
end
local minBtn = mkTBtn("-", -62)
local clsBtn = mkTBtn("X", -32)

-- SIDEBAR
local sidebar = newFrame(main,
    UDim2.new(0,158,1,-50), UDim2.new(0,0,0,50), SIDE)
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0,1)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- CONTENIDO
local cArea = newFrame(main,
    UDim2.new(1,-158,1,-50), UDim2.new(0,158,0,50), BG, true)

local cHdr = newFrame(cArea, UDim2.new(1,0,0,40), UDim2.new(0,0,0,0),
    Color3.fromRGB(14,11,2))

local pgTitle = newLabel(cHdr,"HOME",13,TEXT,Enum.Font.GothamBlack)
pgTitle.Size = UDim2.new(1,-16,0,20); pgTitle.Position = UDim2.new(0,14,0,5)
pgTitle.TextXAlignment = Enum.TextXAlignment.Left

local pgSub = newLabel(cHdr,"Panel principal del hub",10,G1,Enum.Font.Gotham)
pgSub.Size = UDim2.new(1,-16,0,14); pgSub.Position = UDim2.new(0,14,0,24)
pgSub.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", cArea)
scroll.Size = UDim2.new(1,0,1,-40)
scroll.Position = UDim2.new(0,0,0,40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = G2
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local scrollPad = Instance.new("UIPadding", scroll)
scrollPad.PaddingLeft   = UDim.new(0,10)
scrollPad.PaddingRight  = UDim.new(0,10)
scrollPad.PaddingTop    = UDim.new(0,8)
scrollPad.PaddingBottom = UDim.new(0,8)

local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.Padding = UDim.new(0,5)
scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- SISTEMA DE PAGINAS
local pages   = {}
local navBtns = {}

local subTexts = {
    HOME            = "Panel principal del hub",
    COMBATE         = "Funciones de ataque y vision",
    MOVIMIENTO      = "Velocidad y movilidad",
    ["PLAYER LOCK"] = "TP y seguimiento de jugadores",
    ["SEA 2"]       = "Teletransportes del segundo mar",
    ["SEA 3"]       = "Teletransportes del tercer mar",
}

local function showPage(key)
    for k, pg in pairs(pages) do pg.Visible = (k == key) end
    pgTitle.Text = key
    pgSub.Text   = subTexts[key] or ""
    for k, nb in pairs(navBtns) do
        local on = (k == key)
        nb.txt.TextColor3 = on and TEXT or MUTED
        nb.acc.Visible    = on
        nb.btn.BackgroundColor3 = on and Color3.fromRGB(14,11,1) or SIDE
    end
end

local function mkPage(key)
    local f = newFrame(scroll, UDim2.new(1,0,0,0), UDim2.new(0,0,0,0), BG)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Visible = false
    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0,5)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.SortOrder = Enum.SortOrder.LayoutOrder
    pages[key] = f
    return f
end

local function mkNav(label, key)
    local btn = newBtn(sidebar,"",
        UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), SIDE, TEXT)

    local acc = newFrame(btn, UDim2.new(0,2,1,0), UDim2.new(0,0,0,0), G2)
    acc.Visible = false

    local icBg = newFrame(btn, UDim2.new(0,26,0,26), UDim2.new(0,12,0.5,-13), DARK)
    corner(icBg, 7)

    local txtLbl = newLabel(btn, label, 11, MUTED, Enum.Font.GothamBold)
    txtLbl.Size = UDim2.new(1,-48,1,0)
    txtLbl.Position = UDim2.new(0,48,0,0)
    txtLbl.TextXAlignment = Enum.TextXAlignment.Left

    btn.MouseButton1Click:Connect(function() showPage(key) end)
    navBtns[key] = {btn=btn, txt=txtLbl, acc=acc}
    return btn
end

local function mkNavSep()
    local f = newFrame(sidebar, UDim2.new(0.85,0,0,1),
        UDim2.new(0,0,0,0), Color3.fromRGB(20,14,2))
    return f
end

local function mkSec(parent, txt, order)
    local f = newFrame(parent, UDim2.new(1,0,0,20), UDim2.new(0,0,0,0), BG)
    f.LayoutOrder = order or 0
    local l = newLabel(f, txt:upper(), 9, G2, Enum.Font.GothamBlack)
    l.Size = UDim2.new(0,0,1,0)
    l.AutomaticSize = Enum.AutomaticSize.X
    l.TextXAlignment = Enum.TextXAlignment.Left
    local line = newFrame(f, UDim2.new(1,-8,0,1), UDim2.new(0,8,0.5,0), G1)
    line.AnchorPoint = Vector2.new(0,0.5)
    return f
end

local function mkToggle(parent, name, desc, order, cb)
    local f = newFrame(parent, UDim2.new(1,0,0,44), UDim2.new(0,0,0,0), ITEM)
    f.LayoutOrder = order or 0
    corner(f, 8); stroke(f, G1)

    local nLbl = newLabel(f, name, 12, Color3.fromRGB(232,204,128), Enum.Font.GothamBold)
    nLbl.Size = UDim2.new(1,-56,0,18)
    nLbl.Position = UDim2.new(0,12,0,5)

    if desc and desc ~= "" then
        local dLbl = newLabel(f, desc, 10, G1, Enum.Font.Gotham)
        dLbl.Size = UDim2.new(1,-56,0,14)
        dLbl.Position = UDim2.new(0,12,0,24)
    end

    local tBg = newFrame(f, UDim2.new(0,38,0,20), UDim2.new(1,-48,0.5,-10), TOGOFF)
    corner(tBg, 10); stroke(tBg, G1)
    local tDot = newFrame(tBg, UDim2.new(0,14,0,14), UDim2.new(0,3,0.5,-7), MUTED)
    corner(tDot, 7)

    local isOn = false
    local clickBtn = newBtn(f, "", UDim2.new(1,0,1,0))
    clickBtn.BackgroundTransparency = 1; clickBtn.ZIndex = 5
    clickBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            TweenService:Create(tBg,  TweenInfo.new(0.2),{BackgroundColor3=G2}):Play()
            TweenService:Create(tDot, TweenInfo.new(0.2),
                {Position=UDim2.new(0,21,0.5,-7),BackgroundColor3=TEXT}):Play()
        else
            TweenService:Create(tBg,  TweenInfo.new(0.2),{BackgroundColor3=TOGOFF}):Play()
            TweenService:Create(tDot, TweenInfo.new(0.2),
                {Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=MUTED}):Play()
        end
        if cb then cb(isOn) end
    end)
    return f
end

local function mkTpBtn(parent, name, coords, order, cb)
    local f = newBtn(parent,"",
        UDim2.new(1,0,0,46), UDim2.new(0,0,0,0), ITEM)
    f.LayoutOrder = order or 0
    corner(f,9); stroke(f,G1)

    local nLbl = newLabel(f,name,12,Color3.fromRGB(232,204,128),Enum.Font.GothamBold)
    nLbl.Size = UDim2.new(1,-16,0,18); nLbl.Position = UDim2.new(0,12,0,6)

    local cLbl = newLabel(f,coords,9,G1,Enum.Font.Code)
    cLbl.Size = UDim2.new(1,-16,0,14); cLbl.Position = UDim2.new(0,12,0,26)

    local arr = newLabel(f,">",16,G1,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
    arr.Size = UDim2.new(0,30,1,0); arr.Position = UDim2.new(1,-34,0,0)

    f.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=G1}):Play()
        task.wait(0.15)
        TweenService:Create(f,TweenInfo.new(0.15),{BackgroundColor3=ITEM}):Play()
        if cb then cb() end
    end)
    return f
end

local function mkPlusMinus(parent, order, defaultVal, minV, maxV, stepV, cb)
    local f = newFrame(parent,UDim2.new(1,0,0,40),UDim2.new(0,0,0,0),ITEM)
    f.LayoutOrder = order or 0
    corner(f,8); stroke(f,G1)
    local val = defaultVal or 0
    local valLbl = newLabel(f,tostring(val),16,G3,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
    valLbl.Size = UDim2.new(0,50,1,0); valLbl.Position = UDim2.new(0.5,-25,0,0)
    local mBtn = newBtn(f,"-",UDim2.new(0,26,0,26),UDim2.new(1,-62,0.5,-13),DARK,G2)
    mBtn.TextSize=18; mBtn.Font=Enum.Font.GothamBlack
    corner(mBtn,6); stroke(mBtn,G1)
    local pBtn = newBtn(f,"+",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),DARK,G2)
    pBtn.TextSize=18; pBtn.Font=Enum.Font.GothamBlack
    corner(pBtn,6); stroke(pBtn,G1)
    mBtn.MouseButton1Click:Connect(function()
        val = math.clamp(val-(stepV or 10), minV or 0, maxV or 500)
        valLbl.Text = tostring(val); if cb then cb(val) end
    end)
    pBtn.MouseButton1Click:Connect(function()
        val = math.clamp(val+(stepV or 10), minV or 0, maxV or 500)
        valLbl.Text = tostring(val); if cb then cb(val) end
    end)
    return f
end

-- ──────────────────────────────────────────────────────────
-- PAGINAS
-- ──────────────────────────────────────────────────────────

-- HOME
local homeP = mkPage("HOME")
local heroF = newFrame(homeP,UDim2.new(1,0,0,118),UDim2.new(0,0,0,0),BG)
heroF.LayoutOrder = 0
local heroLogo = newFrame(heroF,UDim2.new(0,74,0,74),UDim2.new(0.5,-37,0,4),BG)
corner(heroLogo,37); stroke(heroLogo,G2,2)
local heroLogoTxt = newLabel(heroLogo,"R",36,G3,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local heroTitle = newLabel(heroF,"RIVALS PANEL",20,TEXT,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
heroTitle.Size = UDim2.new(1,0,0,26); heroTitle.Position = UDim2.new(0,0,0,82)
local heroBy = newLabel(heroF,"by iSacredRivals",11,G2,Enum.Font.Gotham,Enum.TextXAlignment.Center)
heroBy.Size = UDim2.new(1,0,0,16); heroBy.Position = UDim2.new(0,0,0,104)

local infoRow = newFrame(homeP,UDim2.new(1,0,0,50),UDim2.new(0,0,0,0),BG)
infoRow.LayoutOrder = 1
local function mkInfoCard(parent, lbl, val, xPos)
    local c = newFrame(parent,UDim2.new(0.48,0,1,0),UDim2.new(xPos,0,0,0),ITEM)
    corner(c,9); stroke(c,G1)
    local l = newLabel(c,lbl:upper(),8,G1,Enum.Font.GothamBold)
    l.Size=UDim2.new(1,-8,0,14); l.Position=UDim2.new(0,8,0,6)
    local v = newLabel(c,val,13,Color3.fromRGB(232,204,128),Enum.Font.GothamBold)
    v.Size=UDim2.new(1,-8,0,18); v.Position=UDim2.new(0,8,0,24)
end
mkInfoCard(infoRow,"JUEGO","Blox Fruits",0)
mkInfoCard(infoRow,"EJECUTOR","Delta",0.52)

local discBtn = newBtn(homeP,"",UDim2.new(1,0,0,46),UDim2.new(0,0,0,0),
    Color3.fromRGB(12,14,40))
discBtn.LayoutOrder = 2
corner(discBtn,9); stroke(discBtn,DISC)
local discMain = newLabel(discBtn,"Unete al Discord",13,Color3.fromRGB(232,204,128),Enum.Font.GothamBold)
discMain.Size=UDim2.new(1,-16,0,18); discMain.Position=UDim2.new(0,14,0,6)
local discSub = newLabel(discBtn,"discord.gg/QvpGRwDdpZ",10,G1,Enum.Font.Gotham)
discSub.Size=UDim2.new(1,-16,0,14); discSub.Position=UDim2.new(0,14,0,26)
discBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/QvpGRwDdpZ") end)
end)

-- COMBATE
local combatP = mkPage("COMBATE")
mkSec(combatP,"Fast Attack",0)
mkToggle(combatP,"Fast Attack","Ataca todos los targets en rango",1,function(on)
    State.FastAttack = on
end)
mkSec(combatP,"ESP",2)
mkToggle(combatP,"ESP Nombres","Ver jugadores y NPCs a traves de paredes",3,function(on)
    State.ESP = on; UpdateESP()
end)
mkSec(combatP,"Hitbox",4)
mkToggle(combatP,"Hitbox Expand","Ampliar hitbox de enemigos",5,function(on)
    State.Hitbox = on
end)

-- MOVIMIENTO
local moveP = mkPage("MOVIMIENTO")
mkSec(moveP,"Speed",0)
mkToggle(moveP,"Speed Controller","Control de velocidad de movimiento",1,function(on)
    State.Speed = on
end)
local spdLblF = newFrame(moveP,UDim2.new(1,0,0,14),UDim2.new(0,0,0,0),BG)
spdLblF.LayoutOrder = 2
newLabel(spdLblF,"Velocidad actual:",10,MUTED,Enum.Font.Gotham)
mkPlusMinus(moveP,3,16,16,500,10,function(v) State.SpeedVal = v end)
mkSec(moveP,"Mobility",4)
mkToggle(moveP,"Infinite Jump","Saltar indefinidamente en el aire",5,function(on)
    State.InfJump = on
end)
mkToggle(moveP,"No Clip","Atraviesa paredes y objetos",6,function(on)
    State.NoClip = on
end)
mkToggle(moveP,"Walk on Water","Caminar sobre el agua",7,function(on)
    State.WalkWater = on
end)
mkSec(moveP,"Auto V4",8)
mkToggle(moveP,"Auto V4 Awakening","Activa Awakening de Race V4 automaticamente",9,function(on)
    State.AutoV4 = on
end)

-- PLAYER LOCK
local plockP = mkPage("PLAYER LOCK")
mkSec(plockP,"Seleccion de jugador",0)

local selFrame = newFrame(plockP,UDim2.new(1,0,0,26),UDim2.new(0,0,0,0),BG)
selFrame.LayoutOrder = 1
local selectedLbl = newLabel(selFrame,"Jugador: Ninguno",11,
    Color3.fromRGB(232,204,128),Enum.Font.GothamBold)

local playerListF = newFrame(plockP,UDim2.new(1,0,0,0),UDim2.new(0,0,0,0),BG)
playerListF.AutomaticSize = Enum.AutomaticSize.Y
playerListF.LayoutOrder = 2
local plLayout = Instance.new("UIListLayout",playerListF)
plLayout.Padding = UDim.new(0,4)
plLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local playerBtns = {}
local function RefreshPlayers()
    for _, b in pairs(playerBtns) do pcall(function() b:Destroy() end) end
    playerBtns = {}
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list,p.Name) end
    end
    if #list == 0 then
        local f = newFrame(playerListF,UDim2.new(1,0,0,28),UDim2.new(0,0,0,0),BG)
        newLabel(f,"No hay jugadores en el server",11,G1,Enum.Font.Gotham,Enum.TextXAlignment.Center)
        table.insert(playerBtns,f)
        return
    end
    for _, name in pairs(list) do
        local b = newBtn(playerListF,name,
            UDim2.new(1,0,0,34),UDim2.new(0,0,0,0),ITEM,Color3.fromRGB(232,204,128))
        b.TextXAlignment = Enum.TextXAlignment.Left
        local pad = Instance.new("UIPadding",b); pad.PaddingLeft=UDim.new(0,12)
        corner(b,8); stroke(b,G1)
        b.MouseButton1Click:Connect(function()
            State.SelectedPl = name
            selectedLbl.Text = "Jugador: "..name
            for _, ob in pairs(playerBtns) do
                pcall(function()
                    TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=ITEM}):Play()
                end)
            end
            TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=G1}):Play()
        end)
        table.insert(playerBtns,b)
    end
end
RefreshPlayers()

local refBtn = newBtn(plockP,"Refrescar lista",
    UDim2.new(1,0,0,30),UDim2.new(0,0,0,0),DARK,G2)
refBtn.LayoutOrder=3; corner(refBtn,8); stroke(refBtn,G1)
refBtn.MouseButton1Click:Connect(RefreshPlayers)

mkSec(plockP,"Modos de TP",4)
mkToggle(plockP,"Tween To Player","TP suave siguiendo al objetivo",5,function(on)
    State.TweenTP = on
    if not on then
        if ActiveTween then ActiveTween:Cancel() end
        SetCollide(true)
    end
end)
mkToggle(plockP,"Insta TP","Teletransporte instantaneo encima del jugador",6,function(on)
    State.InstaTP = on
end)
mkToggle(plockP,"Spectate Player","Sigue la camara al jugador seleccionado",7,function(on)
    State.Spectate = on
    if not on then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end
end)

mkSec(plockP,"Ajustes",8)
mkPlusMinus(plockP,9,0,0,200,5,function(v) State.YOffset = v end)

-- SEA 2
local sea2P = mkPage("SEA 2")
mkSec(sea2P,"Sea 2 - Teleports",0)
mkTpBtn(sea2P,"Barco Maldito","923 / 126 / 32852",1,function()
    local ch = LP.Character
    if ch then ch:PivotTo(CFrame.new(923,126,32852)) end
end)

-- SEA 3
local sea3P = mkPage("SEA 3")
mkSec(sea3P,"Sea 3 - Teleports",0)
mkTpBtn(sea3P,"Castillo","-5085 / 316 / -3156",1,function()
    local ch = LP.Character
    if ch then ch:PivotTo(CFrame.new(-5085,316,-3156)) end
end)
mkTpBtn(sea3P,"Mansion","-12463 / 375 / -7523",2,function()
    local ch = LP.Character
    if ch then ch:PivotTo(CFrame.new(-12463,375,-7523)) end
end)

-- NAV + HOME POR DEFECTO
mkNav("Home",        "HOME")
mkNavSep()
mkNav("Combate",     "COMBATE")
mkNavSep()
mkNav("Movimiento",  "MOVIMIENTO")
mkNavSep()
mkNav("Player Lock", "PLAYER LOCK")
mkNavSep()
mkNav("Sea 2",       "SEA 2")
mkNav("Sea 3",       "SEA 3")

showPage("HOME")

-- MINIMIZAR / CERRAR
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        sidebar.Visible = false; cArea.Visible = false
        main:TweenSize(UDim2.new(0,210,0,50),
            Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.3,true)
        minBtn.Text = "+"
    else
        main:TweenSize(UDim2.new(0,680,0,480),
            Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.3,true)
        task.wait(0.25)
        sidebar.Visible = true; cArea.Visible = true
        minBtn.Text = "-"
    end
end)

clsBtn.MouseButton1Click:Connect(function()
    State.FastAttack = false; State.ESP = false
    State.WalkWater  = false; State.TweenTP  = false
    State.InstaTP    = false; State.Spectate = false
    ClearESP()
    local ww = workspace:FindFirstChild("RivalsWaterSolid")
    if ww then ww:Destroy() end
    if ActiveTween then ActiveTween:Cancel() end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then workspace.CurrentCamera.CameraSubject = hum end
    mainGui:Destroy()
end)

-- FIN — RIVALS PANEL v1.0 by iSacredRivals
