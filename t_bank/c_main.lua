local ESX = exports['es_extended']:getSharedObject()


-- 
-- Functions
-- 
local function Menus(type)
    if type == 1 then -- Käteiseltä pankkiin talletus
        local talleta = lib.inputDialog(T.label.title_deposit, {
            { type = "number", label = T.label.howMany, icon = 'hand-holding-dollar', required = true },
        })

        if talleta then
            local amount = talleta[1]

            lib.callback.await('t_bank:DepositMoney', source, amount)
            lib.showContext('bank')    
        end
    elseif type == 2 then -- Panksita käteiselle nosto
        local nosta = lib.inputDialog(T.label.title_withdraw, {
            { type = 'number', label = T.label.howmany, icon = 'sack-dollar', required = true}
        })

        if nosta then
            local amount = nosta[1]

            lib.callback.await('t_bank:WithrawMoney', source, amount)
            lib.showContext('bank')    
        end
    elseif type == 3 then -- Tilisiirto
        local siirto = lib.inputDialog(T.label.title_transfer, {
            { type = 'number', label = T.label.playerID, required = true, icon = 'user' },
            { type = 'number', label = T.label.amountofmoney, required = true, icon = 'money-bill-transfer' },
        })

        if siirto then
            local id = siirto[1]
            local amount = siirto[2]

            lib.callback.await('t_bank:TrasferMoney', source, id, amount)
            lib.showContext('bank')    
        end
    end
end

local function openBank()
    lib.registerContext({
        id = 'bank',
        title = T.label.title,
        onExit = function()
            ClearPedTasks(cache.ped)
        end,
        options = {
            {
                title = T.label.balance,
                description = T.label.balance_des,
                icon = 'list',
                arrow = true,
                onSelect = function()
                    lib.callback.await('t_bank:CheckBalance', source)
                end
            },
            {
                title = T.label.deposit,
                description = T.label.deposit_des,
                icon = 'hand-holding-dollar',
                arrow = true,
                onSelect = function()
                    Menus(1)
                end
            },
            {
                title = T.label.withdraw,
                icon = 'sack-dollar',
                description = T.label.withdraw_des,
                arrow = true,
                onSelect = function()
                    Menus(2)
                end
            },
            {
                title = T.label.transfer,
                icon = 'money-bill-transfer',
                description = T.label.transfer_des,
                arrow = true,
                onSelect = function()
                    Menus(3)
                end
            }
        }
    })
    lib.showContext('bank')    
end

-- 
-- Events
-- 
RegisterNetEvent('t_bank:ShowBalance')
AddEventHandler('t_bank:ShowBalance', function(bank, cash)
    lib.registerContext({
        id = 'balanceCheck',
        title = T.label.balance_title,
        options = {
            {
                title = T.label.bank ..bank.. '€',
                icon = 'piggy-bank'
            },
            {
                title = T.label.cash ..cash.. '€',
                icon = 'wallet',
            },
            {
                title = T.label.back,
                icon = 'xmark',
                arrow = true,
                onSelect = function()
                    lib.hideContext('balanceCheck')
                    lib.showContext('bank')    
                end
            }
        }
    })
    lib.showContext('balanceCheck')  
end)

-- 
-- ATM
-- 
exports.ox_target:addModel(T.atm_Hash, {
    {
        label = T.label.atm,
        icon = 'fa-solid fa-piggy-bank',
        distance = 1.5,
        canInteract = function()
            return not cache.vehicle
        end,
        onSelect = function()
            TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_ATM', 0, true)
            local openingBank = lib.progressCircle({
                label = T.label.openingBank,
                position = 'bottom',
                duration = 4 * 1000,
                allowCuffed = false,
                allowFalling = false,
                allowRagdoll = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                }
            })

            if openingBank then
                openBank()
            end
        end
    }
})

-- 
-- Bank locations
--
for k,v in ipairs(T.banks) do
    local model = v.ped
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local entity = CreatePed(0, model, v.pos, false, false)
    SetEntityAsMissionEntity(entity, true, false)
    SetPedRelationshipGroupHash(entity, GetHashKey("PLAYER"))
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    DisablePedPainAudio(entity, true)
    StopPedSpeaking(entity, true)
    SetPedCombatMovement(entity, true)
    SetPedAsEnemy(entity, false)
    TaskSetBlockingOfNonTemporaryEvents(entity, true)
    SetPedDiesWhenInjured(entity, false)
    SetPedCanPlayAmbientAnims(entity, true)
    SetPedCanRagdollFromPlayerImpact(entity, false)
    exports.ox_target:addBoxZone({
        coords = v.target,
        size = vec3(1, 1, 1),
        rotation = 0.5,
        options = {
            {
                label = v.label,
                distance = 1.5,
                icon = 'fa-solid fa-piggy-bank',
                canInteract = function ()
                    return not cache.vehicle
                end,
                onSelect = function()
                    TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_ATM', 0, true)
                    local openingBank = lib.progressCircle({
                        label = T.label.openingBank,
                        position = 'bottom',
                        duration = 4 * 1000,
                        allowCuffed = false,
                        allowFalling = false,
                        allowRagdoll = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true,
                        }
                    })

                    if openingBank then
                        openBank()
                    end
                end
            }
        }
    })

    if v.showBlip == true then
        local blip = AddBlipForCoord(v.target)
        SetBlipSprite (blip, 431) 
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, 0.5)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(v.label)
        EndTextCommandSetBlipName(blip)
    end
end