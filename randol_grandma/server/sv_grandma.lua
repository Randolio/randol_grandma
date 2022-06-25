local QBCore = exports['qb-core']:GetCoreObject()
local moneytype = 'bank' -- 'cash' 'bank' or 'crypto'
local payment = 1500 -- Payment amount
local CheckBalance = true -- If true, it will check money balance


RegisterServerEvent('randol_grandma:server:checkfunds', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.Functions.GetMoney(moneytype)

    if CheckBalance then -- Checks for money balance
        if balance >= payment then -- Checks to make sure player has enough funds
            TriggerClientEvent('randol_grandma:reviveplayer', source) -- Starts Progressbar for Reviving
        else
            if moneytype == 'crypto' then
                TriggerClientEvent('QBCore:Notify', source, "You don't have enough crypto to pay Grandma!", "error")
            elseif moneytype == 'bank' then
                TriggerClientEvent('QBCore:Notify', source, "You don't have enough money in your bank to pay Grandma!", "error")
            elseif moneytype == 'cash' then
                TriggerClientEvent('QBCore:Notify', source, "You don't have enough cash to pay Grandma!", "error")
            end
        end
    else -- Does not check for money balance
        TriggerClientEvent('randol_grandma:reviveplayer', source)
    end
end)

-- Charges Player
RegisterServerEvent('randol_grandma:server:grandmafee', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney(moneytype, payment) -- Removes money type and amount
end)
