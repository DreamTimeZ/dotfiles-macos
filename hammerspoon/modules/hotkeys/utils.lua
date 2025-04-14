-- Utility functions for hotkeys module with focus on performance and maintainability
local M = {}

-- Cache config reference to avoid redundant requires
local config = require("modules.hotkeys.config")

-- Log a message at the specified level with minimal overhead
function M.log(level, message)
    -- Check if logging is enabled and level is appropriate
    if not config.logging.enabled or level > config.logging.level then return end
    
    local levelName = config.logging.levelNames[level] or "UNKNOWN"
    local timestamp = os.date("%H:%M:%S")
    
    -- Use string format instead of concatenation for better performance
    print(string.format("[Hotkeys %s %s] %s", levelName, timestamp, message))
end

-- Create optimized inline logging functions with level checks to avoid function calls when not needed
function M.error(message) 
    if config.logging.enabled and config.logging.LEVELS.ERROR <= config.logging.level then
        M.log(config.logging.LEVELS.ERROR, message) 
    end
end

function M.warn(message) 
    if config.logging.enabled and config.logging.LEVELS.WARN <= config.logging.level then
        M.log(config.logging.LEVELS.WARN, message) 
    end
end

function M.info(message) 
    if config.logging.enabled and config.logging.LEVELS.INFO <= config.logging.level then
        M.log(config.logging.LEVELS.INFO, message) 
    end
end

function M.debug(message) 
    if config.logging.enabled and config.logging.LEVELS.DEBUG <= config.logging.level then
        M.log(config.logging.LEVELS.DEBUG, message) 
    end
end

-- Set the logging level
function M.setLogLevel(level)
    if type(level) == "string" and config.logging.LEVELS[level] then
        config.logging.level = config.logging.LEVELS[level]
    elseif type(level) == "number" and level >= 0 and level <= 4 then
        config.logging.level = level
    else
        M.error("Invalid log level: " .. tostring(level))
    end
end

-- Enable or disable logging entirely
function M.setLoggingEnabled(enabled)
    config.logging.enabled = enabled
end

-- Error handling helper with improved consistency
local function handleError(message, isFatal)
    -- Log appropriate level based on severity
    if isFatal then
        M.error(message)
        -- Only show alert for fatal errors to avoid UI clutter
        hs.alert.show("ERROR: " .. message)
        return false
    else
        M.warn(message)
        return nil
    end
end

-- Validation helper for common parameter checking
local function validateParam(param, name, errorHandler)
    if not param then
        return errorHandler("No " .. name .. " provided", false)
    end
    return true
end

-- Validate if a binding has required fields for the modal
local function validateBinding(binding, modal)
    if not binding then
        return false, "Invalid binding configuration"
    end
    
    if not modal or not modal.handler or not modal.handler.field then
        return false, "Invalid modal configuration"
    end
    
    -- Check if the binding has the required field
    local requiredField = modal.handler.field
    if not binding[requiredField] then
        return false, "Missing " .. requiredField .. " field"
    end
    
    return true, nil
end

-- Core functionality with improved error handling
function M.launchOrFocus(appName)
    if not validateParam(appName, "app name", handleError) then return false end
    
    hs.application.launchOrFocus(appName)
    hs.timer.doAfter(config.delays.appActivation, function()
        local app = hs.application.get(appName)
        if app then app:activate() end
    end)
    return true
end

function M.openFinderFolder(path)
    if not validateParam(path, "path", handleError) then return false end
    
    if hs.fs.attributes(path) then
        hs.execute("open " .. path)
        return true
    else
        return handleError("Path does not exist: " .. path, true)
    end
end

function M.openURL(url)
    if not validateParam(url, "URL", handleError) then return false end
    
    hs.urlevent.openURL(url)
    return true
end

function M.openSystemPreferencePane(url)
    if not validateParam(url, "preference pane URL", handleError) then return false end
    
    -- Cache frequently accessed configuration
    local sysPrefs = config.systemPreferences
    
    -- Determine which app to use based on macOS version
    local macOSVersion = hs.host.operatingSystemVersion()
    local appName = macOSVersion.major >= 13 and "System Settings" or "System Preferences"
    
    -- Try to open URL directly
    hs.execute("open \"" .. url .. "\"")
    
    -- Check if we successfully opened the URL
    local function checkSettingsOpened()
        local app = hs.application.get(appName)
        return app ~= nil and app:isFrontmost()
    end
    
    -- Set up a single timer for fallback approach
    hs.timer.doAfter(0.5, function()
        if not checkSettingsOpened() then
            M.debug("System settings didn't open correctly, trying fallback method")
            
            -- Close the app if it's running but not activated
            local app = hs.application.get(appName)
            if app then
                app:kill()
                
                -- Wait for app to close before reopening
                hs.timer.doAfter(sysPrefs.forceKillDelay, function()
                    hs.execute("open \"" .. url .. "\"")
                end)
            else
                -- Try launching again
                hs.execute("open \"" .. url .. "\"")
            end
        end
    end)
    
    return true
end

-- Map of action handlers for better performance and maintainability
local ACTION_HANDLERS = {
    launchOrFocus = M.launchOrFocus,
    openURL = M.openURL,
    openFinderFolder = M.openFinderFolder,
    openSystemPreferencePane = M.openSystemPreferencePane,
    clearNotifications = function() 
        hs.execute("killall NotificationCenter 2>/dev/null")
        return true
    end,
    functionCall = function(fn)
        if type(fn) == "function" then
            return fn()
        end
        return false
    end
}

-- Export action handlers for use in other modules
M.actions = ACTION_HANDLERS

-- Generic action executor that handles all action types
function M.executeAction(handler, mapping)
    if not handler or not handler.field or not handler.action or not mapping then
        return handleError("Invalid handler or mapping", true)
    end
    
    local value = mapping[handler.field]
    if not value then
        return handleError("Missing required field in mapping: " .. handler.field, true)
    end
    
    -- Try built-in action handler first
    local actionHandler = ACTION_HANDLERS[handler.action]
    if actionHandler then
        return actionHandler(value)
    -- Try to call a function in the utils module
    elseif M[handler.action] and type(M[handler.action]) == "function" then
        return M[handler.action](value)
    -- Fallback for custom handlers in the mapping
    elseif mapping.action and type(mapping.action) == "function" then
        return mapping.action()
    elseif mapping.fn and type(mapping.fn) == "function" then
        return mapping.fn()
    else
        return handleError("Unknown action handler: " .. handler.action, true)
    end
end

-- Modal management with improved error handling
function M.setupModal(mappings, title, modal)
    if not mappings or type(mappings) ~= "table" then
        return handleError("Invalid mappings table for modal setup", true)
    end
    
    if not modal or not modal.handler then
        return handleError("Invalid modal definition for modal setup", true)
    end
    
    local hotModal = hs.hotkey.modal.new()
    
    -- Modal entry behavior
    function hotModal:entered()
        hs.alert.closeAll()
        local hints = {}
        
        -- Collect hints with their descriptions
        for key, binding in pairs(mappings) do
            -- Skip invalid bindings
            local valid, _ = validateBinding(binding, modal)
            if not valid then
                M.warn("Skipping invalid binding for key: " .. key)
                goto continue
            end
            
            local description = binding.desc or key
            table.insert(hints, { 
                key = key, 
                text = string.format(config.ui.keyFormat, key, description),
                description = description
            })
            
            ::continue::
        end
        
        -- Sort hints by description
        table.sort(hints, function(a, b) 
            return a.description:lower() < b.description:lower() 
        end)
        
        -- Extract the formatted text
        local sortedTexts = {}
        for _, hint in ipairs(hints) do
            table.insert(sortedTexts, hint.text)
        end
        
        M.showFormattedAlert(sortedTexts, title or "Actions:")
    end
    
    -- Create a single action handler function to avoid repeated function creation
    local function handleModalAction(key, binding)
        -- Validate binding only once
        local valid, errorMsg = validateBinding(binding, modal)
        if not valid then
            handleError("Invalid mapping for key '" .. key .. "': " .. errorMsg, true)
            return
        end
        
        -- Execute the action
        local success = M.executeAction(modal.handler, binding)
        
        if not success then
            handleError("Failed to execute action for key '" .. key .. "'", true)
        end
        
        hs.alert.closeAll()
        hotModal:exit()
    end
    
    -- Bind all mapped keys
    for key, binding in pairs(mappings) do
        hotModal:bind("", key, function() handleModalAction(key, binding) end)
    end
    
    -- Always include escape to exit modal
    hotModal:bind("", "escape", function() hs.alert.closeAll() hotModal:exit() end)
    
    return hotModal
end

-- Creates a standardized modal module
function M.createModalModule(mappings, title, modal, modalName)
    if not mappings or type(mappings) ~= "table" then
        M.error("Invalid mappings provided to createModalModule")
        mappings = {}
    end
    
    -- Create the modal
    local hotModal = M.setupModal(mappings, title, modal)
    
    -- Return the module API
    return {
        enter = function() hotModal:enter() end,
        exit = function() hotModal:exit() hs.alert.closeAll() end,
        isActive = function() return hotModal._eventport.m_enabled end
    }
end

-- UI helpers
function M.showFormattedAlert(content, title, options)
    -- Handle string content
    if type(content) ~= "table" then
        content = {tostring(content)}
    end
    
    -- Set default options
    options = options or {}
    
    -- Cache UI config value
    local maxItemsPerLine = options.maxItemsPerLine or config.ui.maxItemsPerLine
    local totalItems = #content
    
    -- Pre-allocate buffer for better performance
    local formattedLines = {}
    if title then table.insert(formattedLines, title) end
    
    local lineItems = {}
    for i, item in ipairs(content) do
        table.insert(lineItems, item)
        
        -- Check if we need a new line
        if #lineItems >= maxItemsPerLine or i == totalItems then
            table.insert(formattedLines, table.concat(lineItems, "   "))
            lineItems = {}
        end
    end
    
    -- Show the alert with all options
    hs.alert.show(table.concat(formattedLines, "\n"), options)
end

-- Simple configuration loader
function M.loadMappings(defaultMappings, localModulePath, modalName)
    -- Start with default mappings or empty table
    local combinedMappings = defaultMappings and table.shallow_copy(defaultMappings) or {}
    
    -- Try to load local customizations
    local localPath = config.paths.localModulesBase .. modalName .. "_mappings"
    local status, localMappings = pcall(require, localPath)
    
    -- If local mappings loaded successfully, merge or replace
    if status and type(localMappings) == "table" then
        -- Check if local mappings completely replace defaults
        if localMappings._replaceDefaults then
            combinedMappings = {}
        end
        
        -- Merge in local mappings (excluding special flags)
        for k, v in pairs(localMappings) do
            if k ~= "_replaceDefaults" then
                combinedMappings[k] = v
            end
        end
        
        M.info("Local mappings loaded for " .. modalName)
    end
    
    return combinedMappings
end

-- Helper function to create a shallow copy of a table
function table.shallow_copy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

return M

