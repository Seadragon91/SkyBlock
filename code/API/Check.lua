-- Check.lua, copied from WorldEdit



--- Called when a challenge is completed, a island value has been calculated
-- returns true to abort operation, returns false to continue.
-- a_HookName is the name of the hook to call. Everything after that are arguments for the hook.
function CallHook(a_HookName, ...)
	assert(g_Hooks[a_HookName] ~= nil)

	for idx, callback in ipairs(g_Hooks[a_HookName]) do
		cPluginManager:CallPlugin(callback.PluginName, callback.CallbackName, ...)
	end
end
