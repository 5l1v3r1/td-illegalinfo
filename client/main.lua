ESX                           = nil
local GUI					  = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
GUI.Time           			  = 0
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local times 				  = 0
local randomnumber 			  = 0
local count					  = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 0, 0, 0, 100)
end

Citizen.CreateThread(function()
    if Config.NPCEnable == true then
        for i, v in pairs(Config.NPC) do
            RequestModel(v.npc)
            while not HasModelLoaded(v.npc) do
                Wait(1)
            end
            illegalped = CreatePed(1, v.npc, v.x, v.y, v.z, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(illegalped, true)
            SetPedDiesWhenInjured(illegalped, false)
            SetPedCanPlayAmbientAnims(illegalped, true)
            SetPedCanRagdollFromPlayerImpact(illegalped, false)
            SetEntityInvincible(illegalped, true)
            FreezeEntityPosition(illegalped, true)
        end
    end
end)

function OpenInfoIllegalMenu()
    local elements = {
		{label = _U('maddex') .. Config.MaddeX .. _U('maddex1'),   value = 'maddex'},
		{label = _U('banktruck') .. Config.BankTruck .. _U('banktruck1'),    value = 'banktruck'},
        {label = 'Menüyü Kapat',   value = 'kapat'},

    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'info', {
        title    = _U('info'),
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
		if data.current.value == 'maddex' then
			menu.close()
			TriggerServerEvent("td-illegalinfo:MaddeX")
		if data.current.value == 'banktruck' then
			menu.close()
           TriggerServerEvent("td-illegalinfo:BankTruckInfo")
        elseif data.current.value == 'kapat' then
			menu.close()
		end
        end
    end)
end		

Citizen.CreateThread(function()
    while true do
	local ped = PlayerPedId()
        Citizen.Wait(1)
		local coords = GetEntityCoords(GetPlayerPed(-1))
			for k,v in pairs(Config.Zones) do
					if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) <  2) then
						DrawText3D(v.x, v.y, 5.37, " [~g~E~w~] Bilgi Satıcısı")
						if IsControlJustReleased(1, 51) then
							OpenInfoIllegalMenu()  
					end
				end
			end
    end
 end)

RegisterNetEvent("td-illegalinfo:MX")
AddEventHandler("td-illegalinfo:MX", function()
	if Config.GPS then
		x, y, z = Config.MaddeXYZ.x, Config.MaddeXYZ.y, Config.MaddeXYZ.z
		SetNewWaypoint(x, y, z)
		local source = GetPlayerServerId();
		exports['mythic_notify']:DoHudText('inform', _U('markgps'))
	else
		exports['mythic_notify']:DoHudText('inform', _U('MaddeX'))
	end
end)

RegisterNetEvent("td-illegalinfo:BTI")
AddEventHandler("td-illegalinfo:BTI", function()
	if Config.GPS then
		x, y, z = Config.BankTruckInfo.x, Config.BankTruckInfo.y, Config.BankTruckInfo.z
		SetNewWaypoint(x, y, z)
		local source = GetPlayerServerId();
		exports['mythic_notify']:DoHudText('inform', _U('markgps'))
	else
		exports['mythic_notify']:DoHudText('inform', _U('BankTruck'))
	end
end)

AddEventHandler('td-illegalinfo:EnteredMarker', function(zone)
	CurrentAction     = 'menuinfoillegal'
	CurrentActionMsg  = _U('pressmenu')
	CurrentActionData = {zone = zone}
end)

AddEventHandler('td-illegalinfo:ExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)


Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		heure = tonumber(GetClockHours())
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil
		
			for k,v in pairs(Config.Zones) do
				if k == randomnumber then
					if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.MarkerSize.x / 2) then
						isInMarker  = true
						currentZone = k
					end
				end
			end
		
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('td-illegalinfo:EnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('td-illegalinfo:ExitedMarker', LastZone)
		end
	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if CurrentAction ~= nil then
		heure	= tonumber(GetClockHours())
		if heure > Config.openHours and heure < Config.closeHours then
		  SetTextComponentFormat('STRING')
		  AddTextComponentString(CurrentActionMsg)
		  DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) and (GetGameTimer() - GUI.Time) > 1000 then
				heure		= tonumber(GetClockHours())
				GUI.Time 	= GetGameTimer()
				
				if CurrentAction == 'menuinfoillegal' then
					if Config.Hours then
						if heure > Config.openHours and heure < Config.closeHours then	
							OpenInfoIllegalMenu()
						else
							TriggerServerEvent('td-illegalinfo:offline')
						end
					else
						OpenInfoIllegalMenu()
					end
				end
				CurrentAction = nil
			end
		end
    end
  end
end)
