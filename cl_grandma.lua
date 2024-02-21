local GRANDMA_PED = {}
local storedPoints = {}
Config = {}

local function resetGrandma(k)
    if DoesEntityExist(GRANDMA_PED[k]) then
        ClearPedTasksImmediately(GRANDMA_PED[k])
        lib.requestAnimDict("timetable@reunited@ig_10", 2000)        
        TaskPlayAnim(GRANDMA_PED[k], "timetable@reunited@ig_10", "base_amanda", 8.0, 1.0, -1, 01, 0, 0, 0, 0)
    end
end

function deleteGrandma()
    for i = 1, #storedPoints do
        if storedPoints[i] then
            storedPoints[i]:remove()
        end
    end
    for ped, _ in pairs(GRANDMA_PED) do
        if DoesEntityExist(GRANDMA_PED[ped]) then
            DeleteEntity(GRANDMA_PED[ped])
            exports['qb-target']:RemoveTargetEntity(GRANDMA_PED[ped], "Get Treated")
        end
    end
    table.wipe(GRANDMA_PED)
    table.wipe(storedPoints)
    table.wipe(Config)
end

local function spawnGrandma(data)
    if not DoesEntityExist(GRANDMA_PED[data.index]) then
        local v = data.pedData
        local model = joaat(v.model)
        lib.requestModel(model, 5000)
        GRANDMA_PED[data.index] = CreatePed(0, model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w, false, false)

        SetEntityAsMissionEntity(GRANDMA_PED[data.index], true, true)
        SetPedFleeAttributes(GRANDMA_PED[data.index], 0, 0)
        SetBlockingOfNonTemporaryEvents(GRANDMA_PED[data.index], true)
        SetEntityInvincible(GRANDMA_PED[data.index], true)
        FreezeEntityPosition(GRANDMA_PED[data.index], true)
        lib.requestAnimDict("timetable@reunited@ig_10", 2000)        
        TaskPlayAnim(GRANDMA_PED[data.index], "timetable@reunited@ig_10", "base_amanda", 8.0, 1.0, -1, 01, 0, 0, 0, 0)

        exports['qb-target']:AddTargetEntity(GRANDMA_PED[data.index], { -- Use qb-target because ox-target has compatability for it.(Works for ESX too if you use ox-target)
            options = {
                { 
                    icon = "fa-solid fa-house-medical",
                    label = "Get Treated",
                    action = function()
                        local success = lib.callback.await('randol_grandma:server:useGrandma', false, data.index)
                        if success then
                            DoNotification("You are being helped.", "success")
                        end
                    end,
                    canInteract = function()
                        return isPlyDead()
                    end,
                },
            },
            distance = 2.5 
        })
    end
end

local function yeetGrandma(data)
    if DoesEntityExist(GRANDMA_PED[data.index]) then
        DeleteEntity(GRANDMA_PED[data.index])
        exports['qb-target']:RemoveTargetEntity(GRANDMA_PED[data.index], "Get Treated")
        GRANDMA_PED[data.index] = nil
    end
end

local function createGrandmaPoints()
    for id, data in pairs(Config.locations) do
        local zone = lib.points.new({
        coords = data.coords,
        distance = 30,
        index = id,
        pedData = data,
        onEnter = spawnGrandma,
        onExit = yeetGrandma,
        })
        storedPoints[#storedPoints+1] = zone
    end
end

RegisterNetEvent('randol_grandma:client:cacheConfig', function(data)
    if GetInvokingResource() or not hasPlyLoaded() then return end
    Config = data
    createGrandmaPoints()
end)

RegisterNetEvent('randol_grandma:client:attemptRevive', function(k)
    if GetInvokingResource() or not k then return end
    local coords = GetOffsetFromEntityInWorldCoords(GRANDMA_PED[k], 0.0, 0.5, 0.0)
    local name = Config.locations[k].name
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z-1.0)
    if lib.progressCircle({
        duration = Config.duration,
        position = 'bottom',
        label = ('%s is healing your wounds..'):format(name),
        useWhileDead = true,
        canCancel = false,
        disable = { move = true, car = true, mouse = false, combat = true, },
    }) then
        local success = lib.callback.await('randol_grandma:server:resetBusy', false, k)
        if success then
            DoNotification(("You were patched up by %s."):format(name), "success")
        end
    end
end)

RegisterNetEvent('randol_grandma:client:syncAnim', function(k)
    if GetInvokingResource() then return end

    TaskStartScenarioInPlace(GRANDMA_PED[k], "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)

    SetTimeout(Config.duration, function()
        resetGrandma(k)
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteGrandma()
    end
end)
