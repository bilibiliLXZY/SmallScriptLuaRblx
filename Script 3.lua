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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local invincible = false
local invincibleLightEnabled = false -- 新增：无敌光源的开关状态

-- 创建无敌状态专用的绿色点光源
local InvincibilityLight = Instance.new("PointLight")
InvincibilityLight.Name = "Invincibility_Light"
InvincibilityLight.Range = 2 -- 范围可以比普通光源小一些
InvincibilityLight.Brightness = 3.125 -- 亮度可以更高以突出状态
InvincibilityLight.Color = Color3.fromRGB(50, 255, 50) -- 绿色
InvincibilityLight.Shadows = false
InvincibilityLight.Enabled = false -- 初始关闭

-- 监听鼠标按键（Roblox环境）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- 检测鼠标中键
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
                -- notifytext("Invincibility Enabled", Color3.fromRGB(50, 255, 50), 3)
            else
                -- 恢复默认值（假设默认是100）
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                invincible = false
                invincibleLightEnabled = false -- 关闭无敌光源
                InvincibilityLight.Enabled = false
                -- notifytext("Invincibility Disabled", Color3.fromRGB(255, 50, 50), 3)
            end
        end
    end
end)

local Camera = workspace.CurrentCamera
LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService") -- 添加输入服务

-- 等待角色加载
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LHRP = Character:WaitForChild("HumanoidRootPart", 10)

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
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- 如果事件被游戏处理过（如聊天框），则忽略
    if input.KeyCode == Enum.KeyCode.Q then
        lightEnabled = not lightEnabled  -- 切换状态
        PointLight.Enabled = lightEnabled
        
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








