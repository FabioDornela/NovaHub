-- Nova Hub | LocalScript para StarterPlayerScripts
-- Estrutura: Main.lua + pasta Modules com os ModuleScripts do projeto.

-- Delta Executor bootstrap (arquivo unico)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function getInterfaceParent()
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return playerGui
end

local moduleSources = {
    ['Config'] = [=[
local Config = {}

Config.Title = "NOVA HUB"
Config.Subtitle = "v1.2"
Config.MobileToggle = true

Config.Theme = {
	Background = Color3.fromRGB(15, 16, 22),
	Sidebar = Color3.fromRGB(20, 22, 30),
	Panel = Color3.fromRGB(25, 27, 37),
	Element = Color3.fromRGB(32, 35, 47),
	ElementHover = Color3.fromRGB(40, 44, 59),
	ElementActive = Color3.fromRGB(48, 52, 70),
	Stroke = Color3.fromRGB(48, 52, 68),
	StrokeLight = Color3.fromRGB(68, 73, 96),
	Accent = Color3.fromRGB(130, 95, 255),
	Text = Color3.fromRGB(242, 243, 248),
	Muted = Color3.fromRGB(148, 152, 168),

	-- Cores semânticas (notificações e estados)
	Info = Color3.fromRGB(130, 95, 255),
	Success = Color3.fromRGB(65, 195, 132),
	Warning = Color3.fromRGB(242, 178, 68),
	Error = Color3.fromRGB(235, 85, 105),
}

Config.Presets = {
	Violet = Color3.fromRGB(130, 95, 255),
	Blue = Color3.fromRGB(65, 145, 255),
	Green = Color3.fromRGB(65, 195, 132),
	Rose = Color3.fromRGB(235, 90, 145),
	Amber = Color3.fromRGB(245, 165, 55),
}

Config.Values = {
	NotificationsEnabled = true,
	AnimationsEnabled = true,
	Compact = false,
	UserScale = 1,
}

Config.Keybind = Enum.KeyCode.RightShift
Config.WindowSize = Vector2.new(720, 460)
Config.CompactSize = Vector2.new(580, 380)

return Config

]=],
    ['UI'] = [=[
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UI = {}

local activeTweens = setmetatable({}, { __mode = "k" })

local function getColor(theme, key, fallback)
	if theme and theme[key] then
		return theme[key]
	end
	return fallback
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function makeStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function playTween(config, instance, info, goals)
	if not instance or not instance.Parent then
		return
	end
	local animate = not config or not config.Values or config.Values.AnimationsEnabled ~= false
	if activeTweens[instance] then
		pcall(function()
			activeTweens[instance]:Cancel()
		end)
		activeTweens[instance] = nil
	end
	if not animate then
		for prop, value in pairs(goals) do
			instance[prop] = value
		end
		return
	end
	local t = TweenService:Create(instance, info, goals)
	activeTweens[instance] = t
	t:Play()
	return t
end

function UI.Create(playerGui, theme, config)
	config = config or {
		WindowSize = Vector2.new(720, 460),
		CompactSize = Vector2.new(580, 380),
		Values = { AnimationsEnabled = true, Compact = false, UserScale = 1 },
	}
	config.Values = config.Values or {}

	local connections = {}
	local themeBindings = {}

	local function bindTheme(instance, prop, key, fallbackKey)
		table.insert(themeBindings, {
			Instance = instance,
			Prop = prop,
			Key = key,
			Fallback = fallbackKey,
		})
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "NovaHub"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.IgnoreGuiInset = false
	screen.Parent = playerGui

	local main = Instance.new("Frame")
	main.Name = "Window"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.Size = UDim2.fromOffset(config.WindowSize.X, config.WindowSize.Y)
	main.BackgroundColor3 = theme.Background
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = screen
	makeCorner(main, 12)
	local mainStroke = makeStroke(main, getColor(theme, "Stroke", theme.Element), 1, 0.15)
	bindTheme(main, "BackgroundColor3", "Background")
	bindTheme(mainStroke, "Color", "Stroke", "Element")

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = main

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 54)
	header.BackgroundColor3 = theme.Sidebar
	header.BorderSizePixel = 0
	header.Parent = main
	bindTheme(header, "BackgroundColor3", "Sidebar")

	local headerDivider = Instance.new("Frame")
	headerDivider.Name = "HeaderDivider"
	headerDivider.AnchorPoint = Vector2.new(0, 1)
	headerDivider.Position = UDim2.fromScale(0, 1)
	headerDivider.Size = UDim2.new(1, 0, 0, 1)
	headerDivider.BackgroundColor3 = getColor(theme, "Stroke", theme.Element)
	headerDivider.BorderSizePixel = 0
	headerDivider.Parent = header
	bindTheme(headerDivider, "BackgroundColor3", "Stroke", "Element")

	-- Marca / Logo
	local brandHolder = Instance.new("Frame")
	brandHolder.Name = "Brand"
	brandHolder.BackgroundTransparency = 1
	brandHolder.Position = UDim2.fromOffset(16, 0)
	brandHolder.Size = UDim2.new(0, 175, 1, 0)
	brandHolder.Parent = header

	local accentDot = Instance.new("Frame")
	accentDot.Name = "AccentDot"
	accentDot.AnchorPoint = Vector2.new(0, 0.5)
	accentDot.Position = UDim2.new(0, 0, 0.5, 0)
	accentDot.Size = UDim2.fromOffset(9, 9)
	accentDot.BackgroundColor3 = theme.Accent
	accentDot.BorderSizePixel = 0
	accentDot.Parent = brandHolder
	makeCorner(accentDot, 9)
	bindTheme(accentDot, "BackgroundColor3", "Accent")

	local logo = Instance.new("TextLabel")
	logo.Name = "Logo"
	logo.BackgroundTransparency = 1
	logo.Position = UDim2.fromOffset(16, 0)
	logo.Size = UDim2.new(0, 108, 1, 0)
	logo.Font = Enum.Font.GothamBold
	logo.TextSize = 16
	logo.TextColor3 = theme.Text
	logo.TextXAlignment = Enum.TextXAlignment.Left
	logo.Text = config.Title or "NOVA HUB"
	logo.Parent = brandHolder
	bindTheme(logo, "TextColor3", "Text")

	local badge = Instance.new("TextLabel")
	badge.Name = "VersionBadge"
	badge.AnchorPoint = Vector2.new(0, 0.5)
	badge.Position = UDim2.new(0, 114, 0.5, 0)
	badge.Size = UDim2.fromOffset(38, 18)
	badge.BackgroundColor3 = theme.Element
	badge.Font = Enum.Font.GothamMedium
	badge.TextSize = 10
	badge.TextColor3 = theme.Accent
	badge.Text = config.Subtitle or "v1.2"
	badge.Parent = brandHolder
	makeCorner(badge, 5)
	bindTheme(badge, "BackgroundColor3", "Element")
	bindTheme(badge, "TextColor3", "Accent")

	-- Barra de busca com container, ícone e botão limpar
	local searchWrap = Instance.new("Frame")
	searchWrap.Name = "SearchWrap"
	searchWrap.AnchorPoint = Vector2.new(1, 0.5)
	searchWrap.Position = UDim2.new(1, -56, 0.5, 0)
	searchWrap.Size = UDim2.fromOffset(210, 32)
	searchWrap.BackgroundColor3 = theme.Element
	searchWrap.BorderSizePixel = 0
	searchWrap.Parent = header
	makeCorner(searchWrap, 8)
	local searchStroke = makeStroke(searchWrap, getColor(theme, "Stroke", theme.Element), 1, 0.25)
	bindTheme(searchWrap, "BackgroundColor3", "Element")
	bindTheme(searchStroke, "Color", "Stroke", "Element")

	local searchIcon = Instance.new("TextLabel")
	searchIcon.BackgroundTransparency = 1
	searchIcon.Position = UDim2.fromOffset(8, 0)
	searchIcon.Size = UDim2.new(0, 18, 1, 0)
	searchIcon.Font = Enum.Font.GothamBold
	searchIcon.TextSize = 13
	searchIcon.TextColor3 = theme.Muted
	searchIcon.Text = "⌕"
	searchIcon.Parent = searchWrap
	bindTheme(searchIcon, "TextColor3", "Muted")

	local search = Instance.new("TextBox")
	search.Name = "SearchInput"
	search.Position = UDim2.fromOffset(28, 0)
	search.Size = UDim2.new(1, -54, 1, 0)
	search.BackgroundTransparency = 1
	search.Text = ""
	search.PlaceholderText = "Pesquisar..."
	search.PlaceholderColor3 = theme.Muted
	search.TextColor3 = theme.Text
	search.TextSize = 12
	search.Font = Enum.Font.Gotham
	search.TextXAlignment = Enum.TextXAlignment.Left
	search.ClearTextOnFocus = false
	search.ClipsDescendants = true
	search.Parent = searchWrap
	bindTheme(search, "TextColor3", "Text")
	bindTheme(search, "PlaceholderColor3", "Muted")

	local clearSearch = Instance.new("TextButton")
	clearSearch.Name = "ClearSearch"
	clearSearch.AnchorPoint = Vector2.new(1, 0.5)
	clearSearch.Position = UDim2.new(1, -6, 0.5, 0)
	clearSearch.Size = UDim2.fromOffset(20, 20)
	clearSearch.BackgroundTransparency = 1
	clearSearch.Text = "×"
	clearSearch.TextColor3 = theme.Muted
	clearSearch.TextSize = 15
	clearSearch.Font = Enum.Font.GothamBold
	clearSearch.Visible = false
	clearSearch.Parent = searchWrap
	bindTheme(clearSearch, "TextColor3", "Muted")

	search.Focused:Connect(function()
		playTween(config, searchStroke, TweenInfo.new(0.15), { Color = theme.Accent, Transparency = 0 })
	end)
	search.FocusLost:Connect(function()
		playTween(config, searchStroke, TweenInfo.new(0.15), {
			Color = getColor(theme, "Stroke", theme.Element),
			Transparency = 0.25,
		})
	end)
	search:GetPropertyChangedSignal("Text"):Connect(function()
		clearSearch.Visible = search.Text ~= ""
	end)
	clearSearch.Activated:Connect(function()
		search.Text = ""
	end)

	-- Botão minimizar
	local minimize = Instance.new("TextButton")
	minimize.Name = "Minimize"
	minimize.AnchorPoint = Vector2.new(1, 0.5)
	minimize.Position = UDim2.new(1, -12, 0.5, 0)
	minimize.Size = UDim2.fromOffset(34, 32)
	minimize.BackgroundColor3 = theme.Element
	minimize.Text = "−"
	minimize.TextColor3 = theme.Text
	minimize.TextSize = 17
	minimize.Font = Enum.Font.GothamBold
	minimize.AutoButtonColor = false
	minimize.Parent = header
	makeCorner(minimize, 8)
	local minStroke = makeStroke(minimize, getColor(theme, "Stroke", theme.Element), 1, 0.35)
	bindTheme(minimize, "BackgroundColor3", "Element")
	bindTheme(minimize, "TextColor3", "Text")
	bindTheme(minStroke, "Color", "Stroke", "Element")

	minimize.MouseEnter:Connect(function()
		playTween(config, minimize, TweenInfo.new(0.12), { BackgroundColor3 = getColor(theme, "ElementHover", theme.Element) })
	end)
	minimize.MouseLeave:Connect(function()
		playTween(config, minimize, TweenInfo.new(0.12), { BackgroundColor3 = theme.Element })
	end)

	-- Sidebar (agora ScrollingFrame para nunca cortar abas)
	local sidebarWidth = 164
	local sidebar = Instance.new("ScrollingFrame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.fromOffset(0, 54)
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, -54)
	sidebar.BackgroundColor3 = theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.ScrollBarThickness = 2
	sidebar.ScrollBarImageColor3 = theme.Accent
	sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sidebar.CanvasSize = UDim2.new()
	sidebar.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	sidebar.Parent = main
	bindTheme(sidebar, "BackgroundColor3", "Sidebar")
	bindTheme(sidebar, "ScrollBarImageColor3", "Accent")

	local sidePadding = Instance.new("UIPadding")
	sidePadding.PaddingTop = UDim.new(0, 12)
	sidePadding.PaddingBottom = UDim.new(0, 12)
	sidePadding.PaddingLeft = UDim.new(0, 10)
	sidePadding.PaddingRight = UDim.new(0, 10)
	sidePadding.Parent = sidebar

	local sideLayout = Instance.new("UIListLayout")
	sideLayout.Padding = UDim.new(0, 6)
	sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sideLayout.Parent = sidebar

	local sideDivider = Instance.new("Frame")
	sideDivider.Name = "SidebarDivider"
	sideDivider.Position = UDim2.fromOffset(sidebarWidth, 54)
	sideDivider.Size = UDim2.new(0, 1, 1, -54)
	sideDivider.BackgroundColor3 = getColor(theme, "Stroke", theme.Element)
	sideDivider.BorderSizePixel = 0
	sideDivider.Parent = main
	bindTheme(sideDivider, "BackgroundColor3", "Stroke", "Element")

	-- Área de conteúdo
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(sidebarWidth + 1, 54)
	content.Size = UDim2.new(1, -(sidebarWidth + 1), 1, -54)
	content.BackgroundColor3 = theme.Background
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = main
	bindTheme(content, "BackgroundColor3", "Background")

	-- Estado interno da janela
	local minimized = false
	local isVisible = true
	local userScale = config.Values.UserScale or 1
	local currentAutoScale = 1

	local function getTargetSize()
		if minimized then
			return UDim2.fromOffset(230, 54)
		end
		if config.Values.Compact then
			return UDim2.fromOffset(config.CompactSize.X, config.CompactSize.Y)
		end
		return UDim2.fromOffset(config.WindowSize.X, config.WindowSize.Y)
	end

	local function getViewportSize()
		local camera = workspace.CurrentCamera
		return camera and camera.ViewportSize or Vector2.new(config.WindowSize.X, config.WindowSize.Y)
	end

	local function clampPositionToScreen()
		local screenSize = getViewportSize()
		if screenSize.X <= 0 or screenSize.Y <= 0 then
			return
		end
		local halfW = (main.AbsoluteSize.X) * 0.5
		local halfH = (main.AbsoluteSize.Y) * 0.5
		local posX = main.Position.X.Scale * screenSize.X + main.Position.X.Offset
		local posY = main.Position.Y.Scale * screenSize.Y + main.Position.Y.Offset

		local marginX = math.min(halfW, screenSize.X * 0.45)
		local marginY = math.min(halfH, screenSize.Y * 0.45)
		local clampedX = math.clamp(posX, marginX, math.max(marginX, screenSize.X - marginX))
		local clampedY = math.clamp(posY, marginY, math.max(marginY, screenSize.Y - marginY))
		main.Position = UDim2.fromOffset(clampedX, clampedY)
	end

	local function updateResponsive()
		local viewport = getViewportSize()
		if viewport.X <= 0 or viewport.Y <= 0 then
			return
		end

		local isNarrow = viewport.X < 640
		sidebarWidth = isNarrow and 132 or 164
		sidebar.Size = UDim2.new(0, sidebarWidth, 1, -54)
		sideDivider.Position = UDim2.fromOffset(sidebarWidth, 54)
		content.Position = UDim2.fromOffset(sidebarWidth + 1, 54)
		content.Size = UDim2.new(1, -(sidebarWidth + 1), 1, -54)
		searchWrap.Size = UDim2.fromOffset(isNarrow and 145 or 210, 32)

		local baseW = (config.Values.Compact and config.CompactSize.X or config.WindowSize.X) + 36
		local baseH = (config.Values.Compact and config.CompactSize.Y or config.WindowSize.Y) + 36
		currentAutoScale = math.clamp(math.min(viewport.X / baseW, viewport.Y / baseH, 1), 0.58, 1)
		scale.Scale = math.clamp(currentAutoScale * userScale, 0.52, 1.25)
	end

	local viewportConnection
	local function bindCurrentCamera()
		if not screen.Parent then return end
		if viewportConnection then
			viewportConnection:Disconnect()
			viewportConnection = nil
		end
		local camera = workspace.CurrentCamera
		if camera then
			viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)
		end
		updateResponsive()
	end
	table.insert(connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCurrentCamera))
	task.defer(bindCurrentCamera)

	-- Minimizar / Restaurar corrigido (oculta busca e respeita modo compacto)
	local function setMinimized(state)
		minimized = state == true
		sidebar.Visible = not minimized
		sideDivider.Visible = not minimized
		content.Visible = not minimized
		searchWrap.Visible = not minimized
		headerDivider.Visible = not minimized
		minimize.Text = minimized and "+" or "−"
		playTween(config, main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = getTargetSize(),
		})
	end

	minimize.Activated:Connect(function()
		setMinimized(not minimized)
	end)

	-- Drag suave com suporte a mouse e touch + clamp na tela
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function isPointInside(guiObject, pos)
		if not guiObject or not guiObject.Visible then
			return false
		end
		local absPos = guiObject.AbsolutePosition
		local absSize = guiObject.AbsoluteSize
		return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
			and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
	end

	header.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if isPointInside(searchWrap, input.Position) or isPointInside(minimize, input.Position) then
			return
		end
		dragInput = input
		dragStart = input.Position
		startPos = main.Position
	end)

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not dragInput then
			return
		end
		local isMouseMove = dragInput.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement
		local isSameTouch = dragInput.UserInputType == Enum.UserInputType.Touch
			and input == dragInput

		if isMouseMove or isSameTouch then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
			clampPositionToScreen()
		end
	end))

	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if dragInput and (input == dragInput or (dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then
			dragInput = nil
		end
	end))

	-- Abrir / fechar janela com animação (mantém notificações e botão mobile funcionando)
	local function setVisible(visible)
		isVisible = visible == true
		if isVisible then
			screen.Enabled = true
			main.Visible = true
			local targetScale = math.clamp(currentAutoScale * userScale, 0.52, 1.25)
			if config.Values.AnimationsEnabled ~= false then
				scale.Scale = targetScale * 0.94
				playTween(config, scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = targetScale,
				})
			else
				scale.Scale = targetScale
			end
		else
			if config.Values.AnimationsEnabled ~= false then
				local targetScale = math.clamp(currentAutoScale * userScale, 0.52, 1.25)
				local t = playTween(config, scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Scale = targetScale * 0.94,
				})
				if t then
					t.Completed:Once(function()
						if not isVisible then
							main.Visible = false
						end
					end)
				end
			else
				main.Visible = false
			end
		end
	end

	-- Botão flutuante para Mobile / Touch (arrastável)
	local floatingButton = nil
	if config.MobileToggle ~= false and UserInputService.TouchEnabled then
		floatingButton = Instance.new("TextButton")
		floatingButton.Name = "NovaToggleButton"
		floatingButton.AnchorPoint = Vector2.new(0, 0.5)
		floatingButton.Position = UDim2.new(0, 14, 0.5, 0)
		floatingButton.Size = UDim2.fromOffset(44, 44)
		floatingButton.BackgroundColor3 = theme.Sidebar
		floatingButton.Text = "N"
		floatingButton.TextColor3 = theme.Accent
		floatingButton.TextSize = 18
		floatingButton.Font = Enum.Font.GothamBold
		floatingButton.AutoButtonColor = false
		floatingButton.ZIndex = 20
		floatingButton.Parent = screen
		makeCorner(floatingButton, 22)
		local floatStroke = makeStroke(floatingButton, theme.Accent, 1.5, 0.1)
		bindTheme(floatingButton, "BackgroundColor3", "Sidebar")
		bindTheme(floatingButton, "TextColor3", "Accent")
		bindTheme(floatStroke, "Color", "Accent")

		local btnDragInput, btnStartPos, btnOrigin, btnMoved = nil, nil, nil, false
		floatingButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				btnDragInput = input
				btnStartPos = input.Position
				btnOrigin = floatingButton.Position
				btnMoved = false
			end
		end)
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			if btnDragInput and (input == btnDragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local delta = input.Position - btnStartPos
				if delta.Magnitude > 8 then
					btnMoved = true
					floatingButton.Position = UDim2.new(
						btnOrigin.X.Scale,
						btnOrigin.X.Offset + delta.X,
						btnOrigin.Y.Scale,
						btnOrigin.Y.Offset + delta.Y
					)
				end
			end
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if btnDragInput and input == btnDragInput then
				btnDragInput = nil
			end
		end))
		floatingButton.Activated:Connect(function()
			if not btnMoved then
				setVisible(not isVisible)
			end
		end)
	end

	local uiObject
	uiObject = {
		Screen = screen,
		Main = main,
		Header = header,
		Sidebar = sidebar,
		Content = content,
		Search = search,
		Minimize = minimize,
		FloatingButton = floatingButton,
		_Config = config,
		_Theme = theme,
		_ThemeBindings = themeBindings,
		_TabCount = 0,
		_Pages = nil,
		_ActivePage = nil,

		Toggle = function()
			setVisible(not isVisible)
		end,
		SetVisible = setVisible,
		SetMinimized = setMinimized,
		SetCompact = function(isCompact)
			config.Values.Compact = isCompact == true
			if not minimized then
				playTween(config, main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = getTargetSize(),
				})
			end
			updateResponsive()
		end,
		SetUserScale = function(factor)
			userScale = math.clamp(factor or 1, 0.7, 1.25)
			config.Values.UserScale = userScale
			updateResponsive()
		end,
		SetTheme = function(newTheme)
			UI.ApplyTheme(uiObject, newTheme)
		end,
		Destroy = function()
			if viewportConnection then viewportConnection:Disconnect() viewportConnection = nil end
			for _, conn in ipairs(connections) do
				conn:Disconnect()
			end
			table.clear(connections)
			if screen and screen.Parent then
				screen:Destroy()
			end
		end,
	}

	screen.Destroying:Connect(function()
		if viewportConnection then viewportConnection:Disconnect() viewportConnection = nil end
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		table.clear(connections)
	end)

	return uiObject
end

function UI.ApplyTheme(ui, newTheme)
	if not ui or not newTheme then
		return
	end
	ui._Theme = newTheme
	for _, entry in ipairs(ui._ThemeBindings or {}) do
		if entry.Instance and entry.Instance.Parent then
			local color = newTheme[entry.Key] or (entry.Fallback and newTheme[entry.Fallback])
			if color then
				entry.Instance[entry.Prop] = color
			end
		end
	end
	if ui._Pages and ui._ActivePage then
		UI.SwitchPage(ui._Pages, ui._ActivePage, newTheme, ui._Config)
	end
end

function UI.CreatePage(ui, theme, name, icon)
	ui._TabCount = (ui._TabCount or 0) + 1

	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = theme.Accent
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new()
	page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	page.Visible = false
	page.Parent = ui.Content
	table.insert(ui._ThemeBindings, { Instance = page, Prop = "ScrollBarImageColor3", Key = "Accent" })

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 18)
	padding.Parent = page

	local tab = Instance.new("TextButton")
	tab.Name = "Tab_" .. name
	tab.LayoutOrder = ui._TabCount
	tab.Size = UDim2.new(1, 0, 0, 38)
	tab.BackgroundColor3 = theme.Sidebar
	tab.Text = ""
	tab.AutoButtonColor = false
	tab.Parent = ui.Sidebar
	makeCorner(tab, 8)

	local indicator = Instance.new("Frame")
	indicator.Name = "ActiveIndicator"
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.Position = UDim2.new(0, 0, 0.5, 0)
	indicator.Size = UDim2.fromOffset(3, 0)
	indicator.BackgroundColor3 = theme.Accent
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.Parent = tab
	makeCorner(indicator, 3)

	local tabLabel = Instance.new("TextLabel")
	tabLabel.Name = "Label"
	tabLabel.BackgroundTransparency = 1
	tabLabel.Position = UDim2.fromOffset(12, 0)
	tabLabel.Size = UDim2.new(1, -18, 1, 0)
	tabLabel.Font = Enum.Font.GothamMedium
	tabLabel.TextSize = 12
	tabLabel.TextColor3 = theme.Muted
	tabLabel.TextXAlignment = Enum.TextXAlignment.Left
	tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
	tabLabel.Text = (icon and icon ~= "" and (icon .. "   ") or "") .. name
	tabLabel.Parent = tab

	tab:SetAttribute("IsActive", false)

	tab.MouseEnter:Connect(function()
		if not tab:GetAttribute("IsActive") then
			local currentTheme = ui._Theme or theme
			playTween(ui._Config, tab, TweenInfo.new(0.12), {
				BackgroundColor3 = getColor(currentTheme, "Element", currentTheme.Sidebar),
			})
		end
	end)

	tab.MouseLeave:Connect(function()
		if not tab:GetAttribute("IsActive") then
			local currentTheme = ui._Theme or theme
			playTween(ui._Config, tab, TweenInfo.new(0.12), {
				BackgroundColor3 = currentTheme.Sidebar,
			})
		end
	end)

	return page, tab
end

function UI.SwitchPage(pages, name, theme, config)
	for pageName, data in pairs(pages) do
		local active = pageName == name
		local page = data.Page
		local tab = data.Tab
		page.Visible = active
		tab:SetAttribute("IsActive", active)

		local label = tab:FindFirstChild("Label")
		local indicator = tab:FindFirstChild("ActiveIndicator")

		if active then
			-- Transição sutil ao entrar na página
			page.CanvasPosition = Vector2.new(0, page.CanvasPosition.Y)
		end

		playTween(config, tab, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = active and getColor(theme, "Element", theme.Accent) or theme.Sidebar,
			TextColor3 = active and theme.Text or theme.Muted,
		})

		if label then
			playTween(config, label, TweenInfo.new(0.16), {
				TextColor3 = active and theme.Text or theme.Muted,
			})
		end

		if indicator then
			indicator.BackgroundColor3 = theme.Accent
			playTween(config, indicator, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = active and UDim2.fromOffset(3, 20) or UDim2.fromOffset(3, 0),
				BackgroundTransparency = active and 0 or 1,
			})
		end
	end
end

return UI

]=],
    ['Components'] = [=[
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Components = {}

local theme = nil
local configRef = nil
local searchItems = {} -- { Row = Instance, Section = Instance? }
local sections = {} -- { Section = Frame, Container = Frame }
local themeBindings = {} -- { Instance, Prop, Key, Fallback, CustomFn }
local activeTweens = setmetatable({}, { __mode = "k" })

-- Gerenciadores globais únicos (evita criar dezenas de conexões no UserInputService)
local activeSlider = nil
local activeKeybindListener = nil
local registeredKeybinds = {}
local globalInputInitialized = false
local globalInputConnections = {}

local function getColor(key, fallbackKey)
	if not theme then
		return Color3.new(1, 1, 1)
	end
	return theme[key] or (fallbackKey and theme[fallbackKey]) or theme.Element
end

local function makeCorner(object, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 7)
	c.Parent = object
	return c
end

local function makeStroke(object, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = object
	return s
end

local function playTween(instance, info, goals)
	if not instance or not instance.Parent then
		return
	end
	local animate = not configRef or not configRef.Values or configRef.Values.AnimationsEnabled ~= false
	if activeTweens[instance] then
		pcall(function()
			activeTweens[instance]:Cancel()
		end)
		activeTweens[instance] = nil
	end
	if not animate then
		for prop, value in pairs(goals) do
			instance[prop] = value
		end
		return
	end
	local t = TweenService:Create(instance, info, goals)
	activeTweens[instance] = t
	t:Play()
	return t
end

local function bindTheme(instance, prop, key, fallbackKey)
	table.insert(themeBindings, {
		Instance = instance,
		Prop = prop,
		Key = key,
		Fallback = fallbackKey,
	})
end

local function bindThemeCallback(instance, callback)
	table.insert(themeBindings, {
		Instance = instance,
		CustomFn = callback,
	})
end

local function ensureGlobalInput()
	if globalInputInitialized then
		return
	end
	globalInputInitialized = true

	table.insert(globalInputConnections, UserInputService.InputChanged:Connect(function(input)
		if not activeSlider then
			return
		end
		local isMouse = activeSlider.Input.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement
		local isTouch = activeSlider.Input.UserInputType == Enum.UserInputType.Touch
			and input == activeSlider.Input

		if isMouse or isTouch then
			activeSlider.Update(input)
		end
	end))

	table.insert(globalInputConnections, UserInputService.InputEnded:Connect(function(input)
		if not activeSlider then
			return
		end
		local endedMouse = activeSlider.Input.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseButton1
		local endedTouch = activeSlider.Input.UserInputType == Enum.UserInputType.Touch
			and input == activeSlider.Input

		if endedMouse or endedTouch then
			local finish = activeSlider.Finish
			activeSlider = nil
			if finish then
				finish()
			end
		end
	end))

	table.insert(globalInputConnections, UserInputService.InputBegan:Connect(function(input, processed)
		if activeKeybindListener then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					activeKeybindListener.Cancel()
				elseif input.KeyCode ~= Enum.KeyCode.Unknown then
					activeKeybindListener.Assign(input.KeyCode)
				end
				activeKeybindListener = nil
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				-- Cancela ao clicar fora, sem cancelar um novo Keybind ativado no mesmo clique.
				local listenerAtClick = activeKeybindListener
				task.defer(function()
					if activeKeybindListener == listenerAtClick then
						listenerAtClick.Cancel()
						activeKeybindListener = nil
					end
				end)
			end
			return
		end

		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		for i = #registeredKeybinds, 1, -1 do
			local kb = registeredKeybinds[i]
			if not kb.Row or not kb.Row.Parent then
				table.remove(registeredKeybinds, i)
			elseif kb.GetKey() == input.KeyCode then
				kb.Trigger()
			end
		end
	end))
end

local function register(row, searchableName)
	row:SetAttribute("SearchName", string.lower(tostring(searchableName or "")))
	table.insert(searchItems, { Row = row })
end

local function formatNumber(val, step)
	if step >= 1 then
		return tostring(math.floor(val + 0.5))
	end
	local decimals = math.max(1, math.ceil(-math.log10(step)))
	return string.format("%." .. tostring(decimals) .. "f", val)
end

function Components.Init(colors, config)
	theme = colors
	configRef = config or configRef
	ensureGlobalInput()
end

function Components.Destroy()
	for _, connection in ipairs(globalInputConnections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(globalInputConnections)
	globalInputInitialized = false
	activeSlider = nil
	activeKeybindListener = nil
	table.clear(registeredKeybinds)
	table.clear(searchItems)
	table.clear(sections)
	table.clear(themeBindings)
end

function Components.RefreshTheme(newTheme)
	theme = newTheme or theme
	for i = #themeBindings, 1, -1 do
		local entry = themeBindings[i]
		if not entry.Instance or not entry.Instance.Parent then
			table.remove(themeBindings, i)
		elseif entry.CustomFn then
			entry.CustomFn(theme)
		else
			local color = getColor(entry.Key, entry.Fallback)
			if color then
				entry.Instance[entry.Prop] = color
			end
		end
	end
end

function Components.Section(parent, title)
	local section = Instance.new("Frame")
	section.Name = "Section_" .. tostring(title)
	section.BackgroundTransparency = 1
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.Parent = parent

	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 6)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section

	local headerRow = Instance.new("Frame")
	headerRow.Name = "SectionHeader"
	headerRow.LayoutOrder = 1
	headerRow.BackgroundTransparency = 1
	headerRow.Size = UDim2.new(1, 0, 0, 22)
	headerRow.Parent = section

	local accentBar = Instance.new("Frame")
	accentBar.AnchorPoint = Vector2.new(0, 0.5)
	accentBar.Position = UDim2.new(0, 2, 0.5, 0)
	accentBar.Size = UDim2.fromOffset(3, 12)
	accentBar.BackgroundColor3 = theme.Accent
	accentBar.BorderSizePixel = 0
	accentBar.Parent = headerRow
	makeCorner(accentBar, 2)
	bindTheme(accentBar, "BackgroundColor3", "Accent")

	local heading = Instance.new("TextLabel")
	heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromOffset(10, 0)
	heading.Size = UDim2.new(1, -10, 1, 0)
	heading.Font = Enum.Font.GothamBold
	heading.TextSize = 12
	heading.TextColor3 = theme.Text
	heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.Text = string.upper(tostring(title))
	heading.Parent = headerRow
	bindTheme(heading, "TextColor3", "Text")

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.LayoutOrder = 2
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundColor3 = theme.Panel
	container.BorderSizePixel = 0
	container.Parent = section
	makeCorner(container, 10)
	local containerStroke = makeStroke(container, getColor("Stroke", "Element"), 1, 0.3)
	bindTheme(container, "BackgroundColor3", "Panel")
	bindTheme(containerStroke, "Color", "Stroke", "Element")

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = container

	table.insert(sections, { Section = section, Container = container })
	return container
end

function Components.Filter(query)
	query = string.lower(query or "")

	for i = #searchItems, 1, -1 do
		local entry = searchItems[i]
		if not entry.Row or not entry.Row.Parent then
			table.remove(searchItems, i)
		else
			local name = entry.Row:GetAttribute("SearchName") or ""
			entry.Row.Visible = (query == "") or (string.find(name, query, 1, true) ~= nil)
		end
	end

	-- Oculta seções que ficaram completamente vazias durante a busca
	for i = #sections, 1, -1 do
		local entry = sections[i]
		if not entry.Section or not entry.Section.Parent then
			table.remove(sections, i)
		elseif query == "" then
			entry.Section.Visible = true
		else
			local hasVisibleChild = false
			for _, child in ipairs(entry.Container:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible and child:GetAttribute("SearchName") ~= nil then
					hasVisibleChild = true
					break
				end
			end
			entry.Section.Visible = hasVisibleChild
		end
	end
end

function Components.Button(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Name = "Button_" .. tostring(text)
	button.Size = UDim2.new(1, 0, 0, 38)
	button.BackgroundColor3 = theme.Element
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = parent
	makeCorner(button, 8)
	local stroke = makeStroke(button, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(button, "BackgroundColor3", "Element")
	bindTheme(stroke, "Color", "Stroke", "Element")

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -38, 1, 0)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextColor3 = theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = tostring(text)
	label.Parent = button
	bindTheme(label, "TextColor3", "Text")

	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -12, 0.5, 0)
	arrow.Size = UDim2.fromOffset(14, 16)
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 14
	arrow.TextColor3 = theme.Muted
	arrow.Text = "›"
	arrow.Parent = button
	bindTheme(arrow, "TextColor3", "Muted")

	button.MouseEnter:Connect(function()
		playTween(button, TweenInfo.new(0.14), { BackgroundColor3 = getColor("ElementHover", "Element") })
		playTween(stroke, TweenInfo.new(0.14), { Color = theme.Accent, Transparency = 0.15 })
		playTween(arrow, TweenInfo.new(0.14), { TextColor3 = theme.Accent, Position = UDim2.new(1, -9, 0.5, 0) })
	end)

	button.MouseLeave:Connect(function()
		playTween(button, TweenInfo.new(0.14), { BackgroundColor3 = theme.Element })
		playTween(stroke, TweenInfo.new(0.14), { Color = getColor("Stroke", "Element"), Transparency = 0.35 })
		playTween(arrow, TweenInfo.new(0.14), { TextColor3 = theme.Muted, Position = UDim2.new(1, -12, 0.5, 0) })
	end)

	button.MouseButton1Down:Connect(function()
		playTween(button, TweenInfo.new(0.08), { BackgroundColor3 = getColor("ElementActive", "Element") })
	end)

	button.MouseButton1Up:Connect(function()
		playTween(button, TweenInfo.new(0.12), { BackgroundColor3 = getColor("ElementHover", "Element") })
	end)

	button.Activated:Connect(function()
		if callback then
			callback()
		end
	end)

	register(button, text)
	return button
end

function Components.Toggle(parent, name, default, callback)
	local value = default == true

	-- Linha inteira clicável (muito melhor em telas touch)
	local row = Instance.new("TextButton")
	row.Name = "Toggle_" .. tostring(name)
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = theme.Element
	row.Text = ""
	row.AutoButtonColor = false
	row.Parent = parent
	makeCorner(row, 8)
	local rowStroke = makeStroke(row, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(row, "BackgroundColor3", "Element")
	bindTheme(rowStroke, "Color", "Stroke", "Element")

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -68, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = tostring(name)
	label.Parent = row
	bindTheme(label, "TextColor3", "Text")

	local switch = Instance.new("Frame")
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -12, 0.5, 0)
	switch.Size = UDim2.fromOffset(40, 22)
	switch.BackgroundColor3 = value and theme.Accent or theme.Background
	switch.BorderSizePixel = 0
	switch.Parent = row
	makeCorner(switch, 20)
	local switchStroke = makeStroke(switch, value and theme.Accent or getColor("StrokeLight", "Stroke"), 1, value and 0.1 or 0.35)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = switch
	makeCorner(knob, 20)

	local function refreshVisual(instant)
		local info = instant and TweenInfo.new(0) or TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		playTween(switch, info, { BackgroundColor3 = value and theme.Accent or theme.Background })
		playTween(switchStroke, info, {
			Color = value and theme.Accent or getColor("StrokeLight", "Stroke"),
			Transparency = value and 0.1 or 0.35,
		})
		playTween(knob, instant and TweenInfo.new(0) or TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		})
	end

	bindThemeCallback(row, function()
		refreshVisual(true)
	end)

	row.MouseEnter:Connect(function()
		playTween(row, TweenInfo.new(0.12), { BackgroundColor3 = getColor("ElementHover", "Element") })
	end)
	row.MouseLeave:Connect(function()
		playTween(row, TweenInfo.new(0.12), { BackgroundColor3 = theme.Element })
	end)

	local function set(nextValue, silent)
		value = nextValue == true
		refreshVisual(false)
		if callback and not silent then
			callback(value)
		end
	end

	row.Activated:Connect(function()
		set(not value)
	end)

	register(row, name)
	return set
end

function Components.Slider(parent, name, minimum, maximum, default, callback, step)
	step = (type(step) == "number" and step > 0) and step or 1
	local range = math.max(maximum - minimum, 1e-6)
	local value = math.clamp(default or minimum, minimum, maximum)

	local row = Instance.new("Frame")
	row.Name = "Slider_" .. tostring(name)
	row.Size = UDim2.new(1, 0, 0, 62)
	row.BackgroundColor3 = theme.Element
	row.BorderSizePixel = 0
	row.Parent = parent
	makeCorner(row, 8)
	local rowStroke = makeStroke(row, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(row, "BackgroundColor3", "Element")
	bindTheme(rowStroke, "Color", "Stroke", "Element")

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 6)
	label.Size = UDim2.new(1, -82, 0, 22)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = tostring(name)
	label.Parent = row
	bindTheme(label, "TextColor3", "Text")

	local valueBadge = Instance.new("TextLabel")
	valueBadge.AnchorPoint = Vector2.new(1, 0)
	valueBadge.Position = UDim2.new(1, -10, 0, 7)
	valueBadge.Size = UDim2.fromOffset(56, 20)
	valueBadge.BackgroundColor3 = theme.Background
	valueBadge.Font = Enum.Font.GothamMedium
	valueBadge.TextSize = 11
	valueBadge.TextColor3 = theme.Accent
	valueBadge.Text = formatNumber(value, step)
	valueBadge.Parent = row
	makeCorner(valueBadge, 5)
	bindTheme(valueBadge, "BackgroundColor3", "Background")
	bindTheme(valueBadge, "TextColor3", "Accent")

	-- Hitbox de 28px de altura para facilitar interação com dedo no mobile
	local hitArea = Instance.new("Frame")
	hitArea.Name = "SliderHitArea"
	hitArea.BackgroundTransparency = 1
	hitArea.Position = UDim2.fromOffset(12, 30)
	hitArea.Size = UDim2.new(1, -24, 0, 28)
	hitArea.Parent = row

	local track = Instance.new("Frame")
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.fromScale(0, 0.5)
	track.Size = UDim2.new(1, 0, 0, 6)
	track.BackgroundColor3 = theme.Background
	track.BorderSizePixel = 0
	track.Parent = hitArea
	makeCorner(track, 6)
	bindTheme(track, "BackgroundColor3", "Background")

	local initialRatio = (value - minimum) / range
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initialRatio, 0, 1, 0)
	fill.BackgroundColor3 = theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	makeCorner(fill, 6)
	bindTheme(fill, "BackgroundColor3", "Accent")

	local thumb = Instance.new("Frame")
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new(initialRatio, 0, 0.5, 0)
	thumb.Size = UDim2.fromOffset(14, 14)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	thumb.Parent = track
	makeCorner(thumb, 14)
	local thumbStroke = makeStroke(thumb, theme.Accent, 2, 0)
	bindTheme(thumbStroke, "Color", "Accent")

	local function snap(rawValue)
		local stepped = math.floor(((rawValue - minimum) / step) + 0.5) * step + minimum
		return math.clamp(stepped, minimum, maximum)
	end

	local function set(nextValue, silent)
		local snapped = snap(nextValue)
		local changed = math.abs(snapped - value) > 1e-6
		value = snapped
		local ratio = (value - minimum) / range
		valueBadge.Text = formatNumber(value, step)
		playTween(fill, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(ratio, 0, 1, 0),
		})
		playTween(thumb, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(ratio, 0, 0.5, 0),
		})
		if callback and not silent and changed then
			callback(value)
		end
	end

	local function updateFromInput(input)
		local width = math.max(track.AbsoluteSize.X, 1)
		local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
		set(minimum + range * ratio)
	end

	hitArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			playTween(thumb, TweenInfo.new(0.12), { Size = UDim2.fromOffset(17, 17) })
			activeSlider = {
				Input = input,
				Update = updateFromInput,
				Finish = function()
					playTween(thumb, TweenInfo.new(0.12), { Size = UDim2.fromOffset(14, 14) })
				end,
			}
			updateFromInput(input)
		end
	end)

	register(row, name)
	return set
end

function Components.Dropdown(parent, name, options, default, callback)
	options = options or {}
	local selected = default or options[1] or ""
	local isOpen = false
	local optionButtons = {}

	local holder = Instance.new("Frame")
	holder.Name = "Dropdown_" .. tostring(name)
	holder.Size = UDim2.new(1, 0, 0, 0)
	holder.BackgroundTransparency = 1
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.Parent = parent

	-- Corrige o bug de sobreposição: empilha a linha e a lista verticalmente
	local holderLayout = Instance.new("UIListLayout")
	holderLayout.Padding = UDim.new(0, 4)
	holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	holderLayout.Parent = holder

	local row = Instance.new("TextButton")
	row.LayoutOrder = 1
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = theme.Element
	row.Text = ""
	row.AutoButtonColor = false
	row.Parent = holder
	makeCorner(row, 8)
	local rowStroke = makeStroke(row, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(row, "BackgroundColor3", "Element")
	bindTheme(rowStroke, "Color", "Stroke", "Element")

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(0.48, -12, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = tostring(name)
	label.Parent = row
	bindTheme(label, "TextColor3", "Text")

	local pickerBox = Instance.new("Frame")
	pickerBox.AnchorPoint = Vector2.new(1, 0.5)
	pickerBox.Position = UDim2.new(1, -8, 0.5, 0)
	pickerBox.Size = UDim2.new(0.5, -4, 0, 28)
	pickerBox.BackgroundColor3 = theme.Background
	pickerBox.BorderSizePixel = 0
	pickerBox.Parent = row
	makeCorner(pickerBox, 6)
	local pickerStroke = makeStroke(pickerBox, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(pickerBox, "BackgroundColor3", "Background")
	bindTheme(pickerStroke, "Color", "Stroke", "Element")

	local pickerText = Instance.new("TextLabel")
	pickerText.BackgroundTransparency = 1
	pickerText.Position = UDim2.fromOffset(8, 0)
	pickerText.Size = UDim2.new(1, -24, 1, 0)
	pickerText.Font = Enum.Font.GothamMedium
	pickerText.TextSize = 11
	pickerText.TextColor3 = theme.Text
	pickerText.TextXAlignment = Enum.TextXAlignment.Left
	pickerText.TextTruncate = Enum.TextTruncate.AtEnd
	pickerText.Text = tostring(selected)
	pickerText.Parent = pickerBox
	bindTheme(pickerText, "TextColor3", "Text")

	local chevron = Instance.new("TextLabel")
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -6, 0.5, 0)
	chevron.Size = UDim2.fromOffset(14, 14)
	chevron.Font = Enum.Font.GothamBold
	chevron.TextSize = 11
	chevron.TextColor3 = theme.Muted
	chevron.Text = "▾"
	chevron.Parent = pickerBox
	bindTheme(chevron, "TextColor3", "Muted")

	local list = Instance.new("Frame")
	list.Name = "OptionsList"
	list.LayoutOrder = 2
	list.Size = UDim2.new(1, 0, 0, 0)
	list.BackgroundColor3 = theme.Background
	list.BorderSizePixel = 0
	list.Visible = false
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.Parent = holder
	makeCorner(list, 8)
	local listStroke = makeStroke(list, getColor("Stroke", "Element"), 1, 0.25)
	bindTheme(list, "BackgroundColor3", "Background")
	bindTheme(listStroke, "Color", "Stroke", "Element")

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	pad.Parent = list

	local function refreshOptionsVisual()
		for _, item in ipairs(optionButtons) do
			local isSelected = item.Value == selected
			item.Button.BackgroundColor3 = isSelected and getColor("ElementActive", "Element") or theme.Element
			item.Label.TextColor3 = isSelected and theme.Accent or theme.Text
			item.Check.Visible = isSelected
			item.Check.TextColor3 = theme.Accent
		end
	end

	local function setOpen(openState)
		isOpen = openState == true
		list.Visible = isOpen
		playTween(chevron, TweenInfo.new(0.15), { Rotation = isOpen and 180 or 0 })
		playTween(pickerStroke, TweenInfo.new(0.15), {
			Color = isOpen and theme.Accent or getColor("Stroke", "Element"),
			Transparency = isOpen and 0.1 or 0.35,
		})
	end

	local function choose(option, silent)
		selected = option
		pickerText.Text = tostring(selected)
		refreshOptionsVisual()
		setOpen(false)
		if callback and not silent then
			callback(selected)
		end
	end

	for index, option in ipairs(options) do
		local choice = Instance.new("TextButton")
		choice.LayoutOrder = index
		choice.Size = UDim2.new(1, 0, 0, 32)
		choice.BackgroundColor3 = theme.Element
		choice.Text = ""
		choice.AutoButtonColor = false
		choice.Parent = list
		makeCorner(choice, 6)

		local optLabel = Instance.new("TextLabel")
		optLabel.BackgroundTransparency = 1
		optLabel.Position = UDim2.fromOffset(10, 0)
		optLabel.Size = UDim2.new(1, -30, 1, 0)
		optLabel.Font = Enum.Font.Gotham
		optLabel.TextSize = 11
		optLabel.TextColor3 = theme.Text
		optLabel.TextXAlignment = Enum.TextXAlignment.Left
		optLabel.TextTruncate = Enum.TextTruncate.AtEnd
		optLabel.Text = tostring(option)
		optLabel.Parent = choice

		local check = Instance.new("TextLabel")
		check.BackgroundTransparency = 1
		check.AnchorPoint = Vector2.new(1, 0.5)
		check.Position = UDim2.new(1, -8, 0.5, 0)
		check.Size = UDim2.fromOffset(14, 14)
		check.Font = Enum.Font.GothamBold
		check.TextSize = 11
		check.TextColor3 = theme.Accent
		check.Text = "✓"
		check.Visible = option == selected
		check.Parent = choice

		choice.MouseEnter:Connect(function()
			if option ~= selected then
				playTween(choice, TweenInfo.new(0.1), { BackgroundColor3 = getColor("ElementHover", "Element") })
			end
		end)
		choice.MouseLeave:Connect(function()
			if option ~= selected then
				playTween(choice, TweenInfo.new(0.1), { BackgroundColor3 = theme.Element })
			end
		end)
		choice.Activated:Connect(function()
			choose(option)
		end)

		table.insert(optionButtons, {
			Value = option,
			Button = choice,
			Label = optLabel,
			Check = check,
		})
	end

	refreshOptionsVisual()
	bindThemeCallback(holder, refreshOptionsVisual)

	row.MouseEnter:Connect(function()
		playTween(row, TweenInfo.new(0.12), { BackgroundColor3 = getColor("ElementHover", "Element") })
	end)
	row.MouseLeave:Connect(function()
		playTween(row, TweenInfo.new(0.12), { BackgroundColor3 = theme.Element })
	end)
	row.Activated:Connect(function()
		setOpen(not isOpen)
	end)

	register(holder, name)
	return choose
end

function Components.Keybind(parent, name, defaultKey, callback)
	local key = defaultKey or Enum.KeyCode.F
	local listening = false

	local row = Instance.new("Frame")
	row.Name = "Keybind_" .. tostring(name)
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = theme.Element
	row.BorderSizePixel = 0
	row.Parent = parent
	makeCorner(row, 8)
	local rowStroke = makeStroke(row, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(row, "BackgroundColor3", "Element")
	bindTheme(rowStroke, "Color", "Stroke", "Element")

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -110, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = tostring(name)
	label.Parent = row
	bindTheme(label, "TextColor3", "Text")

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Size = UDim2.fromOffset(86, 26)
	button.Position = UDim2.new(1, -10, 0.5, 0)
	button.BackgroundColor3 = theme.Background
	button.Text = key.Name
	button.TextColor3 = theme.Accent
	button.TextSize = 11
	button.Font = Enum.Font.GothamMedium
	button.AutoButtonColor = false
	button.Parent = row
	makeCorner(button, 6)
	local btnStroke = makeStroke(button, getColor("Stroke", "Element"), 1, 0.3)
	bindTheme(button, "BackgroundColor3", "Background")
	bindTheme(button, "TextColor3", "Accent")
	bindTheme(btnStroke, "Color", "Stroke", "Element")

	local function stopListening()
		listening = false
		button.Text = key.Name
		playTween(btnStroke, TweenInfo.new(0.14), {
			Color = getColor("Stroke", "Element"),
			Transparency = 0.3,
		})
	end

	button.Activated:Connect(function()
		if activeKeybindListener then
			activeKeybindListener.Cancel()
			activeKeybindListener = nil
		end
		listening = true
		button.Text = "Tecla..."
		playTween(btnStroke, TweenInfo.new(0.14), { Color = theme.Accent, Transparency = 0 })

		activeKeybindListener = {
			Assign = function(newKey)
				key = newKey
				stopListening()
			end,
			Cancel = stopListening,
		}
	end)

	table.insert(registeredKeybinds, {
		Row = row,
		GetKey = function()
			return key
		end,
		Trigger = function()
			if not listening and callback then
				callback(key)
			end
		end,
	})

	register(row, name)
	return function(newKey)
		if typeof(newKey) == "EnumItem" and newKey.EnumType == Enum.KeyCode then
			key = newKey
			if not listening then
				button.Text = key.Name
			end
		end
	end
end

-- Novo componente: TextBox completo com feedback de foco
function Components.TextBox(parent, name, placeholder, defaultText, callback)
	local row = Instance.new("Frame")
	row.Name = "TextBox_" .. tostring(name)
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundColor3 = theme.Element
	row.BorderSizePixel = 0
	row.Parent = parent
	makeCorner(row, 8)
	local rowStroke = makeStroke(row, getColor("Stroke", "Element"), 1, 0.35)
	bindTheme(row, "BackgroundColor3", "Element")
	bindTheme(rowStroke, "Color", "Stroke", "Element")

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(0.45, -12, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = tostring(name)
	label.Parent = row
	bindTheme(label, "TextColor3", "Text")

	local inputWrap = Instance.new("Frame")
	inputWrap.AnchorPoint = Vector2.new(1, 0.5)
	inputWrap.Position = UDim2.new(1, -8, 0.5, 0)
	inputWrap.Size = UDim2.new(0.53, -4, 0, 28)
	inputWrap.BackgroundColor3 = theme.Background
	inputWrap.BorderSizePixel = 0
	inputWrap.Parent = row
	makeCorner(inputWrap, 6)
	local inputStroke = makeStroke(inputWrap, getColor("Stroke", "Element"), 1, 0.3)
	bindTheme(inputWrap, "BackgroundColor3", "Background")
	bindTheme(inputStroke, "Color", "Stroke", "Element")

	local box = Instance.new("TextBox")
	box.BackgroundTransparency = 1
	box.Position = UDim2.fromOffset(8, 0)
	box.Size = UDim2.new(1, -16, 1, 0)
	box.Font = Enum.Font.Gotham
	box.TextSize = 11
	box.TextColor3 = theme.Text
	box.PlaceholderText = tostring(placeholder or "Digite aqui...")
	box.PlaceholderColor3 = theme.Muted
	box.Text = tostring(defaultText or "")
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.ClearTextOnFocus = false
	box.ClipsDescendants = true
	box.Parent = inputWrap
	bindTheme(box, "TextColor3", "Text")
	bindTheme(box, "PlaceholderColor3", "Muted")

	box.Focused:Connect(function()
		playTween(inputStroke, TweenInfo.new(0.14), { Color = theme.Accent, Transparency = 0 })
	end)

	box.FocusLost:Connect(function(enterPressed)
		playTween(inputStroke, TweenInfo.new(0.14), {
			Color = getColor("Stroke", "Element"),
			Transparency = 0.3,
		})
		if callback then
			callback(box.Text, enterPressed)
		end
	end)

	register(row, name)
	return function(newText)
		box.Text = tostring(newText or "")
	end
end

-- Novo componente: Label informativo / status dinâmico
function Components.Label(parent, text, muted)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = muted and theme.Muted or theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.Text = tostring(text)
	label.Parent = parent

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.PaddingTop = UDim.new(0, 2)
	pad.PaddingBottom = UDim.new(0, 2)
	pad.Parent = label

	bindTheme(label, "TextColor3", muted and "Muted" or "Text")
	register(label, text)

	return function(newText)
		label.Text = tostring(newText or "")
	end
end

-- Novo componente: Divider horizontal sutil
function Components.Divider(parent)
	local line = Instance.new("Frame")
	line.Name = "Divider"
	line.Size = UDim2.new(1, 0, 0, 1)
	line.BackgroundColor3 = getColor("Stroke", "Element")
	line.BackgroundTransparency = 0.35
	line.BorderSizePixel = 0
	line.Parent = parent
	bindTheme(line, "BackgroundColor3", "Stroke", "Element")
	return line
end

return Components

]=],
    ['Notifications'] = [=[
local TweenService = game:GetService("TweenService")

local Notifications = {}

local notifGui = nil
local holder = nil
local theme = nil
local configRef = nil
local enabled = true
local maxVisible = 4
local activeCount = 0
local queue = {}
local activeToasts = {}
local initConnections = {}
local viewportConnection = nil

local TYPE_META = {
	Info = { Key = "Info", Icon = "i" },
	Success = { Key = "Success", Icon = "✓" },
	Warning = { Key = "Warning", Icon = "!" },
	Error = { Key = "Error", Icon = "×" },
}

local function getTypeColor(notifType)
	local meta = TYPE_META[notifType] or TYPE_META.Info
	if theme and theme[meta.Key] then
		return theme[meta.Key], meta.Icon
	end
	return (theme and theme.Accent) or Color3.fromRGB(130, 95, 255), meta.Icon
end

local function shouldAnimate()
	return not configRef or not configRef.Values or configRef.Values.AnimationsEnabled ~= false
end

local function updateHolderWidth()
	if not holder or not notifGui then
		return
	end
	local camera = workspace.CurrentCamera
	local screenX = camera and camera.ViewportSize.X or 0
	if screenX > 0 then
		local width = math.clamp(screenX - 28, 220, 310)
		holder.Size = UDim2.new(0, width, 1, -30)
	end
end

function Notifications.Init(parent, colors, config)
	theme = colors
	configRef = config or configRef
	enabled = not (configRef and configRef.Values and configRef.Values.NotificationsEnabled == false)

	-- Se parent for um ScreenGui, cria um ScreenGui irmão dedicado para continuar visível com o Hub fechado
	if parent and parent:IsA("ScreenGui") and parent.Parent then
		local existing = parent.Parent:FindFirstChild("NovaHub_Notifications")
		if existing then
			existing:Destroy()
		end
		notifGui = Instance.new("ScreenGui")
		notifGui.Name = "NovaHub_Notifications"
		notifGui.ResetOnSpawn = false
		notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		notifGui.DisplayOrder = 100
		notifGui.Parent = parent.Parent
		parent = notifGui
	elseif parent then
		notifGui = parent:FindFirstAncestorOfClass("ScreenGui")
	end

	holder = Instance.new("Frame")
	holder.Name = "NotificationHolder"
	holder.AnchorPoint = Vector2.new(1, 1)
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(1, -14, 1, -14)
	holder.Size = UDim2.new(0, 300, 1, -28)
	holder.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = holder

	if notifGui then
		for _, connection in ipairs(initConnections) do
			if connection.Connected then connection:Disconnect() end
		end
		table.clear(initConnections)

		if viewportConnection then
			viewportConnection:Disconnect()
			viewportConnection = nil
		end
		local function bindCurrentCamera()
			if not notifGui then return end
			if viewportConnection then
				viewportConnection:Disconnect()
				viewportConnection = nil
			end
			local camera = workspace.CurrentCamera
			if camera then
				viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHolderWidth)
			end
			updateHolderWidth()
		end

		table.insert(initConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCurrentCamera))
		task.defer(bindCurrentCamera)
	end
end

function Notifications.RefreshTheme(newTheme)
	theme = newTheme or theme
	for i = #activeToasts, 1, -1 do
		local toast = activeToasts[i]
		if not toast.Wrapper or not toast.Wrapper.Parent then
			table.remove(activeToasts, i)
		else
			local color = getTypeColor(toast.Type)
			toast.Box.BackgroundColor3 = theme.Panel
			toast.Stroke.Color = color
			toast.SideBar.BackgroundColor3 = color
			toast.IconBadge.BackgroundColor3 = color
			toast.IconBadge.TextColor3 = color
			toast.Heading.TextColor3 = theme.Text
			toast.Body.TextColor3 = theme.Muted
			toast.Progress.BackgroundColor3 = color
		end
	end
end

function Notifications.Destroy()
	if viewportConnection then
		viewportConnection:Disconnect()
		viewportConnection = nil
	end
	for _, connection in ipairs(initConnections) do
		if connection.Connected then connection:Disconnect() end
	end
	table.clear(initConnections)
	table.clear(queue)
	table.clear(activeToasts)
	activeCount = 0
	holder = nil
	if notifGui and notifGui.Parent then
		notifGui:Destroy()
	end
	notifGui = nil
end

function Notifications.SetEnabled(value)
	enabled = value == true
	if not enabled then
		table.clear(queue)
	end
end

local displayNext

local function createToast(title, message, duration, notifType)
	activeCount += 1
	duration = duration or 3.5
	local accentColor, iconChar = getTypeColor(notifType or "Info")

	local wrapper = Instance.new("Frame")
	wrapper.Name = "ToastWrapper"
	wrapper.BackgroundTransparency = 1
	wrapper.Size = UDim2.new(1, 0, 0, 0)
	wrapper.AutomaticSize = Enum.AutomaticSize.Y
	wrapper.ClipsDescendants = false
	wrapper.Parent = holder

	local box = Instance.new("TextButton")
	box.Name = "Toast"
	box.Size = UDim2.new(1, 0, 0, 0)
	box.Position = UDim2.fromOffset(shouldAnimate() and 40 or 0, 0)
	box.AutomaticSize = Enum.AutomaticSize.Y
	box.BackgroundColor3 = theme.Panel
	box.BackgroundTransparency = shouldAnimate() and 1 or 0.04
	box.Text = ""
	box.AutoButtonColor = false
	box.ClipsDescendants = true
	box.Parent = wrapper

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = box

	local stroke = Instance.new("UIStroke")
	stroke.Color = accentColor
	stroke.Thickness = 1
	stroke.Transparency = shouldAnimate() and 1 or 0.35
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = box

	local sideBar = Instance.new("Frame")
	sideBar.Size = UDim2.new(0, 3, 1, 0)
	sideBar.BackgroundColor3 = accentColor
	sideBar.BackgroundTransparency = shouldAnimate() and 1 or 0
	sideBar.BorderSizePixel = 0
	sideBar.Parent = box

	local iconBadge = Instance.new("TextLabel")
	iconBadge.Position = UDim2.fromOffset(12, 11)
	iconBadge.Size = UDim2.fromOffset(20, 20)
	iconBadge.BackgroundColor3 = accentColor
	iconBadge.BackgroundTransparency = shouldAnimate() and 1 or 0.82
	iconBadge.Font = Enum.Font.GothamBold
	iconBadge.TextSize = 11
	iconBadge.TextColor3 = accentColor
	iconBadge.TextTransparency = shouldAnimate() and 1 or 0
	iconBadge.Text = iconChar
	iconBadge.Parent = box
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 10)
	iconCorner.Parent = iconBadge

	local textContainer = Instance.new("Frame")
	textContainer.BackgroundTransparency = 1
	textContainer.Position = UDim2.fromOffset(40, 0)
	textContainer.Size = UDim2.new(1, -50, 0, 0)
	textContainer.AutomaticSize = Enum.AutomaticSize.Y
	textContainer.Parent = box

	local textPad = Instance.new("UIPadding")
	textPad.PaddingTop = UDim.new(0, 10)
	textPad.PaddingBottom = UDim.new(0, 12)
	textPad.Parent = textContainer

	local textLayout = Instance.new("UIListLayout")
	textLayout.Padding = UDim.new(0, 3)
	textLayout.SortOrder = Enum.SortOrder.LayoutOrder
	textLayout.Parent = textContainer

	local heading = Instance.new("TextLabel")
	heading.LayoutOrder = 1
	heading.BackgroundTransparency = 1
	heading.Size = UDim2.new(1, 0, 0, 18)
	heading.Font = Enum.Font.GothamBold
	heading.TextSize = 12
	heading.TextColor3 = theme.Text
	heading.TextTransparency = shouldAnimate() and 1 or 0
	heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.TextTruncate = Enum.TextTruncate.AtEnd
	heading.Text = tostring(title)
	heading.Parent = textContainer

	local body = Instance.new("TextLabel")
	body.LayoutOrder = 2
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Font = Enum.Font.Gotham
	body.TextSize = 11
	body.TextColor3 = theme.Muted
	body.TextTransparency = shouldAnimate() and 1 or 0
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextWrapped = true
	body.Text = tostring(message)
	body.Parent = textContainer

	-- Barra de tempo restante na base
	local progress = Instance.new("Frame")
	progress.AnchorPoint = Vector2.new(0, 1)
	progress.Position = UDim2.fromScale(0, 1)
	progress.Size = UDim2.new(1, 0, 0, 2)
	progress.BackgroundColor3 = accentColor
	progress.BackgroundTransparency = 0.2
	progress.BorderSizePixel = 0
	progress.Parent = box

	table.insert(activeToasts, {
		Wrapper = wrapper,
		Box = box,
		Stroke = stroke,
		SideBar = sideBar,
		IconBadge = iconBadge,
		Heading = heading,
		Body = body,
		Progress = progress,
		Type = notifType or "Info",
	})

	-- Animação de entrada
	if shouldAnimate() then
		local enterInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(box, enterInfo, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.04 }):Play()
		TweenService:Create(stroke, enterInfo, { Transparency = 0.35 }):Play()
		TweenService:Create(sideBar, enterInfo, { BackgroundTransparency = 0 }):Play()
		TweenService:Create(iconBadge, enterInfo, { BackgroundTransparency = 0.82, TextTransparency = 0 }):Play()
		TweenService:Create(heading, enterInfo, { TextTransparency = 0 }):Play()
		TweenService:Create(body, enterInfo, { TextTransparency = 0 }):Play()
	end

	if shouldAnimate() then
		TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 2),
		}):Play()
	else
		progress.Size = UDim2.new(1, 0, 0, 2)
	end

	local dismissed = false
	local function dismiss()
		if dismissed then
			return
		end
		dismissed = true

		if shouldAnimate() and wrapper.Parent then
			local exitInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(box, exitInfo, { Position = UDim2.fromOffset(35, 0), BackgroundTransparency = 1 }):Play()
			TweenService:Create(stroke, exitInfo, { Transparency = 1 }):Play()
			TweenService:Create(sideBar, exitInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(iconBadge, exitInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			TweenService:Create(heading, exitInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(body, exitInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(progress, exitInfo, { BackgroundTransparency = 1 }):Play()
			task.wait(0.2)
		end

		if wrapper.Parent then
			wrapper:Destroy()
		end
		for i = #activeToasts, 1, -1 do
			if activeToasts[i].Wrapper == wrapper then
				table.remove(activeToasts, i)
				break
			end
		end
		activeCount = math.max(0, activeCount - 1)
		displayNext()
	end

	box.Activated:Connect(dismiss)
	task.delay(duration, dismiss)
end

displayNext = function()
	while activeCount < maxVisible and #queue > 0 do
		local item = table.remove(queue, 1)
		createToast(item.Title, item.Message, item.Duration, item.Type)
	end
end

function Notifications.Show(title, message, duration, notifType)
	if not enabled or not holder then
		return
	end
	table.insert(queue, {
		Title = title,
		Message = message,
		Duration = duration,
		Type = notifType or "Info",
	})
	displayNext()
end

return Notifications

]=],
    ['ThemeManager'] = [=[
local ThemeManager = {}

local theme
local presets
local consumers = {}

function ThemeManager.Init(themeTable, presetTable, targets)
    theme = themeTable
    presets = presetTable or {}
    consumers = targets or {}
end

function ThemeManager.ApplyPreset(name)
    local color = presets and presets[name]
    if not color or not theme then
        return false, "Preset de tema inválido: " .. tostring(name)
    end

    theme.Accent = color
    theme.Info = color

    for _, target in ipairs(consumers) do
        if target and target.SetTheme then
            target.SetTheme(theme)
        elseif target and target.RefreshTheme then
            target.RefreshTheme(theme)
        end
    end

    return true
end

function ThemeManager.GetTheme()
    return theme
end

function ThemeManager.Destroy()
    table.clear(consumers)
    theme = nil
    presets = nil
end

return ThemeManager

]=],
    ['StateManager'] = [=[
local StateManager = {}
StateManager.__index = StateManager

function StateManager.new(initialState)
    local self = setmetatable({}, StateManager)
    self._values = initialState or {}
    self._listeners = {}
    self._destroyed = false
    return self
end

function StateManager:Get(key)
    return self._values[key]
end

function StateManager:Set(key, value)
    if self._destroyed then return false end
    local previous = self._values[key]
    if previous == value then return false end
    self._values[key] = value

    local listeners = self._listeners[key]
    if listeners then
        for _, callback in ipairs(listeners) do
            task.spawn(callback, value, previous, key)
        end
    end
    return true
end

function StateManager:Subscribe(key, callback)
    assert(type(callback) == "function", "StateManager:Subscribe espera uma função")
    self._listeners[key] = self._listeners[key] or {}
    table.insert(self._listeners[key], callback)
    local active = true
    return function()
        if not active then return end
        active = false
        local list = self._listeners[key]
        if not list then return end
        for index = #list, 1, -1 do
            if list[index] == callback then
                table.remove(list, index)
                break
            end
        end
    end
end

function StateManager:Destroy()
    self._destroyed = true
    table.clear(self._listeners)
end

return StateManager

]=],
    ['KeybindManager'] = [=[
local KeybindManager = {}

function KeybindManager.Bind(inputService, keyCode, callback)
    assert(inputService, "KeybindManager precisa do UserInputService")
    assert(typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode, "Keybind inválido")
    assert(type(callback) == "function", "Callback do keybind precisa ser uma função")

    local connection = inputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keyCode then
            callback(input)
        end
    end)

    local disconnected = false
    return function()
        if disconnected then return end
        disconnected = true
        if connection.Connected then connection:Disconnect() end
    end
end

return KeybindManager

]=],
    ['Settings'] = [=[
local Settings = {}

function Settings.ResetInterface(setCompact, setScale)
    if type(setCompact) == "function" then
        setCompact(false)
    end
    if type(setScale) == "function" then
        setScale(100)
    end
end

return Settings

]=],
    ['ServerFinder'] = [=[
local ServerFinder = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local PLACE_ID = 4520749081

local function getRequestFunction()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    if type(env.request) == "function" then return env.request end
    if type(env.http_request) == "function" then return env.http_request end
    if type(env.syn) == "table" and type(env.syn.request) == "function" then
        return env.syn.request
    end
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    return nil
end

local function getJson(url)
    local requestFunction = getRequestFunction()
    if requestFunction then
        local response = requestFunction({
            Url = url,
            Method = "GET",
            Headers = { ["Accept"] = "application/json" },
        })
        if type(response) == "table" then
            local status = tonumber(response.StatusCode or response.Status or 200)
            if status and (status < 200 or status >= 300) then
                error("Roblox API respondeu HTTP " .. tostring(status))
            end
            local body = response.Body or response.body
            if type(body) == "table" then return body end
            if type(body) == "string" then return HttpService:JSONDecode(body) end
        end
        error("Resposta HTTP inválida do executor.")
    end

    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        error("O executor não disponibilizou request nem game:HttpGet.")
    end
    return HttpService:JSONDecode(body)
end

function ServerFinder.Fetch(maxPlayers, maxResults)
    maxPlayers = tonumber(maxPlayers)
    maxResults = math.clamp(tonumber(maxResults) or 20, 1, 50)

    local url = "https://games.roblox.com/v1/games/" .. tostring(PLACE_ID)
        .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"

    local payload = getJson(url)
    if type(payload) ~= "table" or type(payload.data) ~= "table" then
        error("A API do Roblox retornou uma lista inválida.")
    end

    local results = {}
    local currentJobId = game.JobId

    for _, server in ipairs(payload.data) do
        local playing = tonumber(server.playing) or 0
        local capacity = tonumber(server.maxPlayers) or 0
        local id = server.id

        if type(id) == "string"
            and id ~= currentJobId
            and (not maxPlayers or playing <= maxPlayers)
            and capacity > 0 then
            table.insert(results, {
                Id = id,
                Playing = playing,
                MaxPlayers = capacity,
                Ping = tonumber(server.ping),
                FPS = tonumber(server.fps),
            })
        end
    end

    table.sort(results, function(a, b)
        if a.Playing == b.Playing then
            return (a.Ping or math.huge) < (b.Ping or math.huge)
        end
        return a.Playing < b.Playing
    end)

    while #results > maxResults do
        table.remove(results)
    end

    return results
end

function ServerFinder.Join(serverId)
    assert(type(serverId) == "string" and serverId ~= "", "ID de servidor inválido")
    TeleportService:TeleportToPlaceInstance(PLACE_ID, serverId, Players.LocalPlayer)
end

return ServerFinder

]=],
}
local moduleCache = {}
local function loadModule(name)
    if moduleCache[name] then return moduleCache[name] end
    local source = moduleSources[name]
    assert(source, "Nova Hub: modulo ausente: " .. tostring(name))
    assert(type(loadstring) == "function", "Delta: loadstring indisponivel")
    local chunk, compileError = loadstring(source, "NovaHub/" .. name)
    assert(chunk, compileError)
    local result = chunk()
    moduleCache[name] = result
    return result
end
local Config = loadModule("Config")
local UI = loadModule("UI")
local Components = loadModule("Components")
local Notifications = loadModule("Notifications")
local ThemeManager = loadModule("ThemeManager")
local StateManager = loadModule("StateManager")
local KeybindManager = loadModule("KeybindManager")
local Settings = loadModule("Settings")
local ServerFinder = loadModule("ServerFinder")

local state = StateManager.new(Config.Values)
local ui = UI.Create(getInterfaceParent(), Config.Theme, Config)

-- Permite encerrar a interface antes de executar novamente.
local env = (type(getgenv) == "function" and getgenv()) or _G
if env.NovaHubUnload then pcall(env.NovaHubUnload) end
env.NovaHubUnload = function()
    if ui and ui.Screen and ui.Screen.Parent then ui.Screen:Destroy() end
end
Components.Init(Config.Theme, Config)
Notifications.Init(ui.Screen, Config.Theme, Config)

ThemeManager.Init(Config.Theme, Config.Presets, {
    ui,
    Components,
    Notifications,
})

local pages = {}
ui._Pages = pages

local function addPage(name, icon)
    local page, tab = UI.CreatePage(ui, Config.Theme, name, icon)
    pages[name] = { Page = page, Tab = tab }
    tab.Activated:Connect(function()
        ui._ActivePage = name
        UI.SwitchPage(pages, name, Config.Theme, Config)
        ui.Search.Text = ""
        Components.Filter("")
    end)
    return page
end

local Home = addPage("Home", "⌂")
local Visual = addPage("Interface", "◈")
local SettingsPage = addPage("Settings", "⚙")
local ServersPage = addPage("Server Finder", "⌕")

ui._ActivePage = "Home"
UI.SwitchPage(pages, "Home", Config.Theme, Config)

-- Home
local homeSection = Components.Section(Home, "Welcome")
Components.Label(homeSection, "Nova Hub v1.2 — Delta Executor build (single-file).", true)
Components.Divider(homeSection)

Components.Button(homeSection, "Test notification (Success)", function()
    Notifications.Show("Nova Hub", "Sistema de notificações com fila e barra de progresso ativo.", 3.5, "Success")
end)
Components.Button(homeSection, "Show warning", function()
    Notifications.Show("Aviso", "Exemplo de notificação de alerta com quebra automática de linha.", 4, "Warning")
end)
Components.Dropdown(homeSection, "Demo dropdown", { "Option A", "Option B", "Option C" }, "Option A", function(choice)
    Notifications.Show("Dropdown", "Selecionado: " .. choice, 2.5, "Info")
end)
Components.TextBox(homeSection, "Profile name", "Digite um nome...", "", function(text, enterPressed)
    if text ~= "" then
        Notifications.Show("Perfil", "Valor salvo: " .. text .. (enterPressed and " (Enter)" or ""), 3, "Success")
    end
end)
Components.Keybind(homeSection, "Demo keybind", Enum.KeyCode.G, function(key)
    Notifications.Show("Keybind", key.Name .. " pressionada.", 2.5, "Info")
end)
Components.Toggle(homeSection, "Notifications", state:Get("NotificationsEnabled"), function(value)
    state:Set("NotificationsEnabled", value)
    Notifications.SetEnabled(value)
end)

-- Server Finder
local serverControls = Components.Section(ServersPage, "Server search")
Components.Label(serverControls, "Encontre servidores públicos com poucos jogadores. A API pública não informa a idade do servidor.", true)

local selectedPlayerLimit = "0 (vazio)"
local serverStatus = Components.Label(serverControls, "Pronto para buscar.", true)
local resultsSection = Components.Section(ServersPage, "Results")

local function clearServerResults()
    for _, child in ipairs(resultsSection:GetChildren()) do
        if child:GetAttribute("NovaServerResult") then
            child:Destroy()
        end
    end
end

local function renderServerResults(servers)
    clearServerResults()

    if #servers == 0 then
        serverStatus("Nenhum servidor encontrado com esse filtro. Tente aumentar o limite de jogadores.")
        return
    end

    serverStatus("Encontrados " .. tostring(#servers) .. " servidores nesta página da lista pública.")

    for index, server in ipairs(servers) do
        local text = string.format("Servidor %02d  •  %d/%d jogadores", index, server.Playing, server.MaxPlayers)
        local button = Components.Button(resultsSection, text, function()
            serverStatus("Conectando ao servidor selecionado...")
            local ok, err = pcall(function()
                ServerFinder.Join(server.Id)
            end)
            if not ok then
                serverStatus("Não foi possível entrar: " .. tostring(err))
                Notifications.Show("Server Finder", "Falha ao entrar no servidor selecionado.", 4, "Error")
            end
        end)
        button:SetAttribute("NovaServerResult", true)
    end
end

Components.Dropdown(serverControls, "Máximo de jogadores", {
    "0 (vazio)", "1", "2", "3", "4", "5", "Sem filtro"
}, selectedPlayerLimit, function(value)
    selectedPlayerLimit = value
end)

Components.Button(serverControls, "Buscar servidores", function()
    serverStatus("Consultando a lista pública do Roblox...")
    clearServerResults()

    task.spawn(function()
        local maxPlayers = selectedPlayerLimit == "0 (vazio)" and 0 or tonumber(selectedPlayerLimit)
        local ok, result = pcall(function()
            return ServerFinder.Fetch(maxPlayers, 20)
        end)

        if not ok then
            serverStatus("Erro na busca: " .. tostring(result))
            Notifications.Show("Server Finder", "Não foi possível consultar os servidores. Verifique o suporte HTTP do Delta.", 5, "Error")
            return
        end

        renderServerResults(result)
        Notifications.Show("Server Finder", tostring(#result) .. " servidores encontrados.", 3, "Success")
    end)
end)

Components.Label(resultsSection, "Os resultados mostram apenas a primeira página pública disponível. Servidores podem fechar antes da conexão.", true)

-- Interface
local visualSection = Components.Section(Visual, "Interface options")
Components.Toggle(visualSection, "Animations", state:Get("AnimationsEnabled"), function(value)
    state:Set("AnimationsEnabled", value)
end)
local setScaleSlider = Components.Slider(visualSection, "UI scale preview", 70, 115, math.floor((state:Get("UserScale") or 1) * 100), function(value)
    ui.SetUserScale(value / 100)
    state:Set("UserScale", value / 100)
end, 1)

-- Settings
local settingsSection = Components.Section(SettingsPage, "Preferences")
local setCompactToggle = Components.Toggle(settingsSection, "Compact window", state:Get("Compact"), function(value)
    ui.SetCompact(value)
    state:Set("Compact", value)
end)

Components.Button(settingsSection, "Reset interface size", function()
    Settings.ResetInterface(setCompactToggle, setScaleSlider)
    Notifications.Show("Settings", "Tamanho e escala restaurados.", 3, "Success")
end)

Components.Button(settingsSection, "About Nova Hub", function()
    Notifications.Show("Nova Hub", "Framework modular de UI, versão 1.2.", 3, "Info")
end)

Components.Dropdown(settingsSection, "Accent preset", { "Violet", "Blue", "Green", "Rose", "Amber" }, "Violet", function(preset)
    local success = ThemeManager.ApplyPreset(preset)
    if success then
        Notifications.Show("Tema atualizado", "Preset " .. preset .. " aplicado em tempo real.", 3, "Info")
    end
end)

local searchConnection = ui.Search:GetPropertyChangedSignal("Text"):Connect(function()
    Components.Filter(ui.Search.Text)
end)

local unbindToggle = KeybindManager.Bind(UserInputService, Config.Keybind, function()
    ui.Toggle()
end)

ui.Screen.Destroying:Connect(function()
    if searchConnection.Connected then searchConnection:Disconnect() end
    unbindToggle()
    Notifications.Destroy()
    Components.Destroy()
    ThemeManager.Destroy()
    state:Destroy()
end)

Notifications.Show("Nova Hub", "Interface carregada com sucesso.", 3.5, "Success")