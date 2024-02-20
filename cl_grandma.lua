local GRANDMA_PED
Config = {}

local function resetGrandma()
    if DoesEntityExist(GRANDMA_PED) then
        ClearPedTasksImmediately(GRANDMA_PED)
        lib.requestAnimDict("timetable@reunited@ig_10", 2000)        
        TaskPlayAnim(GRANDMA_PED, "timetable@reunited@ig_10", "base_amanda", 8.0, 1.0, -1, 01, 0, 0, 0, 0)
    end
end

function deleteGrandma()
    if DoesEntityExist(GRANDMA_PED) then
        DeletePed(GRANDMA_PED)
        GRANDMA_PED = nil
    end
    table.wipe(PlayerData)
    table.wipe(Config)
end

local function spawnGrandma()
    local model = joaat(Config.model)
    lib.requestModel(model, 5000)
    GRANDMA_PED = CreatePed(0, model, Config.coords.x, Config.coords.y, Config.coords.z, Config.coords.w, false, false)

    SetEntityAsMissionEntity(GRANDMA_PED, true, true)
    SetPedFleeAttributes(GRANDMA_PED, 0, 0)
    SetBlockingOfNonTemporaryEvents(GRANDMA_PED, true)
    SetEntityInvincible(GRANDMA_PED, true)
    FreezeEntityPosition(GRANDMA_PED, true)
    lib.requestAnimDict("timetable@reunited@ig_10", 2000)        
    TaskPlayAnim(GRANDMA_PED, "timetable@reunited@ig_10", "base_amanda", 8.0, 1.0, -1, 01, 0, 0, 0, 0)

    exports['qb-target']:AddTargetEntity(GRANDMA_PED, { -- Use qb-target because ox-target has compatability for it.(Works for ESX too if you use ox-target)
        options = {
            { 
                icon = "fa-solid fa-house-medical",
                label = "Get Treated",
                action = function()
                    local success = lib.callback.await('random_grandma:server:useGrandma', false)
                    if success then
                        DoNotification("You are being helped.", "success")
                    end
                end,
                canInteract = function()
                    return not GlobalState.GRANDMA_BUSY and isPlyDead()
                end,
            },
        },
        distance = 2.5 
    })
end

RegisterNetEvent('randol_grandma:client:cacheConfig', function(data)
    if GetInvokingResource() or not hasPlyLoaded() then return end
    Config = data
    spawnGrandma()
end)

RegisterNetEvent('randol_grandma:client:attemptRevive', function()
    if GetInvokingResource() then return end
    lib.callback.await('randol_grandma:server:syncAnim', false)
    local coords = GetOffsetFromEntityInWorldCoords(GRANDMA_PED, 0.0, 0.5, 0.0)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z-1.0)
    if lib.progressCircle({
        duration = Config.duration,
        position = 'bottom',
        label = 'Grandma is healing your wounds..',
        useWhileDead = true,
        canCancel = false,
        disable = { move = true, car = true, mouse = false, combat = true, },
    }) then
        local success = lib.callback.await('random_grandma:server:resetBusy', false)
        if success then
            DoNotification("You were patched up by Grandma.", "success")
        end
    end
end)

RegisterNetEvent('randol_grandma:client:syncAnim', function()
    if GetInvokingResource() then return end

    TaskStartScenarioInPlace(GRANDMA_PED, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)

    SetTimeout(Config.duration, function()
        resetGrandma()
    end)
end)

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        deleteGrandma()
	end 
end)