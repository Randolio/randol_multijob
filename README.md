# randol_multijob

A multi job script for QBCore/QBox using [**ox_lib**](https://github.com/overextended/ox_lib/releases/tag/v3.1.4)


Firing someone from qb-management boss menu will delete the job from the menu.

# QBOX Support

**1) For qbox users, head to :**

- ``qbx_management/server/main`` and replace the fire employee functions listed below.

**2) make sure you set qbx in config lua :**

- ``Config.Framework = 'qbx'``

**3) Run the SQL in your database and restart your server**

- Default keybind to open is **F10** or use command **/myjobs**

```lua
-- Function to fire an online player from a given group
-- Should be merged with the offline player function once an export from the core is available
---@param source integer
---@param employee Player Player object of player being fired
---@param player Player Player object of player initiating firing action
---@param groupType GroupType
local function fireOnlineEmployee(source, employee, player, groupType)
    if employee.PlayerData.citizenid == player.PlayerData.citizenid then
        local message = groupType == 'gang' and locale('error.kick_yourself') or locale('error.fire_yourself')
        exports.qbx_core:Notify(source, message, 'error')
        return false
    end

    if employee.PlayerData[groupType].grade.level >= player.PlayerData[groupType].grade.level then
        exports.qbx_core:Notify(source, locale('error.fire_boss'), 'error')
        return false
    end

    local success = groupType == 'gang' and employee.Functions.SetGang('none', 0) or employee.Functions.SetJob('unemployed', 0)
    if success then
        if groupType == 'job' then
            MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {employee.PlayerData.citizenid, employee.PlayerData[groupType].name})
        end
        local message = groupType == 'gang' and locale('error.you_gang_fired') or locale('error.you_job_fired')
        exports.qbx_core:Notify(employee.PlayerData.source, message, 'error')
        return true
    end

    return false
end

-- Function to fire an offline player from a given group
-- Should be merged with the online player function once an export from the core is available
---@param source integer
---@param employee string citizenid of player to be fired
---@param player Player Player object of player initiating firing action
---@param groupType GroupType
local function fireOfflineEmployee(source, employee, player, groupType)
    local offlineEmployee = FetchPlayerEntityByCitizenId(employee)
    if not offlineEmployee[1] then
        exports.qbx_core:Notify(source, locale('error.person_doesnt_exist'), 'error')
        return false, nil
    end

    employee = offlineEmployee[1]
    employee[groupType] = json.decode(employee[groupType])
    employee.charinfo = json.decode(employee.charinfo)
    
    if employee[groupType].grade.level >= player.PlayerData[groupType].grade.level then
        exports.qbx_core:Notify(source, locale('error.fire_boss'), 'error')
        return false, nil
    end

    local role = updatePlayer('fire', groupType)
    local updateColumn = groupType == 'gang' and 'gang' or 'job'
    local employeeFullName = employee.charinfo.firstname..' '..employee.charinfo.lastname
    local success = UpdatePlayerGroup(employee.citizenid, updateColumn, role)
    if success > 0 then
        if groupType == 'job' then
            MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {employee.citizenid, employee[groupType].name})
        end
        return true, employeeFullName
    end

    return false, nil
end
```

![Front Menu](https://i.imgur.com/GuCXPhK.png)
![Choice Menu](https://i.imgur.com/bcIgTp3.png)
