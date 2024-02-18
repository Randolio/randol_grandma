local PlayerData = {}
local Config = {}

local function resetGrandma()
    if DoesEntityExist(GRANDMA_PED) then
        ClearPedTasksImmediately(GRANDMA_PED)
        lib.requestAnimDict("timetable@reunited@ig_10", 2000)        
        TaskPlayAnim(GRANDMA_PED, "timetable@reunited@ig_10", "base_amanda", 8.0, 1.0, -1, 01, 0, 0, 0, 0)
    end
end

local function deleteGrandma()
    if DoesEntityExist(GRANDMA_PED) then
        DeletePed(GRANDMA_PED)
    end
    table.wipe(PlayerData)
    table.wipe(Config)
end

local function checkDead()
    if not Config.checkDead then return true end
    
    return PlayerData.metadata.inlaststand or PlayerData.metadata.isdead
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

    exports['qb-target']:AddTargetEntity(GRANDMA_PED, {
        options = {
            { 
                icon = "fa-solid fa-house-medical",
                label = "Get Treated",
                action = function()
                    local success = lib.callback.await('random_grandma:server:useGrandma', false)
                    if success then
                        QBCore.Functions.Notify("You are being helped.", "success")
                    end
                end,
                canInteract = function()
                    return not GlobalState.GRANDMA_BUSY and checkDead()
                end,
            },
        },
        distance = 2.5 
    })
end

RegisterNetEvent('randol_grandma:client:cacheConfig', function(data)
    if GetInvokingResource() then return end
    if LocalPlayer.state.isLoggedIn then
        PlayerData = QBCore.Functions.GetPlayerData()
        Config = data
        spawnGrandma()
    end
end)

RegisterNetEvent('randol_grandma:client:attemptRevive', function()
    if GetInvokingResource() then return end
    lib.callback.await('randol_grandma:server:syncAnim', false)
    local coords = GetOffsetFromEntityInWorldCoords(GRANDMA_PED, 0.0, 0.5, 0.0)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z-1.0)
    QBCore.Functions.Progressbar("grandma", "Grandma is healing your wounds..", Config.duration, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
     }, {}, {}, {}, function()
        local success = lib.callback.await('random_grandma:server:resetBusy', false)
        if success then
            QBCore.Functions.Notify("You were patched up by Grandma.", "success")
        end
    end)
end)

RegisterNetEvent('randol_grandma:client:syncAnim', function()
    if GetInvokingResource() then return end

    TaskStartScenarioInPlace(GRANDMA_PED, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)

    SetTimeout(Config.duration, function()
        resetGrandma()
    end)
end)

AddEventHandler('onResourceStart', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        PlayerData = QBCore.Functions.GetPlayerData()
	end 
end)

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        deleteGrandma()
	end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteGrandma()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)