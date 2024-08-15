-- Framework

if Config.Framework == "esx" then
    if Config.ESXExport ~= "" then
        ESX = exports[Config.ESXExport]:getSharedObject()
    else
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent(Config.Core, function(obj)
                    ESX = obj
                end)
                Citizen.Wait(0)
            end
        end)
    end
elseif Config.Framework == "qb" then
    QBCore = exports[Config.Core]:GetCoreObject()
else
    print("Unrecognized framework")
end


-- Threads

Citizen.CreateThread(function()
    local npcModel = GetHashKey(Config.Npc)
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(1)
    end
    local npc = CreatePed(4, npcModel, Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1.0, Config.NpcCoords.h, false, true)

    SetEntityAsMissionEntity(npc, true, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDiesWhenInjured(npc, false)
    SetPedCanPlayAmbientAnims(npc, true)
    SetPedCanRagdollFromPlayerImpact(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)

    local sleep = 1000
    local showText = false

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - vector3(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z))

        if distance < 5.0 then
            sleep = 3
            if not showText then
                showText = true
            end
            drawTxt(Config.Lang, 1, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
            if IsControlJustPressed(1, 51) then 
                if Config.Framework == "esx" then
                    ESX.TriggerServerCallback('balla-1:requestData', function(discordAvatar, discordName)
                        if discordAvatar and discordName ~= nil then 
                            sendData(discordAvatar, discordName)
                        end
                    end)
                else
                    QBCore.Functions.TriggerCallback('balla-1:requestData', function(discordAvatar, discordName)
                        if discordAvatar and discordName ~= nil then 
                            sendData(discordAvatar, discordName)
                        end
                    end)
                end
                
            end
        else
            sleep = 1000
            showText = false
        end
        Citizen.Wait(sleep)
    end
end)

-- Functions

function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r,g,b,a)
    SetTextDropShadow(0,0,0,0,255)
    SetTextEdge(1,0,0,0,255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end

function sendData(discordAvatar, discordName)
    SendNuiMessage(json.encode({
        type = "show",
        img = discordAvatar,
        name = discordName
    }))
end