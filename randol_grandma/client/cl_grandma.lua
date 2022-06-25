local QBCore = exports['qb-core']:GetCoreObject()
local isDowned = false

grandma = {}

------------------------------------
-- ANIMATIONS / GRANDMA / TARGET --
------------------------------------

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function GrandmaSit()
    loadAnimDict("timetable@reunited@ig_10")        
    TaskPlayAnim(grandma, "timetable@reunited@ig_10", "base_amanda", 8.0, 1.0, -1, 01, 0, 0, 0, 0)
end


function SpawnGrandma()

    RequestModel(GetHashKey('ig_mrs_thornhill'))
    while not HasModelLoaded(GetHashKey('ig_mrs_thornhill')) do
        Wait(0)
    end
    
    grandma = CreatePed(0, GetHashKey('ig_mrs_thornhill') , 2435.63, 4965.12, 45.81, 8.76, false, false)
    --vector4(2435.63, 4965.12, 46.81, 8.76)

    SetEntityAsMissionEntity(grandma)
    SetPedFleeAttributes(grandma, 0, 0)
    SetBlockingOfNonTemporaryEvents(grandma, true)
    SetEntityInvincible(grandma, true)
    FreezeEntityPosition(grandma, true)
    GrandmaSit()  

    exports['qb-target']:AddTargetModel('ig_mrs_thornhill', {
        options = {
            { 
                type = "client",
                event = "randol_grandma:client:checks",
                icon = "fa-solid fa-house-medical",
                label = "Get Treated",
            },
        },
        distance = 2.5 
    })
end

function DeleteGrandma()
    if DoesEntityExist(grandma) then
        DeletePed(grandma)
    end
end

----------------------
-- RESOURCE START --
----------------------

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnGrandma()
    end
end)

------------------
-- CHECK FUNDS --
------------------

RegisterNetEvent('randol_grandma:client:checks', function()
    local ped = PlayerPedId()
    local player = PlayerId()

    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata["inlaststand"] or PlayerData.metadata["isdead"] then
            TriggerServerEvent('randol_grandma:server:checkfunds')
        else
            QBCore.Functions.Notify("You are not downed or dead.", "error")
        end
    end)
end)

----------------------------
-- Grandma Healing Event --
----------------------------

RegisterNetEvent('randol_grandma:reviveplayer', function(source)
    SetEntityCoords(PlayerPedId(), vector4(2435.36, 4965.54, 45.81, 282.65)) -- Move player closer to grandma --CHANGE THIS IF YOU CHANGE LINE 23 COORDINATES.
    TaskStartScenarioInPlace(grandma, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    QBCore.Functions.Progressbar("grandma", "Grandma is healing your wounds..", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
     }, {}, {}, {}, function()
        QBCore.Functions.Notify("You feel much better now.", "success")
        TriggerEvent('hospital:client:Revive')
        TriggerServerEvent('randol_grandma:server:grandmafee') -- Removes Funds
        ClearPedTasks(PlayerPedId())
        ClearPedTasksImmediately(grandma)
        GrandmaSit()
     end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        ClearPedTasksImmediately(grandma)
        GrandmaSit()
    end)
end)

--------------------
-- RESOURCE STOP --
--------------------

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        DeleteGrandma()
	end 
end)
