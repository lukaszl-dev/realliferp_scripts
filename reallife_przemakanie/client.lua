



local czas = 0
local start = false
local przemoczone = false
Citizen.CreateThread(function() 
    while true do 
        Citizen.Wait(5)
        local ped = PlayerPedId()
        local isSwimming = IsPedSwimming(ped)
        if isSwimming and not przemoczone then 
            start = true
            if czas > Config.Czas then 
                TriggerServerEvent("reallife_przemakanie:przemoczone")
                przemoczone = true
                start = false
                czas = 0
            end
        else
            Citizen.Wait(500) 
        end
        if not isSwimming and przemoczone then 
            przemoczone = false 
            Citizen.Wait(250)
        end
    end
end)

Citizen.CreateThread(function() 
    while true do 
        Citizen.Wait(0)
        if start then
            Citizen.Wait(Config.Czas * 60000)
            czas = czas +1
        else 
            Citizen.Wait(1000)
        end 
    end
end)
