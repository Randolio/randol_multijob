local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('myjobs', function(source, args)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local dutyStatus
    local isDisabled
    if PlayerData.job.onduty then
        dutyStatus = 'On Duty'
        dutyicon = 'fa-solid fa-toggle-on'
    else
        dutyStatus = 'Off Duty'
        dutyicon = 'fa-solid fa-toggle-off'
    end
    local jobMenu = { id = 'job_menu', title = 'My Jobs', options = {} }
    lib.callback('randol_multijob:server:myJobs', false, function(myJobs)
        if myJobs then
            jobMenu.options[#jobMenu.options + 1] = {
                title = 'Toggle Duty',
                description = 'Current Status: '..dutyStatus,
                icon = dutyicon,
                serverEvent = 'QBCore:ToggleDuty',
                args = {},
            }
            for k,v in pairs(myJobs) do
                if PlayerData.job.name == v.job then isDisabled = true else isDisabled = false end
                jobMenu.options[#jobMenu.options + 1] = {
                    title = ''..v.jobLabel,
                    description = 'Grade: '..v.gradeLabel..' ['..tonumber(v.grade)..'] \nSalary: $'..v.salary,
                    icon = 'fa-solid fa-briefcase',
                    arrow = true,
                    disabled = isDisabled,
                    event = 'randol_multijob:client:choiceMenu',
                    args = {jobLabel = v.jobLabel, job = v.job, grade = v.grade},
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
end)

AddEventHandler('randol_multijob:client:deleteJob', function(args)
    TriggerServerEvent('randol_multijob:server:deleteJob', args.job)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    TriggerServerEvent('randol_multijob:server:newJob', JobInfo)
end)