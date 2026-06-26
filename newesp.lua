--[[
    UNIVERSAL ESP SCRIPT - FULLY FIXED
    Hỗ trợ: Delta Executor
    Tính năng: ESP Box, Line, Name, Distance, Player Count, Menu thu nhỏ
    Fix: Toggle hoạt động chính xác, ESP cập nhật realtime
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    ESP = {
        Enabled = true,
        Box = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxTransparency = 1,
        BoxThickness = 2,
        Tracers = true,
        TracerColor = Color3.fromRGB(255, 255, 255),
        TracerTransparency = 1,
        TracerThickness = 1,
        TracerOrigin = "Bottom",
        Names = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameSize = 14,
        NameTransparency = 1,
        Distance = true,
        DistanceColor = Color3.fromRGB(255, 255, 255),
        DistanceSize = 13,
        ShowTeam = false,
        MaxDistance = 3000,
    },
    Menu = {
        Keybind = Enum.KeyCode.Delete,
        Visible = true,
        Minimized = false
    }
}

-- ESP Objects Table
local ESPObjects = {}
-- Lưu tất cả connections để cleanup
local AllConnections = {}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalESP"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Menu elements
local MenuGui
local MainFrame
local PlayerCountLabel
local MinimizeButton

-- Tạo nút toggle
local function CreateToggleButton(Parent, Name, YPos, DefaultState, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, YPos)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = Name
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleButton.BackgroundColor3 = DefaultState and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = DefaultState and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = ToggleButton
    
    -- Trạng thái hiện tại
    local isEnabled = DefaultState
    
    -- Hàm cập nhật giao diện nút
    local function UpdateButton()
        ToggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        ToggleButton.Text = isEnabled and "ON" or "OFF"
    end
    
    -- Sự kiện click
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        UpdateButton()
        if Callback then
            Callback(isEnabled)
        end
    end)
    
    -- Trả về object để có thể lấy trạng thái
    return {
        Button = ToggleButton,
        GetState = function() return isEnabled end,
        SetState = function(state) 
            isEnabled = state 
            UpdateButton()
            if Callback then
                Callback(state)
            end
        end
    }
end

-- Tạo Menu chính
local function CreateMenu()
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "ESPMenu"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    MenuGui.Enabled = Settings.Menu.Visible and not Settings.Menu.Minimized
    
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 250, 0, 370)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -185)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MenuGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.Text = "UNIVERSAL ESP"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    -- Minimize Button (top right)
    local MiniButton = Instance.new("TextButton")
    MiniButton.Size = UDim2.new(0, 30, 0, 30)
    MiniButton.Position = UDim2.new(1, -35, 0, 5)
    MiniButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    MiniButton.BorderSizePixel = 0
    MiniButton.Text = "—"
    MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniButton.TextSize = 20
    MiniButton.Font = Enum.Font.GothamBold
    MiniButton.AutoButtonColor = false
    MiniButton.Parent = MainFrame
    
    local MiniCorner = Instance.new("UICorner")
    MiniCorner.CornerRadius = UDim.new(0, 4)
    MiniCorner.Parent = MiniButton
    
    MiniButton.MouseButton1Click:Connect(function()
        MinimizeMenu()
    end)
    
    -- Player Count
    PlayerCountLabel = Instance.new("TextLabel")
    PlayerCountLabel.Name = "PlayerCount"
    PlayerCountLabel.Size = UDim2.new(1, -20, 0, 30)
    PlayerCountLabel.Position = UDim2.new(0, 10, 0, 50)
    PlayerCountLabel.BackgroundTransparency = 1
    PlayerCountLabel.Text = "Players: 0"
    PlayerCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlayerCountLabel.TextSize = 16
    PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerCountLabel.Font = Enum.Font.Gotham
    PlayerCountLabel.Parent = MainFrame
    
    -- Tạo các toggle với callback cập nhật Settings trực tiếp
    local Toggles = {}
    
    Toggles.ESPEnabled = CreateToggleButton(MainFrame, "ESP Enabled", 90, Settings.ESP.Enabled, function(state)
        Settings.ESP.Enabled = state
        print("ESP Enabled:", state)
        if not state then
            -- Ẩn tất cả ESP nhưng không xóa
            for player, data in pairs(ESPObjects) do
                if data and data.Box then data.Box.Visible = false end
                if data and data.Tracer then data.Tracer.Visible = false end
                if data and data.NameTag then data.NameTag.Visible = false end
                if data and data.DistanceTag then data.DistanceTag.Visible = false end
            end
        end
    end)
    
    Toggles.Box = CreateToggleButton(MainFrame, "ESP Box", 125, Settings.ESP.Box, function(state)
        Settings.ESP.Box = state
        print("Box:", state)
        -- Cập nhật visibility cho tất cả box hiện có
        for player, data in pairs(ESPObjects) do
            if data and data.Box then
                data.Box.Visible = state and Settings.ESP.Enabled
            end
        end
        -- Nếu bật lại, refresh ESP
        if state and Settings.ESP.Enabled then
            RefreshESP()
        end
    end)
    
    Toggles.Tracers = CreateToggleButton(MainFrame, "ESP Tracers", 160, Settings.ESP.Tracers, function(state)
        Settings.ESP.Tracers = state
        print("Tracers:", state)
        for player, data in pairs(ESPObjects) do
            if data and data.Tracer then
                data.Tracer.Visible = state and Settings.ESP.Enabled
            end
        end
        if state and Settings.ESP.Enabled then
            RefreshESP()
        end
    end)
    
    Toggles.Names = CreateToggleButton(MainFrame, "ESP Names", 195, Settings.ESP.Names, function(state)
        Settings.ESP.Names = state
        print("Names:", state)
        for player, data in pairs(ESPObjects) do
            if data and data.NameTag then
                data.NameTag.Visible = state and Settings.ESP.Enabled
            end
        end
        if state and Settings.ESP.Enabled then
            RefreshESP()
        end
    end)
    
    Toggles.Distance = CreateToggleButton(MainFrame, "ESP Distance", 230, Settings.ESP.Distance, function(state)
        Settings.ESP.Distance = state
        print("Distance:", state)
        for player, data in pairs(ESPObjects) do
            if data and data.DistanceTag then
                data.DistanceTag.Visible = state and Settings.ESP.Enabled
            end
        end
        if state and Settings.ESP.Enabled then
            RefreshESP()
        end
    end)
    
    -- Close Button (Thu nhỏ)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 80, 0, 30)
    CloseButton.Position = UDim2.new(0.5, -40, 0, 330)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "THU NHỎ"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        MinimizeMenu()
    end)
    
    return MenuGui, PlayerCountLabel, Toggles
end

-- Tạo icon thu nhỏ
local function CreateMinimizedIcon()
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizedESP"
    MinimizeButton.Size = UDim2.new(0, 50, 0, 50)
    MinimizeButton.Position = UDim2.new(0, 20, 0, 100)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "ESP"
    MinimizeButton.TextColor3 = Color3.fromRGB(0, 255, 100)
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Active = true
    MinimizeButton.Draggable = true
    MinimizeButton.Visible = Settings.Menu.Minimized
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.Parent = ScreenGui
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 25)
    IconCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MaximizeMenu()
    end)
    
    return MinimizeButton
end

-- Thu nhỏ menu
function MinimizeMenu()
    Settings.Menu.Minimized = true
    Settings.Menu.Visible = false
    if MenuGui then
        MenuGui.Enabled = false
    end
    if MinimizeButton then
        MinimizeButton.Visible = true
    end
end

-- Mở rộng menu
function MaximizeMenu()
    Settings.Menu.Minimized = false
    Settings.Menu.Visible = true
    if MenuGui then
        MenuGui.Enabled = true
    end
    if MinimizeButton then
        MinimizeButton.Visible = false
    end
end

-- Tạo menu và icon
local Toggles
MenuGui, PlayerCountLabel, Toggles = CreateMenu()
MinimizeButton = CreateMinimizedIcon()

-- Toggle Menu Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.Menu.Keybind then
        if Settings.Menu.Minimized then
            MaximizeMenu()
        else
            MinimizeMenu()
        end
    end
end)

-- Refresh ESP cho tất cả player
function RefreshESP()
    -- Xóa ESP cũ và tạo lại
    for player, data in pairs(ESPObjects) do
        if data then
            -- Ngắt connection cũ
            if data.Connection then
                data.Connection:Disconnect()
                data.Connection = nil
            end
            -- Xóa drawing objects
            if data.Box then pcall(function() data.Box:Destroy() end) end
            if data.Tracer then pcall(function() data.Tracer:Destroy() end) end
            if data.NameTag then pcall(function() data.NameTag:Destroy() end) end
            if data.DistanceTag then pcall(function() data.DistanceTag:Destroy() end) end
        end
    end
    ESPObjects = {}
    
    -- Tạo ESP mới cho tất cả player
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player)
        end
    end
end

-- World to Screen
local function WorldToScreen(Position)
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end
    
    local ScreenPos, OnScreen = Camera:WorldToScreenPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen, ScreenPos.Z
end

-- Lấy kích thước nhân vật
local function GetCharacterBounds(Character)
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChild("Humanoid")
    
    if not HumanoidRootPart or not Head or not Humanoid then
        return nil
    end
    
    local rootPos = HumanoidRootPart.Position
    local headPos = Head.Position
    
    local height = (headPos.Y - rootPos.Y) + 2
    local width = height * 0.65
    local centerPos = Vector3.new(rootPos.X, rootPos.Y + height/2, rootPos.Z)
    
    return {
        Center = centerPos,
        Height = height,
        Width = width,
        RootPos = rootPos,
        HeadPos = headPos + Vector3.new(0, 0.5, 0),
        FeetPos = rootPos - Vector3.new(0, 3, 0)
    }
end

-- Tạo ESP cho một player
function CreateESP(Player)
    if Player == LocalPlayer then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChild("Humanoid")
    
    if not HumanoidRootPart or not Head or not Humanoid then
        task.wait(0.3)
        Character = Player.Character
        if not Character then return end
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Head = Character:FindFirstChild("Head")
        Humanoid = Character:FindFirstChild("Humanoid")
        if not HumanoidRootPart or not Head or not Humanoid then return end
    end
    
    -- Xóa ESP cũ nếu có
    if ESPObjects[Player] then
        if ESPObjects[Player].Connection then
            ESPObjects[Player].Connection:Disconnect()
        end
        if ESPObjects[Player].Box then pcall(function() ESPObjects[Player].Box:Destroy() end) end
        if ESPObjects[Player].Tracer then pcall(function() ESPObjects[Player].Tracer:Destroy() end) end
        if ESPObjects[Player].NameTag then pcall(function() ESPObjects[Player].NameTag:Destroy() end) end
        if ESPObjects[Player].DistanceTag then pcall(function() ESPObjects[Player].DistanceTag:Destroy() end) end
    end
    
    -- Tạo data structure cho player
    ESPObjects[Player] = {
        Box = nil,
        Tracer = nil,
        NameTag = nil,
        DistanceTag = nil,
        Connection = nil
    }
    
    -- Tạo Box
    if Drawing and Drawing.new then
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Settings.ESP.BoxColor
        Box.Thickness = Settings.ESP.BoxThickness
        Box.Transparency = Settings.ESP.BoxTransparency
        Box.Filled = false
        Box.ZIndex = 1
        ESPObjects[Player].Box = Box
    end
    
    -- Tạo Tracer
    if Drawing and Drawing.new then
        local Tracer = Drawing.new("Line")
        Tracer.Visible = false
        Tracer.Color = Settings.ESP.TracerColor
        Tracer.Thickness = Settings.ESP.TracerThickness
        Tracer.Transparency = Settings.ESP.TracerTransparency
        Tracer.ZIndex = 1
        ESPObjects[Player].Tracer = Tracer
    end
    
    -- Tạo Name Tag
    if Drawing and Drawing.new then
        local NameTag = Drawing.new("Text")
        NameTag.Visible = false
        NameTag.Color = Settings.ESP.NameColor
        NameTag.Size = Settings.ESP.NameSize
        NameTag.Transparency = Settings.ESP.NameTransparency
        NameTag.Center = true
        NameTag.Outline = true
        NameTag.OutlineColor = Color3.new(0, 0, 0)
        NameTag.ZIndex = 2
        ESPObjects[Player].NameTag = NameTag
    end
    
    -- Tạo Distance Tag
    if Drawing and Drawing.new then
        local DistanceTag = Drawing.new("Text")
        DistanceTag.Visible = false
        DistanceTag.Color = Settings.ESP.DistanceColor
        DistanceTag.Size = Settings.ESP.DistanceSize
        DistanceTag.Center = true
        DistanceTag.Outline = true
        DistanceTag.OutlineColor = Color3.new(0, 0, 0)
        DistanceTag.ZIndex = 2
        ESPObjects[Player].DistanceTag = DistanceTag
    end
    
    -- Render Loop
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        local data = ESPObjects[Player]
        if not data then 
            if Connection then Connection:Disconnect() end
            return 
        end
        
        local Box = data.Box
        local Tracer = data.Tracer
        local NameTag = data.NameTag
        local DistanceTag = data.DistanceTag
        
        -- Kiểm tra ESP Master Enable
        if not Settings.ESP.Enabled then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- Kiểm tra player tồn tại
        if not Player or not Player.Parent then
            if Connection then Connection:Disconnect() end
            return
        end
        
        local currentCharacter = Player.Character
        if not currentCharacter or not currentCharacter.Parent then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        local currentHumanoid = currentCharacter:FindFirstChild("Humanoid")
        if not currentHumanoid or currentHumanoid.Health <= 0 then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- Kiểm tra team
        if not Settings.ESP.ShowTeam and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- Lấy bounds
        local bounds = GetCharacterBounds(currentCharacter)
        if not bounds then
            if Box then Box.Visible = false end
            return
        end
        
        -- Tính khoảng cách
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        local distance = localRoot and (localRoot.Position - bounds.RootPos).Magnitude or 9999
        
        -- Kiểm tra max distance
        if distance > Settings.ESP.MaxDistance then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- World to Screen
        local feetScreen, feetOnScreen, feetDepth = WorldToScreen(bounds.FeetPos)
        local headScreen, headOnScreen, headDepth = WorldToScreen(bounds.HeadPos)
        local centerScreen, centerOnScreen = WorldToScreen(bounds.Center)
        
        if not feetOnScreen or not headOnScreen or feetDepth < 0 then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- Tính kích thước box
        local boxHeight = math.abs(headScreen.Y - feetScreen.Y)
        local boxWidth = boxHeight * 0.55
        
        -- Cập nhật Box - Kiểm tra Settings.ESP.Box TRỰC TIẾP
        if Box then
            if Settings.ESP.Box and Settings.ESP.Enabled then
                Box.Size = Vector2.new(boxWidth, boxHeight)
                Box.Position = Vector2.new(centerScreen.X - boxWidth/2, feetScreen.Y - boxHeight)
                Box.Visible = true
                Box.Color = Settings.ESP.BoxColor
            else
                Box.Visible = false
            end
        end
        
        -- Cập nhật Tracer - Kiểm tra TRỰC TIẾP
        if Tracer then
            if Settings.ESP.Tracers and Settings.ESP.Enabled then
                local viewportSize = workspace.CurrentCamera.ViewportSize
                Tracer.From = Vector2.new(viewportSize.X / 2, 
                             Settings.ESP.TracerOrigin == "Bottom" and viewportSize.Y or 0)
                Tracer.To = Vector2.new(centerScreen.X, feetScreen.Y)
                Tracer.Visible = true
                Tracer.Color = Settings.ESP.TracerColor
            else
                Tracer.Visible = false
            end
        end
        
        -- Cập nhật Name - Kiểm tra TRỰC TIẾP
        if NameTag then
            if Settings.ESP.Names and Settings.ESP.Enabled then
                NameTag.Text = Player.DisplayName or Player.Name
                NameTag.Position = Vector2.new(centerScreen.X, headScreen.Y - 25)
                NameTag.Visible = true
                NameTag.Color = Settings.ESP.NameColor
            else
                NameTag.Visible = false
            end
        end
        
        -- Cập nhật Distance - Kiểm tra TRỰC TIẾP
        if DistanceTag then
            if Settings.ESP.Distance and Settings.ESP.Enabled then
                DistanceTag.Text = math.floor(distance) .. "m"
                DistanceTag.Position = Vector2.new(centerScreen.X, headScreen.Y - 8)
                DistanceTag.Visible = true
                DistanceTag.Color = Settings.ESP.DistanceColor
            else
                DistanceTag.Visible = false
            end
        end
    end)
    
    ESPObjects[Player].Connection = Connection
end

-- Player Added
local function OnPlayerAdded(Player)
    if Player == LocalPlayer then return end
    
    local function OnCharacterAdded(Character)
        task.wait(0.3)
        CreateESP(Player)
    end
    
    if Player.Character then
        OnCharacterAdded(Player.Character)
    end
    
    Player.CharacterAdded:Connect(OnCharacterAdded)
end

-- Player Removing
local function OnPlayerRemoving(Player)
    local data = ESPObjects[Player]
    if data then
        if data.Connection then
            data.Connection:Disconnect()
        end
        if data.Box then pcall(function() data.Box:Destroy() end) end
        if data.Tracer then pcall(function() data.Tracer:Destroy() end) end
        if data.NameTag then pcall(function() data.NameTag:Destroy() end) end
        if data.DistanceTag then pcall(function() data.DistanceTag:Destroy() end) end
        ESPObjects[Player] = nil
    end
end

-- Update Player Count
local function UpdatePlayerCount()
    while task.wait(1) do
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    count = count + 1
                end
            end
        end
        
        if PlayerCountLabel then
            PlayerCountLabel.Text = "👥 Players: " .. count
        end
        
        if MinimizeButton then
            MinimizeButton.Text = "ESP\n" .. count
        end
    end
end

-- Khởi tạo
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        OnPlayerAdded(Player)
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Bắt đầu đếm player
coroutine.wrap(UpdatePlayerCount)()

-- Refresh khi LocalPlayer respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    RefreshESP()
end)

-- Cleanup
LocalPlayer.OnTeleport:Connect(function()
    if ScreenGui then ScreenGui:Destroy() end
    for player, data in pairs(ESPObjects) do
        if data then
            if data.Connection then data.Connection:Disconnect() end
            if data.Box then pcall(function() data.Box:Destroy() end) end
            if data.Tracer then pcall(function() data.Tracer:Destroy() end) end
            if data.NameTag then pcall(function() data.NameTag:Destroy() end) end
            if data.DistanceTag then pcall(function() data.DistanceTag:Destroy() end) end
        end
    end
    ESPObjects = {}
end)

-- Thông báo
if Drawing and Drawing.new then
    local Notif = Drawing.new("Text")
    Notif.Text = "✅ Universal ESP Loaded! [Delete] Menu"
    Notif.Size = 18
    Notif.Color = Color3.fromRGB(0, 255, 100)
    Notif.Center = true
    Notif.Outline = true
    Notif.OutlineColor = Color3.new(0, 0, 0)
    local camera = workspace.CurrentCamera
    if camera then
        Notif.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2 - 50)
    end
    Notif.Visible = true
    
    task.delay(4, function()
        pcall(function() Notif:Destroy() end)
    end)
end

print("=================================")
print("✅ Universal ESP Script Loaded!")
print("🔧 Toggles hoạt động realtime")
print("🗑️ Delete = Thu nhỏ/Mở Menu")
print("=================================")