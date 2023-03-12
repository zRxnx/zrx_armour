fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zRxnx'
description 'Advanced armour system'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'configuration/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
	'oxmysql',
    'ox_lib'
}
