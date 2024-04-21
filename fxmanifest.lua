fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zRxnx'
description 'Advanced armour system'
version '2.5.0'

dependencies {
    'zrx_utility',
	'ox_lib',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',
    'configuration/config.lua',
    'configuration/strings.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configuration/webhook.lua',
    'server/*.lua'
}