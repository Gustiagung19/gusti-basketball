basketball = nil
tasks = {}

RegisterCommand(Config.Commands, function()
    local forward = GetEntityForwardVector(PlayerPedId())
    local coords = GetEntityCoords(PlayerPedId()) + forward * 2
    local entity = CreateObject(GetHashKey(Config.PropModel), coords, true, true, true)
    SetEntityVelocity(entity, 0.0001, 0.0, 0.0)
    SetEntityAsMissionEntity(entity, true, true)
end)

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, Config.PickUpBall) then
            if not basketball then
                local closestEntity, closestEntityDistance = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.5, GetHashKey(Config.PropModel), false, false, false)
                local closestEntityDistance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(closestEntity))
                if GetEntityModel(closestEntity) == GetHashKey(Config.PropModel) and closestEntityDistance <= 1.5 then
                    PickupBasketball(closestEntity)
                end
            end
        end
        if IsControlJustReleased(0, Config.PlayStyleBall) then
            if basketball then
                if not tasks.isRolling then
                    tasks.isRolling = true
                    LoadAnim('amb@world_human_mobile_film_shocking@male@base')
                    TaskPlayAnim(PlayerPedId(), 'amb@world_human_mobile_film_shocking@male@base', 'base', 8.0, 8.0, -1, 51, 0, false, false, false)
                    local ballRotation = 0.0
                    Citizen.CreateThread(function()
                        while tasks.isRolling do
                            if ballRotation > 360 then
                                ballRotation = 0.0
                                AttachEntityToEntity(basketball, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, false, 0.0, false)
                            else
                                ballRotation = ballRotation + 60
                                AttachEntityToEntity(basketball, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, ballRotation, true, true, true, false, 0.0, false)
                            end
                            Citizen.Wait(0)
                        end
                    end)
                    Citizen.CreateThread(function()
                        Citizen.Wait(12000)
                        if tasks.isRolling then
                            DetachBasketball()
                            tasks.isRolling = false
                        end
                    end)
                else
                    ClearPedTasks(PlayerPedId())
                    tasks.isRolling = false
                end
            end
        end
        if IsDisabledControlPressed(0, Config.ShootBall) then
            if basketball then
                if not tasks.normalShootForce then tasks.normalShootForce = 0.1 end
                if tasks.normalShootForce < 2 then
                    tasks.normalShootForce = tasks.normalShootForce + 0.05
                end
            end
        end
        if IsDisabledControlJustReleased(0, Config.ShootBall) then
            if basketball then
                if not tasks.isShooting then
                    tasks.isShooting = true
                    LoadAnim('amb@prop_human_movie_bulb@exit')
                    ClearPedTasksImmediately(PlayerPedId())
                    local forwardX = GetEntityForwardX(PlayerPedId())
                    local forwardY = GetEntityForwardY(PlayerPedId())
                    DetachEntity(basketball)
                    SetEntityVelocity(basketball, forwardX * (tasks.normalShootForce * 10), forwardY * (tasks.normalShootForce * 10), tasks.normalShootForce * 10)
                    basketball = nil
                    TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)

                    Citizen.Wait(1000)
                    ClearPedTasks(PlayerPedId())
                    tasks.isShooting = false
                    tasks.normalShootForce = 0.1
                    tasks.isDribbling = false
                end
            end
        end
        if IsControlPressed(0, Config.DribbleBall) then
            if basketball and not tasks.isDribbling then
                LoadAnim('anim@move_m@trash')
                TaskPlayAnim(PlayerPedId(), 'anim@move_m@trash', 'walk', 8.0, 8.0, -1, 51, 1, false, false, false)
                tasks.isDribbling = true
            end
        else
            if basketball and tasks.isDribbling then
                tasks.isDribbling = false
                StopAnimTask(PlayerPedId(), 'anim@move_m@trash', 'walk', 51)
                ClearPedTasksImmediately(PlayerPedId())
            end 
        end
        if IsControlJustReleased(0, Config.DetachBall) then
            if basketball then
                DetachBasketball()
            end
        end
        if basketball then
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if basketball and tasks.isDribbling then
            local playerPed = PlayerPedId()
            if IsPedWalking(playerPed) or IsPedRunning(playerPed) then
                DetachEntity(basketball)
                local forwardX = GetEntityForwardX(playerPed)
                local forwardY = GetEntityForwardY(playerPed)
                SetEntityVelocity(basketball, forwardX * 2, forwardY * 2, -3.8)
                Citizen.Wait(300)
                forwardX = GetEntityForwardX(playerPed)
                forwardY = GetEntityForwardY(playerPed)
                SetEntityVelocity(basketball, forwardX * 1.9, forwardY * 1.9, 4.0)
                Citizen.Wait(450)
                AttachEntityToEntity(basketball, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, false, 0.0, true)
            elseif IsPedSprinting(playerPed) then
                DetachEntity(basketball)
                local forwardX = GetEntityForwardX(playerPed)
                local forwardY = GetEntityForwardY(playerPed)
                SetEntityVelocity(basketball, forwardX * 9, forwardY * 9, -10.0)
                Citizen.Wait(200)
                forwardX = GetEntityForwardX(playerPed)
                forwardY = GetEntityForwardY(playerPed)
                SetEntityVelocity(basketball, forwardX * 8, forwardY * 8, 3.0)
                Citizen.Wait(300)
                AttachEntityToEntity(basketball, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, false, 0.0, true)
            else 
                DetachEntity(basketball)
                SetEntityVelocity(basketball, 0.0, 0.0, -3.8)
                Citizen.Wait(250)
                SetEntityVelocity(basketball, 0, 0, 4.0)
                Citizen.Wait(450)
                AttachEntityToEntity(basketball, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, false, 0.0, true)
            end
        end 
        Citizen.Wait(0)
    end
end)

function PickupBasketball(entity)
    NetworkRequestControlOfEntity(entity)
    while (NetworkGetEntityOwner(entity) ~= PlayerId()) and (NetworkGetEntityOwner(entity) ~= -1) do
        Citizen.Wait(0)
    end
    LoadAnim('anim@mp_snowball')
    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, 8.0, -1, 32, 1, false, false, false)
    Citizen.Wait(150)
    AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, false, 0.0, true)
    basketball = entity
    SetEntityAsMissionEntity(entity, true, true)
    Citizen.Wait(1500)
    ClearPedTasksImmediately(PlayerPedId())
end

function DetachBasketball()
    DetachEntity(basketball)
    basketball = nil
    tasks = {}
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    return true
end