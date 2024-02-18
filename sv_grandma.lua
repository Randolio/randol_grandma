local grandma = {
    model = 'ig_mrs_thornhill',
    checkBalance = true,
    checkDead = true,
    coords = vec4(2432.59, 4966.1, 45.81, 51.92),
    cost = 500,
    moneyType = 'cash',
    duration = 10000,
}

lib.callback.register('random_grandma:server:useGrandma', function(source)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    if #(coords - grandma.coords.xyz) > 10 then
        return false
    end

    if GlobalState.GRANDMA_BUSY then
        TriggerClientEvent('QBCore:Notify', src, "Grandma is busy right now.", "error")
        return false
    end

    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.Functions.GetMoney(grandma.moneyType)

    if grandma.checkBalance then
        if balance < grandma.cost then
            TriggerClientEvent('QBCore:Notify', src, ("You don't have enough %s to pay Grandma. ($%s)"):format(grandma.moneyType, grandma.cost), "error")
            return false
        end
    end

    Player.Functions.RemoveMoney(grandma.moneyType, grandma.cost, 'used-grandma')
    GlobalState.GRANDMA_BUSY = true
    TriggerClientEvent('randol_grandma:client:attemptRevive', src)
    return true
end)

lib.callback.register('random_grandma:server:resetBusy', function(source)
    if GlobalState.GRANDMA_BUSY then
        GlobalState.GRANDMA_BUSY = false
        TriggerClientEvent('hospital:client:Revive', source)
        return true
    end
    return false
end)

lib.callback.register('randol_grandma:server:syncAnim', function(source)
    local coords = vec3(grandma.coords.x, grandma.coords.y, grandma.coords.z)
    local plys = lib.getNearbyPlayers(coords, 50.0)
    if plys then
        for i = 1, #plys do
            local player = plys[i]
            TriggerClientEvent('randol_grandma:client:syncAnim', player.id)
        end
        return true
    end
    return false
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetTimeout(2000, function()
        GlobalState.GRANDMA_BUSY = false
        TriggerClientEvent('randol_grandma:client:cacheConfig', -1, grandma)
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(2000, function()
        TriggerClientEvent('randol_grandma:client:cacheConfig', src, grandma)
    end)
end)