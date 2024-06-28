SMDXCore = {}
SMDXCore.PlayerData = {}
SMDXCore.Config = SMDXConfig
SMDXCore.Shared = SMDXShared
SMDXCore.ClientCallbacks = {}
SMDXCore.ServerCallbacks = {}

exports('GetSMDX', function()
    return SMDXCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local SMDXCore = exports['smdx-core']:GetCoreObject()