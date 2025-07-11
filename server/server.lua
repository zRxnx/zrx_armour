---@diagnostic disable: need-check-nil, cast-local-type, missing-parameter
RegisterNetEvent(Config.OnPlayerLoadEvent, function(player)
    Wait(1000)
    ManagePlayer(player).load()
end)

RegisterNetEvent(Config.OnPlayerDeathEvent, function()
    local player = source
    Wait(1000)
    ManagePlayer(player).reset()
end)

AddEventHandler('playerDropped', function()
    local player = source
    print('playerDropped', player)
    local armour = GetPedArmour(GetPlayerPed(player))
    print('playerDropped', armour)

    ManagePlayer(player).save(armour)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Wait(1000)

        for player, state in pairs(ZRX_UTIL.getPlayers()) do
            print('tosave', player)
            ManagePlayer(player).save()
        end
    end)
end)

RegisterNetEvent('zrx_armour:server:manageArmour', function(data)
    local player = source

    if data.action == 'use' and Player(player).state['zrx_armour:used'] then
        print('use', Player(player).state['zrx_armour:current'])
        Player(player).state:set('zrx_armour:used', false, true)
        Player(player).state:set('zrx_armour:current', data.index, true)

        ZRX_UTIL.invObj:RemoveItem(player, data.index, 1)
        lib.logger(player, 'zrx_armour:usedArmour', ('I: %s'):format(data.index))
        ManagePlayer(player).save()
    elseif data.action == 'break' then
        print('break')
        lib.logger(player, 'zrx_armour:breakArmour', ('I: %s'):format(data.index))
        ManagePlayer(player).reset()
    end
end)

if Config.TakeBack then
    RegisterCommand(Config.TakeBack.command, function(player)
        local ped = GetPlayerPed(player)
        local armour = GetPedArmour(ped)

        if armour == 0 then
            ZRX_UTIL.notify(player, Strings.no_armour)
            return
        end

        local response = lib.callback.await('zrx_armour:client:await', player, Player(player).state['zrx_armour:current'])

        if not response then
            return
        end

        print('takeback', Player(player).state['zrx_armour:current'], armour, Strings.value:format(armour))
        ZRX_UTIL.invObj:AddItem(player, Player(player).state['zrx_armour:current'], 1, { value = armour, description = Strings.value:format(armour) })
        ManagePlayer(player).reset()
        ZRX_UTIL.notify(player, Strings.taken_off)
    end)
end

CreateThread(function()
    lib.versionCheck('zrxnx/zrx_armour')

    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_armour` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) DEFAULT NULL,
            `value` int(100) DEFAULT 0,
            `type` longtext DEFAULT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB;
    ]])

    Wait(1000)
    for player, state in pairs(ZRX_UTIL.getPlayers()) do
        print('toload', player)
        ManagePlayer(player).load()
    end

    ZRX_UTIL.invObj:registerHook('createItem', function(payload)
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

    local player = inventory.player.source
    local data = Config.Armour[index]
    local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)
    item = ZRX_UTIL.invObj:GetSlot(player, slot)

    print(item, player)

    print('ui', player)

    if data.allowedJobs and not data.allowedJobs[xPlayer.job.name] then
        ZRX_UTIL.notify(player, Strings.not_permitted)
        return false
    end

    if not data.allowedInVehicles and DoesEntityExist(GetVehiclePedIsIn(GetPlayerPed(player), false)) then
        ZRX_UTIL.notify(player, Strings.in_vehicle)
        return false
    end

    if Player(player).state['zrx_armour:used'] then
        ZRX_UTIL.notify(player, Strings.already_using)
        return false
    end

    Player(player).state:set('zrx_armour:used', true, true)
    if xPlayer.sex == 'f' and data.vest.female.drawable then
        Player(player).state:set('zrx_armour:drawable', data.vest.female.drawable, true)
        Player(player).state:set('zrx_armour:texture', data.vest.female.texture, true)
    else
        Player(player).state:set('zrx_armour:drawable', data.vest.female.drawable, true)
        Player(player).state:set('zrx_armour:texture', data.vest.female.texture, true)
    end

    Wait(100)
    print(player, index, item.metadata.value or data.value)
    TriggerClientEvent('zrx_armour:client:useArmour', player, index, item.metadata.value or data.value)
    print(player, index, item.metadata.value or data.value)

    return false
end)