if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    table.wipe(PlayerData)
    deleteGrandma()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res or not LocalPlayer.state.isLoggedIn then return end
    PlayerData = QBCore.Functions.GetPlayerData()
end)

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function isPlyDead()
    return (not Config.checkDead and true) or PlayerData.metadata.inlaststand or PlayerData.metadata.isdead
end

function DoNotification(text, nType)
    QBCore.Functions.Notify(text, nType)
end
