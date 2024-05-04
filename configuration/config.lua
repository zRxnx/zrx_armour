local seconds, minutes = 1000, 60000
Config = {}

Config.CheckForUpdates = true --| Check for updates?
Config.RemoveArmourOnBreak = true --| Should the vest be removed after no more armour
Config.ForceComponent = true --| Reset player component while armour active
Config.LoadAndSaveArmour = true --| Save armour in database?
Config.Cooldown = 60 --| In seconds
Config.OnPlayerDeathEvent = 'zrx_utility:bridge:onPlayerDeath' --| Event listener
Config.OnPlayerLoadEvent = 'zrx_utility:bridge:playerLoaded' --| First parameter needs the player id

--[[

    If you want to use ox as inventory, read ITEMS.md

--]]
Config.Inventory = 'ox' --| ox or false

Config.TakeBack = { --| Command to take your current equipped armour back to the inv
    enabled = true, --| Only supports Config.Inventory to ox

    command = 'takearmour',
    usetime = 3 * seconds,
    anim = {
        dict = 'clothingtie', --| Dict
        lib = 'try_tie_negative_a', --| Lib
        flag = 1 --| 1 Full body - 16 Upper body
    },

    disable = {
        car = true,
        move = true,
        combat = true
    },
}

Config.Armour = {
    {
        item = 'bulletproof_small', --| Item name
        usetime = 3 * seconds, --| Usetime
        value = 25, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?
        allowedJobs = { --| Allowed jobs
            unemployed = true
        },

        vest = { --| Remove female and male to disable clothing | Setting it to 0 is not enough
            female = {
                drawable = 10, --| Vest drawable
                texture = 0 --| Vest texture
            },

            male = {
                drawable = 10, --| Vest drawable
                texture = 0 --| Vest texture
            }
        },

        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| Dict
            lib = 'gang_chatting_idle01', --| Lib
            flag = 1 --| 1 Full body - 16 Upper body
        },

        disable = {
            car = true,
            move = true,
            combat = true
        },
    },

    {
        item = 'bulletproof_medium', --| Item name
        usetime = 3 * seconds, --| Usetime
        value = 50, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?
        allowedJobs = { --| Allowed jobs
            unemployed = true
        },

        vest = { --| Remove female and male to disable clothing | Setting it to 0 is not enough
            female = {
                drawable = 10, --| Vest drawable
                texture = 1 --| Vest texture
            },

            male = {
                drawable = 10, --| Vest drawable
                texture = 1 --| Vest texture
            }
        },

        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| Dict
            lib = 'gang_chatting_idle01', --| Lib
            flag = 1 --| 1 Full body - 16 Upper body
        },

        disable = {
            car = true,
            move = true,
            combat = true
        },
    },

    {
        item = 'bulletproof_big', --| Item name
        usetime = 3 * seconds, --| Usetime
        value = 100, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?
        allowedJobs = { --| Allowed jobs
            unemployed = true
        },

        vest = { --| Remove female and male to disable clothing | Setting it to 0 is not enough
            female = {
                drawable = 10, --| Vest drawable
                texture = 2 --| Vest texture
            },

            male = {
                drawable = 10, --| Vest drawable
                texture = 2 --| Vest texture
            }
        },

        anim = {
            dict = 'anim@heists@narcotics@funding@gang_idle', --| Dict
            lib = 'gang_chatting_idle01', --| Lib
            flag = 1 --| 1 Full body - 16 Upper body
        },

        disable = {
            car = true,
            move = true,
            combat = true
        },
    }
}

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Links.punish:len() > 0 then
        local message = ([[
            The player got punished

            Reason: **%s**
        ]]):format(reason)

        CORE.Server.DiscordLog(player, 'Punish', message, Webhook.Links.punish)
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