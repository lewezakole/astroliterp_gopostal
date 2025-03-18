ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('courier:giveReward')
AddEventHandler('courier:giveReward', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(amount)
    end
end)
