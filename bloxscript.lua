--[[
    AlwaysLose ESP Script
    UI: Linoria Library
    Features: Box ESP, Name, Health Bar, Distance, Tracers, Skeleton, Head Dot, Weapon, Chams, Glow, Offscreen Arrows
    All fully customizable with color pickers, sliders, and toggles
]]

-- // Load Linoria UI Library
local Linoria = loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernoCollection/Linoria/main/Library.lua"))()

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // Save Manager
local Library = Linoria:Create("AlwaysLose")
local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager

-- // Default Settings
Library:SetWatermark("AlwaysLose | " .. LocalPlayer.Name)
Library:SetWatermarkVisibility(true)

-- // Tabs
local MainTab = Library:CreateTab("ESP", "Eye")

-- // ESP Settings
local ESPSettings = {
    Enabled = true,
    TeamCheck = false,
    MaxDistance = 1000,
    
    -- Box ESP
    BoxEnabled = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1.5,
    BoxType = "2D", -- 2D, Corner
    
    -- Name ESP
    NameEnabled = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,
    
    -- Health Bar
    HealthBarEnabled = true,
    HealthBarWidth = 2,
    
    -- Health Text
    HealthTextEnabled = true,
    
    -- Distance
    DistanceEnabled = true,
    DistanceColor = Color3.fromRGB(200, 200, 200),
    DistanceSize = 12,
    
    -- Tracers
    TracersEnabled = true,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 1,
    TracerOrigin = "Bottom", -- Bottom, Middle, Top
    
    -- Skeleton
    SkeletonEnabled = true,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1,
    
    -- Head Dot
    HeadDotEnabled = true,
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    HeadDotSize = 8,
    HeadDotFilled = true,
    
    -- Weapon
    WeaponEnabled = true,
    WeaponColor = Color3.fromRGB(255, 255, 255),
    WeaponSize = 12,
    
    -- Chams (Highlight)
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsTransparency = 0.5,
    ChamsVisibleOnly = false,
    
    -- Glow
    GlowEnabled = false,
    GlowColor = Color3.fromRGB(255, 0, 0),
    
    -- Snaplines
    SnaplineEnabled = true,
    SnaplineColor = Color3.fromRGB(255, 255, 255),
    SnaplineThickness = 1,
    
    -- Offscreen Arrows
    OffscreenArrowsEnabled = false,
    OffscreenArrowColor = Color3.fromRGB(255, 255, 0),
    OffscreenArrowSize = 15,
    OffscreenArrowRadius = 200,
    
    -- Visibility Check
    VisibilityCheck = false,
    VisibleColor = Color3.fromRGB(0, 255, 0),
    InvisibleColor = Color3.fromRGB(255, 255, 255),
}

-- // Load saved settings
local function LoadSettings()
    local success, saved = pcall(function()
        return readfile("alwayslose_esp_settings.json")
    end)
    if success and saved then
        local success2, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(saved)
        end)
        if success2 and data then
            for k, v in pairs(data) do
                if ESPSettings[k] ~= nil then
                    if typeof(ESPSettings[k]) == "Color3" and type(v) == "table" then
                        ESPSettings[k] = Color3.new(v.R, v.G, v.B)
                    else
                        ESPSettings[k] = v
                    end
                end
            end
        end
    end
end

local function SaveSettings()
    local data = {}
    for k, v in pairs(ESPSettings) do
        if typeof(v) == "Color3" then
            data[k] = {R = v.R, G = v.G, B = v.B}
        else
            data[k] = v
        end
    end
    pcall(function()
        writefile("alwayslose_esp_settings.json", game:GetService("HttpService"):JSONEncode(data))
    end)
end

LoadSettings()

-- // Create UI Groups

-- Main Toggles
local MainGroup = MainTab:CreateGroup("Main", "Settings")
MainGroup:AddToggle("Enabled", { Text = "ESP Enabled", Default = ESPSettings.Enabled, Tooltip = "Master toggle for all ESP" }):BindToValue("ESP_Enabled")
MainGroup:AddToggle("TeamCheck", { Text = "Team Check", Default = ESPSettings.TeamCheck, Tooltip = "Don't show teammates" }):BindToValue("ESP_TeamCheck")
MainGroup:AddToggle("VisibilityCheck", { Text = "Visibility Check", Default = ESPSettings.VisibilityCheck, Tooltip = "Different color for visible/invisible" }):BindToValue("ESP_VisibilityCheck")
MainGroup:AddSlider("MaxDistance", { Text = "Max Distance", Default = ESPSettings.MaxDistance, Min = 100, Max = 5000, Rounding = 0, Suffix = " studs" }):BindToValue("ESP_MaxDistance")

-- Box ESP
local BoxGroup = MainTab:CreateGroup("Box ESP", "Box")
BoxGroup:AddToggle("BoxEnabled", { Text = "Box ESP", Default = ESPSettings.BoxEnabled }):BindToValue("ESP_BoxEnabled")
BoxGroup:AddColorPicker("BoxColor", { Text = "Box Color", Default = ESPSettings.BoxColor }):BindToValue("ESP_BoxColor")
BoxGroup:AddSlider("BoxThickness", { Text = "Box Thickness", Default = ESPSettings.BoxThickness, Min = 0.5, Max = 5, Rounding = 1, Suffix = "px" }):BindToValue("ESP_BoxThickness")
BoxGroup:AddDropdown("BoxType", { Text = "Box Type", Default = "2D", Values = {"2D", "Corner"}, AllowNull = false }):BindToValue("ESP_BoxType")

-- Name ESP
local NameGroup = MainTab:CreateGroup("Name ESP", "User")
NameGroup:AddToggle("NameEnabled", { Text = "Name ESP", Default = ESPSettings.NameEnabled }):BindToValue("ESP_NameEnabled")
NameGroup:AddColorPicker("NameColor", { Text = "Name Color", Default = ESPSettings.NameColor }):BindToValue("ESP_NameColor")
NameGroup:AddSlider("NameSize", { Text = "Name Size", Default = ESPSettings.NameSize, Min = 8, Max = 24, Rounding = 0, Suffix = "px" }):BindToValue("ESP_NameSize")

-- Health
local HealthGroup = MainTab:CreateGroup("Health", "Heart")
HealthGroup:AddToggle("HealthBarEnabled", { Text = "Health Bar", Default = ESPSettings.HealthBarEnabled }):BindToValue("ESP_HealthBarEnabled")
HealthGroup:AddToggle("HealthTextEnabled", { Text = "Health Text", Default = ESPSettings.HealthTextEnabled }):BindToValue("ESP_HealthTextEnabled")
HealthGroup:AddSlider("HealthBarWidth", { Text = "Health Bar Width", Default = ESPSettings.HealthBarWidth, Min = 1, Max = 6, Rounding = 0, Suffix = "px" }):BindToValue("ESP_HealthBarWidth")

-- Distance
local DistanceGroup = MainTab:CreateGroup("Distance", "MapPin")
DistanceGroup:AddToggle("DistanceEnabled", { Text = "Distance ESP", Default = ESPSettings.DistanceEnabled }):BindToValue("ESP_DistanceEnabled")
DistanceGroup:AddColorPicker("DistanceColor", { Text = "Distance Color", Default = ESPSettings.DistanceColor }):BindToValue("ESP_DistanceColor")
DistanceGroup:AddSlider("DistanceSize", { Text = "Distance Size", Default = ESPSettings.DistanceSize, Min = 8, Max = 24, Rounding = 0, Suffix = "px" }):BindToValue("ESP_DistanceSize")

-- Tracers
local TracerGroup = MainTab:CreateGroup("Tracers", "ArrowUpRight")
TracerGroup:AddToggle("TracersEnabled", { Text = "Tracers", Default = ESPSettings.TracersEnabled }):BindToValue("ESP_TracersEnabled")
TracerGroup:AddColorPicker("TracerColor", { Text = "Tracer Color", Default = ESPSettings.TracerColor }):BindToValue("ESP_TracerColor")
TracerGroup:AddSlider("TracerThickness", { Text = "Tracer Thickness", Default = ESPSettings.TracerThickness, Min = 0.5, Max = 4, Rounding = 1, Suffix = "px" }):BindToValue("ESP_TracerThickness")
TracerGroup:AddDropdown("TracerOrigin", { Text = "Tracer Origin", Default = "Bottom", Values = {"Bottom", "Middle", "Top"}, AllowNull = false }):BindToValue("ESP_TracerOrigin")

-- Skeleton
local SkeletonGroup = MainTab:CreateGroup("Skeleton", "GitBranch")
SkeletonGroup:AddToggle("SkeletonEnabled", { Text = "Skeleton ESP", Default = ESPSettings.SkeletonEnabled }):BindToValue("ESP_SkeletonEnabled")
SkeletonGroup:AddColorPicker("SkeletonColor", { Text = "Skeleton Color", Default = ESPSettings.SkeletonColor }):BindToValue("ESP_SkeletonColor")
SkeletonGroup:AddSlider("SkeletonThickness", { Text = "Skeleton Thickness", Default = ESPSettings.SkeletonThickness, Min = 0.5, Max = 4, Rounding = 1, Suffix = "px" }):BindToValue("ESP_SkeletonThickness")

-- Head Dot
local HeadDotGroup = MainTab:CreateGroup("Head Dot", "Circle")
HeadDotGroup:AddToggle("HeadDotEnabled", { Text = "Head Dot", Default = ESPSettings.HeadDotEnabled }):BindToValue("ESP_HeadDotEnabled")
HeadDotGroup:AddColorPicker("HeadDotColor", { Text = "Head Dot Color", Default = ESPSettings.HeadDotColor }):BindToValue("ESP_HeadDotColor")
HeadDotGroup:AddSlider("HeadDotSize", { Text = "Head Dot Size", Default = ESPSettings.HeadDotSize, Min = 3, Max = 20, Rounding = 0, Suffix = "px" }):BindToValue("ESP_HeadDotSize")
HeadDotGroup:AddToggle("HeadDotFilled", { Text = "Filled", Default = ESPSettings.HeadDotFilled }):BindToValue("ESP_HeadDotFilled")

-- Weapon
local WeaponGroup = MainTab:CreateGroup("Weapon", "Crosshair")
WeaponGroup:AddToggle("WeaponEnabled", { Text = "Weapon ESP", Default = ESPSettings.WeaponEnabled }):BindToValue("ESP_WeaponEnabled")
WeaponGroup:AddColorPicker("WeaponColor", { Text = "Weapon Color", Default = ESPSettings.WeaponColor }):BindToValue("ESP_WeaponColor")
WeaponGroup:AddSlider("WeaponSize", { Text = "Weapon Text Size", Default = ESPSettings.WeaponSize, Min = 8, Max = 20, Rounding = 0, Suffix = "px" }):BindToValue("ESP_WeaponSize")

-- Snaplines
local SnaplineGroup = MainTab:CreateGroup("Snaplines", "ArrowDown")
SnaplineGroup:AddToggle("SnaplineEnabled", { Text = "Snaplines", Default = ESPSettings.SnaplineEnabled }):BindToValue("ESP_SnaplineEnabled")
SnaplineGroup:AddColorPicker("SnaplineColor", { Text = "Snapline Color", Default = ESPSettings.SnaplineColor }):BindToValue("ESP_SnaplineColor")
SnaplineGroup:AddSlider("SnaplineThickness", { Text = "Snapline Thickness", Default = ESPSettings.SnaplineThickness, Min = 0.5, Max = 4, Rounding = 1, Suffix = "px" }):BindToValue("ESP_SnaplineThickness")

-- Chams
local ChamsGroup = MainTab:CreateGroup("Chams", "Layers")
ChamsGroup:AddToggle("ChamsEnabled", { Text = "Chams (Highlight)", Default = ESPSettings.ChamsEnabled }):BindToValue("ESP_ChamsEnabled")
ChamsGroup:AddColorPicker("ChamsColor", { Text = "Chams Color", Default = ESPSettings.ChamsColor }):BindToValue("ESP_ChamsColor")
ChamsGroup:AddSlider("ChamsTransparency", { Text = "Chams Transparency", Default = ESPSettings.ChamsTransparency, Min = 0, Max = 1, Rounding = 2, Suffix = "" }):BindToValue("ESP_ChamsTransparency")
ChamsGroup:AddToggle("ChamsVisibleOnly", { Text = "Visible Only", Default = ESPSettings.ChamsVisibleOnly }):BindToValue("ESP_ChamsVisibleOnly")

-- Glow
local GlowGroup = MainTab:CreateGroup("Glow", "Sun")
GlowGroup:AddToggle("GlowEnabled", { Text = "Glow ESP", Default = ESPSettings.GlowEnabled }):BindToValue("ESP_GlowEnabled")
GlowGroup:AddColorPicker("GlowColor", { Text = "Glow Color", Default = ESPSettings.GlowColor }):BindToValue("ESP_GlowColor")

-- Offscreen Arrows
local ArrowGroup = MainTab:CreateGroup("Offscreen Arrows", "Navigation")
ArrowGroup:AddToggle("OffscreenArrowsEnabled", { Text = "Offscreen Arrows", Default = ESPSettings.OffscreenArrowsEnabled }):BindToValue("ESP_OffscreenArrowsEnabled")
ArrowGroup:AddColorPicker("OffscreenArrowColor", { Text = "Arrow Color", Default = ESPSettings.OffscreenArrowColor }):BindToValue("ESP_OffscreenArrowColor")
ArrowGroup:AddSlider("OffscreenArrowSize", { Text = "Arrow Size", Default = ESPSettings.OffscreenArrowSize, Min = 8, Max = 30, Rounding = 0, Suffix = "px" }):BindToValue("ESP_OffscreenArrowSize")
ArrowGroup:AddSlider("OffscreenArrowRadius", { Text = "Arrow Radius", Default = ESPSettings.OffscreenArrowRadius, Min = 50, Max = 400, Rounding = 0, Suffix = "px" }):BindToValue("ESP_OffscreenArrowRadius")

-- Visibility Colors
local VisGroup = MainTab:CreateGroup("Visibility Colors", "Eye")
VisGroup:AddColorPicker("VisibleColor", { Text = "Visible Color", Default = ESPSettings.VisibleColor }):BindToValue("ESP_VisibleColor")
VisGroup:AddColorPicker("InvisibleColor", { Text = "Hidden Color", Default = ESPSettings.InvisibleColor }):BindToValue("ESP_InvisibleColor")

-- // Settings Tab
local SettingsTab = Library:CreateTab("Settings", "Settings")
local SettingsGroup = SettingsTab:CreateGroup("Config", "Save")

SettingsGroup:AddButton("Save Config", function()
    for k, _ in pairs(ESPSettings) do
        local val = Library.Flags["ESP_" .. k]
        if val ~= nil then
            ESPSettings[k] = val
        end
    end
    SaveSettings()
    Library:Notify("Config saved!", 2)
end)

SettingsGroup:AddButton("Load Config", function()
    LoadSettings()
    for k, v in pairs(ESPSettings) do
        if Library.Flags["ESP_" .. k] ~= nil then
            Library.Flags["ESP_" .. k] = v
        end
    end
    Library:Notify("Config loaded!", 2)
end)

-- // Theme
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("AlwaysLose")
SaveManager:BuildConfigSection(SettingsTab)

-- // Hook values for performance
local Flags = Library.Flags

-- // Drawing
local Drawing = {}
local DrawCache = {}

-- Create a drawing object
function Drawing.new(type)
    local obj = Drawing.new(type) or Instance.new("Frame")
    -- We'll use the actual Drawing library from the executor
    return obj
end

-- // ESP Helper Functions

-- Get team of a player (works with most Roblox FPS games)
local function GetTeam(player)
    if player.Team then
        return player.Team
    end
    -- Alternative: check for Team folder/attribute
    local teamFolder = workspace:FindFirstChild("Teams") or workspace:FindFirstChild("Team")
    if teamFolder then
        for _, team in ipairs(teamFolder:GetChildren()) do
            if team:IsA("Folder") or team:IsA("Team") then
                -- Check if player character is parented under team folder
            end
        end
    end
    -- Fallback: Player.TeamColor
    if player.TeamColor then
        return player.TeamColor
    end
    return nil
end

local function IsTeammate(player)
    if not ESPSettings.TeamCheck then return false end
    local lpTeam = GetTeam(LocalPlayer)
    local pTeam = GetTeam(player)
    if lpTeam and pTeam then
        return lpTeam == pTeam
    end
    return false
end

local function IsPlayerVisible(character)
    if not ESPSettings.VisibilityCheck then return nil end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    local origin = Camera.CFrame.Position
    local target = head.Position
    local ray = Ray.new(origin, (target - origin).Unit * ESPSettings.MaxDistance)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character}, false, true)
    if hit then
        -- Check if hit is part of the character
        return hit:IsDescendantOf(character)
    end
    return false
end

local function WorldToScreen(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetBoundingBox(character)
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not (head and hrp) then return nil end
    
    local headPos = head.Position
    local height = (headPos - hrp.Position).Magnitude
    
    local top = headPos + Vector3.new(0, 0.5, 0)
    local bottom = hrp.Position - Vector3.new(0, height * 0.5, 0)
    
    local topScreen, topOnScreen = WorldToScreen(top)
    local bottomScreen, bottomOnScreen = WorldToScreen(bottom)
    
    local width = (topScreen - bottomScreen).Magnitude * 0.35
    
    return {
        Top = topScreen,
        Bottom = bottomScreen,
        Width = width,
        Height = (bottomScreen.Y - topScreen.Y),
        OnScreen = topOnScreen and bottomOnScreen,
        HeadPos = headPos,
        RootPos = hrp.Position,
    }
end

-- Skeleton bone pairs
local SkeletonBones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

-- // ESP Drawing Functions

-- Storage for persistent drawings
local ESPDrawings = {}
local ChamsCache = {}

-- Cleanup function
local function ClearDrawings()
    for _, drawing in ipairs(ESPDrawings) do
        pcall(function() drawing:Remove() end)
    end
    ESPDrawings = {}
    
    for _, highlight in ipairs(ChamsCache) do
        pcall(function() highlight:Destroy() end)
    end
    ChamsCache = {}
end

-- Create a drawing line
local function CreateLine(from, to, color, thickness)
    local line = Drawing.new("Line")
    line.From = from
    line.To = to
    line.Color = color
    line.Thickness = thickness
    line.Visible = true
    table.insert(ESPDrawings, line)
    return line
end

-- Create a drawing text
local function CreateText(text, position, color, size, center, outline)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Position = position
    txt.Color = color
    txt.Size = size
    txt.Center = center or false
    txt.Outline = outline or true
    txt.Visible = true
    table.insert(ESPDrawings, txt)
    return txt
end

-- Create a square/box
local function CreateSquare(position, size, color, thickness, filled)
    local sq = Drawing.new("Square")
    sq.Position = position
    sq.Size = size
    sq.Color = color
    sq.Thickness = thickness
    sq.Filled = filled or false
    sq.Visible = true
    table.insert(ESPDrawings, sq)
    return sq
end

-- Create a circle
local function CreateCircle(position, radius, color, thickness, filled)
    local circle = Drawing.new("Circle")
    circle.Position = position
    circle.Radius = radius
    circle.Color = color
    circle.Thickness = thickness
    circle.Filled = filled or false
    circle.Visible = true
    table.insert(ESPDrawings, circle)
    return circle
end

-- Create a triangle (for offscreen arrows)
local function CreateTriangle(p1, p2, p3, color, thickness, filled)
    local tri = Drawing.new("Triangle")
    tri.PointA = p1
    tri.PointB = p2
    tri.PointC = p3
    tri.Color = color
    tri.Thickness = thickness
    tri.Filled = filled or false
    tri.Visible = true
    table.insert(ESPDrawings, tri)
    return tri
end

-- Get ESP color based on visibility
local function GetESPColor(baseColor, isVisible)
    if not ESPSettings.VisibilityCheck then return baseColor end
    if isVisible == nil then return baseColor end
    return isVisible and ESPSettings.VisibleColor or ESPSettings.InvisibleColor
end

-- Get tracer origin position on screen
local function GetTracerOrigin()
    local viewportSize = Camera.ViewportSize
    if ESPSettings.TracerOrigin == "Bottom" then
        return Vector2.new(viewportSize.X / 2, viewportSize.Y)
    elseif ESPSettings.TracerOrigin == "Middle" then
        return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    else -- Top
        return Vector2.new(viewportSize.X / 2, 0)
    end
end

-- Get health color (green to red)
local function HealthColor(health)
    if health > 50 then
        return Color3.fromRGB(255 - (health - 50) * 5.1, 255, 0)
    else
        return Color3.fromRGB(255, health * 5.1, 0)
    end
end

-- Get weapon name
local function GetWeaponName(character)
    local tool = nil
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            tool = child
            break
        end
    end
    if tool then
        return tool.Name
    end
    return ""
end

-- // Main ESP Render Loop
local function RenderESP()
    ClearDrawings()
    
    if not Flags.ESP_Enabled then return end
    
    -- Update settings from flags
    for k, _ in pairs(ESPSettings) do
        local val = Flags["ESP_" .. k]
        if val ~= nil then
            ESPSettings[k] = val
        end
    end
    
    local players = Players:GetPlayers()
    local origin = GetTracerOrigin()
    local viewportSize = Camera.ViewportSize
    
    for _, player in ipairs(players) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        -- Team check
        if IsTeammate(player) then continue end
        
        local box = GetBoundingBox(character)
        if not box then continue end
        
        -- Distance check
        local distance = (box.RootPos - Camera.CFrame.Position).Magnitude
        if distance > ESPSettings.MaxDistance then continue end
        
        -- Visibility check
        local isVisible = IsPlayerVisible(character)
        
        -- Skip offscreen players for most ESP (except offscreen arrows)
        local skipESP = not box.OnScreen
        
        -- === Box ESP ===
        if ESPSettings.BoxEnabled and not skipESP then
            local boxColor = GetESPColor(Flags.ESP_BoxColor, isVisible)
            local thickness = Flags.ESP_BoxThickness
            
            if Flags.ESP_BoxType == "2D" then
                -- Full rectangle
                CreateSquare(
                    Vector2.new(box.Top.X - box.Width / 2, box.Top.Y),
                    Vector2.new(box.Width, box.Height),
                    boxColor,
                    thickness,
                    false
                )
            else
                -- Corner boxes
                local cornerLen = box.Height * 0.25
                local w2 = box.Width / 2
                local x, y = box.Top.X, box.Top.Y
                local x2, y2 = box.Bottom.X, box.Bottom.Y
                
                -- Top-left corner
                CreateLine(Vector2.new(x - w2, y), Vector2.new(x - w2, y + cornerLen), boxColor, thickness)
                CreateLine(Vector2.new(x - w2, y), Vector2.new(x - w2 + cornerLen, y), boxColor, thickness)
                
                -- Top-right corner
                CreateLine(Vector2.new(x + w2, y), Vector2.new(x + w2, y + cornerLen), boxColor, thickness)
                CreateLine(Vector2.new(x + w2, y), Vector2.new(x + w2 - cornerLen, y), boxColor, thickness)
                
                -- Bottom-left corner
                CreateLine(Vector2.new(x - w2, y2), Vector2.new(x - w2, y2 - cornerLen), boxColor, thickness)
                CreateLine(Vector2.new(x - w2, y2), Vector2.new(x - w2 + cornerLen, y2), boxColor, thickness)
                
                -- Bottom-right corner
                CreateLine(Vector2.new(x + w2, y2), Vector2.new(x + w2, y2 - cornerLen), boxColor, thickness)
                CreateLine(Vector2.new(x + w2, y2), Vector2.new(x + w2 - cornerLen, y2), boxColor, thickness)
            end
        end
        
        -- === Name ESP ===
        if ESPSettings.NameEnabled and not skipESP then
            local nameColor = GetESPColor(Flags.ESP_NameColor, isVisible)
            CreateText(
                player.Name,
                Vector2.new(box.Top.X, box.Top.Y - 16),
                nameColor,
                Flags.ESP_NameSize,
                true,
                true
            )
        end
        
        -- === Health Bar ===
        if ESPSettings.HealthBarEnabled and not skipESP then
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local healthPercent = math.clamp(health / maxHealth, 0, 1)
            local barHeight = box.Height * healthPercent
            local barX = box.Top.X - box.Width / 2 - Flags.ESP_HealthBarWidth - 2
            local barY = box.Bottom.Y - barHeight
            local barColor = HealthColor(healthPercent * 100)
            
            -- Background (black)
            CreateSquare(
                Vector2.new(barX, box.Top.Y),
                Vector2.new(Flags.ESP_HealthBarWidth, box.Height),
                Color3.new(0, 0, 0),
                1,
                true
            )
            
            -- Health fill
            CreateSquare(
                Vector2.new(barX, barY),
                Vector2.new(Flags.ESP_HealthBarWidth, barHeight),
                barColor,
                0,
                true
            )
        end
        
        -- === Health Text ===
        if ESPSettings.HealthTextEnabled and not skipESP then
            local health = math.floor(humanoid.Health)
            local barOffset = ESPSettings.HealthBarEnabled and (Flags.ESP_HealthBarWidth + 6) or 2
            CreateText(
                tostring(health) .. " HP",
                Vector2.new(box.Top.X - box.Width / 2 - barOffset, box.Bottom.Y + 2),
                HealthColor(humanoid.Health / humanoid.MaxHealth * 100),
                11,
                false,
                true
            )
        end
        
        -- === Distance ESP ===
        if ESPSettings.DistanceEnabled and not skipESP then
            local distColor = GetESPColor(Flags.ESP_DistanceColor, isVisible)
            CreateText(
                string.format("%.0f studs", distance),
                Vector2.new(box.Top.X, box.Bottom.Y + 2),
                distColor,
                Flags.ESP_DistanceSize,
                true,
                true
            )
        end
        
        -- === Weapon ESP ===
        if ESPSettings.WeaponEnabled and not skipESP then
            local weaponName = GetWeaponName(character)
            if weaponName ~= "" then
                local weaponColor = GetESPColor(Flags.ESP_WeaponColor, isVisible)
                local yOffset = ESPSettings.DistanceEnabled and (Flags.ESP_DistanceSize + 4) or 2
                CreateText(
                    weaponName,
                    Vector2.new(box.Top.X, box.Bottom.Y + yOffset),
                    weaponColor,
                    Flags.ESP_WeaponSize,
                    true,
                    true
                )
            end
        end
        
        -- === Tracers ===
        if ESPSettings.TracersEnabled and not skipESP then
            local tracerColor = GetESPColor(Flags.ESP_TracerColor, isVisible)
            local targetPos = box.Bottom
            if ESPSettings.TracerOrigin == "Top" then
                targetPos = box.Top
            elseif ESPSettings.TracerOrigin == "Middle" then
                targetPos = Vector2.new(box.Top.X, box.Top.Y + box.Height / 2)
            end
            CreateLine(origin, targetPos, tracerColor, Flags.ESP_TracerThickness)
        end
        
        -- === Snaplines ===
        if ESPSettings.SnaplineEnabled and not skipESP then
            local lineColor = GetESPColor(Flags.ESP_SnaplineColor, isVisible)
            CreateLine(
                Vector2.new(viewportSize.X / 2, viewportSize.Y),
                box.Bottom,
                lineColor,
                Flags.ESP_SnaplineThickness
            )
        end
        
        -- === Head Dot ===
        if ESPSettings.HeadDotEnabled and not skipESP then
            local headScreen, headOnScreen = WorldToScreen(box.HeadPos + Vector3.new(0, 0.3, 0))
            if headOnScreen then
                local dotColor = GetESPColor(Flags.ESP_HeadDotColor, isVisible)
                CreateCircle(
                    headScreen,
                    Flags.ESP_HeadDotSize / 2,
                    dotColor,
                    1,
                    Flags.ESP_HeadDotFilled
                )
            end
        end
        
        -- === Skeleton ESP ===
        if ESPSettings.SkeletonEnabled then
            local skelColor = GetESPColor(Flags.ESP_SkeletonColor, isVisible)
            for _, bonePair in ipairs(SkeletonBones) do
                local part1 = character:FindFirstChild(bonePair[1])
                local part2 = character:FindFirstChild(bonePair[2])
                if part1 and part2 then
                    local pos1, on1 = WorldToScreen(part1.Position)
                    local pos2, on2 = WorldToScreen(part2.Position)
                    if on1 and on2 then
                        CreateLine(pos1, pos2, skelColor, Flags.ESP_SkeletonThickness)
                    end
                end
            end
        end
        
        -- === Offscreen Arrows ===
        if ESPSettings.OffscreenArrowsEnabled and box.OnScreen == false then
            local targetPos = box.RootPos
            local screenPos, _, _ = WorldToScreen(targetPos)
            
            local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            local arrowRadius = Flags.ESP_OffscreenArrowRadius
            local arrowSize = Flags.ESP_OffscreenArrowSize
            
            -- Calculate arrow position on circle
            local direction = (screenPos - center).Unit
            local arrowPos = center + direction * arrowRadius
            
            -- Calculate perpendicular for triangle base
            local perp = Vector2.new(-direction.Y, direction.X)
            
            -- Arrow triangle points
            local tip = arrowPos + direction * arrowSize
            local left = arrowPos - direction * (arrowSize * 0.5) + perp * (arrowSize * 0.5)
            local right = arrowPos - direction * (arrowSize * 0.5) - perp * (arrowSize * 0.5)
            
            CreateTriangle(tip, left, right, Flags.ESP_OffscreenArrowColor, 1, true)
        end
    end
end

-- === Glow ESP ===
local function UpdateGlow()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        if not Flags.ESP_Enabled or not Flags.ESP_GlowEnabled then
            -- Remove existing glow
            local existingGlow = character:FindFirstChild("ESP_Glow")
            if existingGlow then existingGlow:Destroy() end
            continue
        end
        
        if IsTeammate(player) then
            local existingGlow = character:FindFirstChild("ESP_Glow")
            if existingGlow then existingGlow:Destroy() end
            continue
        end
        
        -- Apply glow via Highlight
        local highlight = character:FindFirstChild("ESP_Glow")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Glow"
            highlight.Parent = character
        end
        highlight.FillColor = Flags.ESP_GlowColor
        highlight.OutlineColor = Flags.ESP_GlowColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
    end
end

-- === Chams (Highlight) ===
local function UpdateChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        if not Flags.ESP_Enabled or not Flags.ESP_ChamsEnabled then
            local existing = character:FindFirstChild("ESP_Chams")
            if existing then existing:Destroy() end
            continue
        end
        
        if IsTeammate(player) then
            local existing = character:FindFirstChild("ESP_Chams")
            if existing then existing:Destroy() end
            continue
        end
        
        local highlight = character:FindFirstChild("ESP_Chams")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Chams"
            highlight.Parent = character
        end
        highlight.FillColor = Flags.ESP_ChamsColor
        highlight.OutlineColor = Flags.ESP_ChamsColor
        highlight.FillTransparency = Flags.ESP_ChamsTransparency
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
    end
end

-- // Main loop
RunService.RenderStepped:Connect(function()
    RenderESP()
end)

-- Glow & Chams update (less frequent = better performance)
task.spawn(function()
    while task.wait(0.5) do
        if Flags.ESP_GlowEnabled then
            UpdateGlow()
        end
        if Flags.ESP_ChamsEnabled then
            UpdateChams()
        end
    end
end)

-- // Unload handler
local function Unload()
    ClearDrawings()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local glow = character:FindFirstChild("ESP_Glow")
            if glow then glow:Destroy() end
            local chams = character:FindFirstChild("ESP_Chams")
            if chams then chams:Destroy() end
        end
    end
    SaveSettings()
    Library:Unload()
end

Library:SetUnloadCallback(Unload)

-- // Keybind to toggle UI
Library:SetKeybind(Enum.KeyCode.RightShift)

-- // Auto-load
Library:Notify("AlwaysLose Loaded! | Right Shift to toggle", 5)

-- Notify about available features
Library:Notify("ESP: Box | Name | Health | Distance | Tracers | Skeleton | Head Dot | Weapon | Snaplines | Chams | Glow | Offscreen Arrows", 8)
