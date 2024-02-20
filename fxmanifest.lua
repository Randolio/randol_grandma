fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Grandma revive script. [QB/ESX]'
lua54 'yes'

shared_scripts {'@ox_lib/init.lua'}

client_scripts {'bridge/client/**.lua', 'cl_grandma.lua'}

server_scripts {'bridge/server/**.lua', 'sv_grandma.lua'}
