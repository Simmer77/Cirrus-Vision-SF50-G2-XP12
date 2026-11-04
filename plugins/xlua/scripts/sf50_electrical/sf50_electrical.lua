--[[
*****************************************************************************************
* Script Name:
*
* Script Description:
*
* Author Name:
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       						   COPYRIGHT © 2023
*					 	    L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]



--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is always
a fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you would do fuel = fuel + 3 * SIM_PERIOD.


IN_REPLAY: evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running = find_dataref('sim/operation/prefs/startup_running')
simDR_battery_on = find_dataref('sim/cockpit2/electrical/battery_on')
simDR_battery_amps = find_dataref('sim/cockpit2/electrical/battery_amps')
simDR_generator_on = find_dataref('sim/cockpit/electrical/generator_on')
simDR_bus_volts = find_dataref('sim/cockpit2/electrical/bus_volts')
simDR_bus_load_amps = find_dataref('sim/cockpit2/electrical/bus_load_amps')

simDR_gpu_on = find_dataref('sim/cockpit2/electrical/GPU_generator_on')
simDR_gpu_on_legacy = find_dataref('sim/cockpit/electrical/gpu_on')
simDR_gpu_volts = find_dataref('sim/cockpit2/electrical/GPU_generator_volts')
simDR_gpu_amps = find_dataref('sim/cockpit/electrical/gpu_amps')
simDR_gpu_gen_amps = find_dataref('sim/cockpit2/electrical/GPU_generator_amps')
simDR_override_gpu_volts = find_dataref('sim/operation/override/override_GPU_volts')

simDR_groundspeed = find_dataref('sim/flightmodel/position/groundspeed')
simDR_on_ground = find_dataref('sim/flightmodel2/gear/on_ground[0]')



--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--
simCMD_gpu_on = find_command('sim/electrical/GPU_on')
simCMD_gpu_off = find_command('sim/electrical/GPU_off')
simCMD_gpu_request = find_command('sim/ground_ops/toggle_gpu_request')



--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
sf50DR_init_electrical_AI = create_dataref('laminar/sf50/AI/init_electrical', 'number')





--*************************************************************************************--
--** 				  CREATE READ-WRITE CUSTOM DATAREFS & HANDLERS                   **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--
function sf50_electrical_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_electrical_AI()
	end
end
sf50CMD_electrical_quick_start = create_command('laminar/sf50/ai/electrical_quick_start', 'AI Electrical Quick Start Init', sf50_electrical_quick_start_CMDhandler)




--*************************************************************************************--
--** 				      X-PLANE 'FILTER' COMMANDS & HANDLERS            			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       X-PLANE 'WRAP' COMMANDS & HANDLERS               	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				     X-PLANE 'REPLACE' COMMANDS & HANDLERS              	  	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					          OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_electrical_AI()

    if sf50DR_init_electrical_AI == 1 then	-- Monitor AI for auto-board call

        init_electrical_all_modes()
        init_electrical_CD()

		simDR_battery_on[0] = 0
		simDR_battery_on[1] = 0

		simDR_generator_on[0] = 0
		simDR_generator_on[1] = 0


        sf50DR_init_electrical_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_electrical_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_electrical_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_electrical_all_modes()



end



--===| DEFERRED INITIALIZATION |=========================================================
--function deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
--function deferred_processing() end








--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--

--===| AIRCRAFT LOAD |===================================================================
-- function aircraft_load() end



--===| FLIGHT START |====================================================================
function flight_start()

    -- INITIALIZE ALL MODES -------------------------------------------------------------
    init_electrical_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_electrical_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_electrical_ER()

    end

end



--===| BEFORE PHYSICS |==================================================================
-- function before_physics() end



--===| AFTER PHYSICS |===================================================================
function after_physics()

	init_electrical_AI()
	if battery_on_0 == 1 and avionics_power_on == 0 then
		avionics_power_on = 1
	end

	-- GPU management, bus power supply, and safety auto-disconnect
	if simDR_gpu_on ~= nil and simDR_gpu_on == 1 then
		-- Auto-disconnect if taxiing (groundspeed > 1.5 m/s ~ 3 kts) or airborne
		if (simDR_groundspeed ~= nil and simDR_groundspeed > 1.5) or (simDR_on_ground ~= nil and simDR_on_ground == 0) then
			simDR_gpu_on = 0
			if simDR_gpu_on_legacy ~= nil then simDR_gpu_on_legacy = 0 end
			if simDR_override_gpu_volts ~= nil then simDR_override_gpu_volts = 0 end
			if simDR_gpu_volts ~= nil then simDR_gpu_volts = 0.0 end
			if simDR_gpu_amps ~= nil then simDR_gpu_amps[0] = 0.0 end
			if simDR_gpu_gen_amps ~= nil then simDR_gpu_gen_amps = 0.0 end
			if simCMD_gpu_off ~= nil then
				simCMD_gpu_off:once()
			end
		else
			-- Active GPU Power Supply: enable voltage override & connect 28V
			if simDR_gpu_on_legacy ~= nil and simDR_gpu_on_legacy == 0 then
				simDR_gpu_on_legacy = 1
			end
			if simDR_override_gpu_volts ~= nil and simDR_override_gpu_volts == 0 then
				simDR_override_gpu_volts = 1
			end
			if simDR_gpu_volts ~= nil then
				simDR_gpu_volts = 28.0
			end
			if simCMD_gpu_on ~= nil then
				simCMD_gpu_on:once()
			end

			-- Calculate and deliver current to the aircraft electrical buses
			local current_load = 28.0
			if simDR_bus_load_amps ~= nil then
				current_load = math.max(28.0, (simDR_bus_load_amps[0] or 14.0) + (simDR_bus_load_amps[1] or 14.0))
			end

			if simDR_gpu_amps ~= nil then
				simDR_gpu_amps[0] = current_load
			end
			if simDR_gpu_gen_amps ~= nil then
				simDR_gpu_gen_amps = current_load
			end

			-- When external 28V power is active and engine generators are off,
			-- external power supplies the buses directly so batteries stop discharging.
			local gen_running = false
			if simDR_generator_on ~= nil then
				if simDR_generator_on[0] == 1 or simDR_generator_on[1] == 1 then
					gen_running = true
				end
			end

			if not gen_running then
				if simDR_bus_volts ~= nil then
					simDR_bus_volts[0] = 28.0
					simDR_bus_volts[1] = 28.0
				end
				if simDR_battery_amps ~= nil then
					-- Float trickle charge (+1A) instead of discharging (-14A)
					simDR_battery_amps[0] = 1.0
					simDR_battery_amps[1] = 1.0
				end
			end
		end
	else
		-- When GPU is turned OFF
		if simDR_override_gpu_volts ~= nil and simDR_override_gpu_volts == 1 then
			simDR_override_gpu_volts = 0
			if simDR_gpu_on_legacy ~= nil then simDR_gpu_on_legacy = 0 end
			if simDR_gpu_volts ~= nil then simDR_gpu_volts = 0.0 end
			if simDR_gpu_amps ~= nil then simDR_gpu_amps[0] = 0.0 end
			if simDR_gpu_gen_amps ~= nil then simDR_gpu_gen_amps = 0.0 end
		end
	end

end



--===| AFTER REPLAY |====================================================================
-- function after_replay() end



--===| FLIGHT CRASH |====================================================================
-- function flight_crash() end



--===| AIRCRAFT UNLOAD |=================================================================
-- function aircraft_unload() end




--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")

