local Config = lib.require('config')

local function GetJobCount(cid)
    local result = MySQL.query.await('SELECT COUNT(*) as jobCount FROM save_jobs WHERE cid = ?', {cid})
    local jobCount = result[1].jobCount
    return jobCount
end

local function CanSetJob(cid, jobName)
    local jobs = MySQL.query.await('SELECT job, grade FROM save_jobs WHERE cid = ? ', {cid})
    if not jobs then return false end
    for i = 1, #jobs do
        if jobs[i].job == jobName then
            return true, jobs[i].grade
        end
    end
    return false
end

lib.callback.register('randol_multijob:server:myJobs', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local storeJobs = {}
    local result = MySQL.query.await('SELECT * FROM save_jobs WHERE cid = ?', {Player.PlayerData.citizenid})
    for k, v in pairs(result) do
        local job = QBCore.Shared.Jobs[v.job]

        if not job then 
            return error(('MISSING JOB FROM jobs.lua: "%s" | CITIZEN ID: %s'): format(v.job, Player.PlayerData.citizenid)) 
        end
        
        local grade = job.grades[tostring(v.grade)]

        if not grade then 
            return error(('MISSING JOB GRADE for "%s". GRADE MISSING: %s | CITIZEN ID: %s'): format(v.job, v.grade, Player.PlayerData.citizenid)) 
        end

        storeJobs[#storeJobs + 1] = {
            job = v.job,
            salary = grade.payment,
            jobLabel = job.label,
            gradeLabel = grade.name,
            grade = v.grade,
        }
    end
    return storeJobs
end)

RegisterNetEvent('randol_multijob:server:changeJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.PlayerData.job.name == job then 
        QBCore.Functions.Notify(src, 'Your current job is already set to this.', 'error') 
        return 
    end

    local jobInfo = QBCore.Shared.Jobs[job]
    if not jobInfo then 
        QBCore.Functions.Notify(src, 'Invalid job.', 'error') 
        return 
    end

    local cid = Player.PlayerData.citizenid
    local canSet, grade = CanSetJob(cid, job)
    
    if not canSet then 
        return 
    end

    Player.Functions.SetJob(job, grade)
    Player.Functions.SetJobDuty(false)
    TriggerClientEvent('QBCore:Client:SetDuty', src, false)
    QBCore.Functions.Notify(src, 'Your job is now: ' .. jobInfo.label)
end)

RegisterNetEvent('randol_multijob:server:newJob', function(newJob)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob = false
    local cid = Player.PlayerData.citizenid
    if newJob.name == 'unemployed' then return end
    local result = MySQL.query.await('SELECT * FROM save_jobs WHERE cid = ? AND job = ?', {cid, newJob.name}) 
    if result[1] then
        MySQL.query.await('UPDATE save_jobs SET grade = ? WHERE job = ? and cid = ?', {newJob.grade.level, newJob.name, cid})
        hasJob = true
        return
    end
    if not hasJob and GetJobCount(cid) < Config.MaxJobs then 
        MySQL.insert.await('INSERT INTO save_jobs (cid, job, grade) VALUE (?, ?, ?)', {cid, newJob.name, newJob.grade.level})
    else
        return QBCore.Functions.Notify(src, 'You have the max amount of jobs.', 'error')
    end
end)

RegisterNetEvent('randol_multijob:server:deleteJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? and job = ?', {Player.PlayerData.citizenid, job})
    QBCore.Functions.Notify(src, 'You deleted '..QBCore.Shared.Jobs[job].label..' job from your menu.')
    if Player.PlayerData.job.name == job then
        Player.Functions.SetJob('unemployed', 0)
    end
end)

RegisterNetEvent('qb-bossmenu:server:FireEmployee', function(target) -- Removes job when fired from qb-bossmenu.
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
        local oldJob = Employee.PlayerData.job.name
        MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {Employee.PlayerData.citizenid, oldJob})
    else
        local player = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { target })
        if player[1] then
            Employee = player[1]
            Employee.job = json.decode(Employee.job)
            if Employee.job.grade.level > Player.PlayerData.job.grade.level then return end
            MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {target, Employee.job.name})
        end
    end
end)

local function adminRemoveJob(src, id, job)
    local Player = QBCore.Functions.GetPlayer(id)
    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM save_jobs WHERE cid = ? AND job = ?', {cid, job})
    if result[1] then
        MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', {cid, job})
        QBCore.Functions.Notify(src, ('Job: %s was removed from ID: %s'):format(job, id), 'success')
        if Player.PlayerData.job.name == job then
            Player.Functions.SetJob('unemployed', 0)
        end
    else
        QBCore.Functions.Notify(src, 'Player doesn\'t have this job?', 'error')
    end
end

QBCore.Commands.Add('removejob', "Remove a job from the player's multijob.", { { name = 'id', help = 'ID of the player' }, { name = 'job', help = 'Name of Job' } }, true, function(source, args)
    local src = source
    if not args[1] then 
        QBCore.Functions.Notify(src, 'Must provide a player id.', 'error') 
        return 
    end
    if not args[2] then 
        QBCore.Functions.Notify(src, 'Must provide the name of the job to remove from the player.', 'error') 
        return 
    end
    local id = tonumber(args[1])
    local Player = QBCore.Functions.GetPlayer(id)
    if not Player then QBCore.Functions.Notify(src, 'Player not online.', 'error') return end

    adminRemoveJob(src, id, args[2])
end, 'admin')

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    MySQL.query([=[
        CREATE TABLE IF NOT EXISTS `save_jobs` (
            `cid` VARCHAR(100) NOT NULL,
            `job` VARCHAR(100) NOT NULL,
            `grade` INT(11) NOT NULL
        );
    ]=])
end)
