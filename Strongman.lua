-- 📦 СЕРВИСЫ
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

-- === ПЕРЕМЕННЫЕ ===
local multiplier = 100
local cooldown = 0.2
local eggCooldown = 0
local autoTraining = false
local autoEggOpen = false
local autoSeasonSpin = true

-- === ФУНКЦИЯ: Добавление скругления
local function addCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = obj
end

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrainingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 500, 0, 440)
mainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.new(0,0,0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Active = true
mainFrame.Draggable = true
addCorner(mainFrame, 12)

local btnHolder = Instance.new("Frame", mainFrame)
btnHolder.Size = UDim2.new(1, 0, 0, 30)
btnHolder.BackgroundTransparency = 1

local tabs = {"Strength","Egg","Season","Boost"}
local tabButtons = {}
local contentFrames = {}

local function styleButton(btn)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.BackgroundTransparency = 0.2
	addCorner(btn, 8)
end

local function styleTextbox(tb)
	tb.BackgroundColor3 = Color3.fromRGB(25,25,25)
	tb.BackgroundTransparency = 0.2
	tb.TextColor3 = Color3.new(1,1,1)
	tb.TextSize = 16
	addCorner(tb, 8)
end

local function styleLabel(lbl)
	lbl.Font = Enum.Font.SourceSansBold
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.BackgroundTransparency = 1
	lbl.TextSize = 16
end

for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton", btnHolder)
	btn.Name = name .. "TabBtn"
	btn.Size = UDim2.new(0, 125, 1, 0)
	btn.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
	btn.Text = name
	styleButton(btn)
	tabButtons[name] = btn

	local frm = Instance.new("Frame", mainFrame)
	frm.Name = name .. "Tab"
	frm.Size = UDim2.new(1, 0, 1, -30)
	frm.Position = UDim2.new(0, 0, 0, 30)
	frm.BackgroundTransparency = 1
	frm.Visible = (i == 1)
	contentFrames[name] = frm

	btn.MouseButton1Click:Connect(function()
		for _, f in pairs(contentFrames) do f.Visible = false end
		frm.Visible = true
	end)
end

-- === Strength Tab ===
do
	local frm = contentFrames["Strength"]
	local y = 10
	local function newLabel(txt)
		local l = Instance.new("TextLabel", frm)
		l.Size = UDim2.new(1,-10,0,20)
		l.Position = UDim2.new(0,5,0,y); y = y + 25
		l.Text = txt
		styleLabel(l)
		return l
	end
	local function newTextbox(placeholder, default)
		local tb = Instance.new("TextBox", frm)
		tb.Size = UDim2.new(1,-10,0,25)
		tb.Position = UDim2.new(0,5,0,y); y = y + 30
		tb.PlaceholderText = placeholder
		tb.Text = default
		styleTextbox(tb)
		return tb
	end
	local function newButton(text)
		local b = Instance.new("TextButton", frm)
		b.Size = UDim2.new(1,-10,0,25)
		b.Position = UDim2.new(0,5,0,y); y = y + 35
		b.Text = text
		styleButton(b)
		return b
	end

	newLabel("Tab Strength")
	local mBox = newTextbox("Add Multiplier",""..multiplier)
	local cBox = newTextbox("Cooldown (sec)",""..cooldown)
	local trainBtn = newButton("Train (x"..multiplier..")")
	local autoBtn = newButton("AutoTrain: OFF")

	mBox.FocusLost:Connect(function()
		local v = tonumber(mBox.Text)
		if v and v>0 then multiplier=v; trainBtn.Text="Train (x"..v..")" end
		mBox.Text = tostring(multiplier)
	end)
	cBox.FocusLost:Connect(function()
		local v = tonumber(cBox.Text)
		if v and v>=0 then cooldown=v end
		cBox.Text = tostring(cooldown)
	end)
	trainBtn.MouseButton1Click:Connect(function()
		ReplicatedStorage:WaitForChild("StrongMan_UpgradeStrength")
		:InvokeServer(multiplier,"Default")
	end)
	autoBtn.MouseButton1Click:Connect(function()
		autoTraining = not autoTraining
		autoBtn.Text = "AutoTrain: "..(autoTraining and "ON" or "OFF")
	end)
end

-- === Egg Tab ===
do
	local frm = contentFrames["Egg"]
	local y = 10
	local btn = Instance.new("TextButton", frm)
	btn.Size = UDim2.new(1,-10,0,25)
	btn.Position = UDim2.new(0,5,0,y); y=y+35
	btn.Text = "AutoEgg: OFF"
	styleButton(btn)
	local tb = Instance.new("TextBox", frm)
	tb.Size = UDim2.new(1,-10,0,25)
	tb.Position = UDim2.new(0,5,0,y); y=y+35
	tb.PlaceholderText = "Egg Cooldown (sec)"
	tb.Text = tostring(eggCooldown)
	styleTextbox(tb)

	btn.MouseButton1Click:Connect(function()
		autoEggOpen = not autoEggOpen
		btn.Text = "AutoEgg: "..(autoEggOpen and "ON" or "OFF")
	end)
	tb.FocusLost:Connect(function()
		local v = tonumber(tb.Text)
		if v and v>=0 then eggCooldown=v end
		tb.Text = tostring(eggCooldown)
	end)
end

-- === Season Tab ===
do
	local frm = contentFrames["Season"]
	local y = 10
	local btn = Instance.new("TextButton", frm)
	btn.Size = UDim2.new(1,-10,0,25)
	btn.Position = UDim2.new(0,5,0,y)
	btn.Text = "AutoSeasonSpin: ON"
	styleButton(btn)
	btn.MouseButton1Click:Connect(function()
		autoSeasonSpin = not autoSeasonSpin
		btn.Text = "AutoSeasonSpin: "..(autoSeasonSpin and "ON" or "OFF")
	end)
end

-- === Boost Tab ===
do
	local frm = contentFrames["Boost"]
	local y = 10

	local btn = Instance.new("TextButton", frm)
	btn.Size = UDim2.new(1, -10, 0, 25)
	btn.Position = UDim2.new(0, 5, 0, y)
	btn.Text = "Activate Boost"
	styleButton(btn)

	local callbacks = ReplicatedStorage:WaitForChild("TGSButtonCallbacks_ServerInvoke")
	local argsList = {
		"Easter23WorkoutSpeed",
		"Easter232xMovementSpeed",
		"Easter23",
		"Christmas22",
		"Summer24",
		"Christmas22First",
		"Christmas22Second",
		"Christmas22Third",
		"Halloween23",
		"Halloween2xMovementSpeed",
		"HalloweenWorkoutSpeed",
		"100X",
		"Midsummer50X",
		"Summer50X",
		"50XSummer" -- ✅ добавлено
	}

	btn.MouseButton1Click:Connect(function()
		for _, arg in ipairs(argsList) do
			callbacks:FireServer(arg)
		end
	end)
end

-- === Циклы ===
task.spawn(function()
	while true do
		if autoTraining then
			ReplicatedStorage:WaitForChild("StrongMan_UpgradeStrength")
			:InvokeServer(multiplier,"Default")
			task.wait(cooldown)
		else task.wait(0.1) end
	end
end)

task.spawn(function()
	while true do
		if autoEggOpen then
			ReplicatedStorage:WaitForChild("TGSPetShopRoll")
			:InvokeServer("27Prison")
			task.wait(eggCooldown)
		else task.wait(0.1) end
	end
end)

task.spawn(function()
	while true do
		if autoSeasonSpin then
			ReplicatedStorage:WaitForChild("SeasonSpin_OpenRemoteCrate"):FireServer(true)
			ReplicatedStorage:WaitForChild("Crates_OpenRemoteCrate"):FireServer(true)
		end
		task.wait(0.01)
	end
end)

-- === Переключатель GUI (Круглая кнопка) ===
local toggleGui = Instance.new("ScreenGui", game.CoreGui)
toggleGui.Name = "FarmToggleGui"
toggleGui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", toggleGui)
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0,10,0.6,0)
toggleBtn.Text = "⚙️"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextSize = 20
toggleBtn.Draggable = true
toggleBtn.Active = true
addCorner(toggleBtn, 30)

toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	screenGui.Parent = game.CoreGui
	toggleGui.Parent = game.CoreGui
end)
