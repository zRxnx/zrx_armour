ESX, HasArmour, Component = Config.EsxImport(), false, {}
local GetPedArmour = GetPedArmour
local SetPedComponentVariation = SetPedComponentVariation
local GetPedTextureVariation = GetPedTextureVariation
local GetPedDrawableVariation = GetPedDrawableVariation
local Wait = Wait

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('zrx_armour:client:useArmour', function(index)
    UseArmour(index)
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
                SetPedComponentVariation(cache.ped, 9, 0, 0, 0)
                HasArmour = false
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while Config.ForceComponent do
        if HasArmour then
            if GetPedDrawableVariation(cache.ped, 9) ~= Component.drawable or GetPedTextureVariation(cache.ped, 9) ~= Component.texture then
                SetPedComponentVariation(cache.ped, 9, Component.drawable, Component.texture, 0)
            end
        end

        Wait(1000)
    end
end)

exports('hasArmour', function()
    return HasArmour
end)