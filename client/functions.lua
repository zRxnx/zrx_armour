ESX = exports.es_extended:getSharedObject()

local SetPedArmour = SetPedArmour
local SetPedComponentVariation = SetPedComponentVariation
local TriggerServerEvent = TriggerServerEvent
local DoesEntityExist = DoesEntityExist
local IsPedMale = IsPedMale

UseArmour = function(index)
    local data = Config.Armour[index]

    if not data.allowedInVehicles and DoesEntityExist(cache.vehicle) then
        TriggerServerEvent('zrx_armour:server:cancelArmour')
        return CORE.Bridge.notification(Strings.in_vehicle)
    end

    if data.allowedJobs and not data.allowedJobs[CORE.Bridge.getVariables().job.name] then
        TriggerServerEvent('zrx_armour:server:cancelArmour')
        return CORE.Bridge.notification(Strings.not_permitted)
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
            clip = data.anim.lib,
            flag = data.anim.flag
        },
    })

    ESX.TriggerServerCallback(GetCurrentResourceName()..":Server:GetGender", function(result)
        if result then
            if result == "f" then
                Component = { drawable = data.vest.female.drawable, texture = data.vest.female.texture }
            else
                Component = { drawable = data.vest.male.drawable, texture = data.vest.male.texture }
            end

            HasArmour = true
            SetPedArmour(cache.ped, data.value)
            SetPedComponentVariation(cache.ped, 9, data.vest.drawable, data.vest.texture, 0)

            CORE.Bridge.notification(Strings.taken)
            TriggerServerEvent('zrx_armour:server:useArmour', index)
        end
    end)
end
