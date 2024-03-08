local Config = lib.require('config')

local function showMultijob()
    local PlayerData = QBX.PlayerData
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
                    showMultijob()
                end,
            },
        },
    }

    for job, grade in pairs(PlayerData.jobs) do
        local isDisabled = PlayerData.job.name == job
        local data = sharedJobs[job]
        jobMenu.options[#jobMenu.options + 1] = {
            title = data.label,
            description = ('Grade: %s [%s]\nSalary: $%s'):format(data.grades[grade].name, grade, data.grades[grade].payment),
            icon = Config.JobIcons[job] or 'fa-solid fa-briefcase',
            arrow = true,
            disabled = isDisabled,
            event = 'randol_multijob:client:choiceMenu',
            args = {jobLabel = data.label, job = job, grade = grade},
        }
    end
    lib.registerContext(jobMenu)
    lib.showContext('job_menu')
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
                    TriggerServerEvent('randol_multijob:server:changeJob', args.job)
                    Wait(100)
                    showMultijob()
                end,
            },
            {
                title = 'Delete Job',
                description = ('Delete the selected job: %s'):format(args.jobLabel),
                icon = 'fa-solid fa-trash-can',
                onSelect = function()
                    TriggerServerEvent('randol_multijob:server:deleteJob', args.job)
                    Wait(100)
                    showMultijob()
                end,
            },
        }
    }
    lib.registerContext(displayChoices)
    lib.showContext('choice_menu')
end)

lib.addKeybind({
    name = 'myjobs',
    description = 'Multi Job',
    defaultKey = 'F10',
    onPressed = function(self)
        showMultijob()
    end
})