local QBCore = exports['qb-core']:GetCoreObject()

grandma = {}

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

-- Requesting grandma to wake the fuck up.

CreateThread(function()
    SpawnGrandma()
end)


function SpawnGrandma()

    RequestModel(GetHashKey('ig_mrs_thornhill'))
    while not HasModelLoaded(GetHashKey('ig_mrs_thornhill')) do
        Wait(0)
    end
    
    grandma = CreatePed(5, GetHashKey('ig_mrs_thornhill') , 2435.63, 4965.12, 45.81, 8.76, true, false)
    --vector4(2435.63, 4965.12, 46.81, 8.76)

    SetEntityAsMissionEntity(grandma)
    SetPedFleeAttributes(grandma, 0, 0)
    SetBlockingOfNonTemporaryEvents(grandma, true)
    SetEntityInvincible(grandma, true)
    FreezeEntityPosition(grandma, true)
    GrandmaSit()  

end

CreateThread(function()
    exports['qb-target']:AddTargetModel('ig_mrs_thornhill', {
        options = {
            { 
                type = "client",
                event = "randol_grandma:reviveplayer",
                icon = "fa-solid fa-house-medical",
                label = "Get Treated",
            },
        },
        distance = 2.5 
    })
end)

-- Grandma healing event.

RegisterNetEvent('randol_grandma:reviveplayer', function()
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
        TriggerServerEvent('randol_grandma:server:grandmafee') -- Removes $2000 from bank.
        ClearPedTasks(PlayerPedId())
        ClearPedTasksImmediately(grandma)
        GrandmaSit()
     end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        ClearPedTasksImmediately(grandma)
        GrandmaSit()
    end)
end)

-- Remove grandma on resource stop
AddEventHandler('onResourceStop', function(resource) 
	if resource == GetCurrentResourceName() then
        DeletePed(grandma)
	end 
end)