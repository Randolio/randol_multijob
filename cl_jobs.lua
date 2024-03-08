local Config = lib.require('config')

local function showMultijob()
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
                onSelect = function()
                    TriggerServerEvent('QBCore:ToggleDuty')
                    Wait(500)
                    ExecuteCommand('myjobs')
                end,
            },
        },
    }
    local myJobs = lib.callback.await('randol_multijob:server:myJobs', false)
    if next(myJobs) then
        for _, job in ipairs(myJobs) do
            local isDisabled = PlayerData.job.name == job.job
            jobMenu.options[#jobMenu.options + 1] = {
                title = job.jobLabel,
                description = ('Grade: %s [%s]\nSalary: $%s'):format(job.gradeLabel, tonumber(job.grade), job.salary),
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
end

AddEventHandler('randol_multijob:client:choiceMenu', function(args)
    local displayChoices = {
        id = 'choice_menu',
        title = 'Job Actions',
        menu = 'job_menu',
        options = {
            {
                title = 'Switch Job',
                description = ('Switch your job to: %s'):format(args.jobLabel),
                icon = 'fa-solid fa-circle-check',
                onSelect = function()
                    TriggerServerEvent('randol_multijob:server:changeJob', args.job, args.grade)
                    Wait(100)
                    ExecuteCommand('myjobs')
                end,
            },
            {
                title = 'Delete Job',
                description = ('Delete the selected job: %s'):format(args.jobLabel),
                icon = 'fa-solid fa-trash-can',
                onSelect = function()
                    TriggerServerEvent('randol_multijob:server:deleteJob', args.job)
                    Wait(100)
                    ExecuteCommand('myjobs')
                end,
            },
        }
    }
    lib.registerContext(displayChoices)
    lib.showContext('choice_menu')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    TriggerServerEvent('randol_multijob:server:newJob', JobInfo)
end)

RegisterCommand('myjobs', showMultijob, false)
RegisterKeyMapping('myjobs', 'Multi Job', 'keyboard', 'F10')