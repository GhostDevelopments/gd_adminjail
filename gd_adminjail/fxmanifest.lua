fx_version "cerulean"
game "gta5"

author "SwisserAI"
description "Admin Jail System - Generated with SwisserAI - https://ai.swisser.dev"
version "1.0.0"

ui_page "html/ui.html"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua"
}

files {
    "html/ui.html",
    "html/script.js"
}