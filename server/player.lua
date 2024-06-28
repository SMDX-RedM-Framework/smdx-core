SMDXCore.Players = {}
SMDXCore.Player = {}

-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function SMDXCore.Player.Login(source, citizenid, newData)
    if source and source ~= "" then
        if citizenid then
            local license = SMDXCore.Functions.GetIdentifier(source, "license")
            local PlayerData = MySQL.prepare.await("SELECT * FROM players where citizenid = ?", { citizenid })
            if PlayerData and license == PlayerData.license then
                PlayerData.money = json.decode(PlayerData.money)
                PlayerData.job = json.decode(PlayerData.job)
                PlayerData.position = json.decode(PlayerData.position)
                PlayerData.metadata = json.decode(PlayerData.metadata)
                PlayerData.charinfo = json.decode(PlayerData.charinfo)
                if PlayerData.gang then
                    PlayerData.gang = json.decode(PlayerData.gang)
                else
                    PlayerData.gang = {}
                end
                SMDXCore.Player.CheckPlayerData(source, PlayerData)
            else
                DropPlayer(source, Lang:t("info.exploit_dropped"))
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "anticheat",
                    "Anti-Cheat",
                    "white",
                    GetPlayerName(source) .. " Has Been Dropped For Character Joining Exploit",
                    false
                )
            end
        else
            SMDXCore.Player.CheckPlayerData(source, newData)
        end
        return true
    else
        SMDXCore.ShowError(GetCurrentResourceName(), "ERROR SMDXCORE.PLAYER.LOGIN - NO SOURCE GIVEN!")
        return false
    end
end

function SMDXCore.Player.GetOfflinePlayer(citizenid)
    if citizenid then
        local PlayerData = MySQL.Sync.prepare("SELECT * FROM players where citizenid = ?", { citizenid })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            if PlayerData.gang then
                PlayerData.gang = json.decode(PlayerData.gang)
            else
                PlayerData.gang = {}
            end
            return SMDXCore.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

function SMDXCore.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = true
    if source then
        PlayerData.source = source
        PlayerData.license = PlayerData.license or SMDXCore.Functions.GetIdentifier(source, "license")
        PlayerData.name = GetPlayerName(source)
        Offline = false
    end

    PlayerData.citizenid = PlayerData.citizenid or SMDXCore.Player.CreateCitizenId()
    PlayerData.cid = PlayerData.cid or 1
    PlayerData.money = PlayerData.money or {}
    PlayerData.optin = PlayerData.optin or true
    for moneytype, startamount in pairs(SMDXCore.Config.Money.MoneyTypes) do
        PlayerData.money[moneytype] = PlayerData.money[moneytype] or startamount
    end

    -- Charinfo
    PlayerData.charinfo = PlayerData.charinfo or {}
    PlayerData.charinfo.firstname = PlayerData.charinfo.firstname or "Förnamn"
    PlayerData.charinfo.lastname = PlayerData.charinfo.lastname or "Efternamn"
    PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate or "00-00-0000"
    PlayerData.charinfo.gender = PlayerData.charinfo.gender or 0
    PlayerData.charinfo.nationality = PlayerData.charinfo.nationality or "Svensk"
    PlayerData.charinfo.account = PlayerData.charinfo.account or SMDXCore.Functions.CreateAccountNumber()
	
    -- OutlawStatus
    PlayerData.outlawstatus = PlayerData.outlawstatus or 0

    -- Metadata
    PlayerData.metadata = PlayerData.metadata or {}
    PlayerData.metadata['house'] = PlayerData.metadata['house'] or 'none'
    PlayerData.metadata["health"] = PlayerData.metadata["health"] or 600
    PlayerData.metadata["hunger"] = PlayerData.metadata["hunger"] or 100
    PlayerData.metadata["thirst"] = PlayerData.metadata["thirst"] or 100
    PlayerData.metadata["cleanliness"] = PlayerData.metadata["cleanliness"] or 100
    PlayerData.metadata["stress"] = PlayerData.metadata["stress"] or 0
    PlayerData.metadata["isdead"] = PlayerData.metadata["isdead"] or false
    PlayerData.metadata["armor"] = PlayerData.metadata["armor"] or 0
    PlayerData.metadata["ishandcuffed"] = PlayerData.metadata["ishandcuffed"] or false
    PlayerData.metadata["isescorted"] = PlayerData.metadata["isescorted"] or false
    PlayerData.metadata["injail"] = PlayerData.metadata["injail"] or 0
    PlayerData.metadata["jailitems"] = PlayerData.metadata["jailitems"] or {}
    PlayerData.metadata["status"] = PlayerData.metadata["status"] or {}
    PlayerData.metadata["bloodtype"] = PlayerData.metadata["bloodtype"] or SMDXCore.Config.Player.Bloodtypes[math.random(1, #SMDXCore.Config.Player.Bloodtypes)]
    PlayerData.metadata["dealerrep"] = PlayerData.metadata["dealerrep"] or 0
    PlayerData.metadata["craftingrep"] = PlayerData.metadata["craftingrep"] or 0
    PlayerData.metadata["attachmentcraftingrep"] = PlayerData.metadata["attachmentcraftingrep"] or 0
    PlayerData.metadata["jobrep"] = PlayerData.metadata["jobrep"] or {}
    PlayerData.metadata["fingerprint"] = PlayerData.metadata["fingerprint"] or SMDXCore.Player.CreateFingerId()
    PlayerData.metadata["walletid"] = PlayerData.metadata["walletid"] or SMDXCore.Player.CreateWalletId()
    PlayerData.metadata["criminalrecord"] = PlayerData.metadata["criminalrecord"] or { ["hasRecord"] = false, ["date"] = nil,}

    -- Job
    if PlayerData.job and PlayerData.job.name and not SMDXCore.Shared.Jobs[PlayerData.job.name] then
        PlayerData.job = nil
    end
    PlayerData.job = PlayerData.job or {}
    PlayerData.job.name = PlayerData.job.name or "unemployed"
    PlayerData.job.label = PlayerData.job.label or "Arbetslös"
    PlayerData.job.payment = PlayerData.job.payment or 10
    PlayerData.job.type = PlayerData.job.type or "none"
    if SMDXCore.Shared.ForceJobDefaultDutyAtLogin or PlayerData.job.onduty == nil then
        PlayerData.job.onduty = SMDXCore.Shared.Jobs[PlayerData.job.name].defaultDuty
    end
    PlayerData.job.isboss = PlayerData.job.isboss or false
    PlayerData.job.grade = PlayerData.job.grade or {}
    PlayerData.job.grade.name = PlayerData.job.grade.name or "Frilansare"
    PlayerData.job.grade.level = PlayerData.job.grade.level or 0

    -- Gang
    if PlayerData.gang and PlayerData.gang.name and not SMDXCore.Shared.Gangs[PlayerData.gang.name] then
        PlayerData.gang = nil
    end
    PlayerData.gang = PlayerData.gang or {}
    PlayerData.gang.name = PlayerData.gang.name or "none"
    PlayerData.gang.label = PlayerData.gang.label or "Inge Gängtillhörighet"
    PlayerData.gang.isboss = PlayerData.gang.isboss or false
    PlayerData.gang.grade = PlayerData.gang.grade or {}
    PlayerData.gang.grade.name = PlayerData.gang.grade.name or "none"
    PlayerData.gang.grade.level = PlayerData.gang.grade.level or 0
    
    -- Other
    PlayerData.position = PlayerData.position or SMDXConfig.DefaultSpawn
    PlayerData.items = GetResourceState("smdx-inventory") ~= "missing"
            and exports["smdx-inventory"]:LoadInventory(PlayerData.source, PlayerData.citizenid)
        or {}
    return SMDXCore.Player.CreatePlayer(PlayerData, Offline)
end

-- On player logout

function SMDXCore.Player.Logout(source)
    TriggerClientEvent("SMDXCore:Client:OnPlayerUnload", source)
    TriggerEvent("SMDXCore:Server:OnPlayerUnload", source)
    TriggerClientEvent("SMDXCore:Player:UpdatePlayerData", source)
    Wait(200)
    SMDXCore.Players[source] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function SMDXCore.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then
            return
        end -- Unsupported for Offline Players
        TriggerEvent("SMDXCore:Player:SetPlayerData", self.PlayerData)
        TriggerClientEvent("SMDXCore:Player:SetPlayerData", self.PlayerData.source, self.PlayerData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = tostring(grade) or "0"
        if not SMDXCore.Shared.Jobs[job] then
            return false
        end
        self.PlayerData.job.name = job
        self.PlayerData.job.label = SMDXCore.Shared.Jobs[job].label
        self.PlayerData.job.onduty = SMDXCore.Shared.Jobs[job].defaultDuty
        self.PlayerData.job.type = SMDXCore.Shared.Jobs[job].type or "none"
        if SMDXCore.Shared.Jobs[job].grades[grade] then
            local jobgrade = SMDXCore.Shared.Jobs[job].grades[grade]
            self.PlayerData.job.grade = {}
            self.PlayerData.job.grade.name = jobgrade.name
            self.PlayerData.job.grade.level = tonumber(grade)
            self.PlayerData.job.payment = jobgrade.payment or 30
            self.PlayerData.job.isboss = jobgrade.isboss or false
        else
            self.PlayerData.job.grade = {}
            self.PlayerData.job.grade.name = "Inga Grader"
            self.PlayerData.job.grade.level = 0
            self.PlayerData.job.payment = 30
            self.PlayerData.job.isboss = false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent("SMDXCore:Server:OnJobUpdate", self.PlayerData.source, self.PlayerData.job)
            TriggerClientEvent("SMDXCore:Client:OnJobUpdate", self.PlayerData.source, self.PlayerData.job)
        end

        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = tostring(grade) or "0"
        if not SMDXCore.Shared.Gangs[gang] then
            return false
        end
        self.PlayerData.gang.name = gang
        self.PlayerData.gang.label = SMDXCore.Shared.Gangs[gang].label
        if SMDXCore.Shared.Gangs[gang].grades[grade] then
            local ganggrade = SMDXCore.Shared.Gangs[gang].grades[grade]
            self.PlayerData.gang.grade = {}
            self.PlayerData.gang.grade.name = ganggrade.name
            self.PlayerData.gang.grade.level = tonumber(grade)
            self.PlayerData.gang.isboss = ganggrade.isboss or false
        else
            self.PlayerData.gang.grade = {}
            self.PlayerData.gang.grade.name = "Inga Grader"
            self.PlayerData.gang.grade.level = 0
            self.PlayerData.gang.isboss = false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent("SMDXCore:Server:OnGangUpdate", self.PlayerData.source, self.PlayerData.gang)
            TriggerClientEvent("SMDXCore:Client:OnGangUpdate", self.PlayerData.source, self.PlayerData.gang)
        end

        return true
    end

    function self.Functions.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = not not onDuty -- Make sure the value is a boolean if nil is sent
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= "string" then
            return
        end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= "string" then
            return
        end
        if meta == "hunger" or meta == "thirst" then
            val = val > 100 and 100 or val
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= "string" then
            return
        end
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.AddJobReputation(amount)
        if not amount then
            return
        end
        amount = tonumber(amount)
        self.PlayerData.metadata["jobrep"][self.PlayerData.job.name] = self.PlayerData.metadata["jobrep"][self.PlayerData.job.name]
            + amount
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.AddMoney(moneytype, amount, reason, showhud)
        reason = reason or "unknown"
        if showhud == nil then showhud = true end
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then
            return
        end
        if not self.PlayerData.money[moneytype] then
            return false
        end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "playermoney",
                    "AddMoney",
                    "lightgreen",
                    "**"
                        .. GetPlayerName(self.PlayerData.source)
                        .. " (citizenid: "
                        .. self.PlayerData.citizenid
                        .. " | id: "
                        .. self.PlayerData.source
                        .. ")** $"
                        .. amount
                        .. " ("
                        .. moneytype
                        .. ") added, new "
                        .. moneytype
                        .. " balance: "
                        .. self.PlayerData.money[moneytype]
                        .. " reason: "
                        .. reason,
                    true
                )
            else
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "playermoney",
                    "AddMoney",
                    "lightgreen",
                    "**"
                        .. GetPlayerName(self.PlayerData.source)
                        .. " (citizenid: "
                        .. self.PlayerData.citizenid
                        .. " | id: "
                        .. self.PlayerData.source
                        .. ")** $"
                        .. amount
                        .. " ("
                        .. moneytype
                        .. ") added, new "
                        .. moneytype
                        .. " balance: "
                        .. self.PlayerData.money[moneytype]
                        .. " reason: "
                        .. reason
                )
            end
            if showhud then TriggerClientEvent("hud:client:OnMoneyChange", self.PlayerData.source, moneytype, amount, false) end
            TriggerClientEvent("SMDXCore:Client:OnMoneyChange", self.PlayerData.source, moneytype, amount, "add", reason)
            TriggerEvent("SMDXCore:Server:OnMoneyChange", self.PlayerData.source, moneytype, amount, "add", reason)
        end

        return true
    end

    function self.Functions.RemoveMoney(moneytype, amount, reason, showhud)
        reason = reason or "unknown"
        if showhud == nil then showhud = true end
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then
            return
        end
        if not self.PlayerData.money[moneytype] then
            return false
        end
        for _, mtype in pairs(SMDXCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "playermoney",
                    "RemoveMoney",
                    "red",
                    "**"
                        .. GetPlayerName(self.PlayerData.source)
                        .. " (citizenid: "
                        .. self.PlayerData.citizenid
                        .. " | id: "
                        .. self.PlayerData.source
                        .. ")** $"
                        .. amount
                        .. " ("
                        .. moneytype
                        .. ") removed, new "
                        .. moneytype
                        .. " balance: "
                        .. self.PlayerData.money[moneytype]
                        .. " reason: "
                        .. reason,
                    true
                )
            else
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "playermoney",
                    "RemoveMoney",
                    "red",
                    "**"
                        .. GetPlayerName(self.PlayerData.source)
                        .. " (citizenid: "
                        .. self.PlayerData.citizenid
                        .. " | id: "
                        .. self.PlayerData.source
                        .. ")** $"
                        .. amount
                        .. " ("
                        .. moneytype
                        .. ") removed, new "
                        .. moneytype
                        .. " balance: "
                        .. self.PlayerData.money[moneytype]
                        .. " reason: "
                        .. reason
                )
            end
            if showhud then TriggerClientEvent("hud:client:OnMoneyChange", self.PlayerData.source, moneytype, amount, true) end
            TriggerClientEvent("SMDXCore:Client:OnMoneyChange", self.PlayerData.source, moneytype, amount, "remove", reason)
            TriggerEvent("SMDXCore:Server:OnMoneyChange", self.PlayerData.source, moneytype, amount, "remove", reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or "unknown"
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then
            return false
        end
        if not self.PlayerData.money[moneytype] then
            return false
        end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent(
                "smdx-log:server:CreateLog",
                "playermoney",
                "SetMoney",
                "green",
                "**"
                    .. GetPlayerName(self.PlayerData.source)
                    .. " (citizenid: "
                    .. self.PlayerData.citizenid
                    .. " | id: "
                    .. self.PlayerData.source
                    .. ")** $"
                    .. amount
                    .. " ("
                    .. moneytype
                    .. ") set, new "
                    .. moneytype
                    .. " balance: "
                    .. self.PlayerData.money[moneytype]
                    .. " reason: "
                    .. reason
            )
            TriggerClientEvent(
                "hud:client:OnMoneyChange",
                self.PlayerData.source,
                moneytype,
                math.abs(difference),
                difference < 0
            )
            TriggerClientEvent("SMDXCore:Client:OnMoneyChange", self.PlayerData.source, moneytype, amount, "set", reason)
            TriggerEvent("SMDXCore:Server:OnMoneyChange", self.PlayerData.source, moneytype, amount, "set", reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        if not moneytype then
            return false
        end
        moneytype = moneytype:lower()
        return self.PlayerData.money[moneytype]
    end

    function self.Functions.Save()
        if self.Offline then
            SMDXCore.Player.SaveOffline(self.PlayerData)
        else
            SMDXCore.Player.Save(self.PlayerData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then
            return
        end -- Unsupported for Offline Players
        SMDXCore.Player.Logout(self.PlayerData.source)
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    if self.Offline then
        return self
    else
        SMDXCore.Players[self.PlayerData.source] = self
        SMDXCore.Player.Save(self.PlayerData.source)

        -- At this point we are safe to emit new instance to third party resource for load handling
        TriggerEvent("SMDXCore:Server:PlayerLoaded", self)
        self.Functions.UpdatePlayerData()
    end
end

-- Add a new function to the Functions table of the player class
-- Use-case:
--[[
    AddEventHandler('SMDXCore:Server:PlayerLoaded', function(Player)
        SMDXCore.Functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
            -- do something here
        end)
    end)
]]

function SMDXCore.Functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(SMDXCore.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not SMDXCore.Players[ids] then
                return
            end

            SMDXCore.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            SMDXCore.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

-- Add a new field table of the player class
-- Use-case:
--[[
    AddEventHandler('SMDXCore:Server:PlayerLoaded', function(Player)
        SMDXCore.Functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]

function SMDXCore.Functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(SMDXCore.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not SMDXCore.Players[ids] then
                return
            end

            SMDXCore.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            SMDXCore.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function SMDXCore.Player.Save(source)
    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped)
    local PlayerData = SMDXCore.Players[source].PlayerData
    if PlayerData then
        MySQL.insert(
            "INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata",
            {
                citizenid = PlayerData.citizenid,
                cid = tonumber(PlayerData.cid),
                license = PlayerData.license,
                name = PlayerData.name,
                money = json.encode(PlayerData.money),
                charinfo = json.encode(PlayerData.charinfo),
                job = json.encode(PlayerData.job),
                gang = json.encode(PlayerData.gang),
                position = json.encode(pcoords),
                metadata = json.encode(PlayerData.metadata),
            }
        )
        if GetResourceState("smdx-inventory") ~= "missing" then
            exports["smdx-inventory"]:SaveInventory(source)
        end
        SMDXCore.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. " SPELARE SPARAD!")
    else
        SMDXCore.ShowError(GetCurrentResourceName(), "ERROR SMDXCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!")
    end
end

function SMDXCore.Player.SaveOffline(PlayerData)
    if PlayerData then
        MySQL.Async.insert(
            "INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata",
            {
                citizenid = PlayerData.citizenid,
                cid = tonumber(PlayerData.cid),
                license = PlayerData.license,
                name = PlayerData.name,
                money = json.encode(PlayerData.money),
                charinfo = json.encode(PlayerData.charinfo),
                job = json.encode(PlayerData.job),
                gang = json.encode(PlayerData.gang),
                position = json.encode(PlayerData.position),
                metadata = json.encode(PlayerData.metadata),
            }
        )
        if GetResourceState("smdx-inventory") ~= "missing" then
            exports["smdx-inventory"]:SaveInventory(PlayerData, true)
        end
        SMDXCore.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. " OFFLINE PLAYER SAVED!")
    else
        SMDXCore.ShowError(GetCurrentResourceName(), "ERROR SMDXCORE.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!")
    end
end

-- Delete character

local playertables = { -- Add tables as needed
    { table = "players"},
    { table = "playeroutfit"},
    { table = "playerskins"},
    { table = "player_horses"},
    { table = "player_weapons"},
    { table = "address_book"},
    { table = "telegrams"},
}

function SMDXCore.Player.DeleteCharacter(source, citizenid)
    local license = SMDXCore.Functions.GetIdentifier(source, "license")
    local result = MySQL.scalar.await("SELECT license FROM players where citizenid = ?", { citizenid })
    if license == result then
        local query = "DELETE FROM %s WHERE citizenid = ?"
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)
        
        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end
        
        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "joinleave",
                    "Character Deleted",
                    "red",
                    "**" .. GetPlayerName(source) .. "** " .. license .. " deleted **" .. citizenid .. "**.."
                )
            end
        end)
    else
        DropPlayer(source, Lang:t("info.exploit_dropped"))
        TriggerEvent(
            "smdx-log:server:CreateLog",
            "anticheat",
            "Anti-Cheat",
            "white",
            GetPlayerName(source) .. " Has Been Dropped For Character Deletion Exploit",
            true
        )
    end
end

function SMDXCore.Player.ForceDeleteCharacter(citizenid)
    local result = MySQL.scalar.await("SELECT license FROM players where citizenid = ?", { citizenid })
    if result then
        local query = "DELETE FROM %s WHERE citizenid = ?"
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)
        local Player = SMDXCore.Functions.GetPlayerByCitizenId(citizenid)

        if Player then
            DropPlayer(Player.PlayerData.source, "An admin deleted the character which you are currently using")
        end
        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent(
                    "smdx-log:server:CreateLog",
                    "joinleave",
                    "Character Force Deleted",
                    "red",
                    "Character **" .. citizenid .. "** got deleted"
                )
            end
        end)
    end
end

-- Inventory Backwards Compatibility

function SMDXCore.Player.SaveInventory(source)
    if GetResourceState("smdx-inventory") == "missing" then
        return
    end
    exports["smdx-inventory"]:SaveInventory(source, false)
end

function SMDXCore.Player.SaveOfflineInventory(PlayerData)
    if GetResourceState("smdx-inventory") == "missing" then
        return
    end
    exports["smdx-inventory"]:SaveInventory(PlayerData, true)
end

function SMDXCore.Player.GetTotalWeight(items)
    if GetResourceState("smdx-inventory") == "missing" then
        return
    end
    return exports["smdx-inventory"]:GetTotalWeight(items)
end

function SMDXCore.Player.GetSlotsByItem(items, itemName)
    if GetResourceState("smdx-inventory") == "missing" then
        return
    end
    return exports["smdx-inventory"]:GetSlotsByItem(items, itemName)
end

function SMDXCore.Player.GetFirstSlotByItem(items, itemName)
    if GetResourceState("smdx-inventory") == "missing" then
        return
    end
    return exports["smdx-inventory"]:GetFirstSlotByItem(items, itemName)
end

-- Util Functions

function SMDXCore.Player.CreateCitizenId()
    local UniqueFound = false
    local CitizenId = nil
    while not UniqueFound do
        CitizenId = tostring(SMDXCore.Shared.RandomStr(3) .. SMDXCore.Shared.RandomInt(5)):upper()
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM players WHERE citizenid = ?", { CitizenId })
        if result == 0 then
            UniqueFound = true
        end
    end
    return CitizenId
end

function SMDXCore.Functions.CreateAccountNumber()
    local UniqueFound = false
    local AccountNumber = nil
    while not UniqueFound do
        AccountNumber = "SMDX"
            .. math.random(1, 9)
            .. math.random(1111, 9999)
            .. math.random(1111, 9999)
            .. math.random(11, 99)
        local query = "%" .. AccountNumber .. "%"
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM players WHERE charinfo LIKE ?", { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return AccountNumber
end

function SMDXCore.Player.CreateFingerId()
    local UniqueFound = false
    local FingerId = nil
    while not UniqueFound do
        FingerId = tostring(
            SMDXCore.Shared.RandomStr(2)
                .. SMDXCore.Shared.RandomInt(3)
                .. SMDXCore.Shared.RandomStr(1)
                .. SMDXCore.Shared.RandomInt(2)
                .. SMDXCore.Shared.RandomStr(3)
                .. SMDXCore.Shared.RandomInt(4)
        )
        local query = "%" .. FingerId .. "%"
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE ?", { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return FingerId
end

function SMDXCore.Player.CreateWalletId()
    local UniqueFound = false
    local WalletId = nil
    while not UniqueFound do
        WalletId = "smdx-" .. math.random(11111111, 99999999)
        local query = "%" .. WalletId .. "%"
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?", { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return WalletId
end

function SMDXCore.Player.CreateSerialNumber()
    local UniqueFound = false
    local SerialNumber = nil
    while not UniqueFound do
        SerialNumber = math.random(11111111, 99999999)
        local query = "%" .. SerialNumber .. "%"
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?", { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return SerialNumber
end

if SMDXConfig.Money.PayCheckEnabled then
    PaycheckInterval() -- This starts the paycheck system end
end