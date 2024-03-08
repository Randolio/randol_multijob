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

RegisterNetEvent('randol_multijob:server:changeJob', function(job)
    local src = source
    local player = qbx:GetPlayer(src)

    if player.PlayerData.job.name == job then 
        qbx:Notify(src, 'Your current job is already set to this.', 'error') 
        return 
    end

    local jobInfo = sharedJobs[job]
    if not jobInfo then 
        qbx:Notify(src, 'Invalid job.', 'error') 
        return 
    end

    local cid = player.PlayerData.citizenid
    local canSet = canSetJob(player, job)

    if not canSet then return end

    qbx:SetPlayerPrimaryJob(cid, job)
    qbx:Notify(src, ('Your job is now: %s'):format(jobInfo.label))
end)


RegisterNetEvent('randol_multijob:server:deleteJob', function(job)
    local src = source
    local player = qbx:GetPlayer(src)
    qbx:RemovePlayerFromJob(player.PlayerData.citizenid, job)
    qbx:Notify(src, ('You deleted %s job from your menu.'):format(sharedJobs[job].label))
end)