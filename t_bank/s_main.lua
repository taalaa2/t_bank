local ESX = exports['es_extended']:getSharedObject()

local webhook = 'PUT YOUR DISCORD WEBHOOK HERE'

local function notify(viesti, type)
    lib.notify(source, {
        description = viesti,
        type = type,
    })    
end

lib.callback.register('t_bank:CheckBalance', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount('bank').money
    local cash = xPlayer.getAccount('money').money

    TriggerClientEvent('t_bank:ShowBalance', source, bank, cash)
end)

lib.callback.register('t_bank:DepositMoney', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cash = xPlayer.getAccount('money').money
    if xPlayer then
        if cash > amount - 1 then
            xPlayer.removeMoney(amount)
            xPlayer.addAccountMoney('bank', amount)
            notify('Sinä tallettit pankki tilillesi ' ..amount.. '€', 'success')
            LOG('## Pankki - Talletus \n\n Pelaaja: **' ..GetPlayerName(source).. '** \n\n Talletti: **' ..amount.. '€** \n\n RP-Nimi: **' ..xPlayer.getName().. '**')
        else
            notify('Valitse oikea käteis määrä!', 'error')
        end
    end
end)

lib.callback.register('t_bank:WithrawMoney', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount('bank').money

    if not xPlayer then return end

    if bank > amount - 1 then
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addAccountMoney('money', amount)
        LOG('## Pankki - Nosto \n\n Pelaaja: **' ..GetPlayerName(source).. '** \n\n Nosti: **' ..amount.. '€** \n\n RP-Nimi: **' ..xPlayer.getName().. '**')
    else
        notify('Pankissa ei ole näin paljoa rahaa! Valitse oikea määrä.', 'error')
    end
end)

lib.callback.register('t_bank:TrasferMoney', function(source, id, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Target = ESX.GetPlayerFromId(id)
    local Bank = xPlayer.getAccount('bank').money

    if not xPlayer then
        return
    end

    if not Target then
        notify('Henkilö ei ole paikalla!', 'error')
        return
    end

    if tonumber(source) == tonumber(id) then
        notify('Sinä et voi siirtää itsellesi rahaa!', 'error')
        return
    end

    if not Bank then 
        return
    end

    if Bank < amount then
        notify('Sinulla ei ole tarpeeksi rahaa!', 'error')
        return
    end

    xPlayer.removeAccountMoney('bank', amount)
    Target.addAccountMoney('bank', amount)
    TriggerClientEvent('ox_lib:notify', Target, {
        description = 'Sinä vastaan otit siirron: ' ..xPlayer.getName()..' summalla : '..amount.. '€',
        type = 'inform',
    })
    notify('Siirto onnistui! Vastaan ottaja: ' ..Target.getName().. ', raha määrä: ' ..amount.. '€', 'inform')
end)

function LOG(message, color)
    local connect = {  {  ["description"] = message, ["color"] = color, ["footer"] = { ["text"] = os.date("Date:\n📅 %d.%m.%Y \n⏰ %X"), }, } }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = 'Taala-Scripts', embeds = connect}), { ['Content-Type'] = 'application/json' })
end
