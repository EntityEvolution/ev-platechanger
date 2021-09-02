local stateEsx =  GetResourceState('es_extended') == 'started' or GetResourceState('extendedmode') == 'started'
local stateQbus =  GetResourceState('qb-core') == 'started'

if stateEsx then
    RegisterNetEvent('ev:getPlate', function(plate, currentPlate)
        local source <const> = source
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 or not currentPlate then
                return xPlayer.showNotification(Config.Locales.ErrorVehicle)
            elseif plate:len() > 6 then
                return xPlayer.showNotification(Config.Locales.ErrorCharsMax)
            end
            for i=0, #Config.Blacklist, 1 do
                if Config.Blacklist[i] == plate then
                    return xPlayer.showNotification('You tried to set a plate with a bad word: ' .. plate)
                end
            end
            MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
                ['owner'] = xPlayer.identifier,
                ['plate'] = currentPlate
            }, function(resultPlate)
                if not resultPlate then
                    return xPlayer.showNotification(Config.Locales.ErrorOwner)
                else
                    MySQL.Async.fetchScalar('SELECT * FROM owned_vehicles WHERE plate = @plate', {
                        ['plate'] = plate
                    }, function(result)
                        if not result then
                            MySQL.Async.fetchAll('SELECT plate, vehicle FROM owned_vehicles WHERE plate = @plate', {
                                ['plate'] = currentPlate
                            },function(result)
                                if result[1] then
                                    local vehicle = json.decode(result[1].vehicle)
                                    if not vehicle.plate then
                                        return xPlayer.showNotification(Config.Locales.ErrorPlateReal)
                                    end
                                    local oldPlate = vehicle.plate
                                    vehicle.plate = plate
                                    MySQL.Async.execute('UPDATE owned_vehicles SET plate = @newplate, vehicle = @vehicle WHERE plate = @oldplate AND owner=@identifier', {
                                        ['newplate'] = plate,
                                        ['oldplate'] = oldPlate, 
                                        ['identifier'] = xPlayer.identifier,
                                        ['vehicle'] = json.encode(vehicle)
                                    })
                                    SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source)), plate)
                                    xPlayer.removeInventoryItem('licenseplate', 1)
                                    xPlayer.showNotification(Config.Locales.NewPlate)
                                    return
                                end
                            end)
                        else
                            xPlayer.showNotification(Config.Locales.ErrorPlate)
                        end
                    end)
                end
            end)
        end
    end)

    ESX.RegisterUsableItem('licenseplate', function(source)
        local source <const> = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(source))
        if vehicle ~= 0 then
            MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
                ['owner'] = xPlayer.identifier,
                ['plate'] = GetVehicleNumberPlateText(vehicle):match( "^%s*(.-)%s*$" )
            }, function(plate)
                if plate then
                    TriggerClientEvent('ev:getPlateNui', source)
                else
                    xPlayer.showNotification(Config.Locales.ErrorOwner)
                end
            end)
        else
            xPlayer.showNotification(Config.Locales.ErrorWalking)
        end
    end)
elseif stateQbus then
    RegisterNetEvent('ev:getPlate', function(plate, currentPlate)
        local source <const> = source
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 or not currentPlate then
                return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorVehicle)
            elseif plate:len() > 6 then
                return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorCharsMax)
            end
            for i=0, #Config.Blacklist, 1 do
                if Config.Blacklist[i] == data then
                    return TriggerClientEvent('QBCore:Notify', source, 'You tried to set a plate with a bad word: ' .. plate)
                end
            end
            exports.ghmattimysql.execute('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
                ['owner'] = xPlayer.PlayerData.license,
                ['plate'] = currentPlate
            }, function(resultPlate)
                if not resultPlate then
                    return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorOwner)
                else
                    exports.ghmattimysql.execute('SELECT * FROM owned_vehicles WHERE plate = @plate', {
                        ['plate'] = plate
                    }, function(result)
                        if not result then
                            exports.ghmattimysql.execute('SELECT plate, vehicle FROM owned_vehicles WHERE plate = @plate', {
                                ['plate'] = currentPlate
                            },function(result)
                                if result[1] then
                                    local vehicle = json.decode(result[1].vehicle)
                                    if not vehicle.plate then
                                        return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlateReal)
                                    end
                                    local oldPlate = vehicle.plate
                                    vehicle.plate = plate
                                    exports.ghmattimysql.execute('UPDATE owned_vehicles SET plate = @newplate, vehicle = @vehicle WHERE plate = @oldplate AND owner=@identifier', {
                                        ['newplate'] = plate,
                                        ['oldplate'] = oldPlate, 
                                        ['identifier'] = xPlayer.PlayerData.license,
                                        ['vehicle'] = json.encode(vehicle)
                                    })
                                    SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source)), plate)
                                    xPlayer.removeInventoryItem('licenseplate', 1)
                                    TriggerClientEvent('QBCore:Notify', source, Config.Locales.NewPlate)
                                    return
                                end
                            end)
                        else
                            TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlate)
                        end
                    end)
                end
            end)
        end
    end)

    QBCore.Functions.CreateUseableItem('licenseplate', function(source)
        local source <const> = source
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(source))
        if vehicle ~= 0 then
            exports.ghmattimysql.execute('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
                ['owner'] = xPlayer.PlayerData.license,
                ['plate'] = GetVehicleNumberPlateText(vehicle):match( "^%s*(.-)%s*$" )
            }, function(plate)
                if plate then
                    TriggerClientEvent('ev:getPlateNui', source)
                else
                    TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorOwner)
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorWalking)
        end
    end)
end