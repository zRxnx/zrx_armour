---@diagnostic disable: need-check-nil, cast-local-type
CORE = exports.zrx_utility:GetUtility()
OX_INV = exports?.ox_inventory
PLAYER_CACHE, USED, COOLDOWN, CURRENT = {}, {}, {}, 1

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
        CURRENT = index

        if Webhook.Links.useArmour:len() > 0 then
            local message = ([[
                The player used a armour
    
                Item: **%s**
                Value: **%s**
            ]]):format(index, Config.Armour[index].value)

            CORE.Server.DiscordLog(source, 'USE ARMOUR', message, Webhook.Links.useArmour)
        end

        CORE.Bridge.getPlayerObject(source).removeInventoryItem(index, 1)
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

if Config.Inventory == 'ox' and Config.TakeBack then
    RegisterCommand(Config.TakeBack.command, function(source)
        local ped = GetPlayerPed(source)
        local armour = GetPedArmour(ped)

        if armour == 0 then
            return CORE.Bridge.notification(source, Strings.no_armour)
        end

        local response = lib.callback.await('zrx_armour:client:awaitState', source, CURRENT)

        if not response then
            return
        end

        Player.Reset(source)
        OX_INV:AddItem(source, CURRENT, 1, { value = armour, description = Strings.value:format(armour) })
        CORE.Bridge.notification(source, Strings.taken_off)
    end)
end

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

    if Config.Inventory ~= 'ox' then
        for item, data in pairs(Config.Armour) do
            CORE.Bridge.registerUsableItem(item, function(source)
                local xPlayer = CORE.Bridge.getPlayerObject(source)

                if Player.HasCooldown(source) then
                    return CORE.Bridge.notification(source, Strings.on_cooldown)
                end

                if USED[source] then
                    return CORE.Bridge.notification(source, Strings.already_using)
                end

                USED[source] = true
                if xPlayer.sex == 'm' and data.vest.male?.drawable then
                    PLAYER_CACHE[source].vData.drawable = data.vest.male.drawable
                    PLAYER_CACHE[source].vData.texture = data.vest.male.texture
                elseif data.vest?.female?.drawable then
                    PLAYER_CACHE[source].vData.drawable = data.vest.female.drawable
                    PLAYER_CACHE[source].vData.texture = data.vest.female.texture
                end

                if Webhook.Links.startArmour:len() > 0 then
                    local message = ([[
                        The player started a armour
            
                        Item: **%s**
                        Value: **%s**
                    ]]):format(item, data.value)

                    CORE.Server.DiscordLog(source, 'START ARMOUR', message, Webhook.Links.startArmour)
                end

                TriggerClientEvent('zrx_armour:client:useArmour', source, i, data.value)
            end)
        end
    end

    if Config.Inventory == 'ox' then
        OX_INV:registerHook('createItem', function(payload)
            local index = ''

            for item, data in pairs(Config.Armour) do
                index = payload.item.name == item and item or ''

                if index ~= '' then
                    break
                end
            end

            if index == '' then
                return
            end

            local metadata = payload.metadata

            if not metadata.value then
                metadata.value = Config.Armour[index].value
                metadata.index = index
                metadata.description = Strings.value:format(metadata.value)
            end

            return metadata
        end, {
            print = false,
        })
    end
end)

exports('useItem', function(event, item, inventory, slot)
    if event ~= 'usingItem' then return end
    local index = 0

    for item2, data in pairs(Config.Armour) do
        index = item.name == item2 and item2 or ''

        if index ~= '' then
            break
        end
    end

    if index == '' then
        return
    end

    local xPlayer = CORE.Bridge.getPlayerObject(inventory.player.source)
    item = OX_INV:GetSlot(inventory.player.source, slot)

    if Player.HasCooldown(inventory.player.source) then
        CORE.Bridge.notification(inventory.player.source, Strings.on_cooldown)
        return false
    end

    if USED[inventory.player.source] then
        CORE.Bridge.notification(inventory.player.source, Strings.already_using)
        return false
    end

    USED[inventory.player.source] = true
    if xPlayer.sex == 'm' and Config.Armour[index].vest?.male?.drawable then
        PLAYER_CACHE[inventory.player.source].vData.drawable = Config.Armour[index].vest.male.drawable
        PLAYER_CACHE[inventory.player.source].vData.texture = Config.Armour[index].vest.male.texture
    elseif Config.Armour[index].vest?.female?.drawable then
        PLAYER_CACHE[inventory.player.source].vData.drawable = Config.Armour[index].vest.female.drawable
        PLAYER_CACHE[inventory.player.source].vData.texture = Config.Armour[index].vest.female.texture
    end

    if Webhook.Links.startArmour:len() > 0 then
        local message = ([[
            The player started a armour

            Item: **%s**
            Value: **%s**
        ]]):format(item.name, item.metadata.value)

        CORE.Server.DiscordLog(inventory.player.source, 'START ARMOUR', message, Webhook.Links.startArmour)
    end

    TriggerClientEvent('zrx_armour:client:useArmour', inventory.player.source, index, item.metadata.value)

    return false
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[PLAYER_CACHE[player].license]
end)