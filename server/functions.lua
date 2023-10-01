local GetPedArmour = GetPedArmour
local GetPlayerPed = GetPlayerPed
local SetPedArmour = SetPedArmour
local SetPedComponentVariation = SetPedComponentVariation
local TriggerClientEvent = TriggerClientEvent
local Wait = Wait
local GetPlayerName = GetPlayerName
local GetNumPlayerTokens = GetNumPlayerTokens
local GetPlayerGuid = GetPlayerGuid
local GetPlayerToken = GetPlayerToken
local PerformHttpRequest = PerformHttpRequest
local GetPlayerPing = GetPlayerPing
local GetCurrentResourceName = GetCurrentResourceName
local GetResourceMetadata = GetResourceMetadata
local GetPlayerIdentifierByType = GetPlayerIdentifierByType

GetPlayerData = function(player)
    local p1, p2 = promise.new(), promise.new()
    local name = GetPlayerName(player)
    local numTokens = GetNumPlayerTokens(player)
    local guid = GetPlayerGuid(player)
    local fivem = (GetPlayerIdentifierByType(player, 'fivem') or 'NOT FOUND'):gsub('fivem:', '')
    local steam = (GetPlayerIdentifierByType(player, 'steam') or 'NOT FOUND'):gsub('steam:', '')
    local license = (GetPlayerIdentifierByType(player, 'license') or 'NOT FOUND'):gsub('license:', '')
    local license2 = (GetPlayerIdentifierByType(player, 'license2'):gsub('license2:', '') or 'NOT FOUND'):gsub('license2:', '')
    local discord = (GetPlayerIdentifierByType(player, 'discord') or 'NOT FOUND'):gsub('discord:', '')
    local xbl = (GetPlayerIdentifierByType(player, 'xbl') or 'NOT FOUND'):gsub('xbl:', '')
    local liveid = (GetPlayerIdentifierByType(player, 'liveid') or 'NOT FOUND'):gsub('liveid:', '')
    local ip = (GetPlayerIdentifierByType(player, 'ip'):gsub('ip:', '') or 'NOT FOUND'):gsub('ip:', '')
    local country = 'NOT FOUND'
    local vpn = false
    local hwids = {}

    for i = 0, numTokens, 1 do
        hwids[#hwids + 1] = GetPlayerToken(player, i)
    end

    PerformHttpRequest(('http://ip-api.com/json/%s?fields=61439'):format(ip), function(_, result, _)
        if result then
            local data = json.decode(result)

            p1:resolve(data.country or 'NOT FOUND')
            p2:resolve(not not (data.hosting or data.proxy))
        end
    end)

    country = Citizen.Await(p1)
    vpn = Citizen.Await(p2)

    return {
        player = player,
        name = name,
        guid = guid,
        hwids = hwids,
        steam = steam,
        license = license,
        license2 = license2,
        fivem = fivem,
        xbl = xbl,
        ip = ip,
        discord = discord,
        liveid = liveid,
        country = country,
        vpn = vpn
    }
end

DiscordLog = function(player, title, message, webhook)
    if Webhook.Links[webhook]:len() <= 0 then return end
    local description = ('%s\n\n'):format(message)

    if not Webhook.Execlude.name then
        description = ('%s `👤` **Player**: %s\n'):format(description, PLAYER_CACHE[player].name)
    end

    if not Webhook.Execlude.player then
        description = ('%s `#️⃣` **Server ID**: `%s`\n'):format(description, PLAYER_CACHE[player].player)
    end

    if not Webhook.Execlude.ping then
        description = ('%s `📶` **Player Ping**: `%sms`\n'):format(description, GetPlayerPing(player) )
    end

    if not Webhook.Execlude.discord then
        description = ('%s `📌` **Discord ID**: `%s` <@%s>\n'):format(description, PLAYER_CACHE[player].discord, PLAYER_CACHE[player].discord)
    end

    if not Webhook.Execlude.fivem then
        description = ('%s `🟧` **FiveM ID**: `%s`\n'):format(description, PLAYER_CACHE[player].fivem)
    end

    if not Webhook.Execlude.license then
        description = ('%s `📀` **License ID**: `%s`\n'):format(description, PLAYER_CACHE[player].license)
    end

    if not Webhook.Execlude.license2 then
        description = ('%s `💿` **License2 ID**: `%s`\n'):format(description, PLAYER_CACHE[player].license2)
    end

    if not Webhook.Execlude.hwid then
        description = ('%s `💻` **Hardware ID**: `%s`\n'):format(description, PLAYER_CACHE[player].hwids[1])
    end

    if not Webhook.Execlude.steam then
        description = ('%s `👾` **Steam ID**: `%s`\n'):format(description, PLAYER_CACHE[player].steam)
    end

    if not Webhook.Execlude.xbl then
        description = ('%s `🕹️` **XBOX Live ID**: `%s`\n'):format(description, PLAYER_CACHE[player].xbl)
    end

    if not Webhook.Execlude.guid then
        description = ('%s `⚙️` **GUID**: `%s`\n'):format(description, PLAYER_CACHE[player].guid)
    end

    if not Webhook.Execlude.ip then
        description = ('%s `🌐` **IP**: ||%s||\n'):format(description, PLAYER_CACHE[player].ip)
    end

    if not Webhook.Execlude.country then
        description = ('%s `🌍` **Country**: ||%s||\n'):format(description, PLAYER_CACHE[player].country)
    end

    if not Webhook.Execlude.vpn then
        description = ('%s `🤖` **VPN**: ||%s||\n'):format(description, PLAYER_CACHE[player].vpn)
    end

    local embed = {
        {
            ['color'] = 255,
            ['title'] = title,
            ['description'] = description,
            ['footer'] = {
                ['text'] = ('Made by %s | %s'):format(GetResourceMetadata(GetCurrentResourceName(), 'author'), os.date()),
                ['icon_url'] = 'https://i.imgur.com/QOjklyr.png'
            },

            ['author'] = {
                ['name'] = 'zrx_armour',
                ['icon_url'] = 'https://i.imgur.com/QOjklyr.png'
            }
        }
    }

    PerformHttpRequest(Webhook.Links[webhook], nil, 'POST', json.encode({
        username = 'ZRX LOGS',
        embeds = embed,
        avatar_url = 'https://i.imgur.com/QOjklyr.png'
    }), {
        ['Content-Type'] = 'application/json'
    })
end

Player = {
    Load = function(player)
        local xPlayer = ESX.GetPlayerFromId(player)
        local response = MySQL.query.await('SELECT * FROM `zrx_armour` WHERE `identifier` = ?', { xPlayer.identifier })
        local data = response[1]

        if Webhook.Settings.loadArmour then
            DiscordLog(xPlayer.source, 'LOAD ARMOUR', 'Loaded armour of player', 'loadArmour')
        end

        if not data then
            MySQL.insert.await('INSERT INTO `zrx_armour` (identifier) VALUES (?)', { xPlayer.identifier })
            return
        elseif not data.drawable or data.texture == 0 then
            return
        end

        PLAYER_CACHE[xPlayer.source].vData.drawable = data.drawable
        PLAYER_CACHE[xPlayer.source].vData.texture = data.texture

        while GetPedArmour(GetPlayerPed(xPlayer.source)) ~= data.value do
            SetPedArmour(GetPlayerPed(xPlayer.source), data.value)
            Wait()
        end

        SetPedComponentVariation(GetPlayerPed(xPlayer.source), 9, data.drawable, data.texture, 0)

        TriggerClientEvent('zrx_armour:client:setState', xPlayer.source, { drawable = data.drawable, texture = data.texture }, true)
    end,

    Save = function(player)
        local xPlayer = ESX.GetPlayerFromId(player)
        if not xPlayer then return end
        local ped = GetPlayerPed(xPlayer.source)

        if Webhook.Settings.saveArmour then
            DiscordLog(xPlayer.source, 'SAVE ARMOUR', 'Saved armour of player', 'saveArmour')
        end

        MySQL.update.await('UPDATE `zrx_armour` SET `value` = ?, `drawable` = ?, `texture` = ? WHERE identifier = ?', {
            GetPedArmour(ped),
            PLAYER_CACHE[xPlayer.source].vData.drawable,
            PLAYER_CACHE[xPlayer.source].vData.texture,
            xPlayer.identifier
        })
    end,

    Reset = function(player)
        local xPlayer = ESX.GetPlayerFromId(player)
        local ped = GetPlayerPed(xPlayer.source)

        if Webhook.Settings.resetArmour then
            DiscordLog(xPlayer.source, 'RESET ARMOUR', 'Reseted armour of player', 'resetArmour')
        end

        SetPedComponentVariation(ped, 9, 0, 0, 0)
        MySQL.update.await('UPDATE `zrx_armour` SET `value` = ?, `drawable` = ?, `texture` = ? WHERE identifier = ?', { 0, 0, 0, xPlayer.identifier })

        TriggerClientEvent('zrx_armour:client:setState', xPlayer.source, {}, false)
    end,

    HasCooldown = function(player)
        if not Config.Cooldown then return false end
        local identifier = PLAYER_CACHE[player].license

        if COOLDOWN[identifier] then
            if os.time() - Config.Cooldown > COOLDOWN[identifier] then
                COOLDOWN[identifier] = nil
            else
                return true
            end
        else
            COOLDOWN[identifier] = os.time()
        end

        return false
    end
}