# Randolio: Multijob (QBX Branch)

A multi management script for qbox using [**ox_lib**](https://github.com/overextended/ox_lib/releases/tag/v3.1.4)

* Default keybind to open is **F10**.
* Now supports multi-gang management too.

![View Jobs](https://i.imgur.com/R5ln3nt.png)
![Front Menu](https://i.imgur.com/I7YUOE6.png)
![View Gangs](https://i.imgur.com/Qxfv7fD.png)

**Note*: Make sure your qbx_core is up to date to the point where you see these 4 at the top of your qbx_core/server/player.lua:

```lua
local maxJobsPerPlayer = GetConvarInt('qbx:max_jobs_per_player', 1)
local maxGangsPerPlayer = GetConvarInt('qbx:max_gangs_per_player', 1)
local setJobReplaces = GetConvar('qbx:setjob_replaces', 'true') == 'true'
local setGangReplaces = GetConvar('qbx:setgang_replaces', 'true') == 'true'
```
PR relating to the above is here: https://github.com/Qbox-project/qbx_core/pull/409/files

To make the multijob function correctly, you'll need these convars in your server.cfg. Number of jobs/gangs can be adjusted to whatever suits you but it's gotta be higher than 1 otherwise the multijob is useless.

```
set qbx:max_jobs_per_player 5 # Sets the number of jobs per player
set qbx:max_gangs_per_player 5 # Sets the number of gangs per player
set qbx:setjob_replaces "false"
set qbx:setgang_replaces "false"
```
