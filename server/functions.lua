ManagePlayer = function(player)
    local self = {}

    self.player = player
    self.identifier = GetPlayerIdentifierByType(self.player, 'license'):gsub('license:', '')

    self.load = function()
        local response = MySQL.query.await('SELECT * FROM `zrx_armour` WHERE `identifier` = ?', { self.identifier })
        local data = response[1]

        if not data then
            MySQL.insert.await('INSERT INTO `zrx_armour` (identifier) VALUES (?)', { self.identifier })
            return
        end

        if not data.type or data.value == 0 then
            return
        end

        local drawable
        local texture
        local ped

        drawable = Config.Armour[data.type].vest.male.drawable
        texture = Config.Armour[data.type].vest.male.texture

        print('load', self.player)
        Player(self.player).state:set('zrx_armour:drawable', drawable, true)
        Player(self.player).state:set('zrx_armour:texture', texture, true)
        Player(self.player).state:set('zrx_armour:current', data.type, true)

        Wait(1000)

        ped = GetPlayerPed(self.player)
        while GetPedArmour(ped) ~= data.value do
            ped = GetPlayerPed(self.player)

            SetPedArmour(ped, data.value)

            Wait(0)
        end

        SetPedComponentVariation(ped, 9, drawable, texture, 0)

        TriggerClientEvent('zrx_armour:client:setState', self.player, { drawable = drawable, texture = texture, value = data.value })
    end

    self.save = function(data)
        local armour = data or 0

        if not data then
            local ped = GetPlayerPed(self.player)

            while GetPedArmour(ped) == -1 and DoesEntityExist(ped) do
                ped = GetPlayerPed(self.player)
                armour = GetPedArmour(ped)

                Wait(0)
            end
        end

        print('save', armour, Player(player).state['zrx_armour:current'])

        MySQL.update.await('UPDATE `zrx_armour` SET `value` = ?, `type` = ? WHERE identifier = ?', {
            armour,
            Player(player).state['zrx_armour:current'],
            self.identifier
        })
    end

    self.reset = function()
        local ped

        Player(self.player).state:set('zrx_armour:drawable', 0, true)
        Player(self.player).state:set('zrx_armour:texture', 0, true)
        Player(self.player).state:set('zrx_armour:current', nil, true)

        ped = GetPlayerPed(self.player)
        while GetPedArmour(ped) ~= 0 do
            ped = GetPlayerPed(self.player)

            SetPedArmour(ped, 0)

            Wait(0)
        end

        MySQL.update.await('UPDATE `zrx_armour` SET `value` = ?, `type` = NULL WHERE identifier = ?', { 0, self.identifier })

        TriggerClientEvent('zrx_armour:client:setState', self.player, {})
    end

    return self
end