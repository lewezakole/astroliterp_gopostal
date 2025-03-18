local jobActive = false
local packagesToDeliver = 0
local deliveryPoints = {}
local currentDelivery = 1
local courierVehicle = nil
local canStartJob = true
local activeBlip = nil
local activeDeliveryZone = nil

function CreateCourierNPC()
    local npcModel = Config.NPC.model
    local npcCoords = Config.NPC.coords
    local npcHeading = Config.NPC.heading

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do Wait(100) end

    local npc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcHeading, false, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)

    exports.ox_target:addLocalEntity(npc, {
        {
            label = "Rozpocznij pracę kuriera",
            icon = "fa-solid fa-truck",
            onSelect = function()
                StartCourierJob()
            end
        }
    })
end

function StartCourierJob()
    if not canStartJob then
        lib.notify({title = 'Kurier', description = 'Musisz poczekać 30 sekund przed kolejnym zleceniem.', type = 'error'})
        return
    end

    if jobActive then
        lib.notify({title = 'Kurier', description = 'Już pracujesz!', type = 'error'})
        return
    end

    canStartJob = false
    SetTimeout(30000, function() 
        canStartJob = true 
    end)

    jobActive = true
    packagesToDeliver = math.random(Config.MinPackages, Config.MaxPackages)

    deliveryPoints = {}
    for i = 1, packagesToDeliver do
        local randIndex = math.random(#Config.DeliveryLocations)
        table.insert(deliveryPoints, Config.DeliveryLocations[randIndex])
    end

    local vehicleHash = GetHashKey('nspeedo')
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do Wait(100) end

    courierVehicle = CreateVehicle(vehicleHash, Config.VehicleSpawn.x, Config.VehicleSpawn.y, Config.VehicleSpawn.z, 0.0, true, false)
    SetPedIntoVehicle(PlayerPedId(), courierVehicle, -1)

    lib.notify({title = 'Kurier', description = 'Rozpocząłeś pracę! Jedź do pierwszego miejsca dostawy.', type = 'success'})

    SetNextDeliveryPoint()
end

function SetNextDeliveryPoint()
    if currentDelivery > packagesToDeliver then
        FinishCourierJob()
        return
    end

    local nextPoint = deliveryPoints[currentDelivery]

    if DoesBlipExist(activeBlip) then
        RemoveBlip(activeBlip)
    end

    activeBlip = AddBlipForCoord(nextPoint.x, nextPoint.y, nextPoint.z)
    SetBlipSprite(activeBlip, 1)
    SetBlipScale(activeBlip, 1.0)
    SetBlipColour(activeBlip, 5)
    SetBlipRoute(activeBlip, true)

    if activeDeliveryZone then
        exports.ox_target:removeZone(activeDeliveryZone)
    end

    activeDeliveryZone = exports.ox_target:addSphereZone({
        coords = nextPoint,
        radius = 2.0,
        debug = false, 
        options = {
            {
                label = "Oddaj paczkę",
                icon = "fa-solid fa-box",
                onSelect = function()
                    DeliverPackage()
                end
            }
        }
    })
end

function DeliverPackage()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= courierVehicle then
        lib.notify({title = 'Kurier', description = 'Musisz być w pojeździe, aby oddać paczkę!', type = 'error'})
        return
    end

    lib.progressBar({
        duration = 5000,
        label = "Oddawanie paczki...",
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true }
    })


    local reward = math.random(Config.Reward.min, Config.Reward.max)
    TriggerServerEvent('courier:giveReward', reward)

    if activeDeliveryZone then
        exports.ox_target:removeZone(activeDeliveryZone)
        activeDeliveryZone = nil
    end

    currentDelivery = currentDelivery + 1
    SetNextDeliveryPoint()
end

function FinishCourierJob()
    jobActive = false
    currentDelivery = 1
    packagesToDeliver = 0

    local npcCoords = Config.NPC.coords

    if DoesBlipExist(activeBlip) then
        RemoveBlip(activeBlip)
    end

    activeBlip = AddBlipForCoord(npcCoords.x, npcCoords.y, npcCoords.z)
    SetBlipSprite(activeBlip, 1)
    SetBlipScale(activeBlip, 1.0)
    SetBlipColour(activeBlip, 3) 
    SetBlipRoute(activeBlip, true)

    lib.notify({title = 'Kurier', description = 'Wróć do punktu początkowego, aby zakończyć pracę.', type = 'info'})

    exports.ox_target:addSphereZone({
        coords = npcCoords,
        radius = 2.0,
        debug = false,
        options = {
            {
                label = "Zakończ pracę",
                icon = "fa-solid fa-clipboard-check",
                onSelect = function()
                    if DoesEntityExist(courierVehicle) then
                        DeleteEntity(courierVehicle)
                    end
                    lib.notify({title = 'Kurier', description = 'Praca zakończona.', type = 'success'})

                    if DoesBlipExist(activeBlip) then
                        RemoveBlip(activeBlip)
                    end
                end
            }
        }
    })
end

CreateThread(function()
    Wait(1000)
    CreateCourierNPC()
end)
