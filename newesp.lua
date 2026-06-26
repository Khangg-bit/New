--[[
    UNIVERSAL ESP SCRIPT - FIXED VERSION
    Hỗ trợ: Delta Executor
    Tính năng: ESP Box (chính xác), Line, Name, Distance, Player Count, Menu có thể thu nhỏ
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

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalESP"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Create Folder for ESP drawings
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = ScreenGui

-- Create Menu
local MenuGui
local MainFrame
local PlayerCountLabel
local MinimizeButton

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
    
    -- Toggle Functions
    local function CreateToggle(Name, YPos, Setting, Callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 10, 0, YPos)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = MainFrame
        
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
        ToggleButton.BackgroundColor3 = Setting and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = Setting and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.AutoButtonColor = false
        ToggleButton.Parent = ToggleFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = ToggleButton
        
        ToggleButton.MouseButton1Click:Connect(function()
            Setting = not Setting
            ToggleButton.BackgroundColor3 = Setting and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            ToggleButton.Text = Setting and "ON" or "OFF"
            if Callback then
                Callback(Setting)
            end
        end)
        
        return ToggleButton, Setting
    end
    
    CreateToggle("ESP Enabled", 90, Settings.ESP.Enabled, function(val)
        Settings.ESP.Enabled = val
        if not val then
            HideAllESP()
        end
    end)
    CreateToggle("ESP Box", 125, Settings.ESP.Box, function(val)
        Settings.ESP.Box = val
        ClearESP()
    end)
    CreateToggle("ESP Tracers", 160, Settings.ESP.Tracers, function(val)
        Settings.ESP.Tracers = val
        ClearESP()
    end)
    CreateToggle("ESP Names", 195, Settings.ESP.Names, function(val)
        Settings.ESP.Names = val
        ClearESP()
    end)
    CreateToggle("ESP Distance", 230, Settings.ESP.Distance, function(val)
        Settings.ESP.Distance = val
        ClearESP()
    end)
    
    -- Close Button (Thu nhỏ thay vì tắt hẳn)
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
    
    return MenuGui, PlayerCountLabel
end

-- Tạo icon thu nhỏ có thể kéo
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
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 25)
    UICorner2.Parent = MinimizeButton
    
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
MenuGui, PlayerCountLabel = CreateMenu()
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

-- Ẩn tất cả ESP
function HideAllESP()
    for player, objects in pairs(ESPObjects) do
        if type(objects) == "table" then
            for _, obj in pairs(objects) do
                if obj and type(obj) ~= "userdata" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
        end
    end
end

-- Clear ESP hoàn toàn
function ClearESP()
    for player, objects in pairs(ESPObjects) do
        if type(objects) == "table" then
            for i, obj in pairs(objects) do
                if obj and type(obj) ~= "thread" and type(obj) ~= "userdata" then
                    pcall(function() obj:Remove() end)
                elseif type(obj) == "userdata" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
    ESPObjects = {}
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
    
    -- Tính toán vị trí
    local rootPos = HumanoidRootPart.Position
    local headPos = Head.Position
    
    -- Chiều cao từ chân đến đỉnh đầu
    local height = (headPos.Y - rootPos.Y) + 2 -- Thêm offset cho đỉnh đầu
    local width = height * 0.65 -- Tỉ lệ chiều rộng
    
    -- Vị trí trung tâm
    local centerPos = Vector3.new(rootPos.X, rootPos.Y + height/2, rootPos.Z)
    
    return {
        Center = centerPos,
        Height = height,
        Width = width,
        RootPos = rootPos,
        HeadPos = headPos + Vector3.new(0, 0.5, 0), -- Offset lên một chút
        FeetPos = rootPos - Vector3.new(0, 3, 0) -- Vị trí chân
    }
end

-- Tạo ESP cho player
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    
    local Character = Player.Character
    if not Character then return end
    
    -- Đợi character load đầy đủ
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChild("Humanoid")
    
    if not HumanoidRootPart or not Head or not Humanoid then
        -- Thử đợi thêm
        task.wait(0.5)
        Character = Player.Character
        if not Character then return end
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Head = Character:FindFirstChild("Head")
        Humanoid = Character:FindFirstChild("Humanoid")
        if not HumanoidRootPart or not Head or not Humanoid then return end
    end
    
    -- Clean up old ESP
    if ESPObjects[Player] then
        for _, obj in pairs(ESPObjects[Player]) do
            if obj and type(obj) ~= "thread" then
                pcall(function() 
                    if type(obj) == "userdata" then
                        obj:Destroy() 
                    elseif obj.Remove then
                        obj:Remove()
                    end
                end)
            end
        end
    end
    ESPObjects[Player] = {}
    
    -- Tạo Box
    local Box = nil
    if Drawing and Drawing.new then
        Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Settings.ESP.BoxColor
        Box.Thickness = Settings.ESP.BoxThickness
        Box.Transparency = Settings.ESP.BoxTransparency
        Box.Filled = false
        Box.ZIndex = 1
        table.insert(ESPObjects[Player], Box)
    end
    
    -- Tạo Tracer
    local Tracer = nil
    if Drawing and Drawing.new then
        Tracer = Drawing.new("Line")
        Tracer.Visible = false
        Tracer.Color = Settings.ESP.TracerColor
        Tracer.Thickness = Settings.ESP.TracerThickness
        Tracer.Transparency = Settings.ESP.TracerTransparency
        Tracer.ZIndex = 1
        table.insert(ESPObjects[Player], Tracer)
    end
    
    -- Tạo Name Tag
    local NameTag = nil
    if Drawing and Drawing.new then
        NameTag = Drawing.new("Text")
        NameTag.Visible = false
        NameTag.Color = Settings.ESP.NameColor
        NameTag.Size = Settings.ESP.NameSize
        NameTag.Transparency = Settings.ESP.NameTransparency
        NameTag.Center = true
        NameTag.Outline = true
        NameTag.OutlineColor = Color3.new(0, 0, 0)
        NameTag.ZIndex = 2
        table.insert(ESPObjects[Player], NameTag)
    end
    
    -- Tạo Distance Tag
    local DistanceTag = nil
    if Drawing and Drawing.new then
        DistanceTag = Drawing.new("Text")
        DistanceTag.Visible = false
        DistanceTag.Color = Settings.ESP.DistanceColor
        DistanceTag.Size = Settings.ESP.DistanceSize
        DistanceTag.Center = true
        DistanceTag.Outline = true
        DistanceTag.OutlineColor = Color3.new(0, 0, 0)
        DistanceTag.ZIndex = 2
        table.insert(ESPObjects[Player], DistanceTag)
    end
    
    -- Render Loop
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Kiểm tra ESP enabled
        if not Settings.ESP.Enabled then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- Kiểm tra player và character còn tồn tại
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
        
        -- Lấy bounds của nhân vật
        local bounds = GetCharacterBounds(currentCharacter)
        if not bounds then
            if Box then Box.Visible = false end
            return
        end
        
        -- Lấy vị trí LocalPlayer
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        local distance = localRoot and (localRoot.Position - bounds.RootPos).Magnitude or 9999
        
        -- Kiểm tra khoảng cách
        if distance > Settings.ESP.MaxDistance then
            if Box then Box.Visible = false end
            if Tracer then Tracer.Visible = false end
            if NameTag then NameTag.Visible = false end
            if DistanceTag then DistanceTag.Visible = false end
            return
        end
        
        -- Chuyển đổi sang màn hình
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
        
        -- Tính toán kích thước box
        local boxHeight = math.abs(headScreen.Y - feetScreen.Y)
        local boxWidth = boxHeight * 0.55 -- Tỉ lệ width/height
        
        -- Vẽ Box
        if Box and Settings.ESP.Box then
            Box.Size = Vector2.new(boxWidth, boxHeight)
            Box.Position = Vector2.new(centerScreen.X - boxWidth/2, feetScreen.Y - boxHeight)
            Box.Visible = true
            Box.Color = Settings.ESP.BoxColor
        end
        
        -- Vẽ Tracer
        if Tracer and Settings.ESP.Tracers then
            local viewportSize = workspace.CurrentCamera.ViewportSize
            Tracer.From = Vector2.new(viewportSize.X / 2, 
                         Settings.ESP.TracerOrigin == "Bottom" and viewportSize.Y or 0)
            Tracer.To = Vector2.new(centerScreen.X, feetScreen.Y)
            Tracer.Visible = true
            Tracer.Color = Settings.ESP.TracerColor
        end
        
        -- Vẽ tên
        if NameTag and Settings.ESP.Names then
            local displayName = Player.DisplayName or Player.Name
            NameTag.Text = displayName
            NameTag.Position = Vector2.new(centerScreen.X, headScreen.Y - 25)
            NameTag.Visible = true
            NameTag.Color = Settings.ESP.NameColor
        end
        
        -- Vẽ khoảng cách
        if DistanceTag and Settings.ESP.Distance then
            DistanceTag.Text = math.floor(distance) .. "m"
            DistanceTag.Position = Vector2.new(centerScreen.X, headScreen.Y - 8)
            DistanceTag.Visible = true
            DistanceTag.Color = Settings.ESP.DistanceColor
        end
    end)
    
    -- Lưu connection
    table.insert(ESPObjects[Player], Connection)
end

-- Player Added
local function OnPlayerAdded(Player)
    if Player == LocalPlayer then return end
    
    local function OnCharacterAdded(Character)
        task.wait(0.3) -- Đợi character load
        CreateESP(Player)
    end
    
    if Player.Character then
        OnCharacterAdded(Player.Character)
    end
    
    Player.CharacterAdded:Connect(OnCharacterAdded)
end

-- Player Removing
local function OnPlayerRemoving(Player)
    if ESPObjects[Player] then
        for _, obj in pairs(ESPObjects[Player]) do
            if obj then
                pcall(function()
                    if type(obj) == "userdata" then
                        obj:Destroy()
                    elseif type(obj) == "thread" then
                        obj:Disconnect()
                    elseif obj.Remove then
                        obj:Remove()
                    end
                end)
            end
        end
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
        
        -- Cập nhật text trên icon thu nhỏ
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

-- Hàm reconnect ESP khi player respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    -- Refresh ESP cho tất cả player
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            OnPlayerRemoving(Player)
            OnPlayerAdded(Player)
        end
    end
end)

-- Cleanup
LocalPlayer.OnTeleport:Connect(function()
    if ScreenGui then ScreenGui:Destroy() end
    ClearESP()
end)

-- Thông báo
if Drawing and Drawing.new then
    local Notif = Drawing.new("Text")
    Notif.Text = "✅ Universal ESP Loaded! [Delete] để thu nhỏ/mở menu"
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
print("Universal ESP Script Loaded!")
print("Delete = Thu nhỏ/Mở Menu")
print("Kéo icon ESP để di chuyển")
print("=================================")