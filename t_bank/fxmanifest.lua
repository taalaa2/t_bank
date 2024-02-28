fx_version 'adamant'

game 'gta5'
lua54 'yes'
description 'Banking With OX LIB'
author 'Taala'
version '1.0'

client_scripts {
	'c_*.lua',
}

shared_script {'@ox_lib/init.lua', 's_config.lua'}

server_scripts  {
    's_*.lua',
}

dependencies {
	't_bank',
}
