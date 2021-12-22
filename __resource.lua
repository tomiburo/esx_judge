resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'esx_judgejob made by tomiburo'

version '1.0.0'

server_scripts {
    'server/main.lua',
    'config.lua' -- just in case we need anything later on
}

client_scripts {
    'client/main.lua',
    'config.lua'
}