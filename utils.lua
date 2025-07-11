---@diagnostic disable: cast-local-type, need-check-nil
ZRX_UTIL = {}

-- FRAMEWORK
ZRX_UTIL.fw = 'unknown'
if GetResourceState('es_extended') ~= 'missing' then
    ZRX_UTIL.fw = 'esx'
    ZRX_UTIL.fwObj = exports.es_extended:getSharedObject()
end

if ZRX_UTIL.fw == 'unknown' then
    error('The framework could not get fetched, only ESX supported')
end

if not lib.checkDependency('es_extended', '1.12.0') then
    error('You need to use atleast version 1.12.0 of es_extended')
end

ZRX_UTIL.notify = function(player, msg, title, type, color, time)
    Config.Notify(player, msg, title, type, color, time)
end
ZRX_UTIL.n = ZRX_UTIL.notify

ZRX_UTIL.trim = function(string)
    return string:match('^%s*(.-)%s*$')
end
ZRX_UTIL.t = ZRX_UTIL.trim

ZRX_UTIL.printDebug = function(...)
    if ZRX_UTIL.debug then
        print(...)
    end
end
ZRX_UTIL.pd = ZRX_UTIL.printDebug

if IsDuplicityVersion() then
    -- INVENTORY
    ZRX_UTIL.inv = 'default'
    if GetResourceState('ox_inventory') ~= 'missing' then
        ZRX_UTIL.inv = 'ox'
        ZRX_UTIL.invObj = exports.ox_inventory

        if not lib.checkDependency('ox_inventory', '2.44.0') then
            error('You need to use atleast version 2.44.0 of ox_inventory')
        end
    end

    ZRX_UTIL.getPlayers = function()
        local players = {}

        for index, player in pairs(GetPlayers()) do
            player = tonumber(player)

            players[player] = true
        end

        return players
    end
else
    ZRX_UTIL.drawText3D = function(x, y, z, str, length, r, g, b, a)
        local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
        if not onScreen then return end

        local factor = #str / 370

        if length then
            factor = #str / length
        end

        SetTextScale(0.30, 0.30)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(r or 255, g or 255, b or 255, a or 215)
        BeginTextCommandDisplayText('STRING')
        SetTextCentre(true)
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandDisplayText(_x, _y)
        DrawRect(_x, _y + 0.0120, 0.006 + factor, 0.024, 0, 0, 0, 155)
    end

    ZRX_UTIL.addBlip = function(coords, sprite, scale, color, str)
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, color)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, scale)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandSetBlipName(blip)

        return blip
    end

    ZRX_UTIL.drawSubtitle = function(str, time)
        BeginTextCommandPrint('STRING')
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandPrint(time or 4000, true)
    end

    ZRX_UTIL.drawSpinner = function(str)
        BeginTextCommandBusyspinnerOn('STRING')
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandBusyspinnerOn(3)
    end

    ZRX_UTIL.spawnObject = function(model, coords, isLocal)
        model = type(model) == 'number' and model or joaat(model)

        lib.requestModel(model, 10000)

        local obj = CreateObject(model, coords.x, coords.y, coords.z, not isLocal, true, false)

        SetEntityAsMissionEntity(obj, true, false)
        SetModelAsNoLongerNeeded(model)

        if DoesEntityExist(obj) then
            return obj
        end
    end

    ZRX_UTIL.spawnPed = function(model, coords, heading, isLocal, cb)
        model = type(model) == 'number' and model or joaat(model)

        lib.requestModel(model, 10000)

        local ped = CreatePed(0, model, coords.x, coords.y, coords.z, heading, not isLocal, false)

        SetEntityAsMissionEntity(ped, true, false)
        SetModelAsNoLongerNeeded(model)

        if DoesEntityExist(ped) then
            return ped
        end
    end

    ZRX_UTIL.createMenu = function(menu, options, useContext, position)
        local showMenu = menu?.show == nil and true or menu?.show

        if useContext then
            lib.registerContext({
                id = menu.id,
                title = menu.title,
                menu = menu.menu,
                canClose = menu.canClose,
                onExit = menu.onExit,
                onBack = menu.onBack,
                options = options
            })

            if showMenu then
                lib.showContext(menu.id)
            end
        else
            local OPTIONS, FUNCTIONS, DISABLED, METADATA = {}, {}, {}, nil

            for i, data in ipairs(options) do
                if data.metadata then
                    METADATA = {}
                    for k, data2 in ipairs(data.metadata) do
                        METADATA[k] = ('%s: %s'):format(data2.label, data2.value)
                    end
                end

                FUNCTIONS[i] = data.onSelect
                DISABLED[i] = not not data.disabled

                OPTIONS[i] = {
                    label = data.title,
                    values = METADATA,
                    progress = data.progess,
                    colorScheme = data.colorScheme,
                    icon = data.icon,
                    iconColor = data.iconColor,
                    description = data.disabled == true and 'DISABLED | ' .. data.description or data.description,
                    args = data.args,
                }
            end

            lib.registerMenu({
                id = menu.id,
                title = menu.title,
                position = position,
                canClose = menu.canClose,
                onClose = function(keyPressed)
                    Wait(200)
                    if menu.menu and not IsPauseMenuActive() then
                        lib.showMenu(menu.menu)

                        if menu.onBack then
                            menu.onBack()
                        end
                    else
                        if menu.onExit then
                            menu.onExit()
                        end
                    end
                end,
                options = OPTIONS
            }, function(selected, scrollIndex, args)
                if not DISABLED[selected] and FUNCTIONS[selected] then
                    FUNCTIONS[selected](args)
                else
                    lib.showMenu(menu.id)
                end
            end)

            if showMenu then
                lib.showMenu(menu.id)
            end
        end
    end
end

ZU = ZRX_UTIL