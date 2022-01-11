ESX              = nil
local PlayerData = {}
local CurrentActionData = {}
local isInShopMenu            = false

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
        {label = 'Preveri kazni osebi', value = 'kazni'},
        {label = 'Poslji osebo v zapor', value = 'zapor'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'defalut', {
        title = 'Sodnik - F6',
        align = 'bottom-right',
        elements = stuff
    }, function(data, menu)
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        local x = data.current.value
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            if x == 'id' then
                OpenIDCardMenu(closestPlayer)
            elseif x == 'kazni' then
                OpenFineMenu(closestPlayer)
            elseif x == 'zapor' then
                TriggerEvent('esx_qalle_jail:openJailMenu')
            end
        else
            ESX.ShowNotification('V blizini ni igralca.')
        end
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

function OpenIDCardMenu(player)
	ESX.TriggerServerCallback('esx_judge:getOtherPlayerData', function(data)
		local elements = {}
		local nameLabel = _U('name', data.name)
		local jobLabel, sexLabel, dobLabel, heightLabel, idLabel

		if data.job.grade_label and  data.job.grade_label ~= '' then
			jobLabel = _U('job', data.job.label .. ' - ' .. data.job.grade_label)
		else
			jobLabel = _U('job', data.job.label)
		end

		if Config.EnableESXIdentity then
			nameLabel = _U('name', data.firstname .. ' ' .. data.lastname)

			if data.sex then
				if string.lower(data.sex) == 'm' then
					sexLabel = _U('sex', _U('male'))
				else
					sexLabel = _U('sex', _U('female'))
				end
			else
				sexLabel = _U('sex', _U('unknown'))
			end

			if data.dob then
				dobLabel = _U('dob', data.dob)
			else
				dobLabel = _U('dob', _U('unknown'))
			end

			if data.height then
				heightLabel = _U('height', data.height)
			else
				heightLabel = _U('height', _U('unknown'))
			end

			if data.name then
				idLabel = _U('id', data.name)
			else
				idLabel = _U('id', _U('unknown'))
			end
		end

		local elements = {
			{label = nameLabel},
			{label = jobLabel}
		}

        table.insert(elements, {label = sexLabel})
        table.insert(elements, {label = dobLabel})
        table.insert(elements, {label = heightLabel})
        table.insert(elements, {label = idLabel})


		if data.drunk then
			table.insert(elements, {label = _U('bac', data.drunk)})
		end

		if data.licenses then
			table.insert(elements, {label = _U('license_label')})

			for i=1, #data.licenses, 1 do
				table.insert(elements, {label = data.licenses[i].label})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
			title    = _U('citizen_interaction'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player)) 
end

function OpenFineMenu(player)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine', {
		title    = _U('fine'),
		align    = 'top-left',
		elements = {
			{label = _U('traffic_offense'), value = 0},
			{label = _U('minor_offense'),   value = 1},
			{label = _U('average_offense'), value = 2},
			{label = _U('major_offense'),   value = 3}
	}}, function(data, menu)
		OpenFineCategoryMenu(player, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenFineCategoryMenu(player, category)
	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)
		local elements = {}

		for k,fine in ipairs(fines) do
			table.insert(elements, {
				label     = ('%s <span style="color:green;">%s</span>'):format(fine.label, _U('armory_item', ESX.Math.GroupDigits(fine.amount))),
				value     = fine.id,
				amount    = fine.amount,
				fineLabel = fine.label
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category', {
			title    = _U('fine'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()

			if Config.EnablePlayerManagement then
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', _U('fine_total', data.current.fineLabel), data.current.amount)
			else
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', _U('fine_total', data.current.fineLabel), data.current.amount)
			end

			ESX.SetTimeout(300, function()
				OpenFineCategoryMenu(player, category)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, category)
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

				for i=1, #v.SefovMeni, 1 do
					local distance = GetDistanceBetweenCoords(coords, v.BossActions[i], true)

					if distance < Config.DrawDistance then
						DrawMarker(22, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
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
	elseif part == 'BossActions' then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = "Pritisni ~INPUT_CONTEXT~, da odpres sefov meni."
		CurrentActionData = {}
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
        if CurrentAction then
            ESX.ShowHelpNotification(CurrentActionMsg)
            if IsControlJustPressed(0, 38) and PlayerData.job and PlayerData.job.name == 'judge' then
                if CurrentAction == 'menu_vehicle_spawner' then
                    OpenVozilaMenu()
                elseif CurrentAction == 'menu_cloakroom' then
                    OpenCloakroomMenu()
				elseif CurrentAction == 'menu_boss_actions' then
					ESX.UI.Menu.CloseAll()
					TriggerEvent('esx_society:openBossMenu', 'judge', function(data, menu)
						menu.close()

						CurrentAction     = 'menu_boss_actions'
						CurrentActionMsg  = "Pritisni ~INPUT_CONTEXT~ da odprete sefov meni!"
						CurrentActionData = {}
					end, { wash = false }) -- disable washing money
                end
            end
        end
    end
end)

--F6 MENU FUNCTIONS, COMING AS SOON AS POSSIBLE