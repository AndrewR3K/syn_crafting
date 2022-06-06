-- TODO: Better animations/scenarioa

local iscrafting = false
local propinfo
local loctitle
local type = 0
local campfire = 0
local initialized = false

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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        -- Check for craftable object starters
        local player = PlayerPedId()
        local Coords = GetEntityCoords(player)
        for k, v in pairs(Config.craftingProps) do
            local campfire = DoesObjectOfTypeExistAtCoords(Coords.x, Coords.y, Coords.z, 1.5, GetHashKey(v), 0) -- prop required to interact
            if campfire ~= false and iscrafting == false then
                DrawTxt("Press [~e~G~q~] to Craft", 0.50, 0.95, 0.7, 0.5, true, 255, 255, 255, 255, true)
                if whenKeyJustPressed(keys["G"]) then
                    TriggerServerEvent('syn:findjob')
                    Wait(500)
                    if keyopen == false then
                        propinfo = v
                        loctitle = 0
                        SendNUIMessage({
                            type = 'bcc-craft-open',
                            craftables = Config.crafting,
                            categories = Config.categories,
                            crafttime = Config.CraftTime
                        })
                        SetNuiFocus(true, true)
                    else
                    end
                end
            end
        end

        -- Check for craftable location starters
        for k, v in pairs(Config.locations) do
            local dist = GetDistanceBetweenCoords(v.x, v.y, v.z, Coords.x, Coords.y, Coords.z, 0)
            if 2.5 > dist then
                DrawTxt("Press [~e~G~q~] to Craft", 0.50, 0.95, 0.7, 0.5, true, 255, 255, 255, 255, true)
                if whenKeyJustPressed(keys["G"]) then
                    TriggerServerEvent('syn:findjob')
                    Wait(500)
                    if keyopen == false then
                        loctitle = k
                        SendNUIMessage({
                            type = 'bcc-craft-open',
                            craftables = Config.crafting,
                            categories = Config.categories,
                            crafttime = Config.CraftTime
                        })
                        SetNuiFocus(true, true)
                    else
                    end
                end
            end
        end
    end
end)

RegisterNUICallback('bcc-craft-close', function(args, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('bcc-craftevent', function(args, cb)

    local count = tonumber(args.quantity)
    if count ~= nil and count ~= 'close' and count ~= '' and count ~= 0 then
        TriggerServerEvent('syn:craftingalg', args.craftable, count)
    else
        TriggerEvent("vorp:TipBottom", "Invalid Amount", 4000)
    end

    cb('ok')
end)

RegisterNetEvent("syn:crafting")
AddEventHandler("syn:crafting", function()
    local playerPed = PlayerPedId()
    iscrafting = true
    
    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), Config.CraftTime, true, false, false, false)
    exports['progressBars']:startUI(Config.CraftTime, "Crafting...")
    
    Citizen.Wait(Config.CraftTime)
    TriggerEvent("vorp:TipRight", "You finished crafting", 4000)
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
    exports['progressBars']:startUI(30000, "You're placing a campfire...")
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

    RegisterCommand('dcampfire', function(source, args, rawCommand)
        if campfire ~= 0 then
            SetEntityAsMissionEntity(campfire)
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), 7000, true, false, false, false)
            TriggerEvent("vorp:TipRight", "Putting out the campfire...", 7000)
            Wait(7000)
            ClearPedTasksImmediately(PlayerPedId())
            DeleteObject(campfire)
            campfire = 0            
        end
    end, false)
end
