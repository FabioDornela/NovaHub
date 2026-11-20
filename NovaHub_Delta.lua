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