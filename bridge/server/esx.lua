if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function RemovePlayerMoney(xPlayer, amount, moneyType)
    if moneyType == 'cash' then
        if xPlayer.getMoney() >= amount then
            xPlayer.removeMoney(amount, "grandma-fee")
            return true
        end
    elseif moneyType == 'bank' then
        if xPlayer.getAccount('bank').money >= amount then
            xPlayer.removeAccountMoney('bank', amount, "grandma-fee")
            return true
        end
    end
    return false
end

AddEventHandler('esx:playerLoaded', function(source)
    PlayerHasLoaded(source)
end)

AddEventHandler('randol_grandma:server:handleRevive', function(src)
    TriggerClientEvent('esx_ambulancejob:revive', src)
end)
