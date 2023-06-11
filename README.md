# angelicxs-TargetPing

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
