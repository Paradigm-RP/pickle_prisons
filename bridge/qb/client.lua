if GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') ~= 'started' then return end

local isQbox = GetResourceState('qbx_core') == 'started'
QBCore = isQbox and exports.qbx_core or exports['qb-core']:GetCoreObject()

function ServerCallback(name, cb, ...)
    if isQbox then
        lib.callback(name, false, cb, ...)
    else
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end
end

function ShowNotification(text)
    if isQbox then
        lib.notify({description = text, type = 'info'})
    else
        QBCore.Functions.Notify(text)
    end
end

function GetPlayersInArea(coords, radius)
    local coords = coords or GetEntityCoords(PlayerPedId())
    local radius = radius or 3.0
    if isQbox then
        local players = {}
        local nearbyPlayers = lib.getNearbyPlayers(coords, radius, true)
        for _, data in pairs(nearbyPlayers) do
            if data.id ~= cache.playerId then
                players[#players + 1] = data.id
            end
        end
        return players
    else
        local list = QBCore.Functions.GetPlayersFromCoords(coords, radius)
        local players = {}
        for _, player in pairs(list) do 
            if player ~= PlayerId() then
                players[#players + 1] = player
            end
        end
        return players
    end
end

RegisterNetEvent(GetCurrentResourceName()..":showNotification", function(text)
    ShowNotification(text)
end)

if isQbox then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent("pickle_prisons:initializePlayer")
    end)
    RegisterNetEvent('qbx_core:client:playerLoaded', function()
        TriggerServerEvent("pickle_prisons:initializePlayer")
    end)
else
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent("pickle_prisons:initializePlayer")
    end)
end

RegisterNetEvent('pickle_prisons:SetDeathStatus', function(status)
    if status then
        CheckBreakout = false 
    else
        TeleportHospital()
        CheckBreakout = true  
    end
end)

function ToggleOutfit(inPrison)
    if inPrison then 
        local prison = Config.Prisons[Prison.index]
        local outfits = prison.outfit or Config.Default.outfit
        local playerData = isQbox and exports.qbx_core:GetPlayerData() or QBCore.Functions.GetPlayerData()
        local gender = playerData.charinfo.gender
        local outfit = gender == 1 and outfits.female or outfits.male
        if not outfit then return end
        TriggerEvent('qb-clothing:client:loadOutfit', {outfitData = outfit})
    else
        if isQbox then
            TriggerServerEvent('qb-clothing:loadPlayerSkin')
        else
            TriggerServerEvent('qb-clothes:loadPlayerSkin')
        end
    end
end

function GetConvertedClothes(oldClothes)
    local clothes = {}
    local components = {
        ['arms'] = "arms",
        ['tshirt_1'] = "t-shirt", 
        ['torso_1'] = "torso2", 
        ['bproof_1'] = "vest",
        ['decals_1'] = "decals", 
        ['pants_1'] = "pants", 
        ['shoes_1'] = "shoes", 
        ['helmet_1'] = "hat", 
        ['chain_1'] = "accessory", 
    }
    local textures = {
        ['tshirt_1'] = 'tshirt_2', 
        ['torso_1'] = 'torso_2',
        ['bproof_1'] = 'bproof_2',
        ['decals_1'] = 'decals_2',
        ['pants_1'] = 'pants_2',
        ['shoes_1'] = 'shoes_2',
        ['helmet_1'] = 'helmet_2',
        ['chain_1'] = 'chain_2',
    }
    for k,v in pairs(oldClothes) do 
        local component = components[k]
        if component then 
            local texture = textures[k] and (oldClothes[textures[k]] or 0) or 0
            clothes[component] = {item = v, texture = texture}
        end
    end
    return clothes
end

CreateThread(function()
    for k,v in pairs(Config.Prisons) do
        local prison = v
        local outfits = prison.outfit or Config.Default.outfit
        if not Config.Prisons[k].outfit then 
            Config.Prisons[k].outfit = {}
        end
        Config.Prisons[k].outfit.male = GetConvertedClothes(outfits.male)
        Config.Prisons[k].outfit.female = GetConvertedClothes(outfits.female)
    end
end)

-- Inventory Fallback

CreateThread(function()
    Wait(100)
    
    if InitializeInventory then return InitializeInventory() end -- Already loaded through inventory folder.

    Inventory = {}

    Inventory.Items = {}
    
    Inventory.Ready = false
    
    RegisterNetEvent("pickle_prisons:setupInventory", function(data)
        Inventory.Items = data.items
        Inventory.Ready = true
    end)
end)
