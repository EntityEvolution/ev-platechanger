RegisterNetEvent('ev:getPlate', function(plate, currentPlate)
    local source <const> = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if veh == 0 or not currentPlate then
        return xPlayer.showNotification('You have to stay in your vehicle!')
    elseif plate:len() > 6 then
        return xPlayer.showNotification('Somehow you achieved to pass more than 6 chars')
    end
    MySQL.Async.fetchScalar('SELECT * FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if not result then
            MySQL.Async.fetchAll('SELECT plate, vehicle FROM owned_vehicles WHERE plate = @plate', {
                ['plate'] = currentPlate
            },function(result)
                if result[1] ~= nil then
                    local vehicle = json.decode(result[1].vehicle)
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
                    xPlayer.showNotification('Your new plate has been set')
                end
            end)
        else
            xPlayer.showNotification('Plate already exists')
        end
    end)
end)

-- ESX Stuff
ESX.RegisterServerCallback('ev:getVehicle', function(source, cb, plate)
    local source <const> = source
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate
    }, function(plate)
        cb(not not plate) -- if nil then change to false, if has value change to true (thanks avarian)
    end)
end)

ESX.RegisterUsableItem('licenseplate', function(source)
    TriggerClientEvent('ev:getPlateNui', source)
end)