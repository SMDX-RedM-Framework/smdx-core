SMDXCore.Functions = {}

-- Player

function SMDXCore.Functions.GetPlayerData(cb)
    if not cb then return SMDXCore.PlayerData end
    cb(SMDXCore.PlayerData)
end

function SMDXCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity)
    return vector4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
end

function SMDXCore.Functions.HasItem(items, amount)
    return exports['smdx-inventory']:HasItem(items, amount)
end

-- Utility

function SMDXCore.Functions.DrawText(x, y, width, height, scale, r, g, b, a, text)
    -- Use local function instead
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

function SMDXCore.Functions.DrawText3D(x, y, z, text)
    -- Use local function instead
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

SMDXCore.Functions.RequestAnimDict = lib.requestAnimDict

SMDXCore.Functions.LoadModel = lib.requestModel

SMDXCore.Functions.LoadAnimSet = lib.requestAnimSet

function SMDXCore.Functions.PlayAnim(animDict, animName, upperbodyOnly, duration)
    local flags = upperbodyOnly and 16 or 0
    local runTime = duration or -1
    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animName, 8.0, 3.0, runTime, flags, 0.0, false, false, true)
    RemoveAnimDict(animDict)
end

RegisterNUICallback('getNotifyConfig', function(_, cb)
    cb(SMDXCore.Config.Notify)
end)

---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
---@alias NotificationType 'inform' | 'error' | 'success'
---@alias DeprecatedNotificationType 'primary'

---@class NotifyProps
---@field id? string notifications with the same id will not be on the screen at the same time
---@field title? string displayed to the player
---@field description? string displayed to the player
---@field duration? number milliseconds notification is on screen
---@field position? NotificationPosition
---@field type? NotificationType
---@field icon? string https://fontawesome.com icon name
---@field iconColor? string css color value for the icon

---Text box popup for player which dissappears after a set time.
---@param props NotifyProps
function SMDXCore.Functions.NotifyV2(props)
    props.style = nil
    if not props.position then
        props.position = SMDXConfig.NotifyPosition
    end
    lib.notify(props)
end

---@deprecated in favor of SMDXCore.Functions.NotifyV2()
---@param text table|string text of the notification
---@param notifyType? NotificationType|DeprecatedNotificationType informs default styling. Defaults to 'inform'.
---@param duration? integer milliseconds notification will remain on scren. Defaults to 5000.
function SMDXCore.Functions.Notify(text, notifyType, duration)
    notifyType = notifyType or 'inform'
    if notifyType == 'primary' then notifyType = 'inform' end
    duration = duration or 5000
    local position = SMDXConfig.NotifyPosition
    if type(text) == "table" then
        local title = text.text or 'Placeholder'
        local description = text.caption or 'Placeholder'
        lib.notify({ title = title, description = description, duration = duration, type = notifyType, position = position})
    else
        lib.notify({ description = text, duration = duration, type = notifyType, position = position})
    end
end

function SMDXCore.Debug(resource, obj, depth)
    TriggerServerEvent('SMDXCore:DebugSomething', resource, obj, depth)
end

-- Callback Functions --

-- Client Callback
function SMDXCore.Functions.CreateClientCallback(name, cb)
    SMDXCore.ClientCallbacks[name] = cb
end

function SMDXCore.Functions.TriggerClientCallback(name, cb, ...)
    if not SMDXCore.ClientCallbacks[name] then return end
    SMDXCore.ClientCallbacks[name](cb, ...)
end

-- Server Callback
function SMDXCore.Functions.TriggerCallback(name, cb, ...)
    SMDXCore.ServerCallbacks[name] = cb
    TriggerServerEvent('SMDXCore:Server:TriggerCallback', name, ...)
end

local PROGconversion = {
    disableMovement = 'move',
    disableCarMovement = 'car',
    disableCombat = 'combat',
    disableMouse = 'mouse'
}

--- Converts the disableControls table to the correct format for the ox_lib library
---@param table table the old table
---@return table the new table
local function ConvertProgressbar(table)
    local newTable = {}
    for k, v in pairs(table) do
        if PROGconversion[k] then
            newTable[PROGconversion[k]] = v
        else
            newTable[k] = v
        end
    end
    return newTable
end

function SMDXCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if lib.progressActive() then 
        SMDXCore.Functions.Notify("You are already doing something", "error", 5000)
        return
    end

    local prog = lib.progressCircle({
        label = label,
        duration = duration,
        position = 'bottom',
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        disable = ConvertProgressbar(disableControls),
        anim = {
            dict = animation.animDict,
            clip = animation.anim,
            flag = animation.flags
        },
        prop = {
            model = prop.model and joaat(prop.model) or nil,
            pos = prop.coords,
            rot = prop.rotation
        }
    })

    if prog then
        if onFinish then
            onFinish()
        end
    else
        if onCancel then
            onCancel()
        end
    end

    return prog
end

-- Getters

function SMDXCore.Functions.GetVehicles()
    return GetGamePool('CVehicle')
end

function SMDXCore.Functions.GetObjects()
    return GetGamePool('CObject')
end

function SMDXCore.Functions.GetPlayers()
    return GetActivePlayers()
end

function SMDXCore.Functions.GetPeds(ignoreList)
    local pedPool = GetGamePool('CPed')
    local peds = {}
    ignoreList = ignoreList or {}
    for i = 1, #pedPool, 1 do
        local found = false
        for j = 1, #ignoreList, 1 do
            if ignoreList[j] == pedPool[i] then
                found = true
            end
        end
        if not found then
            peds[#peds + 1] = pedPool[i]
        end
    end
    return peds
end

function SMDXCore.Functions.GetClosestPed(coords, ignoreList)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    local ignoreList = ignoreList or {}
    local peds = SMDXCore.Functions.GetPeds(ignoreList)
    local closestDistance = -1
    local closestPed = -1
    for i = 1, #peds, 1 do
        local pedCoords = GetEntityCoords(peds[i])
        local distance = #(pedCoords - coords)
        if peds[i] ~= cache.ped then
            if closestDistance == -1 or closestDistance > distance then
                closestPed = peds[i]
                closestDistance = distance
            end
        end
    end
    return closestPed, closestDistance
end

function SMDXCore.Functions.IsWearingGloves()
    local armIndex = GetPedDrawableVariation(cache.ped, 3)
    local model = GetEntityModel(cache.ped)
    if model == `mp_m_freemode_01` then
        if SMDXCore.Shared.MaleNoGloves[armIndex] then
            return false
        end
    else
        if SMDXCore.Shared.FemaleNoGloves[armIndex] then
            return false
        end
    end
    return true
end

function SMDXCore.Functions.GetClosestPlayer(coords)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    local closestPlayers = SMDXCore.Functions.GetPlayersFromCoords(coords)
    local closestDistance = -1
    local closestPlayer = -1
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= cache.playerId and closestPlayers[i] ~= -1 then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function SMDXCore.Functions.GetPlayersFromCoords(coords, distance)
    local players = GetActivePlayers()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    distance = distance or 5
    local closePlayers = {}
    for _, player in pairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

function SMDXCore.Functions.GetClosestVehicle(coords)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

function SMDXCore.Functions.GetClosestObject(coords)
    local objects = GetGamePool('CObject')
    local closestDistance = -1
    local closestObject = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end

function SMDXCore.Functions.GetClosestBone(entity, list)
    local playerCoords, bone, coords, distance = GetEntityCoords(cache.ped)
    for _, element in pairs(list) do
        local boneCoords = GetWorldPositionOfEntityBone(entity, element.id or element)
        local boneDistance = #(playerCoords - boneCoords)
        if not coords then
            bone, coords, distance = element, boneCoords, boneDistance
        elseif distance > boneDistance then
            bone, coords, distance = element, boneCoords, boneDistance
        end
    end
    if not bone then
        bone = {id = GetEntityBoneIndexByName(entity, "bodyshell"), type = "remains", name = "bodyshell"}
        coords = GetWorldPositionOfEntityBone(entity, bone.id)
        distance = #(coords - playerCoords)
    end
    return bone, coords, distance
end

function SMDXCore.Functions.GetBoneDistance(entity, boneType, boneIndex)
    local bone
    if boneType == 1 then
        bone = GetPedBoneIndex(entity, boneIndex)
    else
        bone = GetEntityBoneIndexByName(entity, boneIndex)
    end
    local boneCoords = GetWorldPositionOfEntityBone(entity, bone)
    local playerCoords = GetEntityCoords(cache.ped)
    return #(boneCoords - playerCoords)
end

function SMDXCore.Functions.AttachProp(ped, model, boneId, x, y, z, xR, yR, zR, vertex)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    local bone = GetPedBoneIndex(ped, boneId)
    lib.requestModel(modelHash)
    local prop = CreateObject(modelHash, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(prop, ped, bone, x, y, z, xR, yR, zR, 1, 1, 0, 1, not vertex and 2 or 0, 1)
    SetModelAsNoLongerNeeded(modelHash)
    return prop
end

-- Vehicle

function SMDXCore.Functions.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    model = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelInCdimage(model) then return end
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    isnetworked = isnetworked == nil or isnetworked
    lib.requestModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    NetworkRequestControlOfNetworkId(netid)
    SetModelAsNoLongerNeeded(model)
    if teleportInto then TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1) end
    if cb then cb(veh) end
end

function SMDXCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function SMDXCore.Functions.GetPlate(vehicle)
    if vehicle == 0 then return end
    return SMDXCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
end

function SMDXCore.Functions.GetVehicleLabel(vehicle)
    if vehicle == nil or vehicle == 0 then return end
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

function SMDXCore.Functions.SpawnClear(coords, radius)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    local vehicles = GetGamePool('CVehicle')
    local closeVeh = {}
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if distance <= radius then
            closeVeh[#closeVeh + 1] = vehicles[i]
        end
    end
    if #closeVeh > 0 then return false end
    return true
end

function SMDXCore.Functions.GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        -- get vehicle stuff here
    else
        return
    end
end

function SMDXCore.Functions.SetVehicleProperties(vehicle, props)
    if DoesEntityExist(vehicle) then
        -- set vehicle stuff here
    end
end

function SMDXCore.Functions.LoadParticleDictionary(dictionary)
    if HasNamedPtfxAssetLoaded(dictionary) then return end
    RequestNamedPtfxAsset(dictionary)
    while not HasNamedPtfxAssetLoaded(dictionary) do
        Wait(0)
    end
end

function SMDXCore.Functions.StartParticleAtCoord(dict, ptName, looped, coords, rot, scale, alpha, color, duration)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(cache.ped)
    end
    SMDXCore.Functions.LoadParticleDictionary(dict)
    UseParticleFxAssetNextCall(dict)
    SetPtfxAssetNextCall(dict)
    local particleHandle
    if looped then
        particleHandle = StartParticleFxLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0)
        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end
        SetParticleFxLoopedAlpha(particleHandle, alpha or 10.0)
        if duration then
            Wait(duration)
            StopParticleFxLooped(particleHandle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)
        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end
        StartParticleFxNonLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0)
    end
    return particleHandle
end

function SMDXCore.Functions.StartParticleOnEntity(dict, ptName, looped, entity, bone, offset, rot, scale, alpha, color, evolution, duration)
    SMDXCore.Functions.LoadParticleDictionary(dict)
    UseParticleFxAssetNextCall(dict)
    local particleHandle, boneID
    if bone and GetEntityType(entity) == 1 then
        boneID = GetPedBoneIndex(entity, bone)
    elseif bone then
        boneID = GetEntityBoneIndexByName(entity, bone)
    end
    if looped then
        if bone then
            particleHandle = StartParticleFxLoopedOnEntityBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale)
        else
            particleHandle = StartParticleFxLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale)
        end
        if evolution then
            SetParticleFxLoopedEvolution(particleHandle, evolution.name, evolution.amount, false)
        end
        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end
        SetParticleFxLoopedAlpha(particleHandle, alpha)
        if duration then
            Wait(duration)
            StopParticleFxLooped(particleHandle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)
        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end
        if bone then
            StartParticleFxNonLoopedOnPedBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale)
        else
            StartParticleFxNonLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale)
        end
    end
    return particleHandle
end

function SMDXCore.Functions.GetStreetNametAtCoords(coords)
    local streetname1, streetname2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return { main = GetStreetNameFromHashKey(streetname1), cross = GetStreetNameFromHashKey(streetname2) }
end

function SMDXCore.Functions.GetZoneAtCoords(coords)
    return GetLabelText(GetNameOfZone(coords))
end

function SMDXCore.Functions.GetCardinalDirection(entity)
    entity = DoesEntityExist(entity) and entity or PlayerPedId()
    if DoesEntityExist(entity) then
        local heading = GetEntityHeading(entity)
        if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
            return "Norr"
        elseif (heading >= 45 and heading < 135) then
            return "Väst"
        elseif (heading >= 135 and heading < 225) then
            return "Syd"
        elseif (heading >= 225 and heading < 315) then
            return "Öst"
        end
    else
        return "Cardinal Direction Error"
    end
end

function SMDXCore.Functions.GetCurrentTime()
    local obj = {}
    obj.min = GetClockMinutes()
    obj.hour = GetClockHours()

    if obj.hour <= 12 then
        obj.ampm = "AM"
    elseif obj.hour >= 13 then
        obj.ampm = "PM"
        obj.formattedHour = obj.hour - 12
    end

    if obj.min <= 9 then
        obj.formattedMin = "0" .. obj.min
    end

    return obj
end

function SMDXCore.Functions.GetGroundZCoord(coords)
    if not coords then return end

    local retval, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
    if retval then
        return vector3(coords.x, coords.y, groundZ)
    else
        print('Couldn\'t find Ground Z Coordinates given 3D Coordinates')
        print(coords)
        return coords
    end
end