local Config = lib.require('config')

local function canSetJob(player, jobName)
    local jobs = player.PlayerData.jobs
    for job, _ in pairs(jobs) do
        if job == jobName then
            return true
        end
    end
    return false
end

local function canSetGang(player, gangName)
    local gangs = player.PlayerData.gangs
    for gang, _ in pairs(gangs) do
        if gang == gangName then
            return true
        end
    end
    return false
end

RegisterNetEvent('randol_multijob:server:changeJob', function(job)
    local src = source
    local player = qbx:GetPlayer(src)

    if player.PlayerData.job.name == job then 
        qbx:Notify(src, 'Your current job is already set to this.', 'error') 
        return 
    end

    local jobInfo = qbx:GetJob(job)
    if not jobInfo then 
        qbx:Notify(src, 'Invalid job.', 'error') 
        return 
    end

    local cid = player.PlayerData.citizenid
    local canSet = canSetJob(player, job)

    if not canSet then return end

    qbx:SetPlayerPrimaryJob(cid, job)
    qbx:Notify(src, ('Your job is now: %s'):format(jobInfo.label))
    player.Functions.SetJobDuty(false)
end)

RegisterNetEvent('randol_multijob:server:changeGang', function(gang)
    local src = source
    local player = qbx:GetPlayer(src)

    if player.PlayerData.gang.name == gang then 
        qbx:Notify(src, 'Your current gang is already set to this.', 'error') 
        return 
    end

    local gangInfo = qbx:GetGang(gang)
    if not gangInfo then 
        qbx:Notify(src, 'Invalid gang.', 'error') 
        return 
    end

    local cid = player.PlayerData.citizenid
    local canSet = canSetGang(player, gang)

    if not canSet then return end

    qbx:SetPlayerPrimaryGang(cid, gang)
    qbx:Notify(src, ('Your gang is now: %s'):format(gangInfo.label))
end)

RegisterNetEvent('randol_multijob:server:deleteJob', function(job)
    local src = source
    local player = qbx:GetPlayer(src)
    local jobInfo = qbx:GetJob(job)

    if not jobInfo then 
        qbx:Notify(src, 'Invalid job.', 'error') 
        return 
    end
    
    qbx:RemovePlayerFromJob(player.PlayerData.citizenid, job)
    qbx:Notify(src, ('You deleted %s job from your menu.'):format(jobInfo.label))
end)

RegisterNetEvent('randol_multijob:server:deleteGang', function(gang)
    local src = source
    local player = qbx:GetPlayer(src)
    local gangInfo = qbx:GetGang(gang)

    if not gangInfo then 
        qbx:Notify(src, 'Invalid gang.', 'error') 
        return 
    end
    
    qbx:RemovePlayerFromGang(player.PlayerData.citizenid, gang)
    qbx:Notify(src, ('You deleted %s gang from your menu.'):format(gangInfo.label))
end)