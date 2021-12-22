ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

function OpenCloakroomMenu()
    local elements = {
        {label = 'Civilna oblacila', value = 'civil'},
        {label = 'Obleka sodnika I', value = 'sodnik'},
        {label = 'Obleka sodnika II', value = 'sodnik2'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'defautl', {
        title = 'Sodnik - OBLACILA',
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        -- TODO WARDROBE
        local a = data.current.value
        if a == 'civil' then
            ObleciCivil()
        elseif a == 'sodnik' then
            ObleciSodnik()
        elseif a == 'sodnik2' then
            ObleciSodnik()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- F6 MENU, WARDROBE FUNCTIONS, VEHICLES AND BLIPS COMING AS SOON AS POSSIBLE