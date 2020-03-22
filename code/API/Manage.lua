
-- Manage.lua, copied from WorldEdit

-- Implements functions that can be called by external plugins to listen for completed challenges





g_Hooks = {
	["OnChallengeCompleted"]            = {}, -- Signature: function(a_Player, a_LevelName, a_ChallengeName)
	["OnIslandValueCalculated"]             = {}, -- Signature: function(a_Player, a_IslandValue)
}





-- Registers a SkyBlock hook.
-- All arguments are strings.
-- a_HookName is the name of the hook. (List can be seen above)
-- a_PluginName is the name of the plugin that wants to register a callback
-- a_CallbackName is the name of the function the plugin wants to use as the callback.
function AddHook(a_HookName, a_PluginName, a_CallbackName)
	if (
		(type(a_HookName) ~= "string") or
		(type(a_PluginName)   ~= "string") or (a_PluginName   == "") or not cPluginManager:Get():IsPluginLoaded(a_PluginName) or
		(type(a_CallbackName) ~= "string") or (a_CallbackName == "")
	) then
		LOGWARNING("[SkyBlock] Invalid callback registration parameters.")
		LOGWARNING("  AddHook() was called with params " ..
			tostring(a_HookName     or "<nil>") .. ", " ..
			tostring(a_PluginName   or "<nil>") .. ", " ..
			tostring(a_CallbackName or "<nil>")
		)

		return false
	end

	if (not g_Hooks[a_HookName]) then
		LOGWARNING("[SkyBlock] Plugin \"" .. a_PluginName .. "\" tried to register an unexisting hook called \"" .. a_HookName .. "\"")
		return false
	end

	table.insert(g_Hooks[a_HookName], {PluginName = a_PluginName, CallbackName = a_CallbackName})
	return true
end
