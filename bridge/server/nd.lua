if not lib.checkDependency('ND_Core', '2.0.0') then return end

NDCore = {}

lib.load('@ND_Core.init')

function GetPlayer(id)
    return NDCore.getPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('ox_lib:notify', src, { type = nType, description = text })
end

function GetCharacterName(Player)
    return Player.fullname
end

function RemovePlayerMoney(Player, amount, moneyType)
    local balance = Player[moneyType]
    if balance >= amount then
        Player.deductMoney(moneyType, amount, "grandma-fee")
        return true
    end
    return false
end

function handleRevive(src)
    local Player = NDCore.getPlayer(src)
    if not Player then return end
    Player.revive()
end

AddEventHandler("ND:characterLoaded", function(character)
    PlayerHasLoaded(character.source)
end)
