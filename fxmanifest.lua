fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"

lua54 'yes'
version '1.2.3'

client_scripts {'client/client.lua'}
server_scripts {'server/server.lua'}

shared_scripts {
    'config.lua',
    'shared/locale.lua',
    'languages/*.lua'
}

files {
    'ui/*',
    'ui/assets/*',
    'ui/vendor/*',
    'ui/assets/fonts/*'
}
    
ui_page 'ui/index.html'

dependency 'vorp_core'
