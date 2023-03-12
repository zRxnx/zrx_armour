ESX = Config.esxImport()
WEBHOOK = ''

CreateThread(function()
	MySQL.Sync.execute(
        'ALTER TABLE `users` ' ..
        'ADD IF NOT EXISTS armour int(100) DEFAULT 0; '
	)

    Config.RegisterItems()
    CheckValues()
end)

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer)
    if not xPlayer then return end
    player = tonumber(player)

    MySQL.query('SELECT `armour` FROM `users` WHERE `identifier` = ?', {
        xPlayer.identifier
    }, function(data)
        local armour = tonumber(data[1].armour)

        if armour > 0 then
            local ped = GetPlayerPed(player)

            SetPedArmour(ped, armour)
            SetPedComponentVariation(ped, 9, Config.Default.vest.texture, Config.Default.vest.secTexture, 0)
            TriggerClientEvent('zrx_armour:client:setState', player, true)
        end
    end)
end)

RegisterNetEvent('esx:onPlayerDeath', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.update.await('UPDATE `users` SET `armour` = ? WHERE `identifier` = ?', {
        0,
        xPlayer.identifier
    })
end)

AddEventHandler('esx:playerDropped', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local armour = GetPedArmour(GetPlayerPed(source))

    MySQL.update.await('UPDATE `users` SET `armour` = ? WHERE `identifier` = ?', {
        armour,
        xPlayer.identifier
    })
end)