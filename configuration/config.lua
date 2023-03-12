local seconds, minutes = 1000, 60000
Config = {}

Config.RemoveArmourOnBreak = true --| Should the vest be removed after he has no more armour
Config.LoadAndSaveArmour = true --| Save the armour in database?

Config.Default = {
    vest = {
        texture = 15, --| Vest texture
        secTexture = 2 --| Vest 2nd texture
    }
}

Config.Armour = {
    {
        item = 'bulletproof_small', --| Item name
        usetime = 10 * seconds, --| Usetime
        value = 250, --| 0-100 armour value
        vest = {
            texture = 15, --| Vest texture
            secTexture = 2 --| Vest 2nd texture
        },
        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| dict
            lib = 'gang_chatting_idle01' --| lib
        }
    }
}

--| Place your progressbar here
Config.ProgressBar = function(dict, lib, value, usetime, vest)
    if IsDuplicityVersion() then return end

    ESX.Progressbar(Strings.using, usetime, {
        FreezePlayer = true,
        animation = {
            type = 'anim',
            dict = dict,
            lib = lib
        },
        onFinish = function()
            local ped = PlayerPedId()

            SetPedArmour(ped, value)
            SetPedComponentVariation(ped, 9, vest.texture, vest.secTexture, 0)

            Config.Notification(nil, Strings.taken)
    end})
end

--| Place your notification here
Config.Notification = function(source, msg)
    if IsDuplicityVersion() then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.showNotification(msg)
    else
        ESX.ShowNotification(msg)
    end
end

--| Place your esx Import here
Config.esxImport = function()
	if IsDuplicityVersion() then
		return exports['es_extended']:getSharedObject()
	else
		return exports['es_extended']:getSharedObject()
	end
end

--| Place your Register items here
Config.RegisterItems = function()
    if not IsDuplicityVersion() then return end

    for k, data in pairs(Config.Armour) do
        ESX.RegisterUsableItem(data.item, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            xPlayer.removeInventoryItem(data.item, 1)
            DiscordLog(source, Strings.logTitle, Strings.logDesc)
            TriggerClientEvent('zrx_armour:client:useArmour', source, k)
        end)
    end
end