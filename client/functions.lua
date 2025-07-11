UseArmour = function(index, value)
    print(value, index)
    local data = Config.Armour[index]

    local response = lib.progressBar({
        duration = data.usetime,
        label = Strings.using,
        useWhileDead = false,
        canCancel = true,
        disable = data.disable,
        anim = {
            dict = data.anim.dict,
            clip = data.anim.lib,
            flag = data.anim.flag
        },
    })

    if not response then
        return
    end

    Component = {
        drawable = LocalPlayer.state['zrx_armour:drawable'],
        texture = LocalPlayer.state['zrx_armour:texture'],
    }

    SetPedArmour(cache.ped, value)
    print(GetPedArmour(cache.ped))

    while GetPedArmour(cache.ped) ~= value do
        SetPedArmour(cache.ped, value)
        Wait(0)
    end

    print(GetPedArmour(cache.ped))

    SetPedComponentVariation(cache.ped, 9, Component.drawable, Component.texture, 0)

    ZRX_UTIL.notify(nil, Strings.taken)
    TriggerServerEvent('zrx_armour:server:manageArmour', { action = 'use', index = index })

    HasArmour = true
end