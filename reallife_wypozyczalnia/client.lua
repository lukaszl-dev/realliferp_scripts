


local wypozyczone = false
local priceperframe = 0
local rentedvehicle 
local addMoneyEvent

RegisterNetEvent("reallife_wypozyczalnia:getevent")
AddEventHandler("reallife_wypozyczalnia:getevent", function(event) 
    addMoneyEvent = event
end)


Citizen.CreateThread(function()
    local delay = 1
    while true do
        local wait = true
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped) 
        for k,v in next, Config.Wypozyczalnie do 
        
            for i = 1, #v.coords, 1 do 
                local dist = Vdist(pos, v.coords[i].crds)
                if dist <= 20 then
                    wait = false
            
                    if dist < 5  and not v.coords[i].used then 
                        ESX.Game.Utils.DrawText3D(v.coords[i].crds + 0.6, 'Naciśnij [~r~H~w~] aby wynająć pojazd <br> Kaucja to: ~r~'..v.coords[i].caution..' $', 1.0)
                    	
                        if IsControlJustReleased(0, 74) then
                            if rentedvehicle ==  nil then 
                                ESX.TriggerServerCallback("esx_license:checkLicense", function(have) 
                                    if have then 
                                        ESX.TriggerServerCallback("reallife_wypozyczalnia:checkMoeny", function(can) 
                                            if can then
                                                v.coords[i].used = true
                                                ESX.ShowNotification("Wypożyczyłeś auto, pobrana kaucja to: "..v.coords[i].caution.."!")
                                                ESX.ShowHelpNotification("Nie zniszcz auta a po zakończeniu dostarcz go do Pana Mietka! On się zajmie autem!")
                                                local vehicle = ESX.Game.GetClosestVehicle(pos)
                                                rentedvehicle = vehicle
                                                rentedvehicleid = i
                                                rentedvehiclemodel = GetHashKey(v.coords[i].model)
                                                rentedvehicleplate = GetVehicleNumberPlateText(vehicle)
                                                rentedvehiclecaution = v.coords[i].caution
                                                SetPedIntoVehicle(ped, vehicle, -1)
                                                SetVehicleDoorsLocked(vehicle, 1)
                                                SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                                                FreezeEntityPosition(vehicle, false)
                                                wypozyczone = true
                                                local plate = GetVehicleNumberPlateText(vehicle)
                                                TriggerServerEvent("reallife_carcfg-addkeys", plate)
                                                priceperframe =  v.coords[i].price_per_s
                                            else 
                                                ESX.ShowNotification("Zapraszamy ponownie później!")
                                            end 
                                        end, v.coords[i].caution)
                                    else 
                                        ESX.ShowNotification("Musisz posiadać prawo jazdy kategorii B!")
                                    end
                                
                                end, GetPlayerServerId(PlayerId()), 'drive')
                                
                            else 
                                ESX.ShowNotification("Masz już wypożyczone auto!")
                            end 
                        end
                    end 

                    if ESX.Game.IsSpawnPointClear(v.coords[i].crds, 2.5) and not v.coords[i].used and not v.coords[i].spawned then 
                        --  aby to bylo oznaczeniem serverowym nie klienckim bo inaczeej respia się auta razy tyle ile jest graczy!
                        -- v.coords[i].spawned = true
                        TriggerServerEvent("reallife_wypozyczalnia:spawned", i, false)
                        spawn(v.coords[i].model, v.coords[i].crds, v.coords[i].h)
                    end
                 
                end
            end
        end
        if wait then delay = 1000 else delay = 1 end
        Citizen.Wait(delay)
    end
end) 


local czas = 0
local fina_price = 0
local lasthealth = 1000
Citizen.CreateThread(function() 
    while true do 
        Citizen.Wait(1000)
        if wypozyczone then
            czas = czas +1
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(ped)
            local health = GetVehicleEngineHealth(vehicle)
            if health < lasthealth then 
                lasthealth = health
                ESX.ShowNotification("Uszkodziłeś pojazd, z twojego konta bankowego pobraliśmy karę w wysokości 250$")
                TriggerServerEvent("reallife_wypozyczalnia:pay", 250, "dpoiwjipdoa9hdipao0i=du9-93534592482374jfhaDPDADNADADNA@@111!!!")
            end 
    
            if vehicle ~= rentedvehicle and IsPedSittingInAnyVehicle(ped) ~= false  then 
                ESX.ShowNotification("Opuściłeś pojazd! Kaucja zostaje zabrana! Umowa wynajecia zostaje zerwana - po auto zjawi się pracownik!")
             
                --  vehicle event's
                SetVehicleDoorsLocked(rentedvehicle, 2)
                SetEntityAsMissionEntity(rentedvehicle, true, true)
                FreezeEntityPosition(rentedvehicle, true)
                -- to-do remove keys from player inventory !

                TriggerServerEvent("reallife_wypozyczalnia:pay", fina_price, "dpoiwjipdoa9hdipao0i=du9-93534592482374jfhaDPDADNADADNA@@111!!!")
                ESX.ShowNotification("Z twojego konta pobraliśmy "..fina_price.." $ opłaty za wypożyczenie auta!")
                
                -- rented vehicle coords 
                vehcoords = GetEntityCoords(rentedvehicle)

                -- shit result but working 
                for k,v in next, Config.Wypozyczalnie do 
                    for i = 1, #v.coords, 1 do 
                        v.coords[rentedvehicleid].crds = vehcoords
                        v.coords[rentedvehicleid].used = false
                    end
                end
         
                wypozyczone = false
                rentedvehicleid = nil 
                rentedvehicle = nil
                rentedvehiclemodel = nil
                rentedvehicleplate = nil
                rentedvehiclecaution = nil
                fina_price = 0
            end
            fina_price = fina_price + priceperframe
        end
    end
end)



-- spawn ped 

Citizen.CreateThread(function()
    
    for k,v in pairs(Config.Wypozyczalnie) do

        RequestModel("a_m_m_prolhost_01")
        while not HasModelLoaded("a_m_m_prolhost_01") do
            Wait(1)
        end

     
        peds =  CreatePed(4, "a_m_m_prolhost_01", v.returnCarPed, false, true)
        SetBlockingOfNonTemporaryEvents(peds, true)
        SetPedDiesWhenInjured(peds, false)
        SetPedCanPlayAmbientAnims(peds, true)
        SetPedCanRagdollFromPlayerImpact(peds, false)
        SetEntityInvincible(peds, true)
        FreezeEntityPosition(peds, true)
       
    end
end)

-- blips 
Citizen.CreateThread(function() 
    for k,v in next, Config.Wypozyczalnie do 
        local blip = AddBlipForCoord(v.blipCoords)

        SetBlipSprite (blip, 225)
        SetBlipScale  (blip, 0.8)
        SetBlipColour (blip, 46)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Wypozyczalnia Aut')
        EndTextCommandSetBlipName(blip)
    end
end)


-- target events 
RegisterNetEvent("reallife_wypozyczalnia:wypozyczenie")
AddEventHandler("reallife_wypozyczalnia:wypozyczenie", function() 
    ESX.ShowNotification("Cześć, wszystko mamy zautomatyzowane - po prostu wybierz swój pojazd, my sprawdzimy czy masz prawo jazdy  i już możesz jechać!, wszystko obsłuży nasz system!")
end)


RegisterNetEvent("reallife_wypozyczalnia:zdajauto")
AddEventHandler("reallife_wypozyczalnia:zdajauto", function() 
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped) 
    local vehicle = ESX.Game.GetClosestVehicle(pos)

    local vehicleModel = ESX.Game.GetVehicleProperties(vehicle).model 
    local vehiclePlate = GetVehicleNumberPlateText(vehicle)
    
    if rentedvehicle ~= nil and vehicle ~= nil and vehicleModel == rentedvehiclemodel and vehiclePlate == rentedvehicleplate then 
        DeleteEntity(rentedvehicle)
        
        -- shit result but working 
        for k,v in next, Config.Wypozyczalnie do 
            for i = 1, #v.coords, 1 do 
                v.coords[rentedvehicleid].used = false
                -- v.coords[rentedvehicleid].spawned = false
                TriggerServerEvent("reallife_wypozyczalnia:spawned", rentedvehicleid, true)
            end
        end
        ESX.ShowNotification("Zdałeś auto! Kaucja wraca do Ciebie!")
        TriggerServerEvent("reallife_wypozyczalnia:pay", fina_price, "dpoiwjipdoa9hdipao0i=du9-93534592482374jfhaDPDADNADADNA@@111!!!")
        TriggerServerEvent(addMoneyEvent, rentedvehiclecaution, "dpwodiwp9hdaiu39082592i21ddad")
        ESX.ShowNotification("Z twojego konta pobraliśmy "..fina_price.." $ opłaty za wypożyczenie auta!")
        wypozyczone = false
        rentedvehicleid = nil 
        rentedvehicle = nil
        rentedvehiclemodel = nil
        rentedvehicleplate = nil
        rentedvehiclecaution = nil
        fina_price = 0
    else 
        ESX.ShowNotification("Nie masz wypozyczonego auta lub próbujesz oddać niewłaściwe auto!")
    end 

end)



-- functions
function spawn(model, crds, h)
    vehiclehash = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do 
        Citizen.Wait(5)
    end
    local car = CreateVehicle(vehiclehash, crds, h, true, true)
    SetVehicleDoorsLocked(car, 2)
    SetDefaultVehicleNumberPlateTextPattern(car, 'F^AYUM11A')
    SetVehicleCustomPrimaryColour(car, 255, 255, 255)
    SetVehicleCustomSecondaryColour(car, 255, 255, 255)
    SetEntityAsMissionEntity(car, true, true)
    FreezeEntityPosition(car, true)
end

