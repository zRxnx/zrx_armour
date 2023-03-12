GetPlayerData = function(player)
    local name = GetPlayerName(player) or 'NOT FOUND'
    local hwid = GetPlayerToken(player, 0) or 'NOT FOUND'
    local ping = GetPlayerPing(player) or 'NOT FOUND'
    local guid = GetPlayerGuid(player) or 'NOT FOUND'
    local steam = 'NOT FOUND'
    local license = 'NOT FOUND'
    local discord = 'NOT FOUND'
    local xbl = 'NOT FOUND'
    local liveid = 'NOT FOUND'
    local ip = 'NOT FOUND'

    for _, identifier in pairs(GetPlayerIdentifiers(player)) do
        if string.sub(identifier, 1, string.len('steam:')) == 'steam:' then
            steam = identifier:gsub('steam:', '')
        elseif string.sub(identifier, 1, string.len('license:')) == 'license:' then
            license = identifier:gsub('license:', '')
        elseif string.sub(identifier, 1, string.len('xbl:')) == 'xbl:' then
            xbl  = identifier:gsub('xbl:', '')
        elseif string.sub(identifier, 1, string.len('ip:')) == 'ip:' then
            ip = identifier:gsub('ip:', '')
        elseif string.sub(identifier, 1, string.len('discord:')) == 'discord:' then
            discord = identifier:gsub('discord:', '')
        elseif string.sub(identifier, 1, string.len('live:')) == 'live:' then
            liveid = identifier:gsub('live:', '')
        end
    end

    return { name = name, ping = ping, guid = guid, hwid = hwid, steam = steam, license = license, xbl = xbl, ip = ip, discord = discord, liveid = liveid }
end

DiscordLog = function(player, title, message)
    if WEBHOOK == '' then return end
    local plyData = GetPlayerData(player)

    local embed = {
        {
            ['color'] = 255,
            ['title'] = title,
            ['description'] = string.format(
            '%s\n\n' ..
            '`👤` **Player**: %s\n' ..
            '`#️⃣` **Server ID**: `%s`\n' ..
            '`📶` **Player Ping**: `%s`\n' ..
            '`📌` **Discord ID**: `%s` <@%s>\n' ..
            '`👾` **Steam ID**: `%s`\n' ..
            '`📀` **License ID**: `%s`\n' ..
            '`💻` **Hardware ID**: `%s`\n' ..
            '`⚙️` **GUID ID**: `%s`\n' ..
            '`🕹️` **XBOX Live ID**: `%s`\n' ..
            '`🌐` **IP**: ||%s||'
            , message, plyData.name, player, plyData.ping, plyData.discord, plyData.discord, plyData.steam, plyData.license, plyData.hwid, plyData.guid, plyData.xbl, plyData.ip
            ),
            ['footer'] = {
                ['text'] = ('Made by %s | %s'):format(GetResourceMetadata(GetCurrentResourceName(), 'author'), os.date()),
                ['icon_url'] = 'https://i.imgur.com/QOjklyr.png'
            },

            ['author'] = {
                ['name'] = 'zrxn_panicbutton',
                ['icon_url'] = 'https://i.imgur.com/QOjklyr.png'
            }
        }
    }

    PerformHttpRequest(WEBHOOK, function(err, text, headers) end, 'POST', json.encode({
        username = 'ZRX LOGS',
        embeds = embed,
        avatar_url = 'https://i.imgur.com/QOjklyr.png'
    }), {
        ['Content-Type'] = 'application/json'
    })
end

CheckValues = function()
    for k, data in pairs(Config.Armour) do
        if data.value > 100 then
            print(("^0[^3WARNING^0] Value for %s (i = %s) is too high! Maximum: 100 - Current: %s"):format(data.item, k, data.value))
        elseif data.value < 0 then
            print(("^0[^3WARNING^0] Value for %s (i = %s) is too small! Minimum: 0 - Current: %s"):format(data.item, k, data.value))
        end
    end
end