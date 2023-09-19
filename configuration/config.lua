local seconds, minutes = 1000, 60000
Config = {}

Config.RemoveArmourOnBreak = true --| Should the vest be removed after no more armour
Config.ForceComponent = true --| Reset player component while armour active
Config.LoadAndSaveArmour = true --| Save armour in database?
Config.Cooldown = 60 --| In seconds
Config.OnPlayerDeathEvent = 'esx:onPlayerDeath' --| Event listener
Config.OnPlayerLoadEvent = 'esx:playerLoaded' --| First parameter needs the player id

Config.Armour = {
    {
        item = 'bulletproof_small', --| Item name
        usetime = 10 * seconds, --| Usetime
        value = 25, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?
        allowedJobs = { --| Allowed jobs
            unemployed = true
        },
        vest = {
            drawable = 15, --| Vest drawable
            texture = 2 --| Vest texture
        },
        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| Dict
            lib = 'gang_chatting_idle01' --| Lib
        }
    },

    {
        item = 'bulletproof_medium', --| Item name
        usetime = 15 * seconds, --| Usetime
        value = 50, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?
        allowedJobs = { --| Allowed jobs
            unemployed = true
        },
        vest = {
            drawable = 15, --| Vest drawable
            texture = 2 --| Vest texture
        },
        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| Dict
            lib = 'gang_chatting_idle01' --| Lib
        }
    },

    {
        item = 'bulletproof_big', --| Item name
        usetime = 15 * seconds, --| Usetime
        value = 100, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?
        allowedJobs = { --| Allowed jobs
            unemployed = true
        },
        vest = {
            drawable = 15, --| Vest drawable
            texture = 2 --| Vest texture
        },
        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| Dict
            lib = 'gang_chatting_idle01' --| Lib
        }
    }
}

--| Place here your notification
Config.Notification = function(player, msg)
    if IsDuplicityVersion() then
        local xPlayer = ESX.GetPlayerFromId(player)
        xPlayer.showNotification(msg)
    else
        ESX.ShowNotification(msg)
    end
end

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Settings.punish then
        DiscordLog(player, 'PUNISH', reason, 'punish')
    end

    DropPlayer(player, reason)
end

--| Place here your esx Import
Config.EsxImport = function()
	if IsDuplicityVersion() then
		return exports.es_extended:getSharedObject()
	else
		return exports.es_extended:getSharedObject()
	end
end