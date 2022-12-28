


ESX.RegisterServerCallback('reallife_wypozyczalnia:checkMoeny', function(src, cb, cash)
    local xPlayer = ESX.GetPlayerFromId(src)
    local money = xPlayer.getAccount('money').money 
    if money > cash then
        xPlayer.removeAccountMoney('bank', cash)
        cb(true)
    else 
        TriggerClientEvent("esx:showNotification", src, "Masz za mało gotówki!")
        cb(false)
    end
end)

RegisterServerEvent("reallife_wypozyczalnia:pay")
AddEventHandler("reallife_wypozyczalnia:pay", function(count, cheat) 
    local xPlayer = ESX.GetPlayerFromId(source)
    if cheat == "dpoiwjipdoa9hdipao0i=du9-93534592482374jfhaDPDADNADADNA@@111!!!" then
        xPlayer.removeAccountMoney('bank', count)
    else
        DropPlayer(source,"Nie wolno!")
    end 
end)



local randomEvent = math.random(10000,99999)
Citizen.CreateThread(function() 
    Citizen.Wait(2000)
    TriggerClientEvent("reallife_wypozyczalnia:getevent", -1, tostring(randomEvent)) 
end)



RegisterServerEvent(tostring(randomEvent))
AddEventHandler(tostring(randomEvent), function(count, cheat)

    local xPlayer = ESX.GetPlayerFromId(source)
    if cheat == "dpwodiwp9hdaiu39082592i21ddad" then
        xPlayer.addAccountMoney('money', count)
    else
        DropPlayer(source,"Nie wolno!")
    end 
end)


RegisterNetEvent("reallife_wypozyczalnia:spawned")
AddEventHandler("reallife_wypozyczalnia:spawned", function(number, state) 
    for k,v in next, Config.Wypozyczalnie do 
        
        for i = 1, #v.coords, 1 do 
            if state == false then
                v.coords[number].spawned = true
            else 
                v.coords[number].spawned = false
            end
        end

    end
end)