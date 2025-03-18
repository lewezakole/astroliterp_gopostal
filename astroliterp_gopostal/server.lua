ESX = exports["es_extended"]:getSharedObject()

local lastPayout = {}

local jobStatus = {}

local PAYOUT_COOLDOWN = 30 -- Tutaj wpisujesz jaki ma być cooldown na otrzymanie pieniedzy z zlecenia ( jest to takie zabezpieczenie przed spamieniem triggerem )

RegisterServerEvent('courier:giveReward')
AddEventHandler('courier:giveReward', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not xPlayer then
        print(('gopostal: %s próbował dodać sobie pieniądze triggerem '):format(_source))
        return
    end

    if not jobStatus[_source] then
        print(('gopostal: %s próbował zrespić siano nie będąć nawet podczas robieia zlecenia idiota'):format(xPlayer.identifier))

        SendDiscordWebhook({
            playerId = _source,
            playerName = GetPlayerName(_source) 
        })

        TriggerClientEvent('esx:showNotification', _source, 'Nie jesteś podczas dostarczania paczek')
        return
    end

    local currentTime = os.time()

    if lastPayout[_source] and (currentTime - lastPayout[_source]) < PAYOUT_COOLDOWN then
        print(('courier: %s próbował otrzymać nagrodę przed upływem cooldownu!'):format(xPlayer.identifier))

        SendDiscordWebhook({
            playerId = _source,  
            playerName = GetPlayerName(_source)  
        })

        TriggerClientEvent('esx:showNotification', _source, 'Musisz poczekać przed kolejną nagrodą.')
        return
    end

    lastPayout[_source] = currentTime

    if not Config.Reward or not Config.Reward.min or not Config.Reward.max then
        print("Błąd konfiguracji: Config.Reward.min lub Config.Reward.max nie są zdefiniowane!")
        return
    end

    local rewardAmount = math.random(Config.Reward.min, Config.Reward.max) 
    xPlayer.addMoney(rewardAmount)
    TriggerClientEvent('esx:showNotification', _source, ('Otrzymałeś $%d za dostarczenie paczki!'):format(rewardAmount))
end)

RegisterServerEvent('courier:setJobStatus')
AddEventHandler('courier:setJobStatus', function(status)
    local _source = source
    jobStatus[_source] = status 
end)

function SendDiscordWebhook(cheaterInfo)
    local webhookURL = "https://discord.com/api/webhooks/1351205648263548989/Rs3ezuyLrupRdg6LMZ55Yq7YCeXhAx0OfBPf-DbSERaodkILy2167kI40NjR8XLdbtiU" -- wklej tutaj link do webhooka pamietaj zeby był dobrze ustawioyn

    if webhookURL == "https://discord.com/api/webhooks/your-webhook-url" then
        print("Błąd podczas odpalania skryptu wkleiłeś nie poprawny link do webhooka")
        return
    end

    local embed = {
        {
            ["title"] = "Wykryto próbe uzycia trigger", 
            ["description"] = "Osoba ktora uzyla triggera",
            ["fields"] = {
                {
                    ["name"] = "ID Gracza",
                    ["value"] = tostring(cheaterInfo.playerId),  
                    ["inline"] = true
                },
                {
                    ["name"] = "Nazwa Gracza",
                    ["value"] = tostring(cheaterInfo.playerName),  
                    ["inline"] = true
                },
                {
                    ["name"] = "Czas",
                    ["value"] = os.date("%Y-%m-%d %H:%M:%S"),  
                    ["inline"] = true
                }
            },
            ["color"] = 5255860 -- Kolor embeda edytować to możezs na tej stronie https://www.mathsisfun.com/hexadecimal-decimal-colors.html ( w sensie generowac sekolor )
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err then
            print("Błąd podczas wysyłania webhooka: " .. err)
        else
            print("Webhook wysłany pomyślnie!")
        end
    end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end