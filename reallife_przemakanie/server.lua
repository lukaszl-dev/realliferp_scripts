


RegisterServerEvent("reallife_przemakanie:przemoczone")
AddEventHandler("reallife_przemakanie:przemoczone",function() 
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = Config.Itemki
    local have = {}
    local usunal = false

    for k,v in ipairs(items) do 
        local item = json.encode(exports.ox_inventory:GetItem(source, v, false, true))
        if  item > "0"  then 
            table.insert(have, v)
        end
    end

 
    for k,v in ipairs(have) do 
        xPlayer.removeInventoryItem(v, count)
        usunal = true
    end
    
    if usunal == true then 
      
        TriggerClientEvent("esx:showNotification", source, "Niektóre z twoich rzeczy przemokły od przebywania w wodzie!")
    end
end)