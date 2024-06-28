-- Add or change (a) method(s) in the SMDXCore.Functions table
local function SetMethod(methodName, handler)
    if type(methodName) ~= "string" then
        return false, "invalid_method_name"
    end

    SMDXCore.Functions[methodName] = handler

    TriggerEvent('SMDXCore:Server:UpdateObject')

    return true, "success"
end

SMDXCore.Functions.SetMethod = SetMethod
exports("SetMethod", SetMethod)

-- Add or change (a) field(s) in the SMDXCore table
local function SetField(fieldName, data)
    if type(fieldName) ~= "string" then
        return false, "invalid_field_name"
    end

    SMDXCore[fieldName] = data

    TriggerEvent('SMDXCore:Server:UpdateObject')

    return true, "success"
end

SMDXCore.Functions.SetField = SetField
exports("SetField", SetField)

-- Single add job function which should only be used if you planning on adding a single job
local function AddJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if SMDXCore.Shared.Jobs[jobName] then
        return false, "job_exists"
    end

    SMDXCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
local function AddJobs(jobs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(jobs) do
        if type(key) ~= "string" then
            message = 'invalid_job_name'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        if SMDXCore.Shared.Jobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        SMDXCore.Shared.Jobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('SMDXCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, message, nil
end

SMDXCore.Functions.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
local function RemoveJob(jobName)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not SMDXCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    SMDXCore.Shared.Jobs[jobName] = nil

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
local function UpdateJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not SMDXCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    SMDXCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

-- Single add item
local function AddItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if SMDXCore.Shared.Items[itemName] then
        return false, "item_exists"
    end

    SMDXCore.Shared.Items[itemName] = item

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
local function UpdateItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end
    if not SMDXCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end
    SMDXCore.Shared.Items[itemName] = item
    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
local function AddItems(items)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if SMDXCore.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        SMDXCore.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('SMDXCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, message, nil
end

SMDXCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
local function RemoveItem(itemName)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if not SMDXCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end

    SMDXCore.Shared.Items[itemName] = nil

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
local function AddGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if SMDXCore.Shared.Gangs[gangName] then
        return false, "gang_exists"
    end

    SMDXCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
local function AddGangs(gangs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(gangs) do
        if type(key) ~= "string" then
            message = "invalid_gang_name"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        if SMDXCore.Shared.Gangs[key] then
            message = "gang_exists"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        SMDXCore.Shared.Gangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('SMDXCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, message, nil
end

SMDXCore.Functions.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
local function RemoveGang(gangName)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not SMDXCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    SMDXCore.Shared.Gangs[gangName] = nil

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
local function UpdateGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not SMDXCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    SMDXCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('SMDXCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('SMDXCore:Server:UpdateObject')
    return true, "success"
end

SMDXCore.Functions.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

local function GetCoreVersion(InvokingResource)
    local resourceVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
    if InvokingResource and InvokingResource ~= '' then
        print(("%s called SMDXCore version check: %s"):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

SMDXCore.Functions.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        name,
        SMDXCore.Functions.GetIdentifier(playerId, 'license'),
        SMDXCore.Functions.GetIdentifier(playerId, 'discord'),
        SMDXCore.Functions.GetIdentifier(playerId, 'ip'),
        origin,
        2147483647,
        'Anti Cheat'
    })
    DropPlayer(playerId, Lang:t('info.exploit_banned', {discord = SMDXCore.Config.Server.Discord}))
    TriggerEvent("smdx-log:server:CreateLog", "anticheat", "Anti-Cheat", "red", name .. " has been banned for exploiting " .. origin, true)
end

exports('ExploitBan', ExploitBan)