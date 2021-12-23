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
        -- wardrobe done - not tested yet
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

function F6Menu() -- F6 MENU IN PROGRESS
    local stuff = {
        {label = 'Preveri identiteto osebe', value = 'id'},
        {label = 'Preveri kazni osebi', value = 'kazni'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'defalut', {
        title = 'Sodnik - F6',
        align = 'bottom-right',
        elements = stuff
    }, function(data, menu)
        local x = data.current.value
        if x == 'id' then
            OpenIDCardMenu()
        elseif x == 'kazni' then
            OpenFineMenu()
    end, function(data, menu)
        menu.close()
    end)
end

function ObleciCivil()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        local isMale = skin.sex == 0

        TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
                TriggerEvent('esx:restoreLoadout')
            end)
        end)

    end)
end

function ObleciSodnik()
    TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			if Config.Uniforms[job].female then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		end
	end) 
end

function OpenVozilaMenu()
    local elements = {
        for k,v in pairs(Config.SodnikVehicles) do
			table.insert(elements, {label = v.label, name = v.label, model = v.model, price = v.price, type = 'car'})
		end
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'default', {
        title = 'Sodnik - VOZILA',
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        for k,v in pairs(Config.SodnikVehicles) do
            local d = v.model

            if d == 'audia8' then
                ESX.Game.SpawnVehicle('audia8', 192.10, 1021.21, 210.10, 90.0)
            end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenIDCardMenu()
-- TODO 
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsControlJustPressed(0,167) then
            F6Menu()
        end
    end
end)

--F6 MENU FUNCTIONS, COTNROLS, VEHICLES AND BLIPS COMING AS SOON AS POSSIBLE