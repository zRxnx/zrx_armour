local SetPedArmour = SetPedArmour
local SetPedComponentVariation = SetPedComponentVariation

UseArmour = function(index)
    local data = Config.Armour[index]

    if not data.allowedInVehicles and DoesEntityExist(cache.vehicle) then
        TriggerServerEvent('zrx_armour:server:cancelArmour')
        return Config.Notification(nil, Strings.in_vehicle)
    end

    if data.allowedJobs and not data.allowedJobs[ESX.PlayerData.job.name] then
        TriggerServerEvent('zrx_armour:server:cancelArmour')
        return Config.Notification(nil, Strings.not_permitted)
    end

    lib.progressBar({
        duration = data.usetime,
        label = Strings.using,
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = data.anim.dict,
            clip = data.anim.lib
        },
    })

    HasArmour = true
    Component = { drawable = data.vest.drawable, texture = data.vest.texture }
    SetPedArmour(cache.ped, data.value)
    SetPedComponentVariation(cache.ped, 9, data.vest.drawable, data.vest.texture, 0)

    Config.Notification(nil, Strings.taken)
    TriggerServerEvent('zrx_armour:server:useArmour', index)
end