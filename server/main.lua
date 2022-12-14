local playersProcessingCannabis = {}
local outofbound = true
local alive = true

RegisterServerEvent('AndiyScripts_esx_drugs:sellDrug')
AddEventHandler('AndiyScripts_esx_drugs:sellDrug', function(label, item, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(item).count
	if xItem > 0 then
		local finaleprice = (price * xItem)
		xPlayer.removeInventoryItem(item, xItem)
		if Config.GiveBlack then
			xPlayer.addAccountMoney('black_money', finaleprice, "Drugs Sold")
		else
			xPlayer.addMoney(finaleprice, "Drugs Sold")
		end
		xPlayer.showNotification(_U('dealer_sold', amount, label, ESX.Math.GroupDigits(finaleprice)))
	end
end)

RegisterServerEvent('AndiyScripts_esx_drugs:PickUpDrug')
AddEventHandler('AndiyScripts_esx_drugs:PickUpDrug', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cime = math.random(5,10)

	if xPlayer.canCarryItem(item, cime) then
		xPlayer.addInventoryItem(item, cime)
	else
		xPlayer.showNotification(_U('weed_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('AndiyScripts_esx_drugs:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('AndiyScripts_esx_drugs:outofbound')
AddEventHandler('AndiyScripts_esx_drugs:outofbound', function()
	outofbound = true
end)

ESX.RegisterServerCallback('AndiyScripts_esx_drugs:drug_count', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xDrug = xPlayer.getInventoryItem(item).count
	cb(xDrug)
end)

RegisterServerEvent('AndiyScripts_esx_drugs:processDrug')
AddEventHandler('AndiyScripts_esx_drugs:processDrug', function(item, get, proccesstime)
	if not playersProcessingCannabis[source] then
		local source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		local xCannabis = xPlayer.getInventoryItem(item)
		local can = true
		outofbound = false
    	if xCannabis.count >= 3 then
      		while outofbound == false and can do
				if playersProcessingCannabis[source] == nil then
					playersProcessingCannabis[source] = ESX.SetTimeout(proccesstime , function()
            			if xCannabis.count >= 3 then
							if xPlayer.canSwapItem(item, 3, get, 1) then
								xPlayer.removeInventoryItem(item, 3)
								xPlayer.addInventoryItem(get, 1)
								xPlayer.showNotification(_U('weed_processed'))
							else
								can = false
								xPlayer.showNotification(_U('weed_processingfull'))
								TriggerEvent('AndiyScripts_esx_drugs:cancelProcessing')
							end
						else						
							can = false
							xPlayer.showNotification(_U('weed_processingenough'))
							TriggerEvent('AndiyScripts_esx_drugs:cancelProcessing')
						end

						playersProcessingCannabis[source] = nil
					end)
				else
					Wait(proccesstime)
				end	
			end
		else
			xPlayer.showNotification(_U('weed_processingenough'))
			TriggerEvent('AndiyScripts_esx_drugs:cancelProcessing')
		end	
			
	else
		print(('AndiyScripts_esx_drugs: %s attempted to exploit weed processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingCannabis[playerId] then
		ESX.ClearTimeout(playersProcessingCannabis[playerId])
		playersProcessingCannabis[playerId] = nil
	end
end

RegisterServerEvent('AndiyScripts_esx_drugs:cancelProcessing')
AddEventHandler('AndiyScripts_esx_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
