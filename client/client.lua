-- TODO: Better animations/scenario
-- TODO: Abstract functions to a shared functions helper file.

local promptGroup = GetRandomIntInRange(0, 0xffffff)
local CraftPrompt

local iscrafting = false
local propinfo
local loctitle
local type = 0
local campfire = 0
local initialized = false
local uiopen = false

keys = Config.keys

function whenKeyJustPressed(key)
    if Citizen.InvokeNative(0x580417101DDB492F, 0, key) then
        return true
    else
        return false
    end
end

local keyopen = false
local craftingx = Config.crafting
function contains(table, element)
    if table ~= 0 then
        for k, v in pairs(table) do
            if v == element then
                return true
            end
        end
    end
    return false
end

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    SetTextFontForCurrentCommand(15)
    if enableShadow then
        SetTextDropshadow(1, 0, 0, 0, 255)
    end
    DisplayText(str, x, y)
end

function openUI()
    local allText = _all()

    if allText then
        uiopen = true
        SendNUIMessage({
            type = 'bcc-craft-open',
            craftables = Config.crafting,
            categories = Config.categories,
            crafttime = Config.CraftTime,
            style = Config.styles,
            language = allText
        })
        SetNuiFocus(true, true)
    end
end

Citizen.CreateThread(function()
    local str = _U('CraftText')
    CraftPrompt = PromptRegisterBegin()
    PromptSetControlAction(CraftPrompt, keys["G"])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CraftPrompt, str)
    PromptSetEnabled(CraftPrompt, 1)
    PromptSetVisible(CraftPrompt, 1)
    PromptSetStandardMode(CraftPrompt, 1)
    PromptSetGroup(CraftPrompt, promptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CraftPrompt, true)
    PromptRegisterEnd(CraftPrompt)
    
    while true do
        Citizen.Wait(1)

        -- Check for craftable object starters
        local player = PlayerPedId()
        local Coords = GetEntityCoords(player)
        for k, v in pairs(Config.craftingProps) do
            local campfire = DoesObjectOfTypeExistAtCoords(Coords.x, Coords.y, Coords.z, 1.5, GetHashKey(v), 0) -- prop required to interact
            if campfire ~= false and iscrafting == false and uiopen == false  then

                local label = CreateVarString(10, 'LITERAL_STRING', 'Campfire')
                PromptSetActiveGroupThisFrame(promptGroup, label)

                if Citizen.InvokeNative(0xC92AC953F0A982AE, CraftPrompt) then
                    TriggerServerEvent('syn:findjob')
                    Wait(500)
                    if keyopen == false then
                        propinfo = v
                        loctitle = 0
                        openUI()
                    end
                end
            end
        end

        -- Check for craftable location starters
        for k, loc in pairs(Config.locations) do
            local dist = GetDistanceBetweenCoords(loc.x, loc.y, loc.z, Coords.x, Coords.y, Coords.z, 0)
            if 2.5 > dist and uiopen == false then
                local label = CreateVarString(10, 'LITERAL_STRING', loc.name)
                PromptSetActiveGroupThisFrame(promptGroup, label)

                if Citizen.InvokeNative(0xC92AC953F0A982AE, CraftPrompt) then
                    TriggerServerEvent('syn:findjob')
                    Wait(500)
                    if keyopen == false then
                        loctitle = k
                        openUI()
                    end
                end
            end
        end
    end
end)

RegisterNUICallback('bcc-craft-close', function(args, cb)
    SetNuiFocus(false, false)
    uiopen = false
    cb('ok')
end)

RegisterNUICallback('bcc-openinv', function(args, cb)
    TriggerServerEvent('syn:openInv')
    cb('ok')
end)

RegisterNUICallback('bcc-craftevent', function(args, cb)

    local count = tonumber(args.quantity)
    if count ~= nil and count ~= 'close' and count ~= '' and count ~= 0 then
        TriggerServerEvent('syn:craftingalg', args.craftable, count)
        cb('ok')
    else
        TriggerEvent("vorp:TipBottom", _U('InvalidAmount'), 4000)
        cb('invalid')
    end
end)

RegisterNetEvent("syn:crafting")
AddEventHandler("syn:crafting", function()
    local playerPed = PlayerPedId()
    iscrafting = true
    
    -- Sent NUI a message to hide its UI while the crafting animations play out
    SendNUIMessage({
        type = 'bcc-craft-animate'
    })
    
    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), Config.CraftTime, true, false, false, false)
    exports['progressBars']:startUI(Config.CraftTime, _U('Crafting'))
    
    Citizen.Wait(Config.CraftTime)
    TriggerEvent("vorp:TipRight", _U('FinishedCrafting'), 4000)
    keyopen = false
    iscrafting = false
end)

function placeCampfire()
    if campfire ~= 0 then
        SetEntityAsMissionEntity(campfire)
        DeleteObject(campfire)
        campfire = 0
    end

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 30000, true, false, false, false)
    exports['progressBars']:startUI(30000, _U('PlaceFire'))
    Citizen.Wait(30000)
    
    ClearPedTasksImmediately(PlayerPedId())
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, -1.55))
    
    local prop = CreateObject(GetHashKey(Config.PlaceableCampfire), x, y, z, true, false, true)
    SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
    PlaceObjectOnGroundProperly(prop)
    campfire = prop
end

RegisterNetEvent('syn:campfire')
AddEventHandler('syn:campfire', function()
    placeCampfire()
end)

if Config.commands.campfire == true then
    RegisterCommand("campfire", function(source, args, rawCommand)
        placeCampfire()
    end, false)
end

if Config.commands.extinguish == true then
    RegisterCommand('extinguish', function(source, args, rawCommand)
        if campfire ~= 0 then
            SetEntityAsMissionEntity(campfire)
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), 7000, true, false, false, false)
            TriggerEvent("vorp:TipRight", _U('PutOutFire'), 7000)
            Wait(7000)
            ClearPedTasksImmediately(PlayerPedId())
            DeleteObject(campfire)
            campfire = 0            
        end
    end, false)
end
