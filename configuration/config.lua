local seconds, minutes = 1000, 60000
Config = {}

Config.RemoveArmourOnBreak = true --| Should the vest be removed after no more armour
Config.ForceComponent = true --| Reset player component while armour active
Config.OnPlayerDeathEvent = 'esx:onPlayerDeath' --| Event listener
Config.OnPlayerLoadEvent = 'esx:playerLoaded' --| First parameter needs the player id

Config.TakeBack = { --| Command to take your current equipped armour back to the inv
    enabled = true,

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
    bulletproof_small = {
        usetime = 3 * seconds, --| Usetime
        value = 25, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?

        allowedJobs = { --| Allowed jobs
            unemployed = true
        },

        vest = {
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

    bulletproof_medium = {
        usetime = 3 * seconds, --| Usetime
        value = 50, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?

        allowedJobs = { --| Allowed jobs
            unemployed = true
        },

        vest = {
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

    bulletproof_big = {
        usetime = 3 * seconds, --| Usetime
        value = 100, --| 0 - 100 value
        allowedInVehicles = false, --| Enabled?

        allowedJobs = { --| Allowed jobs
            unemployed = true
        },

        vest = {
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

Config.Notify = function(player, msg, title, type, color, time)
    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', player, {
            title = title,
            description = msg,
            type = type,
            duration = time,
            style = {
                color = color
            }
        })
    else
        lib.notify({
            title = title,
            description = msg,
            type = type,
            duration = time,
            style = {
                color = color
            }
        })
    end
end