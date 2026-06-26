--[[
    UNIVERSAL ESP SCRIPT
    Hỗ trợ: Delta Executor
    Tính năng: ESP Box, Line, Name, Player Count, Menu Toggle
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
        BoxThickness = 1,
        Tracers = true,
        TracerColor = Color3.fromRGB(255, 255, 255),
        TracerTransparency = 1,
        TracerThickness = 1,
        TracerOrigin = "Bottom",
        Names = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameSize = 13,
        NameTransparency = 1,
        Distance = true,
        DistanceColor = Color3.fromRGB(255, 255, 255),
        DistanceSize = 12,
        ShowTeam = false,
        MaxDistance = 5000,
    },
    Menu = {
        Keybind = Enum.KeyCode.Delete,
        Visible = true
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
local function CreateMenu()
    local MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "ESPMenu"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    MenuGui.Enabled = Settings.Menu.Visible
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 250, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
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
    
    -- Player Count
    local PlayerCount = Instance.new("TextLabel")
    PlayerCount.Name = "PlayerCount"
    PlayerCount.Size = UDim2.new(1, -20, 0, 30)
    PlayerCount.Position = UDim2.new(0, 10, 0, 50)
    PlayerCount.BackgroundTransparency = 1
    PlayerCount.Text = "Players: 0"
    PlayerCount.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlayerCount.TextSize = 16
    PlayerCount.TextXAlignment = Enum.TextXAlignment.Left
    PlayerCount.Font = Enum.Font.Gotham
    PlayerCount.Parent = MainFrame
    
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
        
        return ToggleButton
    end
    
    CreateToggle("ESP Enabled", 90, Settings.ESP.Enabled, function(val)
        Settings.ESP.Enabled = val
        if not val then
            ClearESP()
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
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 60, 0, 25)
    CloseButton.Position = UDim2.new(1, -70, 0, 315)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "CLOSE"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        MenuGui.Enabled = false
        Settings.Menu.Visible = false
    end)
    
    return MenuGui, PlayerCount
end

-- Create the menu
local MenuGui, PlayerCountLabel = CreateMenu()

-- Toggle Menu Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.Menu.Keybind then
        Settings.Menu.Visible = not Settings.Menu.Visible
        MenuGui.Enabled = Settings.Menu.Visible
    end
end)

-- Clear ESP
function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj then
            obj:Destroy()
        end
    end
    ESPObjects = {}
end

-- World to Screen (Updated for modern Roblox)
local function WorldToScreen(Position)
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end
    
    local ScreenPos, OnScreen = Camera:WorldToScreenPoint(Position)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen, ScreenPos.Z
end

-- Create ESP for a player
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChild("Humanoid")
    
    if not HumanoidRootPart or not Head or not Humanoid then return end
    
    -- Clean up old ESP for this player
    if ESPObjects[Player] then
        for _, obj in pairs(ESPObjects[Player]) do
            if obj then obj:Destroy() end
        end
    end
    ESPObjects[Player] = {}
    
    -- Create Box
    if Settings.ESP.Box then
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Settings.ESP.BoxColor
        Box.Thickness = Settings.ESP.BoxThickness
        Box.Transparency = Settings.ESP.BoxTransparency
        Box.Filled = false
        table.insert(ESPObjects[Player], Box)
    end
    
    -- Create Tracers
    if Settings.ESP.Tracers then
        local Tracer = Drawing.new("Line")
        Tracer.Visible = false
        Tracer.Color = Settings.ESP.TracerColor
        Tracer.Thickness = Settings.ESP.TracerThickness
        Tracer.Transparency = Settings.ESP.TracerTransparency
        table.insert(ESPObjects[Player], Tracer)
    end
    
    -- Create Name
    if Settings.ESP.Names then
        local NameTag = Drawing.new("Text")
        NameTag.Visible = false
        NameTag.Color = Settings.ESP.NameColor
        NameTag.Size = Settings.ESP.NameSize
        NameTag.Transparency = Settings.ESP.NameTransparency
        NameTag.Center = true
        NameTag.Outline = true
        NameTag.OutlineColor = Color3.new(0, 0, 0)
        table.insert(ESPObjects[Player], NameTag)
    end
    
    -- Create Distance
    if Settings.ESP.Distance then
        local DistanceTag = Drawing.new("Text")
        DistanceTag.Visible = false
        DistanceTag.Color = Settings.ESP.DistanceColor
        DistanceTag.Size = Settings.ESP.DistanceSize
        DistanceTag.Center = true
        DistanceTag.Outline = true
        DistanceTag.OutlineColor = Color3.new(0, 0, 0)
        table.insert(ESPObjects[Player], DistanceTag)
    end
    
    -- Update ESP
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Settings.ESP.Enabled then
            if ESPObjects[Player] then
                for _, obj in pairs(ESPObjects[Player]) do
                    obj.Visible = false
                end
            end
            return
        end
        
        if not Player.Parent or not Character or not Character.Parent then
            if Connection then Connection:Disconnect() end
            if ESPObjects[Player] then
                for _, obj in pairs(ESPObjects[Player]) do
                    if obj then obj:Destroy() end
                end
                ESPObjects[Player] = nil
            end
            return
        end
        
        if Humanoid.Health <= 0 then
            if ESPObjects[Player] then
                for _, obj in pairs(ESPObjects[Player]) do
                    obj.Visible = false
                end
            end
            return
        end
        
        -- Check Team
        if not Settings.ESP.ShowTeam and Players.LocalPlayer.Team and Player.Team == Players.LocalPlayer.Team then
            if ESPObjects[Player] then
                for _, obj in pairs(ESPObjects[Player]) do
                    obj.Visible = false
                end
            end
            return
        end
        
        -- Calculate positions
        local RootPos = HumanoidRootPart.Position
        local HeadPos = Head.Position
        local ScreenPos, OnScreen, Depth = WorldToScreen(RootPos)
        local HeadScreenPos, HeadOnScreen = WorldToScreen(HeadPos + Vector3.new(0, 0.5, 0))
        
        local Distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                         (LocalPlayer.Character.HumanoidRootPart.Position - RootPos).Magnitude) or 0
        
        if not OnScreen or Depth < 0 or Distance > Settings.ESP.MaxDistance then
            if ESPObjects[Player] then
                for _, obj in pairs(ESPObjects[Player]) do
                    obj.Visible = false
                end
            end
            return
        end
        
        -- Update Box
        if Settings.ESP.Box and ESPObjects[Player][1] then
            local Box = ESPObjects[Player][1]
            local height = math.abs(HeadScreenPos.Y - ScreenPos.Y)
            local width = height / 2
            
            Box.Size = Vector2.new(width, height)
            Box.Position = Vector2.new(ScreenPos.X - width/2, ScreenPos.Y - height)
            Box.Visible = true
            Box.Color = Settings.ESP.BoxColor
        end
        
        -- Update Tracer
        if Settings.ESP.Tracers and ESPObjects[Player][2] then
            local Tracer = ESPObjects[Player][2]
            local viewportSize = workspace.CurrentCamera.ViewportSize
            
            Tracer.From = Vector2.new(viewportSize.X / 2, 
                         Settings.ESP.TracerOrigin == "Bottom" and viewportSize.Y or 0)
            Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
            Tracer.Visible = true
            Tracer.Color = Settings.ESP.TracerColor
        end
        
        -- Update Name
        if Settings.ESP.Names and ESPObjects[Player][3] then
            local NameTag = ESPObjects[Player][3]
            local displayName = Player.DisplayName ~= Player.Name and 
                               Player.DisplayName .. " (@" .. Player.Name .. ")" or 
                               Player.Name
            
            NameTag.Text = displayName
            NameTag.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - height - 20)
            NameTag.Visible = true
            NameTag.Color = Settings.ESP.NameColor
        end
        
        -- Update Distance
        if Settings.ESP.Distance and ESPObjects[Player][4] then
            local DistanceTag = ESPObjects[Player][4]
            DistanceTag.Text = "[" .. math.floor(Distance) .. "m]"
            DistanceTag.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - height - 5)
            DistanceTag.Visible = true
            DistanceTag.Color = Settings.ESP.DistanceColor
        end
    end)
    
    -- Store connection for cleanup
    table.insert(ESPObjects[Player], Connection)
end

-- Player Added
local function OnPlayerAdded(Player)
    if Player ~= LocalPlayer then
        local function OnCharacterAdded(Character)
            wait(0.5) -- Wait for character to load
            CreateESP(Player)
        end
        
        if Player.Character then
            OnCharacterAdded(Player.Character)
        end
        
        Player.CharacterAdded:Connect(OnCharacterAdded)
    end
end

-- Player Removing
local function OnPlayerRemoving(Player)
    if ESPObjects[Player] then
        for _, obj in pairs(ESPObjects[Player]) do
            if obj then 
                pcall(function() obj:Destroy() end)
            end
        end
        ESPObjects[Player] = nil
    end
end

-- Update Player Count
local function UpdatePlayerCount()
    while true do
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and 
               player.Character:FindFirstChild("Humanoid") and 
               player.Character.Humanoid.Health > 0 then
                count = count + 1
            end
        end
        PlayerCountLabel.Text = "Players: " .. count
        wait(1)
    end
end

-- Initialize
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        OnPlayerAdded(Player)
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Start player count update
coroutine.wrap(UpdatePlayerCount)()

-- Cleanup on script end
LocalPlayer.OnTeleport:Connect(function()
    ScreenGui:Destroy()
    MenuGui:Destroy()
    ClearESP()
end)

-- Notification
if Drawing and Drawing.new then
    local Notif = Drawing.new("Text")
    Notif.Text = "Universal ESP Loaded! Press Delete to toggle menu"
    Notif.Size = 20
    Notif.Color = Color3.fromRGB(0, 255, 100)
    Notif.Center = true
    Notif.Outline = true
    Notif.OutlineColor = Color3.new(0, 0, 0)
    Notif.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2 - 50)
    Notif.Visible = true
    
    task.wait(3)
    Notif:Destroy()
end

print("Universal ESP Script Loaded Successfully!")
print("Press Delete to open/close the menu")