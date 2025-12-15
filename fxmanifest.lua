fx_version "cerulean"
game "gta5"
author "Pickle Mods"
version "v1.2.0"

ui_page "nui/index.html"

files {
	"nui/index.html",
	"nui/assets/**/*.*",
}

shared_scripts {
	"@ox_lib/init.lua",
	"config.lua",
	"locales/locale.lua",
    "locales/translations/*.lua",
    "core/shared.lua"
}

client_scripts {
	"bridge/**/**/client.lua",
	"modules/**/client.lua",
    "core/client.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"bridge/database.lua",
	"bridge/**/**/server.lua",
	"modules/**/server.lua",
}

-- Auto-inject database on resource start
database {
	"_INSTALL/SQL/install.sql"
}

lua54 'yes'
