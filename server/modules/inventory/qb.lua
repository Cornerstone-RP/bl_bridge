if GetResourceState('qb-inventory') ~= 'started' and GetResourceState('ps-inventory') ~= 'started' then
    error('The imported file from the chosen framework isn\'t starting')
    return
end

local overrideFunction = {}
local registeredInventories = {}
overrideFunction.methods = {
    Functions = {
        addItem = {
            originalMethod = 'AddItem',
            modifier = {
                effect = function(originalFun, name, amount, metadata, slot)
                    return originalFun(name, amount, slot, metadata)
                end
            }
        },
        removeItem = {
            originalMethod = 'RemoveItem',
        },
        getItem = {
            originalMethod = 'GetItemByName',
        }
    },
    PlayerData = {
        items = {
            originalMethod = 'items',
        },
    }
}

function overrideFunction.registerInventory(id, data)
    local type, name, items, slots, maxWeight in data

    for k,v in ipairs(items) do
        v.amount = v.amount or 10
        v.slot = k
    end

    registeredInventories[('%s-%s'):format(type, id)] = {
        label     = name,
        items     = items,
        slots     = slots or #items,
        maxweight = maxWeight
    }
end

lib.callback.register('bl_bridge:validInventory', function(_, invType, invId)
    local inventory = registeredInventories[('%s-%s'):format(invType, invId)]
    if not inventory then return end
    return inventory
end)

return overrideFunction