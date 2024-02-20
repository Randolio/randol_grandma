Server = {
    checkDead = true,
    locations = { -- Multi location support.
        [1] = {coords = vec4(2432.59, 4966.1, 46.81, 51.92), model = 'ig_mrs_thornhill', name = 'Grandma', busy = false},
        [2] = {coords = vec4(1974.38, 3820.33, 33.43, 215.01), model = 'cs_nigel', name = 'Grandpa', busy = false},
    },
    cost = 500,
    moneyType = 'bank', -- cash/bank ('cash' will convert to 'money' for ESX, so keep it as 'cash' if you wanna use cash and let the bridge handle it)
    duration = 10000,
}

local function resetBusy(index)
    Server.locations[index].busy = true
    CreateThread(function()
        Wait(Server.duration + 2000) -- This is to account for people who may crash/quit during the progress bar. Gotta make sure that grandparent resets.
        Server.locations[index].busy = false
    end)
end

lib.callback.register('randol_grandma:server:useGrandma', function(source, index)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local gparent = Server.locations[index]
    local pos = gparent.coords

    if #(coords - vec3(pos.x, pos.y, pos.z)) > 10 then
        return false
    end

    if gparent.busy then
        DoNotification(src, ("%s is busy right now."):format(gparent.name), "error")
        return false
    end

    local Player = GetPlayer(src)
    local hasPaid = RemovePlayerMoney(Player, Server.cost, Server.moneyType)


    if not hasPaid then
        DoNotification(src, ("You don't have enough %s to pay the fee. ($%s)"):format(Server.moneyType, Server.cost), "error")
        return false
    end

    resetBusy(index)

    TriggerClientEvent('randol_grandma:client:attemptRevive', src, index)
    return true
end)

lib.callback.register('randol_grandma:server:resetBusy', function(source, index)
    if not index then return false end
    if Server.locations[index].busy then
        TriggerEvent('randol_grandma:server:handleRevive', source)
        return true
    end
    return false
end)

lib.callback.register('randol_grandma:server:syncAnim', function(source, index)
    local coords = Server.locations[index].coords
    local plys = lib.getNearbyPlayers(coords.xyz, 50.0)
    if plys then
        for i = 1, #plys do
            local player = plys[i]
            TriggerClientEvent('randol_grandma:client:syncAnim', player.id, index)
        end
        return true
    end
    return false
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetTimeout(2000, function()
        TriggerClientEvent('randol_grandma:client:cacheConfig', -1, Server)
    end)
end)

function PlayerHasLoaded(source)
    local src = source
    SetTimeout(2000, function()
        TriggerClientEvent('randol_grandma:client:cacheConfig', src, Server)
    end)
end
