local stateEsx =  GetResourceState('es_extended') == 'started' or GetResourceState('extendedmode') == 'started'
local stateQbus =  GetResourceState('qb-core') == 'started'
local isOpen = false

local function showNoti(message)
    if stateEsx then
        ESX.ShowNotification(message)
    elseif stateQbus then
        QBCore.Functions.Notify(message)
    end
end

-- NUI Callback
RegisterNUICallback('getPlateText', function(data, cb)
    if isOpen then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then
                if data then
                    for i=0, #Config.Blacklist, 1 do
                        if Config.Blacklist[i] == data then
                            return showNoti('You tried to set a plate with a bad word: ' .. data)
                        end
                    end
                    if data:len() > 0 then
                        SendNUIMessage({action = 'hide'})
                        SetNuiFocus(0, 0)
                        TriggerServerEvent('ev:getPlate', data, GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)):match( "^%s*(.-)%s*$" ))
                        isOpen = false
                    else
                        showNoti(Config.Locales.ErrorCharsMin)
                    end
                else
                    showNoti(Config.Locales.Error)
                end
            else
                showNoti(Config.Locales.ErrorDriver) 
            end
        else
            showNoti(Config.Locales.ErrorVehicle)
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
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then
                isOpen = true
                SendNUIMessage({action = 'show'})
                SetNuiFocus(1, 1)
            else
                showNoti(Config.Locales.ErrorDriver)
            end
        else
            showNoti(Config.Locales.ErrorWalking)
        end
    end
end)

--Handlers
AddEventHandler('playerSpawned', function()
    Wait(3000)
    SendNUIMessage({
        action = 'key',
        key = Config.JsKey,
        title = Config.PlateHeader,
        chars = Config.EightChars,
        buttons = Config.useButtons
    })
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(3000)
        SendNUIMessage({
            action = 'key',
            key = Config.JsKey,
            title = Config.PlateHeader,
            chars = Config.EightChars,
            buttons = Config.useButtons
        })
    end
end)