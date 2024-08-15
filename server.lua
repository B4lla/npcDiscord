-- ### Framework ###
if Config.Framework == "esx" then
    if Config.ESXExport ~= "" then
        ESX = exports[Config.ESXExport]:getSharedObject()
    else
        TriggerEvent(Config.Core, function(obj)
            ESX = obj
        end)
    end
elseif Config.Framework == "qb" then
    QBCore = exports[Config.Core]:GetCoreObject()
else
    print("Unrecognized framework")
end



if Config.Framework == "esx" then
    ESX.RegisterServerCallback("balla-1:requestData", function(source, cb)
        getUserInfo(source, cb)
    end)
else
    QBCore.Functions.CreateCallback("balla-1:requestData", function(source, cb)
        getUserInfo(source, cb)
    end)
end


function getUserInfo(source, cb)
    local player = source
    local discordIdentifier = nil

    for _, id in ipairs(GetPlayerIdentifiers(player)) do
        if string.match(id, "discord:") then
            discordIdentifier = string.gsub(id, "discord:", "")
            break
        end
    end

    if discordIdentifier then
        local endpoint = "https://discord.com/api/v10/users/" .. discordIdentifier
        local requestHeaders = {
            ["Authorization"] = "Bot " .. Config.BotToken 
        }

        PerformHttpRequest(endpoint, function(errorCode, resultData, resultHeaders)
            if errorCode == 200 then
                local userInfo = json.decode(resultData)
                local discordName = userInfo.username
                local discordAvatar = "https://cdn.discordapp.com/avatars/" .. discordIdentifier .. "/" .. userInfo.avatar .. ".png?size=128"
                cb(discordAvatar, discordName)
            else
                print(errorCode)
                cb(nil, nil)
            end
        end, "GET", nil, requestHeaders)
    else
        print("Discord id == nil")
        cb(nil, nil)
    end
end
