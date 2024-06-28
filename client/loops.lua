CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * SMDXCore.Config.UpdateInterval
            TriggerServerEvent('SMDXCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if (SMDXCore.PlayerData.metadata['hunger'] <= 0 or SMDXCore.PlayerData.metadata['thirst'] <= 0) and not SMDXCore.PlayerData.metadata['isdead'] then
                local currentHealth = GetEntityHealth(cache.ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(cache.ped, currentHealth - decreaseThreshold)
            end
        end
        Wait(SMDXCore.Config.StatusInterval)
    end
end)