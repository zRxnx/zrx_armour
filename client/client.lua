HasArmour, DisplayArmour, Component = false, true, {}

RegisterNetEvent('zrx_armour:client:useArmour', function(index, value)
    UseArmour(index, value)
end)

RegisterNetEvent('zrx_armour:client:setState', function(data, state)
    if data?.drawable and data?.texture then
        Component = data
    end

    if state then
        SetPedArmour(cache.ped, state)

        Wait(1000)

        HasArmour = true
    else
        HasArmour = false
    end
end)

CreateThread(function()
    while Config.RemoveArmourOnBreak do
        if HasArmour then
            if GetPedArmour(cache.ped) == 0 then
                HasArmour = false
                SetPedComponentVariation(cache.ped, 9, 0, 0, 0)
                Component = {
                    drawable = 0,
                    texture = 0
                }
                ZRX_UTIL.notify(nil, Strings.broke)
                TriggerServerEvent('zrx_armour:server:manageArmour', { action = 'break' })
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while Config.ForceComponent do
        if HasArmour and DisplayArmour then
            if GetPedDrawableVariation(cache.ped, 9) ~= Component.drawable or GetPedTextureVariation(cache.ped, 9) ~= Component.texture then
                SetPedComponentVariation(cache.ped, 9, Component.drawable, Component.texture, 2)
            end
        end

        Wait(1000)
    end
end)

lib.callback.register('zrx_armour:client:await', function(index)
    local config = Config.TakeBack

    local state = lib.progressBar({
        duration = config.usetime,
        label = Strings.using,
        useWhileDead = false,
        canCancel = true,
        disable = config.disable,
        anim = {
            dict = config.anim.dict,
            clip = config.anim.lib,
            flag = config.anim.flag
        },
    })

    if not state then
        return false
    end

    HasArmour = false
    SetPedArmour(cache.ped, 0)

    print(index)
    print(json.encode(Config.Armour[index], {indent = true}))

    SetPedComponentVariation(cache.ped, 9, 0, 0, 0)

    return true
end)

exports('hasArmour', function()
    return HasArmour
end)

exports('displayArmour', function(bool)
    DisplayArmour = bool

    if not bool then
        SetPedComponentVariation(cache.ped, 9, 0, 0, 2)
    end
end)