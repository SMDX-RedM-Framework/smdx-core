SMDXCore.Functions = {}
SMDXCore.Player_Buckets = {}
SMDXCore.Entity_Buckets = {}
SMDXCore.UsableItems = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = SMDXCore.Functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

function SMDXCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return vector4(coords.x, coords.y, coords.z, heading)
end

function SMDXCore.Functions.GetIdentifier(source, idtype)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end

function SMDXCore.Functions.GetSource(identifier)
    for src, _ in pairs(SMDXCore.Players) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

function SMDXCore.Functions.GetPlayer(source)
    if type(source) == 'number' then
        return SMDXCore.Players[source]
    else
        return SMDXCore.Players[SMDXCore.Functions.GetSource(source)]
    end
end

function SMDXCore.Functions.GetPlayerByCitizenId(citizenid)
    for src in pairs(SMDXCore.Players) do
        if SMDXCore.Players[src].PlayerData.citizenid == citizenid then
            return SMDXCore.Players[src]
        end
    end
    return nil
end

function SMDXCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    return SMDXCore.Player.GetOfflinePlayer(citizenid)
end

function SMDXCore.Functions.GetPlayers()
    local sources = {}
    for k in pairs(SMDXCore.Players) do
        sources[#sources+1] = k
    end
    return sources
end

-- Will return an array of SMDX Player class instances
-- unlike the GetPlayers() wrapper which only returns IDs
function SMDXCore.Functions.GetSMDXPlayers()
    return SMDXCore.Players
end

--- Gets a list of all on duty players of a specified job and the number
function SMDXCore.Functions.GetPlayersOnDuty(job)
    local players = {}
    local count = 0
    for src, Player in pairs(SMDXCore.Players) do
        if Player.PlayerData.job.name == job then
            if Player.PlayerData.job.onduty then
                players[#players + 1] = src
                count += 1
            end
        end
    end
    return players, count
end

-- Returns only the amount of players on duty for the specified job
function SMDXCore.Functions.GetDutyCount(job)
    local count = 0
    for _, Player in pairs(SMDXCore.Players) do
        if Player.PlayerData.job.name == job then
            if Player.PlayerData.job.onduty then
                count += 1
            end
        end
    end
    return count
end

-- Routing buckets (Only touch if you know what you are doing)

-- Returns the objects related to buckets, first returned value is the player buckets, second one is entity buckets
function SMDXCore.Functions.GetBucketObjects()
    return SMDXCore.Player_Buckets, SMDXCore.Entity_Buckets
end

-- Will set the provided player id / source into the provided bucket id
function SMDXCore.Functions.SetPlayerBucket(source --[[ int ]], bucket --[[ int ]])
    if source and bucket then
        local plicense = SMDXCore.Functions.GetIdentifier(source, 'license')
        SetPlayerRoutingBucket(source, bucket)
        SMDXCore.Player_Buckets[plicense] = {id = source, bucket = bucket}
        return true
    else
        return false
    end
end

-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
function SMDXCore.Functions.SetEntityBucket(entity --[[ int ]], bucket --[[ int ]])
    if entity and bucket then
        SetEntityRoutingBucket(entity, bucket)
        SMDXCore.Entity_Buckets[entity] = {id = entity, bucket = bucket}
        return true
    else
        return false
    end
end

-- Will return an array of all the player ids inside the current bucket
function SMDXCore.Functions.GetPlayersInBucket(bucket --[[ int ]])
    local curr_bucket_pool = {}
    if SMDXCore.Player_Buckets and next(SMDXCore.Player_Buckets) then
        for _, v in pairs(SMDXCore.Player_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

-- Will return an array of all the entities inside the current bucket (not for player entities, use GetPlayersInBucket for that)
function SMDXCore.Functions.GetEntitiesInBucket(bucket --[[ int ]])
    local curr_bucket_pool = {}
    if SMDXCore.Entity_Buckets and next(SMDXCore.Entity_Buckets) then
        for _, v in pairs(SMDXCore.Entity_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

-- Server side vehicle creation with optional callback
-- the CreateVehicle RPC still uses the client for creation so players must be near
function SMDXCore.Functions.SpawnVehicle(source, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    return veh
end

-- Server side vehicle creation with optional callback
-- the CreateAutomobile native is still experimental but doesn't use client for creation
-- doesn't work for all vehicles!
function SMDXCore.Functions.CreateVehicle(source, model, coords, warp)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local CreateAutomobile = `CREATE_AUTOMOBILE`
    local veh = Citizen.InvokeNative(CreateAutomobile, model, coords, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    return veh
end

-- Paychecks (standalone - don't touch)
function PaycheckInterval()
    if next(SMDXCore.Players) then
        for _, Player in pairs(SMDXCore.Players) do
            if Player then
                local payment = SMDXShared.Jobs[Player.PlayerData.job.name]['grades'][tostring(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (SMDXShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if SMDXCore.Config.Money.PayCheckSociety then
                        local account = exports['smdx-bossmenu']:GetAccount(Player.PlayerData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('SMDXCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                Player.Functions.AddMoney('bank', payment)
                                exports['smdx-bossmenu']:RemoveMoney(Player.PlayerData.job.name, payment)
                                TriggerClientEvent('SMDXCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            Player.Functions.AddMoney('bank', payment)
                            TriggerClientEvent('SMDXCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        Player.Functions.AddMoney('bank', payment)
                        TriggerClientEvent('SMDXCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(SMDXCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end

-- Callback Functions --

-- Client Callback
function SMDXCore.Functions.TriggerClientCallback(name, source, cb, ...)
    SMDXCore.ClientCallbacks[name] = cb
    TriggerClientEvent('SMDXCore:Client:TriggerClientCallback', source, name, ...)
end

-- Server Callback
function SMDXCore.Functions.CreateCallback(name, cb)
    SMDXCore.ServerCallbacks[name] = cb
end

function SMDXCore.Functions.TriggerCallback(name, source, cb, ...)
    if not SMDXCore.ServerCallbacks[name] then return end
    SMDXCore.ServerCallbacks[name](source, cb, ...)
end

-- Items

function SMDXCore.Functions.CreateUseableItem(item, data)
    SMDXCore.UsableItems[item] = data
end

function SMDXCore.Functions.CanUseItem(item)
    return SMDXCore.UsableItems[item]
end

function SMDXCore.Functions.UseItem(source, item)
    if GetResourceState('smdx-inventory') == 'missing' then return end
    exports['smdx-inventory']:UseItem(source, item)
end

-- Kick Player

function SMDXCore.Functions.Kick(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Kolla in våran Discord för mer information: ' .. SMDXCore.Config.Server.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        for _ = 0, 4 do
            while true do
                if source then
                    if GetPlayerPing(source) >= 0 then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end

-- Check if player is whitelisted, kept like this for backwards compatibility or future plans

function SMDXCore.Functions.IsWhitelisted(source)
    if not SMDXCore.Config.Server.Whitelist then return true end
    if SMDXCore.Functions.HasPermission(source, SMDXCore.Config.Server.WhitelistPermission) then return true end
    return false
end

-- Setting & Removing Permissions

function SMDXCore.Functions.AddPermission(source, permission)
    if not IsPlayerAceAllowed(source, permission) then
        ExecuteCommand(('add_principal player.%s smdxcore.%s'):format(source, permission))
        SMDXCore.Commands.Refresh(source)
    end
end

function SMDXCore.Functions.RemovePermission(source, permission)
    if permission then
        if IsPlayerAceAllowed(source, permission) then
            ExecuteCommand(('remove_principal player.%s smdxcore.%s'):format(source, permission))
            SMDXCore.Commands.Refresh(source)
        end
    else
        for _, v in pairs(SMDXCore.Config.Server.Permissions) do
            if IsPlayerAceAllowed(source, v) then
                ExecuteCommand(('remove_principal player.%s smdxcore.%s'):format(source, v))
                SMDXCore.Commands.Refresh(source)
            end
        end
    end
end

-- Checking for Permission Level

function SMDXCore.Functions.HasPermission(source, permission)
    if type(permission) == "string" then
        if IsPlayerAceAllowed(source, permission) then return true end
    elseif type(permission) == "table" then
        for _, permLevel in pairs(permission) do
            if IsPlayerAceAllowed(source, permLevel) then return true end
        end
    end

    return false
end

function SMDXCore.Functions.GetPermission(source)
    local src = source
    local perms = {}
    for _, v in pairs (SMDXCore.Config.Server.Permissions) do
        if IsPlayerAceAllowed(src, v) then
            perms[v] = true
        end
    end
    return perms
end

-- Opt in or out of admin reports

function SMDXCore.Functions.IsOptin(source)
    local license = SMDXCore.Functions.GetIdentifier(source, 'license')
    if not license or not SMDXCore.Functions.HasPermission(source, 'admin') then return false end
    local Player = SMDXCore.Functions.GetPlayer(source)
    return Player.PlayerData.optin
end

function SMDXCore.Functions.ToggleOptin(source)
    local license = SMDXCore.Functions.GetIdentifier(source, 'license')
    if not license or not SMDXCore.Functions.HasPermission(source, 'admin') then return end
    local Player = SMDXCore.Functions.GetPlayer(source)
    Player.PlayerData.optin = not Player.PlayerData.optin
    Player.Functions.SetPlayerData('optin', Player.PlayerData.optin)
end

-- Check if player is banned

function SMDXCore.Functions.IsPlayerBanned(source)
    local plicense = SMDXCore.Functions.GetIdentifier(source, 'license')
    local result = MySQL.single.await('SELECT * FROM bans WHERE license = ?', { plicense })
    if not result then return false end
    if os.time() < result.expire then
        local timeTable = os.date('*t', tonumber(result.expire))
        return true, 'Du har blivit bannad ifrån servern:\n' .. result.reason .. '\nDin bann utgår/hävs ' .. timeTable.day .. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
    else
        MySQL.query('DELETE FROM bans WHERE id = ?', { result.id })
    end
    return false
end

-- Check for duplicate license

function SMDXCore.Functions.IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                if id == license then
                    return true
                end
            end
        end
    end
    return false
end

-- Utility functions

function SMDXCore.Functions.HasItem(source, items, amount)
    if GetResourceState('smdx-inventory') == 'missing' then return end
    return exports['smdx-inventory']:HasItem(source, items, amount)
end

function SMDXCore.Functions.Notify(source, text, type, length)
    TriggerClientEvent('SMDXCore:Notify', source, text, type, length)
end