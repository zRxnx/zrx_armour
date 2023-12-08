CORE = exports.zrx_utility:GetUtility()
PLAYER_CACHE, USED, COOLDOWN = {}, {}, {}
local GetPlayers = GetPlayers
local TriggerClientEvent = TriggerClientEvent
local GetCurrentResourceName = GetCurrentResourceName

RegisterNetEvent(Config.OnPlayerLoadEvent, function(player)
    PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)
    PLAYER_CACHE[player].vData = {}
    Player.Load(player)
end)

RegisterNetEvent(Config.OnPlayerDeathEvent, function(player)
    Player.Reset(player)
end)

AddEventHandler('playerDropped', function()
    if not PLAYER_CACHE[source] then return end
    Player.Save(source)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        Player.Save(player)
    end
end)

RegisterNetEvent('zrx_armour:server:useArmour', function(index)
    if USED[source] then
        USED[source] = false

        if Webhook.Links.useArmour:len() > 0 then
            local message = ([[
                The player used a armour
    
                Item: **%s**
                Value: **%s**
                Index: **%s**
            ]]):format(Config.Armour[index].item, Config.Armour[index].value, index)

            CORE.Server.DiscordLog(source, 'USE ARMOUR', message, Webhook.Links.useArmour)
        end

        CORE.Bridge.removeInventoryItem(source, Config.Armour[index].item, 1)
    else
        Config.PunishPlayer(source, 'Tried to trigger "zrx_armour:server:useArmour"')
    end
end)

RegisterNetEvent('zrx_armour:server:cancelArmour', function()
    if USED[source] then
        USED[source] = false

        if Webhook.Links.cancelArmour:len() > 0 then
            local message = [[
                The player cancelled a armour
            ]]

            CORE.Server.DiscordLog(source, 'CANCEL ARMOUR', message, Webhook.Links.cancelArmour)
        end
    else
        Config.PunishPlayer(source, 'Tried to trigger "zrx_armour:server:cancelArmour"')
    end
end)

CreateThread(function()
    if Config.CheckForUpdates then
        CORE.Server.CheckVersion('zrx_armour')
    end

    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_armour` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(255) DEFAULT NULL,
            `value` int(100) DEFAULT 0,
            `drawable` varchar(255) DEFAULT 0,
            `texture` varchar(255) DEFAULT 0,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB;
    ]])

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)
        PLAYER_CACHE[player].vData = {}

        Player.Load(player)
    end

    for i, data in pairs(Config.Armour) do
        CORE.Bridge.registerUsableItem(data.item, function(source)
            local xPlayer = CORE.Bridge.getVariables(source)

            if Player.HasCooldown(source) then
                return CORE.Bridge.notification(source, Strings.on_cooldown)
            end

            if USED[source] then
                return CORE.Bridge.notification(source, Strings.already_using)
            end

            USED[source] = true
            if xPlayer.sex == 'm' then
                PLAYER_CACHE[source].vData.drawable = data.vest.male.drawable
                PLAYER_CACHE[source].vData.texture = data.vest.male.texture
            else
                PLAYER_CACHE[source].vData.drawable = data.vest.female.drawable
                PLAYER_CACHE[source].vData.texture = data.vest.female.texture
            end

            if Webhook.Links.startArmour:len() > 0 then
                local message = ([[
                    The player started a armour
        
                    Item: **%s**
                    Value: **%s**
                    Index: **%s**
                ]]):format(data.item, data.value, i)

                CORE.Server.DiscordLog(source, 'START ARMOUR', message, Webhook.Links.startArmour)
            end

            TriggerClientEvent('zrx_armour:client:useArmour', source, i)
        end)
    end
end)

ESX.RegisterServerCallback(GetCurrentResourceName().. ":Server:GetGender", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local result = MySQL.single.await("SELECT sex FROM users WHERE identifier = ?", {xPlayer.identifier})

    if result then
        return cb(result.sex)
    else
        print("Die Spalte 'SEX' für den Spieler ".. xPlayer.identifier .." konnte nicht abgerufen werden.")
        return cb(false)
    end
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[PLAYER_CACHE[player].license]
end)
