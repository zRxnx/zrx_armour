local GetPedArmour = GetPedArmour
local GetPlayerPed = GetPlayerPed
local SetPedArmour = SetPedArmour
local SetPedComponentVariation = SetPedComponentVariation
local TriggerClientEvent = TriggerClientEvent
local Wait = Wait

Player = {
    Load = function(player)
        local xPlayer = CORE.Bridge.getVariables(player)
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
        elseif not data.drawable or data.texture == 0 then
            return
        end

        PLAYER_CACHE[xPlayer.player].vData.drawable = data.drawable
        PLAYER_CACHE[xPlayer.player].vData.texture = data.texture

        while GetPedArmour(GetPlayerPed(xPlayer.player)) ~= data.value do
            SetPedArmour(GetPlayerPed(xPlayer.player), data.value)
            Wait()
        end

        SetPedComponentVariation(GetPlayerPed(xPlayer.player), 9, data.drawable, data.texture, 0)

        TriggerClientEvent('zrx_armour:client:setState', xPlayer.player, { drawable = data.drawable, texture = data.texture }, true)
    end,

    Save = function(player)
        local xPlayer = CORE.Bridge.getVariables(player)
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
        local xPlayer = CORE.Bridge.getVariables(player)
        local ped = GetPlayerPed(xPlayer.player)

        if Webhook.Links.loadArmour:len() > 0 then
            local message = [[
                The player resetted their armour
            ]]

            CORE.Server.DiscordLog(player, 'LOAD ARMOUR', message, Webhook.Links.loadArmour)
        end

        SetPedComponentVariation(ped, 9, 0, 0, 0)
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