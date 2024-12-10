Player = {
    Load = function(player)
        local xPlayer = CORE.Bridge.getPlayerObject(player)
        local response = MySQL.query.await('SELECT * FROM `zrx_armour` WHERE `identifier` = ?', { xPlayer.identifier })
        local data = response[1]

        if Webhook.Links.loadArmour:len() > 0 then
            local message = [[
                The player loaded their armour
            ]]

            CORE.Server.DiscordLog(player, 'LOAD ARMOUR', message, Webhook.Links.loadArmour)
        end

        if not data then
            MySQL.insert.await('INSERT INTO `zrx_armour` (identifier) VALUES (?)', { xPlayer.identifier })
            return
        elseif not data.drawable or data.texture == 0 or data.value == 0 then
            return
        end

        data.drawable = tonumber(data.drawable)
        data.texture = tonumber(data.texture)

        PLAYER_CACHE[xPlayer.player].vData.drawable = data.drawable
        PLAYER_CACHE[xPlayer.player].vData.texture = data.texture

        for item, data2 in pairs(Config.Armour) do
            if data.drawable == data2.vest.male.drawable or data.drawable == data2.vest.female.drawable and
            data.texture == data2.vest.male.texture or data.texture == data2.vest.female.texture then
                CURRENT = item
            end
        end

        Wait(3000)

        while GetPedArmour(GetPlayerPed(xPlayer.player)) ~= data.value do
            SetPedArmour(GetPlayerPed(xPlayer.player), data.value)
            Wait(0)
        end

        if type(data.drawable) == 'number' then
            SetPedComponentVariation(GetPlayerPed(xPlayer.player), 9, data.drawable, data.texture, 0)
        end

        TriggerClientEvent('zrx_armour:client:setState', xPlayer.player, { drawable = data.drawable, texture = data.texture }, data.value)
    end,

    Save = function(player)
        local xPlayer = CORE.Bridge.getPlayerObject(player)
        if not xPlayer then return end
        local ped = GetPlayerPed(xPlayer.player)

        if Webhook.Links.loadArmour:len() > 0 then
            local message = [[
                The player saved their armour
            ]]

            CORE.Server.DiscordLog(player, 'LOAD ARMOUR', message, Webhook.Links.loadArmour)
        end

        if PLAYER_CACHE[xPlayer.player].vData?.drawable and PLAYER_CACHE[xPlayer.player].vData?.texture then
            MySQL.update.await('UPDATE `zrx_armour` SET `value` = ?, `drawable` = ?, `texture` = ? WHERE identifier = ?', {
                GetPedArmour(ped),
                PLAYER_CACHE[xPlayer.player].vData.drawable,
                PLAYER_CACHE[xPlayer.player].vData.texture,
                xPlayer.identifier
            })
        end
    end,

    Reset = function(player)
        local xPlayer = CORE.Bridge.getPlayerObject(player)
        local ped = GetPlayerPed(xPlayer.player)

        if Webhook.Links.loadArmour:len() > 0 then
            local message = [[
                The player resetted their armour
            ]]

            CORE.Server.DiscordLog(player, 'LOAD ARMOUR', message, Webhook.Links.loadArmour)
        end

        if Config.Armour[CURRENT].vest?.male?.drawable then
            SetPedComponentVariation(ped, 9, 0, 0, 0)
        end
        MySQL.update.await('UPDATE `zrx_armour` SET `value` = ?, `drawable` = ?, `texture` = ? WHERE identifier = ?', { 0, 0, 0, xPlayer.identifier })

        TriggerClientEvent('zrx_armour:client:setState', xPlayer.player, {}, false)
    end,

    HasCooldown = function(player)
        if not Config.Cooldown then return false end
        local identifier = PLAYER_CACHE[player].license

        if COOLDOWN[identifier] then
            if os.time() - Config.Cooldown > COOLDOWN[identifier] then
                COOLDOWN[identifier] = nil
            else
                return true
            end
        else
            COOLDOWN[identifier] = os.time()
        end

        return false
    end
}