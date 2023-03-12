ESX = Config.esxImport()
local hasArmour = false

RegisterNetEvent('zrx_armour:client:useArmour', function(index)
    if type(index) ~= 'number' then return end

    UseArmour(index)
    hasArmour = true
end)

RegisterNetEvent('zrx_armour:client:setState', function(state)
    hasArmour = state
end)

RegisterNetEvent('esx:onPlayerDeath', function()
    hasArmour = false
end)

CreateThread(function()
    while Config.RemoveArmourOnBreak do
        if hasArmour then
            if GetPedArmour(cache.ped) == 0 then
                SetPedComponentVariation(cache.ped, 9, 0, 0, 0)
                hasArmour = false
            end

            Wait(1000)
        else
            Wait(2000)
        end
    end
end)

exports('hasArmour', function()
    return hasArmour
end)