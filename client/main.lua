local menuOpen = false
local inZoneDrugShop = false
local drugdealers = AndiyScripts.Dealers
local dealerids = 0
--slow loop
CreateThread(function()
	while true do
		Wait(5)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		for k,v in ipairs(drugdealers) do
			local distDrugShop = #(coords - v.pos)

			if distDrugShop <= v.maxdistance then
				inZoneDrugShop = true
				dealerids = v.dealerid
				DrawMarker(v.type, v.pos,0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.size, v.color.r,v.color.g,v.color.b,v.color.a,false, true, 2, false, nil, nil, false)
			else
				inZoneDrugShop = false
				if menuOpen then
					menuOpen=false
					ESX.UI.Menu.CloseAll()
					break
				end
			end
		end
	end
end)

--main loop
CreateThread(function ()
	while true do 
		local Sleep = 1500
		if inZoneDrugShop and not menuOpen then
			Sleep = 0
			ESX.ShowHelpNotification(_U('dealer_prompt'),true)
			if IsControlJustPressed(0, 38) then
				OpenDrugShop()
			end
		end
	Wait(Sleep)
	end
end)

function OpenDrugShop()
	ESX.UI.Menu.CloseAll()
	menuOpen = true

	local elements = AndiyScripts.DealerMenu

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop',{
        title    = _U('dealer_title'),
        elements = elements
    }, function(data, menu)
		TriggerServerEvent('AndiyScripts_esx_drugs:sellDrug', data.current.label, data.current.name, data.current.value)
	end, function(data, menu)
		menu.close()
		menuOpen = false
	end)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)