# Qbox Setup Guide for pickle_prisons

## ✅ Changes Made (Modernized v1.2.0)

The resource has been **fully modernized** and updated to support **Qbox** alongside QB-Core with minimal configuration needed.

### Modified Files:
- `fxmanifest.lua` - **Updated to v1.2.0** with oxmysql and auto-database injection
- `bridge/qb/client.lua` - Added Qbox (qbx_core) detection
- `bridge/qb/server.lua` - Added Qbox (qbx_core) detection and compatibility
- `modules/prison/server.lua` - **Modernized to use oxmysql async/await syntax**
- `bridge/esx/server.lua` - **Modernized to use oxmysql async/await syntax**

### 🆕 Modernization Features:
- ✨ **Auto-database injection** - SQL tables create automatically on resource start
- 🚀 **oxmysql** - Modern async/await MySQL queries (faster & more reliable)
- 🎯 **No manual SQL installation needed** - Database tables auto-create
- ⚡ **Improved performance** - Non-blocking database queries

## 🔧 Configuration

### 1. Config.lua Settings

Make sure these settings are configured in your `config.lua`:

```lua
Config.UseTarget = true -- Set to true to use ox_target (recommended for Qbox)
```

### 2. Dependencies

Ensure you have these resources started **before** pickle_prisons:

```
ensure qbx_core
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure oxmysql  # Modern MySQL wrapper (replaces mysql-async)
```

### 3. Server.cfg Order

```cfg
# Core
ensure qbx_core
ensure [qbx]

# Dependencies
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure ox_target

# Prison System
ensure pickle_prisons
```

### 4. Items Installation

You need to add prison items to your server. Check the `_INSTALL/Items/` folder:

- For **ox_inventory**: Use `ox_inventory.lua`
- For **QBCore inventory**: Use `qbcore.lua`

**Items needed:**
- `shovel` - For prison breakouts
- `wood`, `metal`, `rope` - Crafting materials for prison items
- `burger`, `water` - Commissary items

### 5. Database Installation

**🎉 DATABASE AUTO-CREATES!** The `pickle_prisons` table is automatically created when the resource starts.

**No manual SQL installation needed!** The resource uses the new `database` field in fxmanifest.lua to auto-inject the database schema.

### 6. Job Permissions

Update the job names in `config.lua` if your Qbox server uses different job names:

```lua
Config.Default = {
    permissions = {
        jail = {
            jobs = {["police"] = 0, ["sheriff"] = 0}, -- Adjust job names as needed
            groups = {"admin", "god"}
        },
```

## 🎮 How It Works

The bridge system automatically detects which framework is running:
- Checks for `qbx_core` first (Qbox)
- Falls back to `qb-core` if Qbox isn't found
- Uses the appropriate exports and functions for each framework

## ⚙️ Recommended Settings for Qbox

```lua
Config.UseTarget = true          -- Use ox_target
Config.NoModelTargeting = true   -- Better targeting experience
Config.ServeTimeOffline = true  -- Players serve time online only
Config.EnableSneakout = false    -- Disable automatic sneakout freedom
```

## 🧪 Testing

1. Start your server with Qbox
2. Test jailing a player: `/jail [player_id] [time] [reason]`
3. Verify the player is teleported to prison
4. Check that prison activities work (workout, cleaning, kitchen)
5. Test the store/commissary
6. Test unjailing: `/unjail [player_id]`

## 🔍 Troubleshooting

### "Resource not starting"
- Verify all dependencies are started first
- Check console for errors
- Ensure ox_lib is up to date

### "Target not working"
- Confirm `Config.UseTarget = true`
- Verify ox_target is running
- Check that ox_target is started before pickle_prisons

### "Inventory issues"
- Make sure ox_inventory is running
- Verify items are added to ox_inventory
- Check that inventory webhooks are configured

### "Permission errors"
- Verify job names match your Qbox configuration
- Check that ace permissions are set up correctly
- Ensure admin groups match your server setup

## 📝 Notes

- This resource is now compatible with both Qbox and QB-Core
- The outfit system will work with qb-clothing or similar clothing resources
- XP system is optional and can be disabled in config
- All bridge files load automatically based on what resources are running

## 🆘 Need Help?

If you encounter issues:
1. Check server console for errors
2. Verify all dependencies are correct versions
3. Ensure database tables were created properly
4. Check that item names match between config and inventory
