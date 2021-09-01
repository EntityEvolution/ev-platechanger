local isOpen = false

-- NUI Callback
RegisterNUICallback('getPlateText', function(data, cb)
    if isOpen then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            if data:len() > 0 then
                if data then
                    SendNUIMessage({action = 'hide'})
                    SetNuiFocus(0, 0)
                    TriggerServerEvent('ev:getPlate', data, GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)):match( "^%s*(.-)%s*$" ))
                    isOpen = false
                else
                    ESX.ShowNotification('You do not own this car')
                end
            else
                ESX.ShowNotification('Plate needs at least 1 character')
            end
        else
            ESX.ShowNotification('You somehow left the vehicle')
        end
    end
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    if isOpen then
        isOpen = false
        SendNUIMessage({action = 'hide'})
        SetNuiFocus(0, 0)
    end
    cb({})
end)

-- Events
RegisterNetEvent('ev:getPlateNui', function()
    if not isOpen then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            ESX.TriggerServerCallback('ev:getVehicle', function(data)
                if data then
                    isOpen = true
                    SendNUIMessage({action = 'show'})
                    SetNuiFocus(1, 1)
                else
                    ESX.ShowNotification('You do not own this car')
                end
            end, GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)):match( "^%s*(.-)%s*$" ))
        else
            ESX.ShowNotification('You are not in a vehicle')
        end
    end
end)

--Handlers
AddEventHandler('playerSpawned', function()
    Wait(3000)
    SendNUIMessage({
        action = 'setAcceptKey',
        key = Config.JsKey
    })
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(3000)
        SendNUIMessage({
            action = 'key',
            key = Config.JsKey
        })
    end
end)