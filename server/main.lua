ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('td-illegalinfo:MaddeX')
AddEventHandler('td-illegalinfo:MaddeX', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.get('money') >= Config.MaddeX then
		xPlayer.removeMoney(Config.MaddeX)
			TriggerClientEvent("td-illegalinfo:MX", source)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = _U('nomoney')})
	end
end)

RegisterServerEvent('td-illegalinfo:BankTruckInfo')
AddEventHandler('td-illegalinfo:BankTruckInfo', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.get('money') >= Config.BankTruck then
		xPlayer.removeMoney(Config.BankTruck)
			TriggerClientEvent("td-illegalinfo:BTI", source)			
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = _U('nomoney')})
	end
end)

RegisterServerEvent('td-illegalinfo:offline')
AddEventHandler('td-illegalinfo:offline', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = _U('offline')})
end)