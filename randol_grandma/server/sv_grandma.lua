local QBCore = exports['qb-core']:GetCoreObject()


RegisterServerEvent('randol_grandma:server:checkfunds', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.Functions.GetMoney(Config.MoneyType)

    if CheckBalance then -- Checks for money balance
        if balance >= Config.Cost then -- Checks to make sure player has enough funds
            TriggerClientEvent('randol_grandma:reviveplayer', source) -- Starts Progressbar for Reviving
        else
            if Config.MoneyType == 'crypto' then
                TriggerClientEvent('QBCore:Notify', source, "You don't have enough crypto to pay Grandma!", "error")
            elseif Config.MoneyType == 'bank' then
                TriggerClientEvent('QBCore:Notify', source, "You don't have enough money in your bank to pay Grandma!", "error")
            elseif Config.MoneyType == 'cash' then
                TriggerClientEvent('QBCore:Notify', source, "You don't have enough cash to pay Grandma!", "error")
            end
        end
    else -- Does not check for money balance
        TriggerClientEvent('randol_grandma:reviveplayer', source)
    end
end)

-- Charges Player
QBCore.Functions.CreateCallback('random_grandma:attemptGrandmaPayment', function(source, cb)
    local src = source
      local Player = QBCore.Functions.GetPlayer(src)
      if Config.CheckBalance then
        if Player.Functions.RemoveMoney(Config.MoneyType, Config.Cost) then -- Removes money type and amount
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
  end)