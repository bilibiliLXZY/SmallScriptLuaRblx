-- local notificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/xaxas-notification/src.lua"))();

-- local function notifytext(text,rgb,dur)
-- 	local notifications = notificationLibrary.new({            
-- 		NotificationLifetime = dur, 
-- 		NotificationPosition = "Middle",

-- 		TextFont = Enum.Font.Jura,
-- 		TextColor = rgb,
-- 		TextSize = 25,

-- 		TextStrokeTransparency = 0, 
-- 		TextStrokeColor = Color3.fromRGB(0, 0, 0)
-- 	});

-- 	notifications:BuildNotificationUI();
-- 	notifications:Notify(text);
-- end
local function highlight(child,rgbcolor)
		local hl = Instance.new("Highlight",child)
		hl.Name = "highlight"
		hl.OutlineTransparency = 1
		hl.FillTransparency = 0.25
		hl.FillColor = rgbcolor
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
LocalPlayer = game:GetService("Players").LocalPlayer

-- 等待角色加载
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LHRP = Character:WaitForChild("HumanoidRootPart", 10)
local invincible = false
local invincibleLightEnabled = false -- 新增：无敌光源的开关状态

-- 创建无敌状态专用的绿色点光源
local InvincibilityLight = Instance.new("PointLight")
InvincibilityLight.Name = "Invincibility_Light"
InvincibilityLight.Range = 6 -- 范围可以比普通光源小一些
InvincibilityLight.Brightness = 3 -- 亮度可以更高以突出状态
InvincibilityLight.Color = Color3.fromRGB(50, 255, 50) -- 绿色
InvincibilityLight.Shadows = false
InvincibilityLight.Enabled = false -- 初始关闭


-- 创建点光源但初始状态为关闭
local PointLight = Instance.new("PointLight")
PointLight.Name = "Light_ESP"
PointLight.Range = 100
PointLight.Brightness = 2.25
PointLight.Shadows = false
PointLight.Enabled = false  -- 初始状态为关闭


if LHRP then 
    PointLight.Parent = LHRP 
    InvincibilityLight.Parent = LHRP
end

-- 连接按键事件
local lightEnabled = false
local noMonsters = false

local batteryy = nil

-- GUI
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 创建ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TopLeftDisplay"
screenGui.ResetOnSpawn = false  -- 防止重生时重置
screenGui.Parent = playerGui

-- 创建TextLabel
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 30)  -- 宽度200，高度30
textLabel.Position = UDim2.new(0, 10, 0, 10)  -- 左上角，偏移10像素
textLabel.Text = "" -- Invinciblity [MOUSE3]
textLabel.TextColor3 = Color3.new(1, 1, 1)  -- 白色文本
textLabel.TextSize = 15
textLabel.BackgroundTransparency = 1  -- 背景透明
textLabel.TextXAlignment = Enum.TextXAlignment.Left  -- 左对齐
textLabel.TextYAlignment = Enum.TextYAlignment.Top  -- 顶部对齐
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Parent = screenGui

local textLabela = Instance.new("TextLabel")
textLabela.Size = UDim2.new(0, 200, 0, 30)  -- 宽度200，高度30
textLabela.Position = UDim2.new(0, 10, 0, 30)  -- 左上角，偏移10像素
textLabela.Text = "" -- NoMonsters [F]
textLabela.TextColor3 = Color3.new(1, 1, 1)  -- 白色文本
textLabela.TextSize = 15
textLabela.BackgroundTransparency = 1  -- 背景透明
textLabela.TextXAlignment = Enum.TextXAlignment.Left  -- 左对齐
textLabela.TextYAlignment = Enum.TextYAlignment.Top  -- 顶部对齐
textLabela.Font = Enum.Font.SourceSansBold
textLabela.Parent = screenGui

local textLabelb = Instance.new("TextLabel")
textLabelb.Size = UDim2.new(0, 200, 0, 30)  -- 宽度200，高度30
textLabelb.Position = UDim2.new(0, 10, 0, 50)  -- 左上角，偏移10像素
textLabelb.Text = "" -- ESP [C]
textLabelb.TextColor3 = Color3.new(1, 1, 1)  -- 白色文本
textLabelb.TextSize = 15
textLabelb.BackgroundTransparency = 1  -- 背景透明
textLabelb.TextXAlignment = Enum.TextXAlignment.Left  -- 左对齐
textLabelb.TextYAlignment = Enum.TextYAlignment.Top  -- 顶部对齐
textLabelb.Font = Enum.Font.SourceSansBold
textLabelb.Parent = screenGui
local espEnabled = false;

local textLabelc = Instance.new("TextLabel")
textLabelc.Size = UDim2.new(0, 200, 0, 30)  -- 宽度200，高度30
textLabelc.Position = UDim2.new(0, 10, 0, 70)  -- 左上角，偏移10像素
textLabelc.Text = "" -- AntiA-120/A-200 [T]
textLabelc.TextColor3 = Color3.new(1, 1, 1)  -- 白色文本
textLabelc.TextSize = 15
textLabelc.BackgroundTransparency = 1  -- 背景透明
textLabelc.TextXAlignment = Enum.TextXAlignment.Left  -- 左对齐
textLabelc.TextYAlignment = Enum.TextYAlignment.Top  -- 顶部对齐
textLabelc.Font = Enum.Font.SourceSansBold
textLabelc.Parent = screenGui
local antimonster2 = false

local function createBatteryFromTemplate()
    if not batteryTemplate then
        warn("没有电池模板可用！")
        return nil
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    -- 计算脚下的位置
    local spawnPosition = humanoidRootPart.Position - Vector3.new(0, 3, 0)
    
    -- 克隆模板
    local newBattery = batteryTemplate:Clone()
    
    -- 找到电池的主部件并设置位置
    -- 方法A：假设电池模型有一个主要部件
    local mainPart = newBattery:FindFirstChildWhichIsA("BasePart")
    if mainPart then
        mainPart.Position = spawnPosition
        mainPart.Anchored = true
    else
        -- 方法B：遍历所有部件设置位置
        for _, child in ipairs(newBattery:GetChildren()) do
            if child:IsA("BasePart") then
                -- 保持原有的相对位置，只设置整体位置偏移
                local relativePosition = child.Position - (mainPart and mainPart.Position or Vector3.new(0,0,0))
                child.Position = spawnPosition + relativePosition
                child.Anchored = true
            end
        end
    end
    
    -- 将新电池放入workspace
    newBattery.Parent = workspace
    return newBattery
end
-- 监听鼠标按键（Roblox环境）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- 检测鼠标中键
    if input.KeyCode == Enum.KeyCode.Q then
        lightEnabled = not lightEnabled  -- 切换状态
        PointLight.Enabled = lightEnabled
    end
    if input.KeyCode == Enum.KeyCode.F then
        noMonsters = not noMonsters
        if noMonsters then
			textLabela.Text = "NoMonsters(Part & Buggy) [F]"
		else
			textLabela.Text = ""
		end
    end
	if input.KeyCode == Enum.KeyCode.Y then
		createBatteryAtFeet()
	end
	if input.KeyCode == Enum.KeyCode.T then
		if antimonster2 then
			textLabelc.Text = "NaNInvincibility [T]"
		else
			textLabelc.Text = ""
		end

		local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if not antimonster2 then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge + math.huge - math.huge
				humanoid.Health += 100
                antimonster2 = true
                textLabelc.Text = "NaNInvincibility [T]"
            else
                -- 恢复默认值（假设默认是100）
				if invincible then
					humanoid.MaxHealth = math.huge
					humanoid.Health = math.huge
				else
                	humanoid.MaxHealth = 100
                	humanoid.Health = 100
				end
                antimonster2 = false
                textLabelc.Text = ""
            end
        end
	end
	if input.KeyCode == Enum.KeyCode.C then
		espEnabled = not espEnabled
		if espEnabled then
			textLabelb.Text = "ESP [C]"
		else
			textLabelb.Text = ""
		end
	end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if not invincible then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                invincible = true
                invincibleLightEnabled = true -- 开启无敌光源
                InvincibilityLight.Enabled = true -- 设置无敌光源为可见
                textLabel.Text = "Invincibility [MOUSE3]"
                -- notifytext("Invincibility Enabled", Color3.fromRGB(50, 255, 50), 3)
            else
                -- 恢复默认值（假设默认是100）
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                invincible = false
                invincibleLightEnabled = false -- 关闭无敌光源
                InvincibilityLight.Enabled = false
                textLabel.Text = ""
                -- notifytext("Invincibility Disabled", Color3.fromRGB(255, 50, 50), 3)
            end
        end
    end
end)
-- 可选：添加角色重新生成时的重新连接
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    LHRP = newCharacter:WaitForChild("HumanoidRootPart", 10)
    if LHRP then
        PointLight.Parent = LHRP
        InvincibilityLight.Parent = LHRP
        InvincibilityLight.Enabled = invincibleLightEnabled;
        PointLight.Enabled = lightEnabled -- 保持之前的开关状态
    end
end)
    
workspace.ChildAdded:Connect(function(child)
	if not noMonsters then return end
	if child:IsA("Part") and child.Name == "monster" then
		wait(0.5)
		child:Destroy()
	end
end)
workspace.ChildAdded:Connect(function(child)
    if not noMonsters then return end

    if child:IsA("Part") and child.Name == "handdebris" then
		wait(2.5)
		child:Destroy() -- Maybe
	end
    if child:IsA("Part") and child.Name == "evilbunger" then
		wait(0.3)
		child:Destroy() -- Possibly Effectless
	end
    if child:IsA("Part") and child.Name == "jack" then
		wait(0.3)
		child:Destroy() -- Maybe Effectless
	end
end)
workspace.rooms.DescendantAdded:Connect(function(child)
	if child:IsA("Model") and child.Name == "jack" and espEnabled then
		if espEnabled then highlight(child.Parent,Color3.fromRGB(250, 125, 125)) end
	end
	if noMonsters then
    if child:IsA("Model") and child.Name == "evilbunger" then
		wait(0.4)
		child:Destroy() -- Possibly Effectless
	end
	end
	if child:IsA("Model") and child.Name == "battery" and espEnabled then
		highlight(child,Color3.fromRGB(255, 143, 74))
	end
	if child:IsA("Model") and child.Name == "battery" then
		batteryy = child:Clone()
	end
end)


