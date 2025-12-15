if GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') ~= 'started' then return end

local isQbox = GetResourceState('qbx_core') == 'started'
QBCore = isQbox and exports.qbx_core or exports['qb-core']:GetCoreObject()

function RegisterCallback(name, cb)
    if isQbox then
        lib.callback.register(name, cb)
    else
        QBCore.Functions.CreateCallback(name, cb)
    end
end

function RegisterUsableItem(...)
    if isQbox then
        -- Qbox uses exports['qbx_core']:RegisterUsableItem instead
        exports['qbx_core']:RegisterUsableItem(...)
    else
        QBCore.Functions.CreateUseableItem(...)
    end
end

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function GetIdentifier(source)
    local source = tonumber(source)
    if isQbox then
        local Player = exports.qbx_core:GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    else
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
end

function SetPlayerMetadata(source, key, data)
    local source = tonumber(source)
    if isQbox then
        local Player = exports.qbx_core:GetPlayer(source)
        if Player then Player.Functions.SetMetaData(key, data) end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.SetMetaData(key, data) end
    end
end

RegisterNetEvent("hospital:server:SetDeathStatus", function(status)
    local source = source
    TriggerClientEvent("pickle_prisons:SetDeathStatus", source, status)
end)

function AddMoney(source, count)
    local source = tonumber(source)
    if isQbox then
        local Player = exports.qbx_core:GetPlayer(source)
        if Player then Player.Functions.AddMoney('cash', count) end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.AddMoney('cash', count) end
    end
end

function RemoveMoney(source, count)
    local source = tonumber(source)
    if isQbox then
        local Player = exports.qbx_core:GetPlayer(source)
        if Player then Player.Functions.RemoveMoney('cash', count) end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.RemoveMoney('cash', count) end
    end
end

function GetMoney(source)
    local source = tonumber(source)
    if isQbox then
        local Player = exports.qbx_core:GetPlayer(source)
        return Player and Player.PlayerData.money.cash or 0
    else
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.money.cash or 0
    end
end

function CheckPermission(source, permission)
    local Player = isQbox and exports.qbx_core:GetPlayer(source) or QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    local PlayerData = Player.PlayerData
    local name = PlayerData.job.name
    local rank = PlayerData.job.grade.level
    if permission.jobs[name] and permission.jobs[name] <= rank then 
        return true
    end
    for i=1, #permission.groups do
        if isQbox then
            if exports.qbx_core:HasPermission(source, permission.groups[i]) then
                return true
            end
        else
            if QBCore.Functions.HasPermission(source, permission.groups[i]) then 
                return true 
            end
        end
    end
end


-- Inventory Fallback

CreateThread(function()
    Wait(100)
    
    if InitializeInventory then return InitializeInventory() end -- Already loaded through inventory folder.
    
    Inventory = {}

    Inventory.Items = {}
    
    Inventory.Ready = false

    Inventory.CanCarryItem = function(source, name, count)
        local source = tonumber(source)
        if isQbox then
            local Player = exports.qbx_core:GetPlayer(source)
            if not Player then return false end
            local weight = exports.qbx_core:GetTotalWeight(Player.PlayerData.items)
            local item = exports.qbx_core:GetItems()[name:lower()]
            if not item then return false end
            return ((weight + (item.weight * count)) <= exports.qbx_core:GetMaxWeight())
        else
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return false end
            local weight = QBCore.Player.GetTotalWeight(Player.PlayerData.items)
            local item = QBCore.Shared.Items[name:lower()]
            if not item then return false end
            return ((weight + (item.weight * count)) <= QBCore.Config.Player.MaxWeight)
        end
    end

    Inventory.GetInventory = function(source)
        local source = tonumber(source)
        local Player = isQbox and exports.qbx_core:GetPlayer(source) or QBCore.Functions.GetPlayer(source)
        if not Player then return {} end
        local items = {}
        local data = Player.PlayerData.items
        for slot, item in pairs(data) do 
            items[#items + 1] = {
                name = item.name,
                label = item.label,
                count = item.amount,
                weight = item.weight,
                metadata = item.info
            }
        end
        return items
    end

    Inventory.AddItem = function(source, name, count, metadata) -- Metadata is not required.
        local source = tonumber(source)
        local Player = isQbox and exports.qbx_core:GetPlayer(source) or QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.AddItem(name, count, nil, metadata) end
    end

    Inventory.RemoveItem = function(source, name, count)
        local source = tonumber(source)
        local Player = isQbox and exports.qbx_core:GetPlayer(source) or QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.RemoveItem(name, count) end
    end

    Inventory.AddWeapon = function(source, name, count, metadata) -- Metadata is not required.
        local source = tonumber(source)
        Inventory.AddItem(source, name, count, metadata)
    end

    Inventory.RemoveWeapon = function(source, name, count)
        local source = tonumber(source)
        Inventory.RemoveItem(source, name, count, metadata)
    end

    Inventory.GetItemCount = function(source, name)
        local source = tonumber(source)
        local Player = isQbox and exports.qbx_core:GetPlayer(source) or QBCore.Functions.GetPlayer(source)
        if not Player then return 0 end
        local item = Player.Functions.GetItemByName(name)
        return item and item.amount or 0
    end

    Inventory.HasWeapon = function(source, name, count)
        local source = tonumber(source)
        return (Inventory.GetItemCount(source, name) > 0)
    end

    RegisterCallback("pickle_prisons:getInventory", function(source, cb)
        cb(Inventory.GetInventory(source))
    end)

    if isQbox then
        local items = exports.qbx_core:GetItems()
        for item, data in pairs(items) do
            Inventory.Items[item] = {label = data.label}
        end
    else
        for item, data in pairs(QBCore.Shared.Items) do
            Inventory.Items[item] = {label = data.label}
        end
    end
    Inventory.Ready = true
end)