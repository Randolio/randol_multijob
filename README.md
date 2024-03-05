# randol_multijob

A multi job script for QBCore/QBox using [**ox_lib**](https://github.com/overextended/ox_lib/releases/tag/v3.1.4)

![Front Menu](https://i.imgur.com/GuCXPhK.png)
![Choice Menu](https://i.imgur.com/bcIgTp3.png)

# QBOX Support -- With the qbx_management commit on Mar 1, 2024.. this should now work.

**1) For qbox users, head to :**

- ``qbx_management/server/main`` and replace the fireEmployee function with the one listed below.
```lua
local function fireEmployee(employeeCitizenId, boss, groupName, groupType)
    local employee = exports.qbx_core:GetPlayerByCitizenId(employeeCitizenId) or exports.qbx_core:GetOfflinePlayer(employeeCitizenId)
    if employee.PlayerData.citizenid == boss.PlayerData.citizenid then
        local message = groupType == 'gang' and locale('error.kick_yourself') or locale('error.fire_yourself')
        exports.qbx_core:Notify(boss.PlayerData.source, message, 'error')
        return false
    end
    if not employee then
        exports.qbx_core:Notify(boss.PlayerData.source, locale('error.person_doesnt_exist'), 'error')
        return false
    end

    local employeeGrade = groupType == 'job' and employee.PlayerData.jobs?[groupName] or employee.PlayerData.gangs?[groupName]
    local bossGrade = groupType == 'job' and boss.PlayerData.jobs?[groupName] or boss.PlayerData.gangs?[groupName]
    if employeeGrade >= bossGrade then
        exports.qbx_core:Notify(boss.PlayerData.source, locale('error.fire_boss'), 'error')
        return false
    end

    if groupType == 'job' then
        MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {employee.PlayerData.citizenid, employee.PlayerData[groupType].name})
        exports.qbx_core:RemovePlayerFromJob(employee.PlayerData.citizenid, groupName)
    else
        exports.qbx_core:RemovePlayerFromGang(employee.PlayerData.citizenid, groupName)
    end

    if not employee.Offline then
        local message = groupType == 'gang' and locale('error.you_gang_fired', GANGS[groupName].label) or locale('error.you_job_fired', JOBS[groupName].label)
        exports.qbx_core:Notify(employee.PlayerData.source, message, 'error')
    end

    return true
end
```

**2) make sure you set qbx in config lua :**

- ``Config.Framework = 'qbx'``

**3) Run the SQL in your database and restart your server**

- Default keybind to open is **F10** or use command **/myjobs**
