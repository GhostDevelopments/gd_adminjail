local isJailed = false
local jailTime = 0

local function startJailLoop()
    CreateThread(function()
        while isJailed do
            local sleep = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            
            if #(coords - Config.JailLocation.xyz) > 20.0 then
                SetEntityCoords(ped, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z)
                lib.notify({title = "Admin Jail", description = "You cannot leave this area!", type = "error"})
            end

            for _, control in ipairs(Config.DisabledControls) do
                DisableControlAction(0, control, true)
            end
            
            sleep = 0
            Wait(sleep)
        end
    end)
end

RegisterNetEvent("adminjail:client:EnterJail", function(time)
    isJailed = true
    jailTime = time
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z)
    SetEntityHeading(PlayerPedId(), Config.JailLocation.w)
    DoScreenFadeIn(500)
    startJailLoop()
end)

RegisterNetEvent("adminjail:client:Release", function()
    isJailed = false
    jailTime = 0
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), Config.ReleaseLocation.x, Config.ReleaseLocation.y, Config.ReleaseLocation.z)
    SetEntityHeading(PlayerPedId(), Config.ReleaseLocation.w)
    DoScreenFadeIn(500)
    lib.notify({title = "Released", description = "Your time is up. Behave yourself!", type = "success"})
end)

RegisterCommand(Config.Commands.time, function()
    if isJailed then
        lib.notify({title = "Jail Time", description = "Remaining: " .. jailTime .. " minutes", type = "inform"})
    else
        lib.notify({title = "Jail Time", description = "You are not jailed", type = "error"})
    end
end)

RegisterCommand(Config.Commands.list, function()
    local data = lib.callback.await("adminjail:server:getJailedPlayers", false)
    if not data then return end
    
    SendNUIMessage({
        action = "open",
        players = data
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)