ESX, PLAYER_CACHE, USED, COOLDOWN = Config.EsxImport(), {}, {}, {}

RegisterNetEvent('esx:playerLoaded', function(player)
    PLAYER_CACHE[player] = GetPlayerData(player)
    PLAYER_CACHE[player].vData = {}
    Player.Load(player)
end)

CreateThread(function()
    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_armour` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(255) DEFAULT NULL,
            `value` int(100) DEFAULT 0,
            `index` int(255) DEFAULT 0,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB;
    ]])

    for i, data in pairs(GetPlayers()) do
        data = tonumber(data)
        PLAYER_CACHE[data] = GetPlayerData(data)
        PLAYER_CACHE[data].vData = {}
        Player.Load(data)
    end

    for i, data in pairs(Config.Armour) do
        ESX.RegisterUsableItem(data.item, function(source)
            if Player.HasCooldown(source) then
                return Config.Notification(source, Strings.on_cooldown)
            end

            USED[source] = true
            PLAYER_CACHE[source].vData.index = i

            if Webhook.Settings.startVest then
                DiscordLog(source, 'START VEST', 'Player started a vest', 'startVest')
            end

            TriggerClientEvent('zrx_armour:client:useArmour', source, i)
        end)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    for i, data in pairs(GetPlayers()) do
        data = tonumber(data)
        Player.Save(data)
    end
end)

RegisterNetEvent('zrx_armour:server:useArmour', function(index)
    if USED[source] then
        USED[source] = false
        local xPlayer = ESX.GetPlayerFromId(source)

        if Webhook.Settings.useVest then
            DiscordLog(source, 'USE VEST', 'Player used a vest', 'useVest')
        end

        xPlayer.removeInventoryItem(Config.Armour[index].item, 1)
    else
        Config.PunishPlayer(source, 'Tried to trigger "zrx_armour:server:useArmour"')
    end
end)

RegisterNetEvent('zrx_armour:server:cancelArmour', function()
    if USED[source] then
        USED[source] = false

        if Webhook.Settings.cancelArmour then
            DiscordLog(source, 'CANCEL ARMOUR', 'Player cancelled a armour', 'cancelArmour')
        end
    else
        Config.PunishPlayer(source, 'Tried to trigger "zrx_armour:server:cancelArmour"')
    end
end)

RegisterNetEvent(Config.OnPlayerDeathEvent, function()
    Player.Reset(source)
end)

AddEventHandler('playerDropped', function(reason)
    Player.Save(source)
end)