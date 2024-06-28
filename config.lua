SMDXConfig = {}

SMDXConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
SMDXConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
SMDXConfig.UpdateInterval = 1 -- how often to update player data in minutes
SMDXConfig.StatusInterval = 5000 -- how often to check hunger/thirst status in milliseconds
SMDXConfig.EnablePVP = true   --- PvP always enabled.  You can use the command /pvp to temporarily disable and re-enable it.
SMDXConfig.HidePlayerNames = true

SMDXConfig.Money = {}
SMDXConfig.Money.MoneyTypes = { cash = 50, bank = 0, valbank = 0, rhobank = 0, blkbank = 0, armbank = 0, bloodmoney = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
SMDXConfig.Money.DontAllowMinus = { 'cash', 'bloodmoney' } -- Money that is not allowed going in minus
SMDXConfig.Money.PayCheckTimeOut = 30 -- The time in minutes that it will give the paycheck
SMDXConfig.Money.PayCheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires qb-management
SMDXConfig.Money.PayCheckEnabled = true -- If false payments will be disabled.

SMDXConfig.Player = {}
SMDXConfig.Player.RevealMap = true
SMDXConfig.Player.HungerRate = 1.0 -- Rate at which hunger goes down.
SMDXConfig.Player.ThirstRate = 1.0 -- Rate at which thirst goes down.
SMDXConfig.Player.CleanlinessRate = 0.0 -- Rate at which cleanliness goes down.
SMDXConfig.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-",
}

SMDXConfig.Server = {} -- General server config
SMDXConfig.Server.Closed = false -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
SMDXConfig.Server.ClosedReason = "Server Closed" -- Reason message to display when people can't join the server
SMDXConfig.Server.Uptime = 0 -- Time the server has been up.
SMDXConfig.Server.Whitelist = false -- Enable or disable whitelist on the server
SMDXConfig.Server.WhitelistPermission = 'admin' -- Permission that's able to enter the server when the whitelist is on
SMDXConfig.Server.Discord = "" -- Discord invite link
SMDXConfig.Server.CheckDuplicateLicense = true -- Check for duplicate rockstar license on join
SMDXConfig.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

SMDXConfig.Notify = {}

SMDXConfig.Notify.NotificationStyling = {
    group = false, -- Allow notifications to stack with a badge instead of repeating
    position = "right", -- top-left | top-right | bottom-left | bottom-right | top | bottom | left | right | center
    progress = true -- Display Progress Bar
}

-- These are how you define different notification variants
-- The "color" key is background of the notification
-- The "icon" key is the css-icon code, this project uses `Material Icons` & `Font Awesome`
SMDXConfig.NotifyPosition = 'top-right' -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'

-- other settings
SMDXConfig.PromptDistance = 1.5 -- distance for prompt to trigger (default = 1.5)
