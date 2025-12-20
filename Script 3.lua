-- local notificationLibrary = loadstring(game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/laagginq/ui-libraries/main/xaxas-notification/src.lua"))();

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
	hl.OutlineTransparency = 0.1
	hl.FillTransparency = 0.2
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

-- 手电筒电量系统
local FlashlightSystem = {
    charge = 0,  -- 0到1之间
    isCharging = false,
    maxCharge = 1,
    chargeSpeed = 0.05,  -- 每秒充电速度
    drainSpeed = 0.3,    -- 每秒放电速度（动画）
    isDraining = false,
    flashlightOn = false
}

-- R6模型手臂控制变量
local rightArm = Character:FindFirstChild("Right Arm")
local torso = Character:FindFirstChild("Torso")
local rightShoulder = torso and torso:FindFirstChild("Right Shoulder")

local originalShoulderC0
if rightShoulder then
    originalShoulderC0 = rightShoulder.C0
end

-- UI组件
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 创建ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TopLeftDisplay"
screenGui.ResetOnSpawn = false  -- 防止重生时重置
screenGui.Parent = playerGui

-- 左上角状态文本
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

-- 手电筒电量UI
local batteryScreenGui
local batteryFrame, batteryFill, batteryBorder

-- 初始化手电筒电量UI
local function createBatteryUI()
    if batteryScreenGui then batteryScreenGui:Destroy() end
    
    batteryScreenGui = Instance.new("ScreenGui")
    batteryScreenGui.Name = "FlashlightBatteryUI"
    batteryScreenGui.ResetOnSpawn = false
    batteryScreenGui.IgnoreGuiInset = true
    batteryScreenGui.Parent = playerGui
    
    -- 边框（深灰色）
    batteryBorder = Instance.new("Frame")
    batteryBorder.Name = "BatteryBorder"
    batteryBorder.Size = UDim2.new(0, 40, 0, 100)
    batteryBorder.Position = UDim2.new(1, -60, 0, 20)  -- 右上角
    batteryBorder.AnchorPoint = Vector2.new(1, 0)
    batteryBorder.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    batteryBorder.BorderSizePixel = 2
    batteryBorder.BorderColor3 = Color3.fromRGB(30, 30, 30)
    batteryBorder.Visible = false
    batteryBorder.Parent = batteryScreenGui
    
    -- 背景（黑色）
    local batteryBackground = Instance.new("Frame")
    batteryBackground.Name = "BatteryBackground"
    batteryBackground.Size = UDim2.new(1, -4, 1, -4)
    batteryBackground.Position = UDim2.new(0, 2, 0, 2)
    batteryBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    batteryBackground.BorderSizePixel = 0
    batteryBackground.Parent = batteryBorder
    
    -- 填充（绿色，从下到上）
    batteryFill = Instance.new("Frame")
    batteryFill.Name = "BatteryFill"
    batteryFill.Size = UDim2.new(1, -4, 0, 0)  -- 高度为0开始
    batteryFill.Position = UDim2.new(0, 2, 1, -2)  -- 底部对齐
    batteryFill.AnchorPoint = Vector2.new(0, 1)
    batteryFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    batteryFill.BorderSizePixel = 0
    batteryFill.BackgroundTransparency = 0.3
    batteryFill.Parent = batteryBackground
end

-- 更新手电筒电量UI
local function updateBatteryUI()
    if not batteryFill or not FlashlightSystem.flashlightOn then return end
    
    local fillHeight = math.clamp(FlashlightSystem.charge, 0, 1)
    
    batteryFill.Size = UDim2.new(1, -4, fillHeight, 0)
    
    batteryFill.BackgroundColor3 = Color3.fromRGB(
        255 * (1 - fillHeight),  -- R: 满电时0，没电时255
        255 * fillHeight,        -- G: 满电时255，没电时0
        0
    )
end

-- R6手臂旋转到指定位置（添加动画效果）
local function rotateArmToPosition()
    if not rightShoulder then return end
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- 修正手臂旋转角度：向内旋转，使手臂靠近身体
    local targetC0 = originalShoulderC0 * CFrame.Angles(math.rad(60), 0, math.rad(40)) -- 正角度使手臂向内
    
    local shoulderTween = tweenService:Create(rightShoulder, tweenInfo, {C0 = targetC0})
    shoulderTween:Play()
end

-- R6手臂回到自然位置
local function resetArmPosition()
    if not rightShoulder then return end
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local shoulderTween = tweenService:Create(rightShoulder, tweenInfo, {C0 = originalShoulderC0})
    shoulderTween:Play()
end

-- 手摇动画（添加平滑动画效果）
local function playCrankAnimation()
    if not rightShoulder then return end
    
    FlashlightSystem.isCharging = true
    
    -- 创建动画循环
    local swingForward = true
    local swingCount = 0
    local maxSwings = 5  -- 每10次摇摆增加一次电量
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    while FlashlightSystem.isCharging and FlashlightSystem.charge < FlashlightSystem.maxCharge do
        -- R6摇摆动画：使用补间动画平滑过渡
        local targetAngle
        if swingForward then
            targetAngle = originalShoulderC0 * CFrame.Angles(math.rad(60), math.rad(10), math.rad(30))
        else
            targetAngle = originalShoulderC0 * CFrame.Angles(math.rad(60), math.rad(10), math.rad(50))
        end
        
        -- 创建并播放补间动画
        local swingTween = tweenService:Create(rightShoulder, tweenInfo, {C0 = targetAngle})
        swingTween:Play()
        
        -- 等待动画完成
        swingTween.Completed:Wait()
        
        swingForward = not swingForward
        swingCount = swingCount + 1
        
        -- 每摇摆一定次数增加电量
        if swingCount >= maxSwings then
            FlashlightSystem.charge = math.min(FlashlightSystem.charge + FlashlightSystem.chargeSpeed, FlashlightSystem.maxCharge)
            swingCount = 0
            updateBatteryUI()
        end
        
        -- 短暂暂停，让动画更自然
        task.wait(0.05)
    end
    
    -- 充满电后的处理
    if FlashlightSystem.charge >= FlashlightSystem.maxCharge then
        FlashlightSystem.charge = FlashlightSystem.maxCharge
        updateBatteryUI()
        
        -- 等待2秒
        wait(2)
        
        -- 开始缓慢放电动画
        FlashlightSystem.isDraining = true
        local startTime = tick()
        local duration = 2  -- 3秒内清空
        
        while FlashlightSystem.isDraining and FlashlightSystem.charge > 0 do
            local elapsed = tick() - startTime
            FlashlightSystem.charge = math.max(1 - (elapsed / duration), 0)
            updateBatteryUI()
            
            if FlashlightSystem.charge <= 0 then
                FlashlightSystem.charge = 0
                FlashlightSystem.isDraining = false
                FlashlightSystem.flashlightOn = false
                batteryBorder.Visible = false
                break
            end
            
            game:GetService("RunService").Heartbeat:Wait()
        end
    end
end

-- 逗号键处理
local commaKeyDown = false
local commaKeyPressedTime = 0
local longPressThreshold = 0.1  -- 长按阈值（秒）

-- 逗号键输入处理函数
local function handleCommaKeyInput()
    if not rightShoulder then return end
    
    commaKeyDown = true
    commaKeyPressedTime = tick()
    
    -- 显示电量UI
    FlashlightSystem.flashlightOn = true
    if batteryBorder then
        batteryBorder.Visible = true
    end
    
    -- 立即旋转手臂到指定位置（使用动画）
    rotateArmToPosition()
    
    -- 检测长按
    spawn(function()
        while commaKeyDown and tick() - commaKeyPressedTime < longPressThreshold do
            task.wait()
        end
        
        if commaKeyDown then
            -- 长按触发摇动动画
            playCrankAnimation()
        end
    end)
end

-- 逗号键释放处理函数
local function handleCommaKeyRelease()
    commaKeyDown = false
    
    -- 停止充电
    FlashlightSystem.isCharging = false
    
    -- 手臂回到自然位置（使用动画）
    resetArmPosition()
    
    -- 如果电量小于等于0，隐藏UI

    if FlashlightSystem.charge <= 0 then
        FlashlightSystem.flashlightOn = false
        if batteryBorder then
            batteryBorder.Visible = false
        end
    end
end

-- 从屏幕中心发射射线获取地面位置
function getGroundPositionFromScreenCenter()
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local unitRay = Camera:ViewportPointToRay(screenCenter.X, screenCenter.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    
    if raycastResult then
        -- 检查是否是地面（法线Y分量接近1）
        local groundNormal = raycastResult.Normal.Y
        if groundNormal > -0.5 then -- 至少是45度以内的斜坡
            return raycastResult.Position
        end
    end
    return nil
end

-- 删除EntityNotification相关代码，改为传送功能

-- 传送功能相关变量
local teleportEffect = Instance.new("Part")
teleportEffect.Name = "TeleportTarget"
teleportEffect.Shape = Enum.PartType.Cylinder
teleportEffect.Size = Vector3.new(0.2, 5, 5)
teleportEffect.Orientation = Vector3.new(0, 0, 90)
teleportEffect.Color = Color3.fromRGB(0, 255, 0)
teleportEffect.Material = Enum.Material.Neon
teleportEffect.Transparency = 0.3
teleportEffect.CanCollide = false
teleportEffect.Anchored = true
teleportEffect.Parent = nil

local isTeleporting = false
local teleportCooldown = false

-- 执行传送
function teleportToPosition(position)
    if not Character or not LHRP or teleportCooldown then return false end
    
    -- 冷却时间
    teleportCooldown = true
    spawn(function()
        teleportCooldown = false
    end)
    
    -- 确保位置在地面以上
    local teleportPos = position + Vector3.new(0, 3, 0)
    
    -- 执行传送
    LHRP.CFrame = CFrame.new(teleportPos)
    
    -- 传送特效
    if teleportEffect.Parent then
        teleportEffect.Transparency = 1
        wait(0.1)
        teleportEffect.Transparency = 0.3
    end
    
    return true
end

-- G键传送功能
function handleTeleport()
    if isTeleporting or teleportCooldown then return end
    
    isTeleporting = true
    
    -- 获取地面位置
    local groundPos = getGroundPositionFromScreenCenter()
    
    if groundPos then
        -- 显示传送目标
        if not teleportEffect.Parent then
            teleportEffect.Parent = workspace
        end
        teleportEffect.Position = groundPos + Vector3.new(0, 0.1, 0)
        teleportEffect.Color = Color3.fromRGB(0, 255, 0)
        
        -- 执行传送
        teleportToPosition(groundPos)
        
        -- 传送后隐藏效果
        teleportEffect.Parent = nil
    else
        -- 无效位置，显示红色效果
        local screenCenter = Camera.CFrame.Position + Camera.CFrame.LookVector * 20
        teleportEffect.Parent = workspace
        teleportEffect.Position = screenCenter
        teleportEffect.Color = Color3.fromRGB(255, 0, 0)
        
        wait(0.3)
        teleportEffect.Parent = nil
    end
    
    isTeleporting = false
end

-- 初始化手电筒电量UI
createBatteryUI()

-- 监听按键事件
local lightEnabled = false
local noMonsters = false

-- 重新获取R6手臂部件的函数
local function setupR6Arms()
    rightArm = Character:FindFirstChild("Right Arm")
    torso = Character:FindFirstChild("Torso")
    rightShoulder = torso and torso:FindFirstChild("Right Shoulder")
    
    if rightShoulder then
        originalShoulderC0 = rightShoulder.C0
    end
end

-- 初始设置R6手臂
setupR6Arms()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- 逗号键：手电筒充电
    if input.KeyCode == Enum.KeyCode.Comma then
        handleCommaKeyInput()
    end
    
    -- 检测鼠标中键
    if input.KeyCode == Enum.KeyCode.Q then
        lightEnabled = not lightEnabled  -- 切换状态
        PointLight.Enabled = lightEnabled
    end
    
    if input.KeyCode == Enum.KeyCode.G then
        noMonsters = not noMonsters
        if noMonsters then
            textLabela.Text = "NoMonsters(Part & Buggy) [G]"
        else
            textLabela.Text = ""
        end
    end
    
    -- G键改为传送功能
    if input.KeyCode == Enum.KeyCode.F then
        handleTeleport()
    end
    
    if input.KeyCode == Enum.KeyCode.T then
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

-- 监听按键释放（用于逗号键）
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Comma then
        handleCommaKeyRelease()
    end
end)

-- 角色重生时重新设置R6手臂
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    LHRP = newCharacter:WaitForChild("HumanoidRootPart", 10)
    if LHRP then
        PointLight.Parent = LHRP
        InvincibilityLight.Parent = LHRP
        InvincibilityLight.Enabled = invincibleLightEnabled;
        PointLight.Enabled = lightEnabled -- 保持之前的开关状态
    end
    
    -- 重新获取R6手臂部件
    setupR6Arms()
end)

-- 更新手电筒电量UI的循环
game:GetService("RunService").Heartbeat:Connect(function()
    if FlashlightSystem.flashlightOn and FlashlightSystem.charge > 0 then
        updateBatteryUI()
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
        wait(1.25)
        child:Destroy() -- Maybe
        local currentPosition = Camera.CFrame.Position
        local currentLookVector = Camera.CFrame.LookVector
        -- 计算当前偏航角，但重置俯仰和横滚
        local currentPitch, currentYaw, _ = Camera.CFrame:ToOrientation()
        
        -- 创建新的CFrame，只有偏航角，俯仰和横滚为0
        local newCFrame = CFrame.new(currentPosition) * 
                          CFrame.Angles(currentPitch, currentYaw, 0)
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        -- 方法1：直接禁用或移除Shaker
        local shaker = playerGui:FindFirstChild("Shaker")
        if shaker then
            -- 方法A：直接销毁（最彻底）
            shaker:Destroy()
        end
        -- 立即应用
        Camera.CFrame = newCFrame
    end
    if child:IsA("Part") and child.Name == "evilbunger" then
        wait(0.3)
        child:Destroy() -- Possibly Effectless
    end
end)
workspace.rooms.DescendantAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "jack" and espEnabled then
        if espEnabled then highlight(child.Parent,Color3.fromRGB(255, 125, 125)) end
    end
    if noMonsters then
        if child:IsA("Model") and child.Name == "evilbunger" then
            wait(0.4)
            child:Destroy() -- Possibly Effectless
        end
    end
    if child:IsA("Model") and child.Name == "battery" and espEnabled then
        highlight(child,Color3.fromRGB(255, 150, 50))
    end
end)
