local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('myjobs', function(source, args)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local dutyStatus = PlayerData.job.onduty and 'On Duty' or 'Off Duty'
    local dutyIcon = PlayerData.job.onduty and 'fa-solid fa-toggle-on' or 'fa-solid fa-toggle-off'
    local colorIcon = PlayerData.job.onduty and '#5ff5b4' or 'red'
    local jobMenu = {
        id = 'job_menu',
        title = 'My Jobs',
        options = {
            {
                title = 'Toggle Duty',
                description = 'Current Status: ' .. dutyStatus,
                icon = dutyIcon,
                iconColor = colorIcon,
                event = 'randol_multijob:client:toggleDuty',
                args = {},
            },
        },
    }
    lib.callback('randol_multijob:server:myJobs', false, function(myJobs)
        if myJobs then
            for _, job in ipairs(myJobs) do
                local isDisabled = PlayerData.job.name == job.job
                jobMenu.options[#jobMenu.options + 1] = {
                    title = job.jobLabel,
                    description = 'Grade: ' .. job.gradeLabel .. ' [' .. tonumber(job.grade) .. ']\nSalary: $' .. job.salary,
                    icon = Config.JobIcons[job.job] or 'fa-solid fa-briefcase',
                    arrow = true,
                    disabled = isDisabled,
                    event = 'randol_multijob:client:choiceMenu',
                    args = {jobLabel = job.jobLabel, job = job.job, grade = job.grade},
                }
            end
            lib.registerContext(jobMenu)
            lib.showContext('job_menu')
        end
    end)
end)

RegisterKeyMapping('myjobs', 'Multi Job', 'keyboard', 'F10')

AddEventHandler('randol_multijob:client:choiceMenu', function(args)
    local displayChoices = {
        id = 'choice_menu',
        title = 'Job Actions',
        menu = 'job_menu',
        options = {
            {
                title = 'Switch Job',
                description = 'Switch your job to: '..args.jobLabel,
                icon = 'fa-solid fa-circle-check',
                event = 'randol_multijob:client:changeJob',
                args = {job = args.job, grade = args.grade}
            },
            {
                title = 'Delete Job',
                description = 'Delete the selected job: '..args.jobLabel,
                icon = 'fa-solid fa-trash-can',
                event = 'randol_multijob:client:deleteJob',
                args = {job = args.job}
            },
        }
    }
    lib.registerContext(displayChoices)
    lib.showContext('choice_menu')
end)

AddEventHandler('randol_multijob:client:changeJob', function(args)
    TriggerServerEvent('randol_multijob:server:changeJob', args.job, args.grade)
    Wait(100)
    ExecuteCommand('myjobs')
end)

AddEventHandler('randol_multijob:client:deleteJob', function(args)
    TriggerServerEvent('randol_multijob:server:deleteJob', args.job)
    Wait(100)
    ExecuteCommand('myjobs')
end)

AddEventHandler('randol_multijob:client:toggleDuty', function()
    TriggerServerEvent('QBCore:ToggleDuty')
    Wait(500)
    ExecuteCommand('myjobs')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    TriggerServerEvent('randol_multijob:server:newJob', JobInfo)
end)
