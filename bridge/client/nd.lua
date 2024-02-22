if not lib.checkDependency('ND_Core', '2.0.0') then return end

NDCore = {}

lib.load('@ND_Core.init')

local PlayerData = {}

RegisterNetEvent('ND:characterUnloaded', function()
    LocalPlayer.state.isLoggedIn = false
    table.wipe(PlayerData)
    deleteGrandma()
end)

RegisterNetEvent('ND:characterLoaded', function(character)
    LocalPlayer.state.isLoggedIn = true
    PlayerData = character
end)

RegisterNetEvent('ND:updateCharacter', function(character)
    PlayerData = character
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res or not LocalPlayer.state.isLoggedIn then return end
    PlayerData = NDCore.getPlayer()
end)

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function isPlyDead()
    return (not Config.checkDead and true) or LocalPlayer.state.dead
end

function DoNotification(text, nType)
    lib.notify({ title = "Notification", description = text, type = nType, })
end
