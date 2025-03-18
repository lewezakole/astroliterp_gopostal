fx_version 'cerulean'
game 'gta5'

author '_zakolinski'
description 'prosty skrypcior na gopostala'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_target',
    'ox_lib',
    'es_extended'
}
