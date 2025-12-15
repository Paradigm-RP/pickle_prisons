-- Auto-create database table on resource start
CreateThread(function()
    local success = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `pickle_prisons` (
            `identifier` varchar(46) NOT NULL,
            `prison` varchar(50) DEFAULT 'default',
            `time` int(11) NOT NULL DEFAULT 0,
            `inventory` longtext NOT NULL,
            `sentence_date` int(11) DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    if success then
        print("^2[pickle_prisons]^7 Database table verified/created successfully")
    else
        print("^1[pickle_prisons]^7 Failed to create database table - please run _INSTALL/SQL/install.sql manually")
    end
end)
