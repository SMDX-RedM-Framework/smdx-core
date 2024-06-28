SMDXCore.Commands = {}
SMDXCore.Commands.List = {}
SMDXCore.Commands.IgnoreList = { -- Ignore old perm levels while keeping backwards compatibility
    ['god'] = true, -- We don't need to create an ace because god is allowed all commands
    ['user'] = true -- We don't need to create an ace because builtin.everyone
}

CreateThread(function() -- Add ace to node for perm checking
    local permissions = SMDXConfig.Server.Permissions
    for i=1, #permissions do
        local permission = permissions[i]
        ExecuteCommand(('add_ace smdxcore.%s %s allow'):format(permission, permission))
    end
end)

-- Register & Refresh Commands

function SMDXCore.Commands.Add(name, help, arguments, argsrequired, callback, permission, ...)
    local restricted = true -- Default to restricted for all commands
    if not permission then permission = 'user' end -- some commands don't pass permission level
    if permission == 'user' then restricted = false end -- allow all users to use command

    RegisterCommand(name, function(source, args, rawCommand) -- Register command within fivem
        if argsrequired and #args < #arguments then
            return TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", Lang:t("error.missing_args2")}
            })
        end
        callback(source, args, rawCommand)
    end, restricted)

    local extraPerms = ... and table.pack(...) or nil
    if extraPerms then
        extraPerms[extraPerms.n + 1] = permission -- The `n` field is the number of arguments in the packed table
        extraPerms.n += 1
        permission = extraPerms
        for i = 1, permission.n do
            if not SMDXCore.Commands.IgnoreList[permission[i]] then -- only create aces for extra perm levels
                ExecuteCommand(('add_ace smdxcore.%s command.%s allow'):format(permission[i], name))
            end
        end
        permission.n = nil
    else
        permission = tostring(permission:lower())
        if not SMDXCore.Commands.IgnoreList[permission] then -- only create aces for extra perm levels
            ExecuteCommand(('add_ace smdxcore.%s command.%s allow'):format(permission, name))
        end
    end

    SMDXCore.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

function SMDXCore.Commands.Refresh(source)
    local src = source
    local Player = SMDXCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(SMDXCore.Commands.List) do
            local hasPerm = IsPlayerAceAllowed(tostring(src), 'command.'..command)
            if hasPerm then
                suggestions[#suggestions + 1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            else
                TriggerClientEvent('chat:removeSuggestion', src, '/'..command)
            end
        end
        TriggerClientEvent('chat:addSuggestions', src, suggestions)
    end
end

---------- pvp on or off
SMDXCore.Commands.Add("pvp", Lang:t('command.pvp.help'), {}, false, function(source)
    local src = source
    TriggerClientEvent('smdx-core:client:pvpToggle', src)
end)

-- Teleport
SMDXCore.Commands.Add('tp', Lang:t("command.tp.help"), { { name = Lang:t("command.tp.params.x.name"), help = Lang:t("command.tp.params.x.help") }, { name = Lang:t("command.tp.params.y.name"), help = Lang:t("command.tp.params.y.help") }, { name = Lang:t("command.tp.params.z.name"), help = Lang:t("command.tp.params.z.help") } }, false, function(source, args)
    if args[1] and not args[2] and not args[3] then
        if tonumber(args[1]) then
        local target = GetPlayerPed(tonumber(args[1]))
        if target ~= 0 then
            local coords = GetEntityCoords(target)
            TriggerClientEvent('SMDXCore:Command:TeleportToPlayer', source, coords)
        else
            TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
        end
    else
            local location = SMDXShared.Locations[args[1]]
            if location then
                TriggerClientEvent('SMDXCore:Command:TeleportToCoords', source, location.x, location.y, location.z, location.w)
            else
                TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.location_not_exist'), 'error')
            end
        end
    else
        if args[1] and args[2] and args[3] then
            local x = tonumber((args[1]:gsub(",",""))) + .0
            local y = tonumber((args[2]:gsub(",",""))) + .0
            local z = tonumber((args[3]:gsub(",",""))) + .0
            if x ~= 0 and y ~= 0 and z ~= 0 then
                TriggerClientEvent('SMDXCore:Command:TeleportToCoords', source, x, y, z)
            else
                TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.wrong_format'), 'error')
            end
        else
            TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.missing_args'), 'error')
        end
    end
end, 'admin')

-- teleport to marker
SMDXCore.Commands.Add('tpm', Lang:t("command.tpm.help"), {}, false, function(source)
    TriggerClientEvent('SMDXCore:Command:GoToMarker', source)
end, 'admin')

-- noclip
SMDXCore.Commands.Add('noclip', Lang:t("command.noclip.help"), {}, false, function(source)
    TriggerClientEvent('SMDXCore:Command:ToggleNoClip', source)
end, 'admin')

-- Permissions

SMDXCore.Commands.Add('addpermission', Lang:t("command.addpermission.help"), { { name = Lang:t("command.addpermission.params.id.name"), help = Lang:t("command.addpermission.params.id.help") }, { name = Lang:t("command.addpermission.params.permission.name"), help = Lang:t("command.addpermission.params.permission.help") } }, true, function(source, args)
    local Player = SMDXCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        SMDXCore.Functions.AddPermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'god')

SMDXCore.Commands.Add('removepermission', Lang:t("command.removepermission.help"), { { name = Lang:t("command.removepermission.params.id.name"), help = Lang:t("command.removepermission.params.id.help") }, { name = Lang:t("command.removepermission.params.permission.name"), help = Lang:t("command.removepermission.params.permission.help") } }, true, function(source, args)
    local Player = SMDXCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        SMDXCore.Functions.RemovePermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'god')

-- Open & Close Server

SMDXCore.Commands.Add('openserver', Lang:t("command.openserver.help"), {}, false, function(source)
    if not SMDXCore.Config.Server.Closed then
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.server_already_open'), 'error')
        return
    end
    if SMDXCore.Functions.HasPermission(source, 'admin') then
        SMDXCore.Config.Server.Closed = false
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('success.server_opened'), 'success')
    else
        SMDXCore.Functions.Kick(source, Lang:t("error.no_permission"), nil, nil)
    end
end, 'admin')

SMDXCore.Commands.Add('closeserver', Lang:t("command.closeserver.help"), {{ name = Lang:t("command.closeserver.params.reason.name"), help = Lang:t("command.closeserver.params.reason.help")}}, false, function(source, args)
    if SMDXCore.Config.Server.Closed then
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.server_already_closed'), 'error')
        return
    end
    if SMDXCore.Functions.HasPermission(source, 'admin') then
        local reason = args[1] or 'No reason specified'
        SMDXCore.Config.Server.Closed = true
        SMDXCore.Config.Server.ClosedReason = reason
        for k in pairs(SMDXCore.Players) do
            if not SMDXCore.Functions.HasPermission(k, SMDXCore.Config.Server.WhitelistPermission) then
                SMDXCore.Functions.Kick(k, reason, nil, nil)
            end
        end
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('success.server_closed'), 'success')
    else
        SMDXCore.Functions.Kick(source, Lang:t("error.no_permission"), nil, nil)
    end
end, 'admin')

-- HORSES / WAGONS
SMDXCore.Commands.Add('dv', Lang:t("command.dv.help"), {}, false, function(source)
    TriggerClientEvent('SMDXCore:Command:DeleteVehicle', source)
end, 'admin')

SMDXCore.Commands.Add('wagon', Lang:t("command.spawnwagon.help"), { { name = 'model', help = 'Model name of the wagon' } }, true, function(source, args)
    local src = source
    TriggerClientEvent('SMDXCore:Command:SpawnVehicle', src, args[1])
end, 'admin')

SMDXCore.Commands.Add('horse', Lang:t("command.spawnhorse.help"), { { name = 'model', help = 'Model name of the horse' } }, true, function(source, args)
    local src = source
    TriggerClientEvent('SMDXCore:Command:SpawnHorse', src, args[1])
end, 'admin')

-- Money

SMDXCore.Commands.Add('givemoney', Lang:t("command.givemoney.help"), { { name = Lang:t("command.givemoney.params.id.name"), help = Lang:t("command.givemoney.params.id.help") }, { name = Lang:t("command.givemoney.params.moneytype.name"), help = Lang:t("command.givemoney.params.moneytype.help") }, { name = Lang:t("command.givemoney.params.amount.name"), help = Lang:t("command.givemoney.params.amount.help") } }, true, function(source, args)
    local Player = SMDXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

SMDXCore.Commands.Add('setmoney', Lang:t("command.setmoney.help"), { { name = Lang:t("command.setmoney.params.id.name"), help = Lang:t("command.setmoney.params.id.help") }, { name = Lang:t("command.setmoney.params.moneytype.name"), help = Lang:t("command.setmoney.params.moneytype.help") }, { name = Lang:t("command.setmoney.params.amount.name"), help = Lang:t("command.setmoney.params.amount.help") } }, true, function(source, args)
    local Player = SMDXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Job

SMDXCore.Commands.Add('job', Lang:t("command.job.help"), {}, false, function(source)
    local PlayerJob = SMDXCore.Functions.GetPlayer(source).PlayerData.job
    TriggerClientEvent('SMDXCore:Notify', source, Lang:t('info.job_info', {value = PlayerJob.label, value2 = PlayerJob.grade.name, value3 = PlayerJob.onduty}))
end, 'user')

SMDXCore.Commands.Add('setjob', Lang:t("command.setjob.help"), { { name = Lang:t("command.setjob.params.id.name"), help = Lang:t("command.setjob.params.id.help") }, { name = Lang:t("command.setjob.params.job.name"), help = Lang:t("command.setjob.params.job.help") }, { name = Lang:t("command.setjob.params.grade.name"), help = Lang:t("command.setjob.params.grade.help") } }, true, function(source, args)
    local Player = SMDXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Gang

SMDXCore.Commands.Add('gang', Lang:t("command.gang.help"), {}, false, function(source)
    local PlayerGang = SMDXCore.Functions.GetPlayer(source).PlayerData.gang
    TriggerClientEvent('SMDXCore:Notify', source, Lang:t('info.gang_info', {value = PlayerGang.label, value2 = PlayerGang.grade.name}))
end, 'user')

SMDXCore.Commands.Add('setgang', Lang:t("command.setgang.help"), { { name = Lang:t("command.setgang.params.id.name"), help = Lang:t("command.setgang.params.id.help") }, { name = Lang:t("command.setgang.params.gang.name"), help = Lang:t("command.setgang.params.gang.help") }, { name = Lang:t("command.setgang.params.grade.name"), help = Lang:t("command.setgang.params.grade.help") } }, true, function(source, args)
    local Player = SMDXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetGang(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('SMDXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Me command
SMDXCore.Commands.Add('me', Lang:t("command.me.help"), {{name = Lang:t("command.me.params.message.name"), help = Lang:t("command.me.params.message.help")}}, false, function(source, args)
    local text = ''
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ' '
   TriggerClientEvent('SMDXCore:triggerDisplay', -1, text, source , "me")
   TriggerClientEvent("sendProximityMessage", -1, source, "Citizen [" .. source .. "]", text, { 255, 255, 255 })
end, 'user')

SMDXCore.Commands.Add('do', Lang:t("command.me.help"), {{name = Lang:t("command.me.params.message.name"), help = Lang:t("command.me.params.message.help")}}, false, function(source, args)
    local text = ''
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ' '
   TriggerClientEvent('SMDXCore:triggerDisplay', -1, text, source , "do")
   TriggerClientEvent("sendProximityMessage", -1, source, "Citizen [" .. source .. "]", text, { 145, 209, 144 })
end, 'user')

SMDXCore.Commands.Add('try', Lang:t("command.me.help"), {{name = Lang:t("command.me.params.message.name"), help = Lang:t("command.me.params.message.help")}}, false, function(source, args)
    local text = ''
    local random = math.random(1,2)
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ' '
    if random == 1 then
        text = 'He succeeded in trying'..text
    else
        text = 'He has failed trying '..text
    end
   TriggerClientEvent('SMDXCore:triggerDisplay', -1, text, source , "try")
   TriggerClientEvent("sendProximityMessage", -1, source, "Citizen [" .. source .. "]", text, { 32, 151, 247 })
end, 'user')

-- IDs
SMDXCore.Commands.Add("id", "Check Your ID #", {}, false, function(source)
    local src = source
    local Player = SMDXCore.Functions.GetPlayer(src)
    TriggerClientEvent('SMDXCore:Notify', source, "ID: "..source, 'primary')
end, 'user')

SMDXCore.Commands.Add("cid", "Check Your Citizen ID #", {}, false, function(source)
    local src = source
    local Player = SMDXCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    TriggerClientEvent('SMDXCore:Notify', source, "Citizen ID: "..Playercid, 'primary')
end, 'user')