local spawnedWeeds = 0
local weedPlants = {}
local isPickingUp, isProcessing = false, false
local drugsplaces = AndiyScripts.Drugs
local drugplacesid = 0
local drugplantid = 0
local drugfindplantid = 0
local fieldlocation

CreateThread(function()
	while true do
		Wait(50)
		local getentity = GetEntityCoords(PlayerPedId())
		for k,v in ipairs(drugsplaces) do
			DistField      = #(v.fieldpos - getentity)
			if DistField < v.maxdistancefield then
				drugspawnids = v.drugid
				fieldlocation = v.fieldpos
				SpawnWeedPlants()
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(10)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		for k,v in ipairs(drugsplaces) do
			DistProcess      = #(v.processpos - coords)
			if DistProcess < v.maxdistanceinteract then
				if not isProcessing then
					ESX.ShowHelpNotification(_U('weed_processprompt'))
				end

				if IsControlJustReleased(0, 38) and not isProcessing then
					ESX.TriggerServerCallback('AndiyScripts_esx_drugs:drug_count', function(xDrug)
						drugplacesid = v.drugid
						ProcessWeed(xDrug)
					end, v.pickdrug)
					Wait(10)
					break
				end
			end
		end
	end
end)

function ProcessWeed(xDrug)
	for k,v in ipairs(drugsplaces) do
		if drugplacesid == v.drugid then
			isProcessing = true
			ESX.ShowNotification(_U('weed_processingstarted'))
			TriggerServerEvent('AndiyScripts_esx_drugs:processDrug', v.pickdrug, v.packdrug, v.proccesstime)
			if xDrug <= 3 then
				xDrug = 0
			end
			
			local timeLeft = (v.proccesstime * xDrug) / 1000
			local playerPed = PlayerPedId()

			while timeLeft > 0 do
				Wait(1000)
				timeLeft = timeLeft - 1
				local getentity = GetEntityCoords(playerPed)
				DistProcess      = #(v.processpos - getentity)
				if DistProcess > v.maxdistanceinteract then
					ESX.ShowNotification(_U('weed_processingtoofar'))
					TriggerServerEvent('AndiyScripts_esx_drugs:cancelProcessing')
					TriggerServerEvent('AndiyScripts_esx_drugs:outofbound')
					break
				end
			end
			isProcessing = false
		end
	end
end

CreateThread(function()
	while true do
		
		for k,v in ipairs(drugsplaces) do
				local Sleep = 1500

				local playerPed = PlayerPedId()
				local coords = GetEntityCoords(playerPed)
				local nearbyObject, nearbyID

				for i=1, #weedPlants, 1 do
					if #(coords - GetEntityCoords(weedPlants[i])) < 1.5 then
						nearbyObject, nearbyID = weedPlants[i], i
						
					end
				end

				if nearbyObject and IsPedOnFoot(playerPed) then
					Sleep = 2
					if not isPickingUp then
						ESX.ShowHelpNotification(_U('weed_pickupprompt'))
					end

					if IsControlJustReleased(0, 38) and not isPickingUp then
						isPickingUp = true
						DistField      = #(v.fieldpos - coords)
						if DistField < v.maxdistancefield then
							ESX.TriggerServerCallback('AndiyScripts_esx_drugs:canPickUp', function(canPickUp)
								if canPickUp then
									TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

									Wait(2000)
									ClearPedTasks(playerPed)
									Wait(1500)
					
									ESX.Game.DeleteObject(nearbyObject)
					
									table.remove(weedPlants, nearbyID)
									spawnedWeeds = spawnedWeeds - 1
									
									TriggerServerEvent('AndiyScripts_esx_drugs:PickUpDrug', v.pickdrug)
								else
									ESX.ShowNotification(_U('weed_inventoryfull'))
								end

								isPickingUp = false
							end, v.pickdrug)
						end
					end
				end
		end
		Wait(Sleep)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(weedPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnWeedPlants()
	while spawnedWeeds < 25 do
		Wait(0)
		local weedCoords = GenerateWeedCoords()

		ESX.Game.SpawnLocalObject('prop_weed_02', weedCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(weedPlants, obj)
			spawnedWeeds = spawnedWeeds + 1
		end)
	end
end

function ValidateWeedCoord(plantCoord)
	if spawnedWeeds > 0 then
		local validate = true

		for k, v in pairs(weedPlants) do
			if #(plantCoord - GetEntityCoords(v)) < 5 then
				validate = false
			end
		end
		if #(plantCoord - fieldlocation) > 50 then
			validate = false
		end
		return validate
	else
		return true
	end
end

function GenerateWeedCoords()
	while true do
		Wait(0)
		local x,y,z = table.unpack(fieldlocation)
			local weedCoordX, weedCoordY

			math.randomseed(GetGameTimer())
			local modX = math.random(-90, 90)

			Wait(100)

			math.randomseed(GetGameTimer())
			local modY = math.random(-90, 90)
				
			weedCoordX = x + modX
			weedCoordY = y + modY

			local coordZ = GetCoordZ(weedCoordX, weedCoordY)
			local coord = vector3(weedCoordX, weedCoordY, coordZ)

			if ValidateWeedCoord(coord) then
				return coord
			end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 43.0
end
