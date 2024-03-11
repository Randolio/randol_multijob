local Config = lib.require('config')

local function viewGangs()
    local sharedGangs = qbx:GetGangs()
    local PlayerData = QBX.PlayerData
    local opts = {}
    for gang, grade in pairs(PlayerData.gangs) do
        local isDisabled = PlayerData.gang.name == gang
        local data = sharedGangs[gang]
        opts[#opts + 1] = {
            title = data.label,
            description = ('Grade: %s [%s]'):format(data.grades[grade].name, grade),
            icon = Config.GangIcons[gang] or 'fa-solid fa-user-ninja',
            arrow = true,
            disabled = isDisabled,
            event = 'randol_multijob:client:choiceMenu',
            args = {gangLabel = data.label, gang = gang, grade = grade},
        }
    end
    lib.registerContext({
        id = 'gang_menu',
        menu = 'multi_main',
        title = 'My Gangs',
        options = opts
    })
    lib.showContext('gang_menu')
end

local function viewJobs()
    local sharedJobs = qbx:GetJobs()
    local PlayerData = QBX.PlayerData
    local dutyStatus = PlayerData.job.onduty and 'On Duty' or 'Off Duty'
    local dutyIcon = PlayerData.job.onduty and 'fa-solid fa-toggle-on' or 'fa-solid fa-toggle-off'
    local colorIcon = PlayerData.job.onduty and '#5ff5b4' or 'red'
    local jobMenu = {
        id = 'job_menu',
        title = 'My Jobs',
        menu = 'multi_main',
        options = {
            {
                title = 'Toggle Duty',
                description = 'Current Status: ' .. dutyStatus,
                icon = dutyIcon,
                iconColor = colorIcon,
                onSelect = function()
                    TriggerServerEvent('QBCore:ToggleDuty')
                    Wait(500)
                    viewJobs()
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

local function showMainMenu()
    local mainMenu = {
        id = 'multi_main',
        title = 'Management Menu',
        options = {
            {
                title = 'Jobs',
                description = 'View all your current jobs.',
                icon = 'fa-solid fa-briefcase',
                arrow = true,
                onSelect = function()
                    viewJobs()
                end,
            },
            {
                title = 'Gangs',
                description = 'View all your current gangs.',
                icon = 'fa-solid fa-user-ninja',
                arrow = true,
                onSelect = function()
                    viewGangs()
                end,
            },
        },
    }
    lib.registerContext(mainMenu)
    lib.showContext('multi_main')
end

AddEventHandler('randol_multijob:client:choiceMenu', function(args)
    local displayChoices = {}
    if args.job then
        displayChoices = {
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
                        viewJobs()
                    end,
                },
                {
                    title = 'Delete Job',
                    description = ('Delete the selected job: %s'):format(args.jobLabel),
                    icon = 'fa-solid fa-trash-can',
                    onSelect = function()
                        TriggerServerEvent('randol_multijob:server:deleteJob', args.job)
                        Wait(100)
                        viewJobs()
                    end,
                },
            }
        }
    else
        displayChoices = {
            id = 'choice_menu',
            title = 'Gang Actions',
            menu = 'gang_menu',
            options = {
                {
                    title = 'Switch Gang',
                    description = ('Switch your gang to: %s'):format(args.gangLabel),
                    icon = 'fa-solid fa-circle-check',
                    onSelect = function()
                        TriggerServerEvent('randol_multijob:server:changeGang', args.gang)
                        Wait(100)
                        viewGangs()
                    end,
                },
                {
                    title = 'Delete Gang',
                    description = ('Delete the selected gang: %s'):format(args.gangLabel),
                    icon = 'fa-solid fa-trash-can',
                    onSelect = function()
                        TriggerServerEvent('randol_multijob:server:deleteGang', args.gang)
                        Wait(100)
                        viewGangs()
                    end,
                },
            }
        }
    end
    lib.registerContext(displayChoices)
    lib.showContext('choice_menu')
end)

lib.addKeybind({
    name = 'multi',
    description = 'Multi Management',
    defaultKey = 'F10',
    onPressed = function(self)
        showMainMenu()
    end
})
