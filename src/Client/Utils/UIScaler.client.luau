local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local TAG_SCALE_COMPONENT = "ScaleComponent"
local TAG_LAYOUT_COMPONENT = "ScrollingFrameLayoutComponent"
local ATTRIBUTE_BASE_RESOLUTION = "BaseResolution"
local LINK_VALUE_NAME = "ScaleComponentReferral"
local MIN_SCALE_ATTRIBUTE = "MinScale"

type ScrollingLayout = UIGridStyleLayout | UIListLayout
type ScaleMap = { [UIScale]: { BaseResolution: Vector2, MinScale: number? } }
type ConnectionMap = { [ScrollingLayout]: RBXScriptConnection }

local camera: Camera = Workspace.CurrentCamera or (Workspace:WaitForChild("Camera") :: Camera)
local viewportSizeConnection: RBXScriptConnection? = nil
local activeScales: ScaleMap = {}
local layoutConnections: ConnectionMap = {}
local currentViewportSize: Vector2 = Vector2.zero

local function updateViewportSize()
	local topInset, bottomInset = GuiService:GetGuiInset()
	currentViewportSize = camera.ViewportSize - topInset - bottomInset
end

local function applyScale(uiScale: UIScale, data: { BaseResolution: Vector2, MinScale: number? })
	if currentViewportSize.X <= 0 or currentViewportSize.Y <= 0 then
		return
	end

	local ratioX = data.BaseResolution.X / currentViewportSize.X
	local ratioY = data.BaseResolution.Y / currentViewportSize.Y
	local scale = 1 / math.max(ratioX, ratioY)

	if data.MinScale then
		scale = math.max(scale, data.MinScale)
	end

	uiScale.Scale = scale
end

local function updateAllScales()
	updateViewportSize()
	for uiScale, baseResolution in pairs(activeScales) do
		applyScale(uiScale, baseResolution)
	end
end

local function bindToCamera(newCamera: Camera)
	if viewportSizeConnection then
		viewportSizeConnection:Disconnect()
	end

	camera = newCamera
	viewportSizeConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateAllScales)

	updateAllScales()
end

local function onCurrentCameraChanged()
	local newCamera = Workspace.CurrentCamera
	if newCamera then
		bindToCamera(newCamera)
	end
end

local function updateCanvasSize(scrollingFrame: ScrollingFrame, layout: ScrollingLayout, uiScale: UIScale)
	local contentSize = layout.AbsoluteContentSize
	local scale = uiScale.Scale

	if scale == 0 then
		return
	end

	scrollingFrame.CanvasSize = UDim2.fromOffset(contentSize.X / scale, contentSize.Y / scale)
end

local function registerScrollingLayout(layout: ScrollingLayout)
	local scaleReferral = layout:FindFirstChild(LINK_VALUE_NAME) :: ObjectValue?

	if not scaleReferral or not scaleReferral.Value or not scaleReferral.Value:IsA("UIScale") then
		warn(`[UISystem] Layout {layout:GetFullName()} has no valid UIScale reference.`)
		return
	end

	local scrollingFrame = layout.Parent
	if not scrollingFrame or not scrollingFrame:IsA("ScrollingFrame") then
		return
	end

	local targetScale = scaleReferral.Value :: UIScale

	local connection = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		updateCanvasSize(scrollingFrame, layout, targetScale)
	end)

	layoutConnections[layout] = connection

	updateCanvasSize(scrollingFrame, layout, targetScale)
end

local function unregisterScrollingLayout(layout: ScrollingLayout)
	local connection = layoutConnections[layout]
	if connection then
		connection:Disconnect()
		layoutConnections[layout] = nil
	end
end

local function registerScaleComponent(uiScale: UIScale)
	local baseResolution = uiScale:GetAttribute(ATTRIBUTE_BASE_RESOLUTION)

	if typeof(baseResolution) ~= "Vector2" then
		warn(
			`[UISystem] UIScale {uiScale:GetFullName()} is missing the '{ATTRIBUTE_BASE_RESOLUTION}' Vector2 attribute.`
		)
		return
	end

	local minScale = uiScale:GetAttribute(MIN_SCALE_ATTRIBUTE)

	activeScales[uiScale] = {
		BaseResolution = baseResolution,
		MinScale = if typeof(minScale) == "number" then minScale else nil,
	}

	applyScale(uiScale, activeScales[uiScale])
end

local function unregisterScaleComponent(uiScale: UIScale)
	activeScales[uiScale] = nil
end

local function initialize()
	bindToCamera(camera)

	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)

	CollectionService:GetInstanceAddedSignal(TAG_SCALE_COMPONENT):Connect(function(obj)
		if obj:IsA("UIScale") then
			registerScaleComponent(obj)
		end
	end)

	CollectionService:GetInstanceRemovedSignal(TAG_SCALE_COMPONENT):Connect(function(obj)
		if obj:IsA("UIScale") then
			unregisterScaleComponent(obj)
		end
	end)

	CollectionService:GetInstanceAddedSignal(TAG_LAYOUT_COMPONENT):Connect(function(obj)
		if obj:IsA("UIGridStyleLayout") or obj:IsA("UIListLayout") then
			registerScrollingLayout(obj)
		end
	end)

	CollectionService:GetInstanceRemovedSignal(TAG_LAYOUT_COMPONENT):Connect(function(obj)
		if obj:IsA("UIGridStyleLayout") or obj:IsA("UIListLayout") then
			unregisterScrollingLayout(obj)
		end
	end)

	for _, obj in CollectionService:GetTagged(TAG_SCALE_COMPONENT) do
		if obj:IsA("UIScale") then
			registerScaleComponent(obj)
		end
	end

	for _, obj in CollectionService:GetTagged(TAG_LAYOUT_COMPONENT) do
		if obj:IsA("UIGridStyleLayout") or obj:IsA("UIListLayout") then
			registerScrollingLayout(obj)
		end
	end
end

initialize()
