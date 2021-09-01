fx_version 'cerulean'

game 'gta5'

lua54 'yes'

description 'A simple NUI plate creator by Entity Evolution'

version '1.0.0'

shared_scripts {
    'config.lua',
    '@es_extended/imports.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/fonts/*.ttf',
    'html/css/style.css',
    'html/js/script.js'
}