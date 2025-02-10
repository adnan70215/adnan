-- خدمات Roblox الأساسية
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- إعدادات السكربت
local AIM_ASSIST_RANGE = 300  -- زيادة نطاق التصويب التلقائي لجعله أكثر قوة
local defaultWalkSpeed = 16
local sprintSpeed = 45  -- سرعة الجري ثابتة عند 45
local isESPEnabled = false
local isAimbotEnabled = false
local isSprintEnabled = false
local isAimbotActive = false

-- حماية قوية ضد الكشف
local function protectScript()
    local success, err = pcall(function()
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        local antiDetect = Instance.new("ScreenGui")
        antiDetect.Name = HttpService:GenerateGUID(false)
        antiDetect.DisplayOrder = 2147483647
        antiDetect.ResetOnSpawn = false
        antiDetect.Parent = game.CoreGui
    end)
    if not success then
        warn("Failed to apply anti-detect protection: " .. tostring(err))
    end
end
protectScript()

-- حماية ديناميكية
local function dynamicProtection()
    while true do
        local success, err = pcall(function()
            for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
                conn:Disable()
            end
            if not game.CoreGui:FindFirstChild("RobloxGui") then
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end
        end)
        if not success then
            warn("Dynamic protection failed: " .. tostring(err))
        end
        wait(1)
    end
end
spawn(dynamicProtection)

-- إنشاء واجهة المستخدم (UI) الاحترافية
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui
screenGui.ResetOnSpawn = false

-- خلفية الواجهة
local background = Instance.new("Frame")
background.Size = UDim2.new(0, 300, 0, 450)
background.Position = UDim2.new(0, 20, 0, 20)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.BackgroundTransparency = 0.2
background.BorderSizePixel = 0
background.ZIndex = 10
background.Parent = screenGui

-- شريط العنوان
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = background

-- عنوان الـ UI
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "Roblox Cheat Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- زر الإغلاق
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 50)
closeButton.Position = UDim2.new(1, -50, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.SourceSansBold
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

-- صندوق التحكم (محتويات)
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(1, 0, 1, -50)
controlFrame.Position = UDim2.new(0, 0, 0, 50)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = background

-- زر Toggle ESP
local espToggleButton = Instance.new("TextButton")
espToggleButton.Size = UDim2.new(0, 260, 0, 50)
espToggleButton.Position = UDim2.new(0, 20, 0, 20)
espToggleButton.Text = "Toggle ESP (Off)"
espToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleButton.TextSize = 18
espToggleButton.Font = Enum.Font.SourceSans
espToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espToggleButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
espToggleButton.BorderSizePixel = 2
espToggleButton.Parent = controlFrame

-- زر Toggle Aimbot
local aimbotToggleButton = Instance.new("TextButton")
aimbotToggleButton.Size = UDim2.new(0, 260, 0, 50)
aimbotToggleButton.Position = UDim2.new(0, 20, 0, 90)
aimbotToggleButton.Text = "Toggle Aimbot (Off)"
aimbotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotToggleButton.TextSize = 18
aimbotToggleButton.Font = Enum.Font.SourceSans
aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimbotToggleButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
aimbotToggleButton.BorderSizePixel = 2
aimbotToggleButton.Parent = controlFrame

-- زر Toggle Sprint
local sprintToggleButton = Instance.new("TextButton")
sprintToggleButton.Size = UDim2.new(0, 260, 0, 50)
sprintToggleButton.Position = UDim2.new(0, 20, 0, 160)
sprintToggleButton.Text = "Toggle Sprint (Off)"
sprintToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintToggleButton.TextSize = 18
sprintToggleButton.Font = Enum.Font.SourceSans
sprintToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sprintToggleButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
sprintToggleButton.BorderSizePixel = 2
sprintToggleButton.Parent = controlFrame

-- إنشاء إطار واحد فقط للـ ESP
local function createESP(character)
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Name = "ESPBox"
    espBox.Adornee = character:FindFirstChild("HumanoidRootPart")
    espBox.Size = Vector3.new(4, 7, 4)
    espBox.Color3 = Color3.fromRGB(255, 0, 0)
    espBox.Transparency = 0.5
    espBox.AlwaysOnTop = true
    espBox.ZIndex = 1
    espBox.Parent = character
end

-- وظيفة تحسين التصويب (Aimbot قوي)
local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = AIM_ASSIST_RANGE
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0 then
                local screenPosition, onScreen = Camera:WorldToScreenPoint(character.HumanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestEnemy = character.HumanoidRootPart
                    end
                end
            end
        end
    end
    return closestEnemy
end

-- تحديث التصويب نحو العدو الأقرب (دقيق)
local function updateAim()
    if isAimbotActive then
        local target = getClosestEnemy()
        if target then
            local screenPosition, onScreen = Camera:WorldToScreenPoint(target.Position)
            if onScreen then
                mousemoverel((screenPosition.X - Mouse.X) / 2, (screenPosition.Y - Mouse.Y) / 2)  -- زيادة دقة التصويب
            end
        end
    end
end

-- وظيفة ESP مع تفاصيل دقيقة
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0 then
                if not character:FindFirstChild("ESPBox") then
                    createESP(character)
                end
            else
                if character:FindFirstChild("ESPBox") then
                    character:FindFirstChild("ESPBox"):Destroy()
                end
            end
        end
    end
end

-- تفعيل/تعطيل ESP
espToggleButton.MouseButton1Click:Connect(function()
    isESPEnabled = not isESPEnabled
    if isESPEnabled then
        espToggleButton.Text = "Toggle ESP (On)"
        espToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        espToggleButton.Text = "Toggle ESP (Off)"
        espToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        for _, player in pairs(Players:GetPlayers()) do
            local character = player.Character
            if character and character:FindFirstChild("ESPBox") then
                character:FindFirstChild("ESPBox"):Destroy()
            end
        end
    end
end)

-- تفعيل/تعطيل Aimbot
aimbotToggleButton.MouseButton1Click:Connect(function()
    isAimbotEnabled = not isAimbotEnabled
    if isAimbotEnabled then
        aimbotToggleButton.Text = "Toggle Aimbot (On)"
        aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        aimbotToggleButton.Text = "Toggle Aimbot (Off)"
        aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- تفعيل/تعطيل Sprint
sprintToggleButton.MouseButton1Click:Connect(function()
    isSprintEnabled = not isSprintEnabled
    if isSprintEnabled then
        sprintToggleButton.Text = "Toggle Sprint (On)"
        sprintToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        LocalPlayer.Character.Humanoid.WalkSpeed = sprintSpeed
    else
        sprintToggleButton.Text = "Toggle Sprint (Off)"
        sprintToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        LocalPlayer.Character.Humanoid.WalkSpeed = defaultWalkSpeed
    end
end)

-- تشغيل الوظائف الأساسية
RunService.RenderStepped:Connect(function()
    if isAimbotActive then
        updateAim()
    end
    
    if isESPEnabled then
        updateESP()
    end
end)

-- وظيفة الجري السريع
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift and isSprintEnabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = sprintSpeed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift and isSprintEnabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = defaultWalkSpeed
    end
end)

-- تفعيل/تعطيل Aimbot بالزر الأيمن للماوس
Mouse.Button2Down:Connect(function()
    if isAimbotEnabled then
        isAimbotActive = true
    end
end)

Mouse.Button2Up:Connect(function()
    if isAimbotEnabled then
        isAimbotActive = false
    end
end)

-- وظيفة تحريك واجهة المستخدم
local dragging = false
local dragInput, mousePos, framePos

background.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = background.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

background.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        background.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- إغلاق واجهة المستخدم
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)