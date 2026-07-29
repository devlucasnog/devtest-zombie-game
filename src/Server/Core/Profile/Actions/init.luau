local ActionsFolder = script

local ProfileActionHandler = {}
ProfileActionHandler.__index = ProfileActionHandler

function ProfileActionHandler.new()
	local self = setmetatable({}, ProfileActionHandler)
	self._handlers = self:_registerHandlers()
	return self
end

function ProfileActionHandler:Run(replica, action)
	if typeof(action) ~= "table" or typeof(action.Name) ~= "string" then
		warn(`[ProfileActionHandler] Invalid action: {tostring(action)}`)
		return false
	end

	local handler = self._handlers[action.Name]
	if not handler then
		warn(`[ProfileActionHandler] No handler found for action {action.Name}`)
		return false
	end

	local success, result = pcall(handler, replica, action)
	if not success then
		warn(`[ProfileActionHandler] Error executing handler for action {action.Name}: {result}`)
		return false
	end

	return true, result
end

function ProfileActionHandler:_registerHandlers()
	local registry = {}

	for _, module in ActionsFolder:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end

		local success, actionModule = pcall(require, module)
		if not success then
			warn(`[ProfileActionHandler] Failed to require action module {module.Name}: {actionModule}`)
			continue
		end

		self:_registerModule(registry, actionModule, module.Name)
	end

	return registry
end

function ProfileActionHandler:_registerModule(registry, actionModule, moduleName)
	if typeof(actionModule) ~= "table" then
		warn(`[ProfileActionHandler] Action module {moduleName} must return a table`)
		return
	end

	for actionName, handlerFunction in actionModule do
		if typeof(handlerFunction) ~= "function" then
			warn(`[ProfileActionHandler] Handler for action {actionName} in {moduleName} must be a function`)
			continue
		end

		if registry[actionName] then
			warn(
				`[ProfileActionHandler] Duplicate handler for action {actionName} detected in {moduleName}. Overwriting existing handler.`
			)
		end

		registry[actionName] = handlerFunction
	end
end

return ProfileActionHandler
