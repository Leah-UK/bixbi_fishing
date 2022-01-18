ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

ESX.RegisterUsableItem('fishing_rod', function(source)
	TriggerClientEvent('bixbi_fishing:Start', source)
end)

RegisterServerEvent('bixbi_fishing:Caught')
AddEventHandler('bixbi_fishing:Caught', function()
    local source = source
    Citizen.Wait(100)
    local randomItemNumber = math.random(1, #Config.Fish)
    exports.bixbi_core:addItem(source, Config.Fish[randomItemNumber], 1)
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetResourceState('bixbi_core') ~= 'started' ) then
        print('Bixbi_Fishing - ERROR: Bixbi_Core hasn\'t been found! This could cause errors!')
    end
end)