ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

local drawText = false
local isFishing = false
local cancelledFishing = true
RegisterNetEvent('bixbi_fishing:Start')
AddEventHandler('bixbi_fishing:Start', function()
    if (isFishing and not cancelledFishing) then return end
    local playerPed = PlayerPedId()
    local pedc = GetEntityCoords(playerPed)
    local boat = GetClosestVehicle(pedc.x, pedc.y, pedc.z, 5.0, 0, 12294)
    if (IsEntityInWater(playerPed) or IsEntityInWater(boat)) then
        if (not IsPedInAnyVehicle(playerPed, false) and not IsPedSwimming(playerPed)) then
            Fishing()
        else
            exports.bixbi_core:Notify('error', 'You cannot do this right now')
        end
    else
        exports.bixbi_core:Notify('error', 'You can\'t fish here')
    end
end)

function Fishing()
    isFishing = true
    cancelledFishing = false
    RequestAnimDict('amb@world_human_stand_fishing@idle_a') 
        while not HasAnimDictLoaded('amb@world_human_stand_fishing@idle_a') do 
            Citizen.Wait(1) 
        end

    local playerPed = PlayerPedId()
	local BoneID = GetPedBoneIndex(playerPed, 60309)
	rod = CreateObject(`prop_fishing_rod_01`,  1729.73,  6403.90,  34.56,  true,  true,  true)
	
    AttachEntityToEntity(rod, playerPed, BoneID, 0, 0, 0, 0, 0, 0, false, false, false, false, 2, true)
    TaskPlayAnim(playerPed, 'amb@world_human_stand_fishing@idle_a', 'idle_b', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
    FishingActive()
end

function CatchFish()
    if (isFishing) then
        local CustomSettings = {
            settings = {
                handleEnd = false;
                speed = 10;
                scoreWin = 300;
                scoreLose = -150;
                maxTime = 15000;
                maxMistake = 3;
                speedIncrement = 1;
            },
            keys = {"a", "w", "d", "s", "g"}; --You can hash this out if you want to use default keys in the java side.
        }
        if exports['cd_keymaster']:StartKeyMaster(CustomSettings) then
            TriggerServerEvent('bixbi_fishing:Caught')
        else
            exports.bixbi_core:Notify('error', 'You didn\'t catch anything')
        end
        Cancel()
        ClearPedTasks(PlayerPedId())
        TriggerEvent('bixbi_fishing:Start')
    end
end

function Cancel()
    isFishing = false
    DeleteObject(rod)
    DeleteEntity(rod)
    ClearPedTasks(PlayerPedId())
    ClearInterval(fishingActive)
end

function AttachEntityToPed(prop, bone_ID, x, y, z, RotX, RotY, RotZ)
    local playerPed = PlayerPedId()
	local BoneID = GetPedBoneIndex(playerPed, bone_ID)
	local obj = CreateObject(GetHashKey(prop),  1729.73,  6403.90,  34.56,  true,  true,  true)
	AttachEntityToEntity(obj, playerPed, BoneID, x, y, z, RotX, RotY, RotZ, false, false, false, false, 2, true)
	return obj
end

function FishingActive()
    exports.bixbi_core:Notify('', 'Press "X" to stop fishing.', 10000)

    fishingActive = SetInterval(function()
        if (IsControlJustPressed(0, 73)) then
            cancelledFishing = true
            Cancel()
        end
    end, 0)
    SetInterval(fishingActive, 0)

    Citizen.Wait(100)
    Citizen.Wait(math.random(Config.FishTime[1] * 1000, Config.FishTime[2] * 1000))
    if (isFishing) then
        CatchFish()
    end
  end

--[[--------------------------------------------------
Skill Check -- Credit: s_fishing
--]]--------------------------------------------------
local display = false
local notComplete = false
local failure = false
local Callback = {}
AddEventHandler('bixbi_fishing:minigame', function(func)
    Callback = func
    SetDisplay(not display)
    notComplete = true
    failure = false
    while notComplete do
        Citizen.Wait(100)
    end
    if failure then
        Callback(false)
    else
        Callback(true)
    end 
end)

RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

RegisterNUICallback("error", function(data)
    if data.error == 'Complete!' then
        SetDisplay(false)
        notComplete = false
    else
        SetDisplay(false)
        notComplete = false 
        failure = true
    end
end)

function SetDisplay(bool)
    SetNuiFocus(bool, false)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)

--[[--------------------------------------------------
Setup
--]]--------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
	if (resourceName == GetCurrentResourceName() and Config.Debug) then
        while (ESX == nil) do Citizen.Wait(100) end
        Citizen.Wait(5000)
        ESX.PlayerLoaded = true
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    while (ESX == nil) do Citizen.Wait(100) end
    ESX.PlayerData = xPlayer
 	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
    Cancel()
end)
