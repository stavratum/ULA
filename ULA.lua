if not game:IsLoaded() then game.Loaded:Wait() end

xpcall(
	function() _G:quit() end,
	function() _G.connections = {} end
)

local RGB = {}
local H = 0

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Instance = Instance.new
local Vector2 = Vector2.new
local UDim = UDim.new
local UDim2 = UDim2
local Color3 = Color3
local Enum = Enum

local Library = {
	Colors = {
		Color3.fromRGB(25, 25, 25), -- UI 
		Color3.fromRGB(30, 30, 30), -- Backgrounds
		Color3.fromRGB(35, 35, 35), -- Objects
	}
}

function Library:Init()
	_G.connections[#_G.connections + 1] =
		game:GetService("RunService").RenderStepped:Connect(function(dt)
			if H > 1 then H = 0 end
			
			H = H + dt * 0.1
			local color = Color3.fromHSV(H, 0.8, 1)

			for i,v in ipairs(RGB) do
				v.BackgroundColor3 = color
			end
		end)

	local UI = Instance("ScreenGui")
	UI.Name = "UI"
	
	local Base, Moved = Instance("Frame")
	Base.Name = "Base"
	Base.Parent = UI
	Base.BackgroundColor3 = self.Colors[1]
	Base.Size = UDim2.new(0, 350, 0, 230)
	Base.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local Mx, My = Mouse.X, Mouse.Y

		Moved = Mouse.Move:Connect(function()
			local nMx, nMy = Mouse.X, Mouse.Y
			local Dx, Dy = nMx - Mx, nMy - My
			Base.Position = Base.Position + UDim2.fromOffset(Dx, Dy)
			Mx, My = nMx, nMy
		end)
	end)
	Base.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return 
		end

		Moved:Disconnect()
	end)
	
	local UICorner = Instance("UICorner")
	UICorner.CornerRadius = UDim(0, 2)
	UICorner.Parent = Base
	
	local Objects = Instance("ScrollingFrame")
	Objects.Name = "Objects"
	Objects.Parent = Base
	Objects.AnchorPoint = Vector2(0.5, 0.5)
	Objects.BackgroundColor3 = self.Colors[2]
	Objects.BorderSizePixel = 0
	Objects.Position = UDim2.new(0.5, 0, 0.5, 0)
	Objects.Size = UDim2.new(0, 340, 0, 220)
	Objects.BottomImage = ""
	Objects.ScrollBarThickness = 2
	Objects.TopImage = ""

	xpcall(
		function() UI.Parent = game:GetService("CoreGui") end,
		function() UI.Parent = LP.PlayerGui end
	)

	local function calc()
		local objects = Objects:GetChildren()
		local aos = 0

		for _, object in ipairs(objects) do
			aos = aos + object.Size.Y.Offset
		end

		return (#objects + 1) * 8 + aos
	end

	function _G:quit()
		UI:Destroy()

		for i,v in ipairs(self.connections) do
			v:Disconnect()
		end
	
		table.clear(self.connections)
	end

	function self:MakeButton(text)
		local Button = Instance("TextButton")
		Button.Name = "Button"
		Button.Parent = Objects
		Button.AnchorPoint = Vector2(0.5, 0)
		Button.BackgroundColor3 = self.Colors[3]
		Button.Position = UDim2.new(0.5, 0, 0, calc())
		Button.Size = UDim2.new(0, 320, 0, 26)
		Button.Font = Enum.Font.RobotoMono
		Button.Text = text
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextSize = 16

		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = Button
	end

	function self:MakeToggle(text)
		local Toggle = Instance("TextButton")
		Toggle.Name = "Toggle"
		Toggle.Parent = Objects
		Toggle.AnchorPoint = Vector2(0.5, 0)
		Toggle.BackgroundColor3 = self.Colors[3]
		Toggle.Position = UDim2.new(0.5, 0, 0, calc())
		Toggle.Size = UDim2.new(0, 320, 0, 26)
		Toggle.Font = Enum.Font.RobotoMono
		Toggle.Text = text .. " [false]"
		Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		Toggle.TextSize = 16
		Toggle.MouseButton1Click:Connect(function()
			local state = not Object.Value
			Object.Value = state
			Object.Instance.Text = text .. " ["..tostring(state).."]"
		end)
		
		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = Toggle
	end

	function self:MakeSlider(options)
		options.Text = options.Text or "Slider"
		options.MinValue = options.MinValue or 0
		options.MaxValue = options.MaxValue or 1
		options.Value = options.Value or 0

		local Slider = Instance("Frame")
		Slider.Name = "Slider"
		Slider.Parent = Objects
		Slider.AnchorPoint = Vector2(0.5, 0)
		Slider.BackgroundColor3 = self.Colors[3]
		Slider.Position = UDim2.new(0.5, 0, 0, calc())
		Slider.Size = UDim2.new(0, 320, 0, 40)
	
		local Bar = Instance("Frame")
		Bar.Name = "Bar"
		Bar.Parent = Slider
		Bar.AnchorPoint = Vector2(0.5, 0)
		Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Bar.BorderSizePixel = 0
		Bar.Position = UDim2.new(0.5, 0, 0.8, 0)
		Bar.Size = UDim2.new(0, options.Value / options.MaxValue * 320, 0, 2)
	
		local TextLabel = Instance("TextLabel")
		TextLabel.Parent = Slider
		TextLabel.BackgroundColor3 = self.Colors[3]
		TextLabel.Size = UDim2.new(0, 320, 0, 26)
		TextLabel.Font = Enum.Font.RobotoMono
		TextLabel.Text = options.Text .. " [" .. tostring(options.Value).."]"
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextSize = 16
	
		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = Slider
	
		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = TextLabel

		Slider.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return 
			end

			local abs = Slider.AbsolutePosition
			local pos = inputObject.Position.X - abs.X

			local min = options.MinValue
			local max = options.MaxValue
			local value = pos / 310 * max

			value = math.clamp(math.round(value), min, max)

			Bar.Size = UDim2.new(0, pos, 0, 2)
			TextLabel.Text = options.Text .. " [" .. tostring(value).."]"
		end)

		RGB[#RGB + 1] = Bar
	end

	function self:MakeKeybind(text) -- todo
		local Keybind = Instance("Frame")
		Keybind.Name = "Keybind"
		Keybind.BackgroundColor3 = self.Colors[2]
		Keybind.Size = UDim2.new(0, 320, 0, 26)
	
		local Key = Instance("TextButton")
		Key.Name = "Key"
		Key.Parent = Keybind
		Key.BackgroundColor3 = self.Colors[3]
		Key.Size = UDim2.new(0, 60, 0, 26)
		Key.Font = Enum.Font.RobotoMono
		Key.Text = "[H]"
		Key.TextColor3 = Color3.fromRGB(255, 255, 255)
		Key.TextSize = 18
	
		local Identifier = Instance("TextLabel")
		Identifier.Name = "Identifier"
		Identifier.Parent = Keybind
		Identifier.BackgroundColor3 = self.Colors[3]
		Identifier.Size = UDim2.new(0, 250, 0, 26)
		Identifier.Font = Enum.Font.RobotoMono
		Identifier.Text = text
		Identifier.TextColor3 = Color3.fromRGB(255, 255, 255)
		Identifier.TextSize = 16
	
		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = Keybind
	
		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = Key
	
		local UICorner = Instance("UICorner")
		UICorner.CornerRadius = UDim(0, 4)
		UICorner.Parent = Identifier
	end
end

return Library
