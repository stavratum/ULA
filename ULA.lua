if not game:IsLoaded() then game.Loaded:Wait() end

xpcall(
	function() _G:quit() end,
	function() _G.connections = {} end
)

local RGB = {}
local H = 0

local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local X = Mouse.ViewSizeX
local Y = Mouse.ViewSizeY

local Instance = Instance.new
local Vector2 = Vector2.new
local UDim = UDim.new
local UDim2 = UDim2
local Color3 = Color3
local Enum = Enum

local math = math
local table = table
local string = string

local pcall = pcall
local ipairs = ipairs
local tostring = tostring

local function fitin(instance)
	repeat instance.Size += UDim2.new(0, 2)
	until instance.TextFits
end

local function uiCorner(radius, instances)
	local uiCorner = Instance("UICorner")
	uiCorner.CornerRadius = radius
	
	for _,v in ipairs(instances) do
		uiCorner:Clone().Parent = v
	end

	uiCorner:Destroy()
end

local Library = {
	Flags = {},
	Colors = {
		Color3.fromRGB(25, 25, 25), -- UI 
		Color3.fromRGB(30, 30, 30), -- Backgrounds
		Color3.fromRGB(35, 35, 35), -- Objects
	},
	BlacklistedInput = {
		Enum.KeyCode.RightShift
	}
}

function Library:Init()
	local UI = Instance("ScreenGui")
	UI.Name = "UI"
	UI.Enabled = false
	
	local Base, Moved = Instance("Frame")
	Base.Name = "Base"
	Base.Parent = UI
	Base.BackgroundColor3 = self.Colors[1]
	Base.Position = UDim2.new(0, X / 16, 0, Y / 16)
	Base.Size = UDim2.new(0, 350, 0, 230)
	Base.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if Moved and Moved.Connected then 
			return 
		end

		local Mx, My = Mouse.X, Mouse.Y

		Moved = Mouse.Move:Connect(function()
			local nMx, nMy = Mouse.X, Mouse.Y
			local Dx, Dy = nMx - Mx, nMy - My
			Mx, My = nMx, nMy

			Base.Position += UDim2.fromOffset(Dx, Dy)
		end)
	end)
	Base.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return 
		end

		Moved:Disconnect()
	end)

	uiCorner(UDim(0, 2), {Base})
	
	local Objects = Instance("ScrollingFrame")
	Objects.Name = "Objects"
	Objects.Parent = Base
	Objects.AnchorPoint = Vector2(0.5, 0.5)
	Objects.BackgroundColor3 = self.Colors[2]
	Objects.BorderSizePixel = 0
	Objects.Position = UDim2.new(0.5, 0, 0.5)
	Objects.Size = UDim2.new(0, 340, 0, 220)
	Objects.BottomImage = ""
	Objects.ScrollBarThickness = 0
	Objects.TopImage = ""

	local Blur = Instance("BlurEffect")
	Blur.Name = tostring(self)
	Blur.Parent = Lighting
	Blur.Size = 0

	local UIListLayout = Instance("UIListLayout")
	UIListLayout.Parent = Objects
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim(0, 8)

	local UIPadding = Instance("UIPadding")
	UIPadding.Parent = Objects
	UIPadding.PaddingBottom = UDim(0, 8)
	UIPadding.PaddingTop = UDim(0, 8)

	xpcall(
		function() UI.Parent = game:GetService("CoreGui") end,
		function() UI.Parent = LP.PlayerGui end
	)

	function _G:quit()
		Blur:Destroy()
		UI:Destroy()

		local connections = self.connections

		for i, connection in next, connections do
			connection:Disconnect()
			connections[i] = nil
		end
	end

	function self:AddButton(options)
		options.Text = tostring(options.Text)
		options.Arguments = options.Arguments or {}

		local Button 
		
		Button = Instance("TextButton")
		Button.Name = "Button"
		Button.Parent = Objects
		Button.AnchorPoint = Vector2(0.5)
		Button.BackgroundColor3 = self.Colors[3]
		Button.Position = UDim2.new(0.5)
		Button.Size = UDim2.new(0, 320, 0, 30)
		Button.Font = Enum.Font.RobotoMono
		Button.Text = options.Text
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextSize = 16
		Button.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return 
			end

			pcall(options.Callback, unpack(options.Arguments))
		end)

		uiCorner(UDim(0, 4), {Button})

		return options
	end

	function self:AddToggle(options)
		options.Text = tostring(options.Text)
		options.Flag = options.Flag or options.Text
		options.Arguments = options.Arguments or {}
		options.Value = options.Value or false

		self.Flags[options.Flag] = options.Value

		local Toggle

		Toggle = Instance("TextButton")
		Toggle.Name = "Toggle"
		Toggle.Parent = Objects
		Toggle.AnchorPoint = Vector2(0.5)
		Toggle.BackgroundColor3 = self.Colors[3]
		Toggle.Position = UDim2.new(0.5)
		Toggle.Size = UDim2.new(0, 320, 0, 30)
		Toggle.Font = Enum.Font.RobotoMono
		Toggle.Text = string.format("%s [%s]", options.Text, tostring(options.Value))
		Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		Toggle.TextSize = 16
		Toggle.MouseButton1Click:Connect(function()
			local state = not self.Flags[options.Flag]

			self.Flags[options.Flag] = state
			Toggle.Text = string.format("%s [%s]", options.Text, tostring(state))

			pcall(options.Callback, unpack(options.Arguments))
		end)
		
		uiCorner(UDim(0, 4), {Toggle})

		return options
	end

	function self:AddSlider(options)
		options.Text = tostring(options.Text)
		options.Flag = options.Flag or options.Text
		options.MinValue = options.MinValue or 0
		options.MaxValue = options.MaxValue or 100
		options.Value = options.Value or options.MaxValue
		options.Arguments = options.Arguments or {}

		self.Flags[options.Flag] = options.Value

		local Slider
		local Bar
		local TextLabel

		Slider = Instance("Frame")
		Slider.Name = "Slider"
		Slider.Parent = Objects
		Slider.AnchorPoint = Vector2(0.5)
		Slider.BackgroundColor3 = self.Colors[3]
		Slider.Position = UDim2.new(0.5)
		Slider.Size = UDim2.new(0, 320, 0, 40)
		Slider.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return 
			end

			local abs = Slider.AbsolutePosition
			local pos = inputObject.Position.X - abs.X - 8

			local min = options.MinValue
			local max = options.MaxValue
			local value =
				pos >= 300 and max or
				pos <= 20 and min or
				math.round(pos / 300 * max)

			self.Flags[options.Flag] = value

			Bar.Size = UDim2.new(0, value / max * 300, 0, 2)
			TextLabel.Text = string.format("%s [%s]", options.Text, tostring(value))

			pcall(options.Callback, unpack(options.Arguments))
		end)
	
		Bar = Instance("Frame")
		Bar.Name = "Bar"
		Bar.Parent = Slider
		Bar.AnchorPoint = Vector2(0.5, 0)
		Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Bar.BorderSizePixel = 0
		Bar.Position = UDim2.new(0.5, 0, 0.8)
		Bar.Size = UDim2.new(0, options.Value / options.MaxValue * 300, 0, 2)
	
		TextLabel = Instance("TextLabel")
		TextLabel.Parent = Slider
		TextLabel.BackgroundColor3 = self.Colors[3]
		TextLabel.Size = UDim2.new(0, 320, 0, 30)
		TextLabel.Font = Enum.Font.RobotoMono
		TextLabel.Text = string.format("%s [%s]", options.Text, tostring(options.Value))
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextSize = 16

		uiCorner(UDim(0, 4), {TextLabel, Slider})
		table.insert(RGB, Bar)

		return options
	end

	function self:AddKeybind(options)
		options.Text = tostring(options.Text)
		options.Flag = options.Flag or options.Text
		options.Arguments = options.Arguments or {}
		options.Value = options.Value or Enum.KeyCode.Space

		self.Flags[options.Flag] = options.Value

		local Keybind
		local Identifier
		local Key

		Keybind = Instance("Frame")
		Keybind.Name = "Keybind"
		Keybind.Parent = Objects
		Keybind.AnchorPoint = Vector2(0.5, 0)
		Keybind.BackgroundColor3 = self.Colors[2]
		Keybind.Position = UDim2.new(0.5)
		Keybind.Size = UDim2.new(0, 320, 0, 30)
	
		Identifier = Instance("TextLabel")
		Identifier.Name = "Identifier"
		Identifier.Parent = Keybind
		Identifier.BackgroundColor3 = self.Colors[3]
		Identifier.Size = UDim2.new(0, 230, 0, 30)
		Identifier.Font = Enum.Font.RobotoMono
		Identifier.Text = options.Text
		Identifier.TextColor3 = Color3.fromRGB(255, 255, 255)
		Identifier.TextSize = 16

		Key = Instance("TextButton")
		Key.Name = "Key"
		Key.Parent = Keybind
		Key.BackgroundColor3 = self.Colors[3]
		Key.Position = UDim2.new(0, 320 - 80)
		Key.Size = UDim2.new(0, 80, 0, 30)
		Key.Font = Enum.Font.RobotoMono
		Key.Text = string.format("[%s]", options.Value.Name)
		Key.TextColor3 = Color3.fromRGB(255, 255, 255)
		Key.TextSize = 18
		Key.MouseButton1Click:Connect(function()
			local oldText = Key.Text
			local key = nil

			Key.Text = "[...]"

			while not key do
				local inputObject, gameProcessed = InputService.InputBegan:Wait()
				local newKey = inputObject.KeyCode

				if newKey == Enum.KeyCode.Escape then
					Key.Text = oldText
					return
				end

				if gameProcessed or table.find(self.BlacklistedInput, newKey) then
					return
				end

				key = newKey
			end

			Key.Size = UDim2.new(0, 60, 0, 30)
			Key.Text = string.format("[%s]", key.Name)
			fitin(Key)

			Key.Position = UDim2.new(0, 320 - Key.Size.X.Offset)
			Identifier.Size = UDim2.new(0, 310 - Key.Size.X.Offset, 0, 30)

			self.Flags[options.Flag] = key
			pcall(options.Callback, unpack(options.Arguments))
		end)

		uiCorner(UDim(0, 4), {Identifier, Keybind, Key})

		Key.Size = UDim2.new(0, 60, 0, 30)
		Key.Text = string.format("[%s]", options.Value.Name)
		fitin(Key)

		Key.Position = UDim2.new(0, 320 - Key.Size.X.Offset)
		Identifier.Size = UDim2.new(0, 310 - Key.Size.X.Offset, 0, 30)

		return options
	end

	_G.connections[#_G.connections + 1] =
		RunService.RenderStepped:Connect(function(dt)
			if H > 1 then H = 0 end
			
			H += dt * 0.1
			local color = Color3.fromHSV(H, 0.8, 1)

			for i,v in ipairs(RGB) do
				v.BackgroundColor3 = color
			end
		end)

	_G.connections[#_G.connections + 1] =
		InputService.InputBegan:Connect(function(inputObject, gameProcessed)
			if gameProcessed then
				return
			end

			if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
				return 
			end

			if inputObject.KeyCode == Enum.KeyCode.RightShift then
				local Enabled = not UI.Enabled
				UI.Enabled = Enabled

				TweenService:Create(Blur, TweenInfo.new(0.35), {Size = Enabled and 12 or 0}):Play()
			end
		end)

	return UI
end

return Library
