local QBCore = exports['qb-core']:GetCoreObject()


-- Charge the player from bank.

RegisterServerEvent('randol_grandma:server:grandmafee')
AddEventHandler('randol_grandma:server:grandmafee', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney('bank', 2000) --$2000 is the current price, change it to whatever.
end)
