CORE = exports.zrx_utility:GetUtility()
HasArmour, DisplayArmour, Component = false, true, {}
local GetPedArmour = GetPedArmour
local SetPedComponentVariation = SetPedComponentVariation
local GetPedTextureVariation = GetPedTextureVariation
local GetPedDrawableVariation = GetPedDrawableVariation
local Wait = Wait

RegisterNetEvent('zrx_armour:client:useArmour', function(index, value)
    UseArmour(index, value)
end)

RegisterNetEvent('zrx_armour:client:setState', function(data, state)
    if data?.drawable and data?.texture then
        Component = data
    end

    HasArmour = state
end)

CreateThread(function()
    while Config.RemoveArmourOnBreak do
        if HasArmour then
            if GetPedArmour(cache.ped) == 0 then
                HasArmour = false
                SetPedComponentVariation(cache.ped, 9, 0, 0, 0)
                CORE.Bridge.notification(Strings.broke)
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

lib.callback.register('zrx_armour:client:awaitState', function(index)
    local state = lib.progressBar({
        duration = Config.TakeBack.usetime,
        label = Strings.using,
        useWhileDead = false,
        canCancel = true,
        disable = Config.TakeBack.disable,
        anim = {
            dict = Config.TakeBack.anim.dict,
            clip = Config.TakeBack.anim.lib,
            flag = Config.TakeBack.anim.flag
        },
    })

    if not state then
        return false
    end

    HasArmour = false
    SetPedArmour(cache.ped, 0)

    if Config.Armour[index].vest?.male?.drawable then
        SetPedComponentVariation(cache.ped, 9, 0, 0, 0)
    end

    return true
end)

exports('hasArmour', function()
    return HasArmour
end)

exports('displayArmour', function(bool)
    DisplayArmour = bool
end)