UseArmour = function(index)
    local data = Config.Armour[index]

    Config.ProgressBar(data.anim.dict, data.anim.lib, data.value, data.usetime, data.vest)
end