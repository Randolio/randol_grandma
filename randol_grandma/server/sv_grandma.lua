local QBCore = exports['qb-core']:GetCoreObject()
local moneytype = 'crypto' -- 'cash' 'bank' or 'crypto'
local payment = 50 -- Payment amount


RegisterServerEvent('randol_grandma:server:checkfunds', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.Functions.GetMoney(moneytype)

    if balance >= payment then -- Checks to make sure player has enough funds
        TriggerClientEvent('randol_grandma:reviveplayer', source) -- Starts Progressbar for Reviving
    else
        TriggerClientEvent('QBCore:Notify', source, "You don't have enough crypto to pay Grandma!", "error")
    end

end)

-- Charges Player
RegisterServerEvent('randol_grandma:server:grandmafee', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney(moneytype, payment) -- Removes money type and amount
end)
