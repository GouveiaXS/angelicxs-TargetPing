----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
----------------------------------------------------------------------

--[[
------------------------INSTAL NOTES----------------------------------

Go to your radio script and put the following event in the Radio Event that updates the client's current radio channel. Ensure that you change the variable newRadioChannel to whatever variable is being sent.
	TriggerEvent('angelicxs-PingTarget:RadioUpdate', newRadioChannel)

Go to the server side of your radio script and add this event to the bottom of it:
	RegisterNetEvent('angelicxs-PingTarget:SendPing', function(radio, coords, entity)
		TriggerClientEvent('angelicxs-PingTarget:ReceivePing', -1, radio, coords, entity)
	end)
------------------------INSTAL NOTES----------------------------------
]]

Config = {}

Config.PingDistance = 150 -- How far can the ping be seen from
Config.PingTimer = 5 -- How long the ping lasts in seconds
Config.PingMarker = 21 -- What the ping marker looks like https://docs.fivem.net/docs/game-references/markers/
Config.PingColour = { -- https://www.padpal.ca/permanent-lights-resources/rgb-codes/
    red = 255,
    green = 69,
    blue = 0
}
Config.PingSize = {
    x = 1.0,
    y = 1.0,
    z = 1.0
}
Config.Height = 1.5 -- How high off the object the marker is
Config.PingCommand = 249 -- Button to press to ping when aiming (default G) https://docs.fivem.net/docs/game-references/controls/
Config.PingProtection = 0 -- Time in seconds before another ping can be sent
Config.RequireAimDownSights = true -- If false players can ping without aiming down weapon sights

local CurrentRadio = nil

AddEventHandler('angelicxs-PingTarget:RadioUpdate', function(newchannel)
    CurrentRadio = newchannel
    if CurrentRadio == 0 then CurrentRadio = nil end
end)

RegisterNetEvent('angelicxs-PingTarget:ReceivePing', function(radio, coords, entity)
    local timer = (Config.PingTimer*100)
    if CurrentRadio == nil then return end
    while CurrentRadio == radio do 
        local pCoords = GetEntityCoords(PlayerPedId())
        local dist = #(pCoords - coords)
        timer = timer-1
        if dist <= Config.PingDistance then
            if entity then
                coords = GetEntityCoords(entity)
            end
            DrawMarker(Config.PingMarker, coords.x, coords.y, (coords.z+Config.Height), 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, Config.PingSize.x, Config.PingSize.y, Config.PingSize.z, Config.PingColour.red, Config.PingColour.green, Config.PingColour.blue, 255, true, true, 2, 0.0, false, false, false)
        end
        if timer <= 0 then break end
        Wait(1)
    end
end)

CreateThread(function()
    while true do
        local Sleep = 1000
        if IsAimCamActive() or not Config.RequireAimDownSights then
            Sleep = 0
            local pingProtection = false
            local targ, coord2
            local coord, distance, entityHit = RaycastCamera()
            local targ, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if targ then
                local distance2 = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity))
                if distance2 < distance then
                    distance = distance2
                    coord = GetEntityCoords(entity)
                end 
            end
            if distance <= Config.PingDistance then
                if IsControlJustReleased(0,Config.PingCommand) and not pingProtection then
                    pingProtection = true
                    TriggerServerEvent('angelicxs-PingTarget:SendPing', CurrentRadio, coord, entity)
                    Wait(Config.PingProtection*1000)
                    pingProtection = false
                end
            end
        end
        Wait(Sleep)
    end
end)




---------------------------------------
--- Source: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/scripting_gta.lua
--- Credits to gottfriedleibniz
-- Cache common functions
local glm = require 'glm'

local glm_rad = glm.rad
local glm_quatEuler = glm.quatEulerAngleZYX
local glm_rayPicking = glm.rayPicking

-- Cache direction vectors
local glm_up = glm.up()
local glm_forward = glm.forward()

function ScreenPositionToCameraRay()
    local pos = GetFinalRenderedCamCoord()
    local rot = glm_rad(GetFinalRenderedCamRot(2))
    local q = glm_quatEuler(rot.z, rot.y, rot.x)
    return pos, glm_rayPicking(
        q * glm_forward,
        q * glm_up,
        glm_rad(GetFinalRenderedCamFov()),
        GetAspectRatio(true),
        0.10000, -- GetFinalRenderedCamNearClip(),
        10000.0, -- GetFinalRenderedCamFarClip(),
        0, 0
    )
end
--------------------- Source: https://github.com/qbcore-framework/qb-target/blob/ca6615462ae620356692158fe4bbc760a7d33f52/client.lua
function RaycastCamera(flag, playerCoords)
    flag = 30
	if not playerPed then playerPed = PlayerPedId() end
	if not playerCoords then playerCoords = GetEntityCoords(playerPed) end

	local rayPos, rayDir = ScreenPositionToCameraRay()
	local destination = rayPos + 16 * rayDir
	local rayHandle = StartShapeTestLosProbe(rayPos.x, rayPos.y, rayPos.z, destination.x, destination.y, destination.z, flag or -1, playerPed, 4)

	while true do
		local result, _, endCoords, _, entityHit = GetShapeTestResult(rayHandle)

		if result ~= 1 then
			local distance = playerCoords and #(playerCoords - endCoords)

			if flag == 30 and entityHit then
				entityHit = HasEntityClearLosToEntity(entityHit, playerPed, 7) and entityHit
			end

			return endCoords, distance, entityHit
		end

		Wait(0)
	end
end