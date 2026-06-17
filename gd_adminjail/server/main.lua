local jailedPlayers = {}

-- Initialize Database
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `admin_jail` (
            `citizenid` VARCHAR(50) NOT NULL,
            `time` INT(11) NOT NULL DEFAULT 0,
            `reason` TEXT DEFAULT NULL,
            PRIMARY KEY (`citizenid`)
        )
    ]])
end)

local function sendToDiscord(title, message)
    if Config.Webhook == "" then return end
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = 16711680,
            ["footer"] = { ["text"] = "Admin Jail Logs" },
            ["timestamp"] = os.date("!YYYY-MM-T%H:%M:%SZ")
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, "POST", json.encode({username = "Jail Logger", embeds = embed}), { ["Content-Type"] = "application/json" })
end

-- Jail Logic
local function jailPlayer(targetSrc, time, reason, adminSrc)
    local player = exports.qbx_core:GetPlayer(targetSrc)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    jailedPlayers[citizenid] = time

    MySQL.prepare("INSERT INTO admin_jail (citizenid, time, reason) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE time = ?, reason = ?", 
    {citizenid, time, reason, time, reason})

    if Config.UseRoutingBuckets then
        SetPlayerRoutingBucket(targetSrc, targetSrc + 1000)
    end

    TriggerClientEvent("adminjail:client:EnterJail", targetSrc, time)
    
    local adminName = adminSrc == 0 and "Console" or GetPlayerName(adminSrc)
    sendToDiscord("Player Jailed", string.format("**Target:** %s\n**Admin:** %s\n**Time:** %d mins\n**Reason:** %s", GetPlayerName(targetSrc), adminName, time, reason))
end

-- Commands
lib.addCommand(Config.Commands.jail, {
    restricted = Config.AdminGroups,
    params = {
        { name = "target", help = "Player ID", type = "number" },
        { name = "time", help = "Time in minutes", type = "number" },
        { name = "reason", help = "Reason for jail", type = "string", optional = true }
    }
}, function(source, args)
    local target = args.target
    local time = args.time
    local reason = args.reason or "No reason provided"
    
    if not GetPlayerName(target) then
        return TriggerClientEvent("ox_lib:notify", source, {title = "Error", description = "Invalid Player ID", type = "error"})
    end

    jailPlayer(target, time, reason, source)
end)

lib.addCommand(Config.Commands.unjail, {
    restricted = Config.AdminGroups,
    params = { { name = "target", help = "Player ID", type = "number" } }
}, function(source, args)
    local target = args.target
    local player = exports.qbx_core:GetPlayer(target)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    jailedPlayers[citizenid] = nil
    MySQL.query("DELETE FROM admin_jail WHERE citizenid = ?", {citizenid})

    if Config.UseRoutingBuckets then
        SetPlayerRoutingBucket(target, 0)
    end

    TriggerClientEvent("adminjail:client:Release", target)
end)

-- Time Tracking Loop
CreateThread(function()
    while true do
        Wait(60000) -- Every 1 minute
        for _, src in ipairs(GetPlayers()) do
            local player = exports.qbx_core:GetPlayer(tonumber(src))
            if player then
                local cid = player.PlayerData.citizenid
                if jailedPlayers[cid] and jailedPlayers[cid] > 0 then
                    jailedPlayers[cid] -= 1
                    MySQL.query("UPDATE admin_jail SET time = ? WHERE citizenid = ?", {jailedPlayers[cid], cid})
                    
                    if jailedPlayers[cid] <= 0 then
                        jailedPlayers[cid] = nil
                        MySQL.query("DELETE FROM admin_jail WHERE citizenid = ?", {cid})
                        if Config.UseRoutingBuckets then SetPlayerRoutingBucket(src, 0) end
                        TriggerClientEvent("adminjail:client:Release", src)
                    end
                end
            end
        end
    end
end)

-- Handle Login
AddEventHandler("qbx_core:server:PlayerLoaded", function(PlayerData)
    local src = PlayerData.source
    local cid = PlayerData.citizenid

    local result = MySQL.prepare.await("SELECT time FROM admin_jail WHERE citizenid = ?", {cid})
    if result and result > 0 then
        jailedPlayers[cid] = result
        if Config.UseRoutingBuckets then SetPlayerRoutingBucket(src, src + 1000) end
        TriggerClientEvent("adminjail:client:EnterJail", src, result)
    end
end)

-- Callback for Menu
lib.callback.register("adminjail:server:getJailedPlayers", function(source)
    return MySQL.query.await("SELECT a.*, p.charinfo FROM admin_jail a LEFT JOIN players p ON a.citizenid = p.citizenid")
end)
