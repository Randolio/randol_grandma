Server = {
    model = 'ig_mrs_thornhill',
    checkDead = true,
    coords = vec4(2432.59, 4966.1, 45.81, 51.92),
    cost = 500,
    moneyType = 'bank', -- cash/bank
    duration = 10000,
}

lib.callback.register('random_grandma:server:useGrandma', function(source)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    if #(coords - Server.coords.xyz) > 10 then
        return false
    end

    if GlobalState.GRANDMA_BUSY then
        DoNotification(src, "Grandma is busy right now.", "error")
        return false
    end

    local Player = GetPlayer(src)
    local hasPaid = RemovePlayerMoney(Player, Server.cost, Server.moneyType)


    if not hasPaid then
        DoNotification(src, ("You don't have enough %s to pay Server. ($%s)"):format(Server.moneyType, Server.cost), "error")
        return false
    end

    GlobalState.GRANDMA_BUSY = true
    TriggerClientEvent('randol_grandma:client:attemptRevive', src)
    return true
end)

lib.callback.register('random_grandma:server:resetBusy', function(source)
    if GlobalState.GRANDMA_BUSY then
        GlobalState.GRANDMA_BUSY = false
        TriggerEvent('random_grandma:server:handleRevive', source)
        return true
    end
    return false
end)

lib.callback.register('randol_grandma:server:syncAnim', function(source)
    local coords = vec3(Server.coords.x, Server.coords.y, Server.coords.z)
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
        TriggerClientEvent('randol_grandma:client:cacheConfig', -1, Server)
    end)
end)

function PlayerHasLoaded(source)
    local src = source
    SetTimeout(2000, function()
        TriggerClientEvent('randol_grandma:client:cacheConfig', src, Server)
    end)
end