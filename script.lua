local LOCAL_PLAYER = game.Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()

local INPUT_SERVICE = game:GetService("UserInputService")

local SCRIPT_ENABLED = true

local APPLICATION_GUI_PARENT = game:GetService("RunService"):IsStudio() and game.Players.LocalPlayer.PlayerGui or game.CoreGui
local APPLICATION_SIZE = UDim2.new(0, 380, 0, 260)
local APPLICATION_MINIMIZED = false

local ELEMENT_CONTAINER_EXTRA_PADDING = 0
local ELEMENT_CONTAINER_HEIGHT = 19
local ELEMENT_TITLE_PADDING = 10
local SLIDER_MAX_DECIMAL_PLACES = 2

local DEFAULT_AIMBOT_KEY = Enum.KeyCode.LeftControl

local APPLICATION_THEME = {}
do
	APPLICATION_THEME.TextColor = Color3.fromRGB(255, 255, 255)
	APPLICATION_THEME.Padding_TextColor = Color3.fromRGB(100, 120, 190)

	APPLICATION_THEME.TextFont_Standard = Enum.Font.Gotham
	APPLICATION_THEME.TextFont_SemiBold = Enum.Font.GothamSemibold
	APPLICATION_THEME.TextFont_Bold = Enum.Font.GothamBold

	APPLICATION_THEME.Cursor_Color = Color3.new(1, 1, 1)

	APPLICATION_THEME.Color_Light = Color3.fromRGB(45, 45, 45)
	APPLICATION_THEME.Color_Medium = Color3.fromRGB(30, 30, 30)
	APPLICATION_THEME.Color_Dark = Color3.fromRGB(15, 15, 15)

	APPLICATION_THEME.Slider_Background_Color = Color3.fromRGB(60, 60, 60)
	APPLICATION_THEME.Slider_Bar_Color = Color3.fromRGB(190, 190, 190)

	APPLICATION_THEME.Keybind_Engaged_Color = Color3.fromRGB(110, 40, 40)
	APPLICATION_THEME.Keybind_NotEngaged_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Button_Engaged_Color = Color3.fromRGB(110, 40, 40)
	APPLICATION_THEME.Button_NotEngaged_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Input_Background_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Switch_Background_Color = Color3.fromRGB(60, 60, 60)
	APPLICATION_THEME.Switch_Knob_Color = Color3.fromRGB(220, 220, 220)
	APPLICATION_THEME.Switch_Off_Color = Color3.fromRGB(30, 30, 30)
	APPLICATION_THEME.Switch_On_Color = Color3.fromRGB(30, 120, 190)
end

-- Functions
local function Lerp(start, finish, alpha)
	return start * (1 - alpha) + (finish * alpha)
end

-- Gui Functions
local function CreateGui(parent, name, resetOnSpawn, ignoreGuiInset)
	local gui = Instance.new("ScreenGui", parent)
	gui.Name = name

	gui.IgnoreGuiInset = ignoreGuiInset
	gui.ResetOnSpawn = resetOnSpawn

	return gui
end

local function AddPadding(parent, size, text)
	local paddingText = text ~= nil and text or ""

	local padding = Instance.new("TextButton", parent)
	padding.Name = "Padding"
	padding.BackgroundTransparency = 1
	padding.BorderSizePixel = 0
	padding.Size = UDim2.new(1, 0, 0, size)
	padding.Font = APPLICATION_THEME.TextFont_SemiBold
	padding.TextColor3 = APPLICATION_THEME.Padding_TextColor
	padding.TextSize = 12
	padding.TextXAlignment = Enum.TextXAlignment.Left
	padding.TextYAlignment = Enum.TextYAlignment.Bottom
	padding.Text = "  " .. paddingText

	return padding
end

local function CreateFrame(parent, name, borderRounding, size, position, anchorPoint, color)
	local frame_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local frame_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local frame = Instance.new("ImageLabel", parent)
	frame.Name = name
	frame.Image = "rbxassetid://3570695787"
	frame.ImageColor3 = color == nil and APPLICATION_THEME.Color_Light or color
	frame.ScaleType = Enum.ScaleType.Slice
	frame.SliceCenter = Rect.new(Vector2.new(100, 100), Vector2.new(100, 100))
	frame.SliceScale = 0.01 * borderRounding
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = true

	frame.Size = size
	frame.Position = frame_Position
	frame.AnchorPoint = frame_AnchorPoint

	return frame
end

local function CreateDragHandle(parent, attachedGui, name, size, position, anchorPoint, text)
	local handle_Size = size ~= nil and size or UDim2.new(1, 0, 1, 0)
	local handle_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local handle_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local handle = Instance.new("TextButton", parent)
	handle.Name = name
	handle.Size = handle_Size
	handle.Position = handle_Position
	handle.AnchorPoint = handle_AnchorPoint
	handle.BackgroundTransparency = 1
	handle.Text = "  " .. text
	handle.TextSize = 14
	handle.Font = APPLICATION_THEME.TextFont_SemiBold
	handle.TextXAlignment = Enum.TextXAlignment.Left
	handle.TextColor3 = APPLICATION_THEME.TextColor

	local border = Instance.new("Frame", handle)
	border.Name = "TitleBorder"
	border.Size = UDim2.new(1, 0, 0, 1)
	border.Position = UDim2.new(0.5, 0, 0, 20)
	border.AnchorPoint = Vector2.new(0.5, 0)
	border.BorderSizePixel = 0
	border.Active = false

	local titleBorder_Gradient = Instance.new("UIGradient", border)
	border.BackgroundColor3 = Color3.new(1, 1, 1)
	titleBorder_Gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.05, 0.5),
		NumberSequenceKeypoint.new(0.95, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}

	local closeButton = Instance.new("ImageButton", handle)
	closeButton.Name = "CloseButton"
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 12, 0, 12)
	closeButton.AnchorPoint = Vector2.new(0, 0.5)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -18, 0.5, 0)

	local miniButton = Instance.new("ImageButton", handle)
	miniButton.Name = "MinimizeButton"
	miniButton.Image = "rbxassetid://4530358017"
	miniButton.Size = UDim2.new(0, 12, 0, 12)
	miniButton.AnchorPoint = Vector2.new(0, 0.5)
	miniButton.BackgroundTransparency = 1
	miniButton.AutoButtonColor = false
	miniButton.Position = UDim2.new(1, -37, 0.5, 0)

	-- Enable Disable
	miniButton.MouseButton1Click:Connect(function()
		if APPLICATION_MINIMIZED then
			APPLICATION_MINIMIZED = false

			--parent.Visible = true
			--parent.Size = UDim2.new(0, APPLICATION_SIZE.X, 0, APPLICATION_SIZE.Y)
		else
			APPLICATION_MINIMIZED = true

			--parent.Visible = false
			--parent.Size = UDim2.new(0, APPLICATION_SIZE.X, 0, ELEMENT_CONTAINER_HEIGHT)

			-- localPlayer.CameraMinZoomDistance = before_CameraMinZoom
			-- localPlayer.CameraMaxZoomDistance = before_CameraMaxZoom
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		SCRIPT_ENABLED = false
		attachedGui:Destroy()
	end)



	local dragging = false

	handle.MouseButton1Down:Connect(function()
		dragging = true

		local dragStartOffset = Vector2.new(MOUSE.X, MOUSE.Y) - handle.AbsolutePosition

		repeat
			parent.Position = UDim2.new(0, MOUSE.X - dragStartOffset.X, 0, MOUSE.Y - dragStartOffset.Y)

			game:GetService("RunService").RenderStepped:Wait()
		until dragging == false
	end)

	handle.MouseButton1Up:Connect(function()
		dragging = false
	end)

	return handle
end

local function CreateScrollingFrame(parent, name, size, position, anchorPoint, padding)
	local container_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local container_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local container = Instance.new("ScrollingFrame", parent)
	container.Name = name
	container.BorderSizePixel = 0
	container.BackgroundTransparency = 1
	container.ScrollingEnabled = true
	container.Size = size
	container.Position = container_Position
	container.AnchorPoint = container_AnchorPoint
	container.BottomImage = container.MidImage
	container.TopImage = container.MidImage
	container.ScrollBarThickness = 4

	local list = Instance.new("UIListLayout", container)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, padding)

	local scrolling = false
	local engaged = false

	container.CanvasSize = UDim2.new(0, 0, 0, ELEMENT_CONTAINER_EXTRA_PADDING)

	container.ChildAdded:Connect(function(c)
		pcall(function()
			wait()
			container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + c.AbsoluteSize.Y + ELEMENT_CONTAINER_EXTRA_PADDING)
		end)
	end)

	container.ChildRemoved:Connect(function(c)
		pcall(function()
			wait()
			container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y - c.AbsoluteSize.Y + ELEMENT_CONTAINER_EXTRA_PADDING)
		end)
	end)

	return container
end

-- Elements
local function CreateSlider(parent, name, titleText, min, max, defaultValue, inputSuffix)
	local suffix = inputSuffix ~= nil and inputSuffix or ""

	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Element
	local sliderBackground = CreateFrame(elementContainer, "SliderBackground", 3, UDim2.new(1, -180, 0, 7), UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), APPLICATION_THEME.Slider_Background_Color)
	local sliderBar = CreateFrame(sliderBackground, "SliderBar", 3, UDim2.new(Lerp(0, 1, (defaultValue - min) / (max - min)), 0, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), APPLICATION_THEME.Slider_Bar_Color)

	local sliderClickBox = Instance.new("TextButton", sliderBackground)
	sliderClickBox.Name = "ClickBox"
	sliderClickBox.BackgroundTransparency = 1
	sliderClickBox.Text = ""
	sliderClickBox.Size = UDim2.new(1, 0, 1, 0)

	local valueTextLabel = Instance.new("TextLabel", sliderClickBox)
	valueTextLabel.Name = "ValueLabel"
	valueTextLabel.BackgroundTransparency = 1
	valueTextLabel.Size = UDim2.new(0, 1000, 0, 14)
	valueTextLabel.Font = APPLICATION_THEME.TextFont_SemiBold
	valueTextLabel.TextSize = 12
	valueTextLabel.TextColor3 = APPLICATION_THEME.TextColor
	valueTextLabel.TextTransparency = 1
	valueTextLabel.Text = ""

	-- Functionality
	local mouseDown = false
	local currentValue = defaultValue

	sliderClickBox.MouseButton1Down:Connect(function()
		mouseDown = true

		do
			local goal = {}
			goal.TextTransparency = 0

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

			local tween = game:GetService("TweenService"):Create(valueTextLabel, tweenInfo, goal)
			tween:Play()
		end

		repeat
			local dt = game:GetService("RunService").RenderStepped:Wait()

			local alpha = (MOUSE.X - sliderClickBox.AbsolutePosition.X) / sliderClickBox.AbsoluteSize.X
			alpha = math.clamp(alpha, 0, 1)

			sliderBar.Size = UDim2.new(Lerp(sliderBar.Size.X.Scale, alpha, 1 - (0.0000001 ^ dt)), 0, 1, 0)

			-- Label
			local realAlpha = sliderBar.AbsoluteSize.X / sliderBackground.AbsoluteSize.X
			local realValue = Lerp(min, max, sliderBar.AbsoluteSize.X / sliderBackground.AbsoluteSize.X)
			local realValueShortened = math.floor((realValue * (10 ^ SLIDER_MAX_DECIMAL_PLACES)) + 0.5) / (10 ^ SLIDER_MAX_DECIMAL_PLACES)

			currentValue = realValue
			valueTextLabel.Text = realValueShortened .. suffix

			valueTextLabel.AnchorPoint = Vector2.new(0.5, 0)
			valueTextLabel.Position = UDim2.new(realAlpha, 0, 1, 4)
			valueTextLabel.ZIndex = 100
		until mouseDown == false

		do
			local goal = {}
			goal.TextTransparency = 1

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

			local tween = game:GetService("TweenService"):Create(valueTextLabel, tweenInfo, goal)
			tween:Play()
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mouseDown = false
			wait(0.25)
			valueTextLabel.ZIndex = 1
		end
	end)

	-- Return
	local t = {}

	function t.GetValue()
		return currentValue
	end

	return t
end

local function CreateSwitch(parent, name, titleText, onByDefault)
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Element
	local backgroundColor = onByDefault and APPLICATION_THEME.Switch_On_Color or APPLICATION_THEME.Switch_Off_Color

	local switchBackground = CreateFrame(elementContainer, "SliderBackground", 7, UDim2.new(0, 30, 0, 13), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5), backgroundColor)

	local knob = Instance.new("ImageLabel", switchBackground)
	knob.Name = "Knob"
	knob.Image = "rbxassetid://3570695787"
	knob.BackgroundTransparency = 1
	knob.ImageColor3 = APPLICATION_THEME.Switch_Knob_Color
	knob.Size = UDim2.new(0, 11, 0, 11)
	knob.Position = UDim2.new(0, 1, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)

	local switchClickBox = Instance.new("TextButton", switchBackground)
	switchClickBox.Name = "ClickBox"
	switchClickBox.BackgroundTransparency = 1
	switchClickBox.Text = ""
	switchClickBox.Size = UDim2.new(1, 0, 1, 0)

	-- Functionality
	local switchUpdated = false
	local switchOn = not onByDefault

	local firstUpdate = false

	local function UpdateSwitch()
		switchOn = not switchOn

		switchUpdated = true

		if firstUpdate == false then
			firstUpdate = true
			switchUpdated = false
		end



		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

		if switchOn then
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(1, 0.5)
			goal_1.Position = UDim2.new(1, -1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = APPLICATION_THEME.Switch_On_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		else
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(0, 0.5)
			goal_1.Position = UDim2.new(0, 1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = APPLICATION_THEME.Switch_Off_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		end
	end

	switchClickBox.MouseButton1Click:Connect(function()
		UpdateSwitch()
	end)

	UpdateSwitch()

	-- Return
	local t = {}

	function t.ValueChanged()
		local r = switchUpdated
		switchUpdated = false

		return r
	end

	function t.GetValue()
		return switchOn
	end

	return t
end

local function CreateKeybind(parent, name, titleText, defaultKeyCode) -- Allows you to set keybinds
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local background = CreateFrame(elementContainer, "Background", 5, UDim2.new(0, 90, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	background.Name = "Background"
	background.ImageColor3 = APPLICATION_THEME.Keybind_NotEngaged_Color

	local clickBox = Instance.new("TextButton", background)
	clickBox.Name = "ClickBox"
	clickBox.BackgroundTransparency = 1
	clickBox.Font = APPLICATION_THEME.TextFont_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = APPLICATION_THEME.TextColor
	clickBox.Text = string.sub(tostring(defaultKeyCode), 14, string.len(tostring(defaultKeyCode)))

	-- Functionality
	local engaged = false

	local function Update(keyName, isEngaged)
		local textWidth = game:GetService("TextService"):GetTextSize(keyName, 12, APPLICATION_THEME.TextFont_SemiBold, Vector2.new(math.huge, math.huge)).X
		background.Size = UDim2.new(0, textWidth + 14, 0, 15)

		if isEngaged then
			background.ImageColor3 = APPLICATION_THEME.Keybind_Engaged_Color
		else
			background.ImageColor3 = APPLICATION_THEME.Keybind_NotEngaged_Color
		end
	end

	Update(clickBox.Text, engaged)

	game:GetService("UserInputService").InputBegan:Connect(function(key)
		if engaged then
			local keyName = tostring(key.KeyCode)
			keyName = string.sub(keyName, 14, string.len(keyName))

			if keyName ~= "Unknown" then
				engaged = false
				clickBox.Text = keyName

				-- Tween
				Update(keyName, engaged)
			end
		end
	end)

	clickBox.MouseButton1Click:Connect(function()
		engaged = true

		-- Tween
		Update(clickBox.Text, engaged)
	end)

	-- Return
	local t = {}

	function t.GetKeyCode()
		return Enum.KeyCode[clickBox.Text]
	end

	return t
end

local function CreateButton(parent, name, titleText, buttonText) -- Allows you to set keybinds
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local button = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(0, 90, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color

	local clickBox = Instance.new("TextButton", button)
	clickBox.Name = "ClickBox"
	clickBox.BackgroundTransparency = 1
	clickBox.Font = APPLICATION_THEME.TextFont_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = APPLICATION_THEME.TextColor
	clickBox.Text = buttonText

	-- Functionality
	local pressed = false
	local mouseEnter = false

	clickBox.MouseEnter:Connect(function()
		button.ImageColor3 = APPLICATION_THEME.Button_Engaged_Color
		mouseEnter = true
	end)

	clickBox.MouseLeave:Connect(function()
		button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color
		mouseEnter = false
	end)

	clickBox.MouseButton1Click:Connect(function()
		pressed = true

		button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color
		wait()
		button.ImageColor3 = APPLICATION_THEME.Button_Engaged_Color
	end)

	-- Return
	local t = {}

	function t.ButtonPressed()
		local p = pressed
		pressed = false

		return p
	end

	function t.HoveringOver()
		return mouseEnter
	end

	return t
end

local function CreateInput(parent, name, titleText, default) -- Allows the user to provide input
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local background = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(1, -180, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	background.ImageColor3 = APPLICATION_THEME.Input_Background_Color

	local inputBox = Instance.new("TextBox", background)
	inputBox.Name = "InputBox"
	inputBox.BackgroundTransparency = 1
	inputBox.Font = APPLICATION_THEME.TextFont_SemiBold
	inputBox.TextSize = 12
	inputBox.Size = UDim2.new(1, -5, 1, 0)
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.AnchorPoint = Vector2.new(1, 0)
	inputBox.Position = UDim2.new(1, 0, 0, 0)
	inputBox.TextColor3 = APPLICATION_THEME.TextColor
	inputBox.Text = default ~= nil and default or "Enter Here"

	-- Functionality
	local textChanged = false
	local previousText = inputBox.Text

	inputBox.FocusLost:Connect(function()
		if previousText ~= inputBox.Text then
			textChanged = true
		end

		previousText = inputBox.Text
	end)

	-- Return
	local t = {}

	function t.InputChanged()
		local v = textChanged
		textChanged = false

		return v
	end

	function t.GetText()
		return inputBox.Text
	end

	function t.GetNumber()
		return typeof(tonumber(inputBox.Text)) == "number" and tonumber(inputBox.Text) or 0
	end

	function t.SetText(t)
		inputBox.Text = t
	end

	return t
end

local function CreateColorPicker(parent, name, titleText)
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, 160)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Gradient Map
	local backplate = Instance.new("Frame", elementContainer)
	backplate.Name = "Backplate"
	backplate.BorderSizePixel = 0
	backplate.BackgroundColor3 = Color3.new(0, 0, 0)
	backplate.Position = UDim2.new(0, 10, 0, 20)
	backplate.Size = UDim2.new(0, 100, 0, 100)

	local colorGradientBox = Instance.new("ImageLabel", backplate)
	colorGradientBox.Name = "ColorGradientBox"
	colorGradientBox.Image = "rbxassetid://1280017782"
	colorGradientBox.Size = UDim2.new(1, 0, 1, 0)
	colorGradientBox.Position = UDim2.new(0, 0, 0, 0)
	colorGradientBox.Rotation = 90
	colorGradientBox.BackgroundTransparency = 1

	local whiteGradientBox = Instance.new("ImageLabel", backplate)
	whiteGradientBox.Name = "WhiteGradientBox"
	whiteGradientBox.Image = "rbxassetid://1280017782"
	whiteGradientBox.ImageColor3 = Color3.new(1, 1, 1)
	whiteGradientBox.Size = UDim2.new(1, 0, 1, 0)
	whiteGradientBox.Position = UDim2.new(0, 0, 0, 0)
	whiteGradientBox.BackgroundTransparency = 1

	local blackGradientBox = Instance.new("ImageLabel", backplate)
	blackGradientBox.Name = "BlackGradientBox"
	blackGradientBox.Image = "rbxassetid://1280017782"
	blackGradientBox.ImageColor3 = Color3.new(0, 0, 0)
	blackGradientBox.Size = UDim2.new(1, 0, 1, 0)
	blackGradientBox.Position = UDim2.new(0, 0, 0, 0)
	blackGradientBox.Rotation = -90
	blackGradientBox.BackgroundTransparency = 1

	-- Color Map
	local backplate2 = Instance.new("Frame", elementContainer)
	backplate2.Name = "Backplate2"
	backplate2.BorderSizePixel = 0
	backplate2.BackgroundColor3 = Color3.new(0, 0, 0)
	backplate2.Position = UDim2.new(0, 115, 0, 20)
	backplate2.Size = UDim2.new(0, 100, 0, 100)

	local colorMap = Instance.new("ImageLabel", backplate2)
	colorMap.Name = "ColorMap"
	colorMap.Image = "rbxassetid://5425155739"
	colorMap.Size = UDim2.new(1, 0, 1, 0)
	colorMap.Position = UDim2.new(0, 0, 0, 0)
	colorMap.BackgroundTransparency = 1

	local desaturatedMap = Instance.new("ImageLabel", backplate2)
	desaturatedMap.Name = "DesaturatedMap"
	desaturatedMap.Image = "rbxassetid://5425157396"
	desaturatedMap.Size = UDim2.new(1, 0, 1, 0)
	desaturatedMap.Position = UDim2.new(0, 0, 0, 0)
	desaturatedMap.BackgroundTransparency = 1

	spawn(function()
		local t = 0
		local t2 = 0

		while true do
			local dt = game:GetService("RunService").RenderStepped:Wait()
			t = t + (dt / 2) if t > 1 then t = 0 end
			t2 = t2 + (dt * 2)

			colorGradientBox.ImageColor3 = Color3.fromHSV(t, 1, 1)

			desaturatedMap.ImageTransparency = math.sin(t2) / 2 + 0.5
		end
	end)
end

local function CreateOutput(parent, name, elementCount) -- Allows the script to show the user info
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, 18 * elementCount + 6)

	local background = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(1, -20, 0, 18 * elementCount), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5))
	background.ImageColor3 = APPLICATION_THEME.Input_Background_Color

	local elements = {} -- Table which store the individual status text labels

	for i = 1, elementCount do
		local label = Instance.new("TextBox", background)
		label.Name = "InputBox"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Code --APPLICATION_THEME.TextFont_SemiBold
		label.TextSize = 14
		label.Size = UDim2.new(1, -5, 0, 15)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.AnchorPoint = Vector2.new(1, 0)
		label.Position = UDim2.new(1, 0, 0, 18 * (i - 1) + 1)
		label.TextColor3 = APPLICATION_THEME.TextColor
		label.Text = ""

		table.insert(elements, label)
	end

	-- Return
	local t = {}

	function t.EditStatus(id, text)
		elements[id].Text = text
	end



	return t
end

-- Misc. Functions
local function MatchPlayerWithString(str)
	for _, v in pairs(game.Players:GetPlayers()) do
		if string.find(string.lower(v.Name), string.lower(str)) then
			return v
		end
	end
end

local function StringToNumber(str, returnValueIfNotValid)
	local ret = returnValueIfNotValid ~= nil and returnValueIfNotValid or 0
	return typeof(tonumber(str)) == "number" and tonumber(str) or ret
end

-- Math Functions
local function RoundNumber(number, decimals)
	local multiplier = 10 ^ decimals

	return math.floor(number * multiplier + 0.5) / multiplier
end







-- Application Gui
local APP_GUI = CreateGui(APPLICATION_GUI_PARENT, "APPLICATION", false, false)

local mainFrame = CreateFrame(APP_GUI, "MainFrame", 3, APPLICATION_SIZE, UDim2.new(0, 0, 0, 0))
mainFrame.ClipsDescendants = true

local dragHandle = CreateDragHandle(mainFrame, APP_GUI, "DragHandle", UDim2.new(1, 0, 0, 20), nil, nil, "Waypoints")

local elements_Container = CreateScrollingFrame(mainFrame, "ElementsContainer", UDim2.new(1, 0, 1, -22), UDim2.new(0, 0, 0, 22), nil, 0)

local cursor = Instance.new("Frame", APP_GUI)
cursor.BorderSizePixel = 0
cursor.Size = UDim2.new(0, 2, 0, 2)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)


AddPadding(elements_Container, 17, "Waypoints")

-- Visualisation
local switch_ShowWaypoints = CreateSwitch(elements_Container, "", "Show Waypoints", true)

-- Buttons
local button_AddWaypoint = CreateButton(elements_Container, "", "Create Waypoint", "Create")

-- Waypoints
local waypointsScrollingFrameBackground = CreateFrame(mainFrame, "", 4, UDim2.new(1, -10, 1, -90), UDim2.new(0.5, 0, 1, -4), Vector2.new(0.5, 1), APPLICATION_THEME.Color_Medium)
local waypointsScrollingFrame = CreateScrollingFrame(waypointsScrollingFrameBackground, "", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), nil, 0)
waypointsScrollingFrame.BackgroundTransparency = 1

local function CreateWaypoint(homeCFrame)
	local exists = true
	
	local frame = Instance.new("Frame", waypointsScrollingFrame)
	frame.Size = UDim2.new(1, 0, 0, 20)
	frame.BackgroundTransparency = 1
	
	-- Name of waypoint
	local nameFrame = CreateFrame(frame, "", 4, UDim2.new(0.73, 0, 1, -4), UDim2.new(0, 4, 0.5, 0), Vector2.new(0, 0.5), Color3.fromRGB(20, 20, 20))
	
	local nameTextBox = Instance.new("TextBox", nameFrame)
	nameTextBox.BackgroundTransparency = 1
	nameTextBox.Size = UDim2.new(1, -2, 1, 0)
	nameTextBox.Position = UDim2.new(1, 2, 0, 0)
	nameTextBox.AnchorPoint = Vector2.new(1, 0)
	nameTextBox.TextXAlignment = Enum.TextXAlignment.Left
	nameTextBox.Font = Enum.Font.GothamSemibold
	nameTextBox.TextColor3 = Color3.new(1, 1, 1)
	nameTextBox.TextSize = 12
	nameTextBox.Text = "New Waypoint"
	
	-- Teleport button
	local teleportFrame = CreateFrame(frame, "", 4, UDim2.new(0.2, 0, 1, -4), UDim2.new(1, -20, 0.5, 0), Vector2.new(1, 0.5), Color3.fromRGB(20, 20, 20))
	
	local teleportButton = Instance.new("TextButton", teleportFrame)
	teleportButton.Size = UDim2.new(1, 0, 1, 0)
	teleportButton.Font = Enum.Font.GothamSemibold
	teleportButton.TextColor3 = Color3.new(1, 1, 1)
	teleportButton.TextSize = 12
	teleportButton.BackgroundTransparency = 1
	teleportButton.Text = "Teleport"
	
	local mouseEnterConnection = teleportButton.MouseEnter:Connect(function()
		teleportFrame.ImageColor3 = Color3.fromRGB(80, 80, 80)
	end)
	
	local mouseLeaveConnection = teleportButton.MouseLeave:Connect(function()
		teleportFrame.ImageColor3 = Color3.fromRGB(20, 20, 20)
	end)
	
	local mouseDownConnection = teleportButton.MouseButton1Down:Connect(function()
		teleportFrame.ImageColor3 = Color3.fromRGB(20, 20, 20)
	end)
	
	local mouseUpConnection = teleportButton.MouseButton1Up:Connect(function()
		teleportFrame.ImageColor3 = Color3.fromRGB(80, 80, 80)
	end)
	
	-- Close button
	local closeButton = Instance.new("ImageButton", frame)
	closeButton.Name = "CloseButton"
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 10, 0, 10)
	closeButton.AnchorPoint = Vector2.new(0, 0.5)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -16, 0.5, 0)
	
	-- Events
	local teleportConnection = teleportButton.MouseButton1Click:Connect(function()
		if LOCAL_PLAYER.Character then
			LOCAL_PLAYER.Character:SetPrimaryPartCFrame(homeCFrame)
		end
	end)
	
	local closeConnection = closeButton.MouseButton1Click:Connect(function()
		exists = false
		frame:Destroy()
	end)
	
	-- Waypoint
	local homePart = Instance.new("Part", APP_GUI)
	homePart.CFrame = homeCFrame
	
	local cone = Instance.new("ConeHandleAdornment", homePart)
	cone.Adornee = homePart
	cone.Radius = 0.3
	cone.Height = 1
	cone.SizeRelativeOffset = Vector3.new(0, 0, -1)
	cone.ZIndex = 10
	cone.AlwaysOnTop = true
	cone.Transparency = 0.5
	cone.Color3 = Color3.new(1, 1, 1)
	
	local cylinder = Instance.new("CylinderHandleAdornment", homePart)
	cylinder.Adornee = homePart
	cylinder.Radius = 0.1
	cylinder.Height = 0.8
	cylinder.SizeRelativeOffset = Vector3.new(0, 0, -0.6)
	cylinder.ZIndex = 10
	cylinder.AlwaysOnTop = true
	cylinder.Transparency = 0.5
	cylinder.Color3 = Color3.new(1, 1, 1)
	
	local box = Instance.new("BoxHandleAdornment", homePart)
	box.Adornee = homePart
	box.Size = Vector3.new(0.4, 0.4, 0.4)
	box.AlwaysOnTop = true
	box.Transparency = 0.5
	box.Color3 = Color3.new(1, 1, 1)
	box.ZIndex = 10
	
	-- Tag
	local waypointTag = Instance.new("TextLabel", APP_GUI)
	waypointTag.Name = "WaypointTag"
	waypointTag.Size = UDim2.new(0, 1000000, 0, 20)
	waypointTag.Font = Enum.Font.GothamSemibold
	waypointTag.TextColor3 = Color3.new(1, 1, 1)
	waypointTag.TextSize = 12
	waypointTag.AnchorPoint = Vector2.new(0.5, 0.5)
	waypointTag.Position = UDim2.new(0.5, 0, 0.5, 0)
	waypointTag.BackgroundTransparency = 1
	waypointTag.TextStrokeTransparency = 0.9
	waypointTag.Text = ""
	
	if switch_ShowWaypoints.GetValue() == true then
		cone.Visible = true
		cylinder.Visible = true
		box.Visible = true
		waypointTag.Visible = true
	else
		cone.Visible = false
		cylinder.Visible = false
		box.Visible = false
		waypointTag.Visible = false
	end
	
	
	local thread = coroutine.create(function()
		while SCRIPT_ENABLED and exists do
			if exists then
				local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(homeCFrame.Position)
				
				if onScreen then
					if switch_ShowWaypoints.GetValue() == true then
						waypointTag.Visible = true
					end
						
					waypointTag.Position = UDim2.new(0, pos.X, 0, pos.Y)
					waypointTag.Text = "Waypoint [" .. nameTextBox.Text .. "]"
				else
					waypointTag.Visible = false
				end
			end
			
			game:GetService("RunService").RenderStepped:Wait()
		end
		
		homePart:Destroy()
		waypointTag:Destroy()
		
		mouseEnterConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
		mouseDownConnection:Disconnect()
		mouseUpConnection:Disconnect()
		teleportConnection:Disconnect()
		closeConnection:Disconnect()
	end)
	
	coroutine.resume(thread)	
end


while SCRIPT_ENABLED do
	local cam = workspace.CurrentCamera
	
	-- Cursor
	cursor.Position = UDim2.new(0, MOUSE.X, 0, MOUSE.Y)
	if MOUSE.X > mainFrame.AbsolutePosition.X and MOUSE.X < mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X and MOUSE.Y > mainFrame.AbsolutePosition.Y and MOUSE.Y < mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y then
		cursor.Visible = true
	else
		cursor.Visible = false
	end

	-- Interaction
	if button_AddWaypoint.ButtonPressed() then
		if LOCAL_PLAYER.Character then
			if LOCAL_PLAYER.Character.PrimaryPart then
				CreateWaypoint(LOCAL_PLAYER.Character:GetPrimaryPartCFrame())
			end
		end
	end
	
	if switch_ShowWaypoints.ValueChanged() then
		for _, v in pairs(APP_GUI:GetChildren()) do
			if v:IsA("Part") then
				for _, c in pairs(v:GetChildren()) do
					if switch_ShowWaypoints.GetValue() == true then
						c.Visible = true
					else
						c.Visible = false
					end
				end
			elseif v.Name == "WaypointTag" then
				if switch_ShowWaypoints.GetValue() == true then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end
	end
	
	
	game:GetService("RunService").RenderStepped:Wait()
end
