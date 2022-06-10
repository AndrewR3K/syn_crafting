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
local keyopen = false
local craftingx = Config.crafting

-- Props
local mainprop
local subprop

-- TODO: Anstract animations to its own helper folder/file
local Anims = {
    ["craft"] = {
        dict = "mech_inventory@crafting@fallbacks",
        name = "full_craft_and_stow", 
        flag = 27,
        type = 'standard'
    },
    ["spindlecook"] = {
        dict = "amb_camp@world_camp_fire_cooking@male_d@wip_base",
        name = "wip_base",
        flag = 17,
        type = 'standard',
        prop = {
            model = 'p_stick04x',
            coords = {
                x = 0.2, 
                y = 0.04,
                z = 0.12,
                xr = 170.0,
                yr = 50.0,
                zr = 0.0
            },
            bone = 'SKEL_R_Finger13',
            subprop = {
                model = 's_meatbit_chunck_medium01x',
                coords = {
                    x = -0.30, 
                    y = -0.08,
                    z = -0.30,
                    xr = 0.0,
                    yr = 0.0,
                    zr = 70.0
                }
            }
        }
    },
    ["knifecooking"] = {
        dict = "amb_camp@world_player_fire_cook_knife@male_a@wip_base",
        name = "wip_base", 
        flag = 17,
        type = 'standard',
        prop = {
            model = 'w_melee_knife06',
            coords = {
                x = -0.01, 
                y = -0.02,
                z = 0.02,
                xr = 190.0,
                yr = 0.0,
                zr = 0.0
            },
            bone = 'SKEL_R_Finger13',
            subprop = {
                model = 'p_redefleshymeat01xa',
                coords = {
                    x = 0.00, 
                    y = 0.02,
                    z = -0.20,
                    xr = 0.0,
                    yr = 0.0,
                    zr = 0.0
                }
            }
        }
    },
    ["campfire"] = {
        dict = "script_campfire@lighting_fire@male_male",
        name = "light_fire_b_p2_male_b", 
        flag = 17,
        type = 'standard'
	}
}

keys = Config.keys

function playAnimation(ped, anim)
    local animation = Anims[anim]
	if not DoesAnimDictExist(animation.dict) then
		return
	end
    
    if animation.prop then
        local coords = GetEntityCoords(ped)
        mainprop = CreateObject(animation.prop.model, coords.x, coords.y, coords.z, true, true, false, false, true)
        local boneIndex = GetEntityBoneIndexByName(ped, animation.prop.bone)
        AttachEntityToEntity(mainprop, ped, boneIndex, animation.prop.coords.x, animation.prop.coords.y, animation.prop.coords.z, animation.prop.coords.xr, animation.prop.coords.yr, animation.prop.coords.zr, true, true, false, true, 1, true)
        
        if animation.prop.subprop then
            local pcoords = GetEntityCoords(subprop)
            subprop = CreateObject(animation.prop.subprop.model, pcoords.x, pcoords.y, pcoords.z, true, true, false, false, true)
            AttachEntityToEntity(subprop, ped, boneIndex, animation.prop.subprop.coords.x, animation.prop.subprop.coords.y, animation.prop.subprop.coords.z, animation.prop.subprop.coords.xr, animation.prop.subprop.coords.yr, animation.prop.subprop.coords.zr, true, true, false, true, 1, true)
        end
    end


    if animation.type == 'scenario' then
        TaskStartScenarioInPlace(ped, GetHashKey(animation.hash), 12000, true, false, false, false)
    elseif animation.type == 'standard' then
        RequestAnimDict(animation.dict)

        while not HasAnimDictLoaded(animation.dict) do
            Wait(0)
        end
        TaskPlayAnim(ped, animation.dict, animation.name, 1.0, 1.0, -1, animation.flag, 1.0, false, false, false, '', false)
    end
end

function endAnimation(anim) 
    local animation = Anims[anim]
    RemoveAnimDict(animation.dict)
    StopAnimTask(PlayerPedId(), animation.dict, animation.name, 1.0)

    if mainprop then
        DeleteObject(mainprop)    
    end

    if subprop then
        DeleteObject(subprop)
    end
end

function endAnimations()
    ClearPedTasksImmediately(PlayerPedId())
end

function whenKeyJustPressed(key)
    if Citizen.InvokeNative(0x580417101DDB492F, 0, key) then
        return true
    else
        return false
    end
end

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

function forceRestScenario(val)
    Citizen.InvokeNative(0xE5A3DD2FF84E1A4B, val) 
end

function disableAllPrompts()
    Citizen.InvokeNative(0xF1622CE88A1946FB) 
end

function openUI()
    local allText = _all()

    if allText then
        uiopen = true
        local playerPed = PlayerPedId()
        forceRestScenario(true)
        

        
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

        -- Hide the native rest prompts while the crafting menu is open
        if (uiopen == true or iscrafting == true) then
            disableAllPrompts()
        end
    end
end)

RegisterNUICallback('bcc-craft-close', function(args, cb)
    SetNuiFocus(false, false)
    uiopen = false
    forceRestScenario(false)

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
AddEventHandler("syn:crafting", function(animation)
    local playerPed = PlayerPedId()
    iscrafting = true

    -- Sent NUI a message to hide its UI while the crafting animations play out
    SendNUIMessage({
        type = 'bcc-craft-animate'
    })
    SetNuiFocus(true, false)
    
    if not animation then
        animation = "craft"
    end

    playAnimation(playerPed, animation)
    exports['progressBars']:startUI(Config.CraftTime, _U('Crafting'))
    
    Wait(Config.CraftTime)
    
    endAnimation(animation)
    
    TriggerEvent("vorp:TipRight", _U('FinishedCrafting'), 4000)
    SetNuiFocus(true, true)

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
    playAnimation(playerPed, "campfire")
    
    exports['progressBars']:startUI(20000, _U('PlaceFire'))
    Citizen.Wait(20000)
    endAnimation("campfire")
    endAnimations() 
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

RegisterCommand("testanimation", function(source, args, rawCommand)
    local playerPed = PlayerPedId()

    playAnimation(playerPed, args[1])
    Citizen.Wait(8000)

    endAnimation(args[1])
    -- endAnimations()
end, false)

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
