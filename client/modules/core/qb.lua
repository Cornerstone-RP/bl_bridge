local coreName = 'qb-core'
if GetResourceState(coreName) ~= 'started' then
    error('The imported file from the chosen framework isn\'t starting')
    return
end

local Core = {}
local retreiveStringIndexedData = require 'utils'.retreiveStringIndexedData

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('bl_bridge:client:playerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('bl_bridge:client:playerUnloaded')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    TriggerEvent('bl_bridge:client:jobUpdated', { name = job.name, label = job.label, onDuty = job.onduty, isBoss = job.isboss, grade = { name = job.grade.level, label = job.grade.name, salary = job.payment } })
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    TriggerEvent('bl_bridge:client:gangUpdated', { name = gang.name, label = gang.label, isBoss = gang.isboss, grade = { name = gang.grade.level, label = gang.grade.label } })
end)

local shared = exports[coreName]:GetCoreObject()

local coreFunctionsOverride = {
    Functions = {
        playerData = {
            originalMethod = 'GetPlayerData',
            modifier = {
                executeFun = true,
                effect = function(originalFun)
                    lib.waitFor(function()if LocalPlayer.state.isLoggedIn then return true end end, nil, 10000)
                    local data = originalFun()
                    local job = data.job
                    local gang = data.gang
                    return {
                        cid = data.citizenid,
                        money = data.money,
                        inventory = type(data.inventory) == 'string' and json.decode(data.inventory) or data.inventory,
                        job = { name = job.name, label = job.label, onDuty = job.onduty, isBoss = job.isboss, grade = { name = job.grade.level, label = job.grade.name, salary = job.payment } },
                        gang = { name = gang.name, label = gang.label, isBoss = gang.isboss, grade = { name = gang.grade.level, label = gang.grade.label } },
                        firstName = data.charinfo.firstname,
                        lastName = data.charinfo.lastname,
                        phone = data.charinfo.phone,
                    }
                end
            }
        },
    },
}

function Core.getPlayerData()
    local wrappedPlayer = retreiveStringIndexedData(shared, coreFunctionsOverride)
    return wrappedPlayer.playerData
end

return Core
