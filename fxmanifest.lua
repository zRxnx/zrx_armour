fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'zrx_armour'
author 'zRxnx'
version '3.0.0'
description 'Advanced armour system'
repository 'https://github.com/zrxnx/zrx_armour'

docs 'https://docs.zrxnx.at'
discord 'https://discord.gg/mcN25FJ33K'

dependencies {
    '/server:6116',
    '/onesync',
	'ox_lib',
    'oxmysql',
}

shared_scripts {
    '@ox_lib/init.lua',
    'utils.lua',
    'configuration/*.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}