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

        CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = 'Pritisni ~INPUT_CONTEXT~, da odpres menu za garderobo.'
		CurrentActionData = {}
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

        CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = 'Pritisni ~INPUT_CONTEXT~, da odpres menu za garazo.'
		CurrentActionData = {}
    end)
end

function OpenIDCardMenu()
-- TODO 
end
-- blips here
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if PlayerData.job and PlayerData.job.name == 'judge' then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local isInMarker, hasExited, letSleep = false, false, true
            local currentStation, currentPart, currentPartNum

            for k,v in pairs(Config.Blips) do
                for i=1, #v.Garderobe, 1 do
                    local distance = GetDistanceBetweenCoords(coords, v.Garderobe, true)

                    if distance < Config.DrawDistance then
                        DrawMarker(20, v.Garderobe[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
                        letSleep = false
                    end

                    if distance < Config.MarkerSize.x then
                        isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Garderoba', i
                    end
                end

                for i=1, #v.Vozila, 1 do
                    local distance = GetDistanceBetweenCoords(coords, v.Vozila, true)

                    if distance < Config.DrawDistance then
                        DrawMarker(20, v.Vozila[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
                        letSleep = false
                    end

                    if distance < Config.MarkerSize.x then
                        isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vozila', i
                    end
                end
            end

            if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_judgejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('esx_judgejob:addBlipReaction', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_judgejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end

		else
			Citizen.Wait(500)
		end
        end
    end
end)

AddEventHandler('esx_judgejob:addBlipReaction', function(station, part, partNum)
    if part == 'Garderoba' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = 'Pritisni ~INPUT_CONTEXT~, da odpres menu za garderobo.'
		CurrentActionData = {}
	elseif part == 'Vozila' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = 'Pritisni ~INPUT_CONTEXT~, da odpres menu za garazo.'
		CurrentActionData = {station = station, part = part, partNum = partNum}
    end
end)

AddEventHandler('esx_judgejob:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)
-- end of blips
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsControlJustPressed(0,167) then
            F6Menu()
        end
    end
end)

--F6 MENU FUNCTIONS, COTNROLS, VEHICLES AND BLIPS COMING AS SOON AS POSSIBLE