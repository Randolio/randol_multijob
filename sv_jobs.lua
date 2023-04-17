local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('randol_multijob:server:myJobs', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local storeJobs = {}
    local result = MySQL.query.await('SELECT * FROM save_jobs WHERE cid = ?', {Player.PlayerData.citizenid})
    for k, v in pairs(result) do
        storeJobs[#storeJobs + 1] = {
            job = v.job,
            salary = QBCore.Shared.Jobs[v.job].grades[tostring(v.grade)].payment,
            jobLabel = QBCore.Shared.Jobs[v.job].label,
            gradeLabel = QBCore.Shared.Jobs[v.job].grades[tostring(v.grade)].name,
            grade = v.grade,
        }
    end
    return storeJobs
end)

RegisterNetEvent('randol_multijob:server:changeJob', function(job, grade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local JobInfo = QBCore.Shared.Jobs[job]
    if Player.PlayerData.job.name == job then QBCore.Functions.Notify(src, 'Your current job is already set to this.', 'error') return end
    TriggerClientEvent("QBCore:Client:SetDuty", src, false)
    Player.Functions.SetJob(job, grade)
    Player.Functions.SetJobDuty(false)
    QBCore.Functions.Notify(src, 'Your job is now: '..JobInfo.label .. '.')
end)

RegisterNetEvent('randol_multijob:server:newJob', function(newJob)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob = false
    local result = MySQL.query.await('SELECT * FROM save_jobs WHERE cid = ?', {Player.PlayerData.citizenid})
    for k, v in pairs(result) do
        if newJob.name == v.job then
           MySQL.query.await('UPDATE save_jobs SET grade = ? WHERE job = ? and cid = ?', {newJob.grade.level, newJob.name, Player.PlayerData.citizenid})
           hasJob = true
        end
    end
    if not hasJob then 
       MySQL.insert.await('INSERT INTO save_jobs (cid, job, grade) VALUE (?, ?, ?)', {Player.PlayerData.citizenid, newJob.name, newJob.grade.level})
    end
end)

RegisterNetEvent('randol_multijob:server:deleteJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if job == 'unemployed' then QBCore.Functions.Notify(src, 'This job can\'t be removed.', 'error') return end
    MySQL.query.await('DELETE FROM `save_jobs` WHERE `cid` = ? and `job` = ?', {Player.PlayerData.citizenid, job})
    QBCore.Functions.Notify(src, 'You deleted '..QBCore.Shared.Jobs[job].label..' job from your menu.')
    Player.Functions.SetJob('unemployed', 0)
end)

RegisterNetEvent('qb-bossmenu:server:FireEmployee', function(target) -- Removes job when fired from qb-bossmenu.
    local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
	local oldJob = Employee.PlayerData.job.name
        MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {Employee.PlayerData.citizenid, oldJob})
    end
end)
