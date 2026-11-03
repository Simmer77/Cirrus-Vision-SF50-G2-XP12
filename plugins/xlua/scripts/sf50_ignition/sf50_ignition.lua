
---------------------------------------------------------------------------------------
-- THIS SCRIPT HANDLE THE IGNITION BIG KNOB IN THE COCKPIT
-- THE START/STOP BUTTON
-- AND THE INFO TEXT IN THE TOUCHSCREEN PANEL
---------------------------------------------------------------------------------------

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local knob_state = 0 --> 0=off 1=run
local button_state = 0 --> 0=shutdown 1=startup
local cmd_start_fired = 0




--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_engine_N2 = find_dataref("sim/cockpit2/engine/indicators/N2_percent[0]")
simDR_starterisrunning = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_engine_mixture = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]") -- NO MORE: controlled by "starter engage condition lever" in planemaker
simDR_engine1_burn_fuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
simDR_igniter_on = find_dataref("sim/cockpit2/engine/actuators/igniter_on[0]")
simDR_startup_running = find_dataref("sim/operation/prefs/startup_running")
simDR_fuel_pump_on = find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[0]")


autostart_in_progress = find_dataref("sim/flightmodel2/misc/auto_start_in_progress")
autoboard_in_progress = find_dataref("sim/flightmodel2/misc/auto_board_in_progress")




--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--
simCMD_engage_starter = find_command("sim/starters/engage_starter_1")
simCMD_shutdown = find_command("sim/starters/shut_down_1")
simCMD_igniter_off = find_command("sim/igniters/igniter_contin_off_1")




--*************************************************************************************--
--** 				  CREATE READ-WRITE CUSTOM DATAREFS & HANDLERS                   **--
--*************************************************************************************--
sf50DR_ignition_pos = create_dataref("laminar/SF50/ignition_position","number")
sf50DR_ignition_msg = create_dataref("laminar/SF50/ignition_message","string") --> used by the eng info text in the panel
sf50DR_ign_fpump_msg = create_dataref("laminar/SF50/ign_fpump_message","string") --> used by the eng info text in the panel
sf50DR_TEST = create_dataref("laminar/SF50/TEST","number")

sf50DR_init_ignition_AI = create_dataref('laminar/sf50/AI/init_ignition', 'number')





--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--

-- KNOB OFF/RUN FUNCTIONS
function SF50_ignition_down_CMDhandler(phase, duration)
	if phase == 0 then
		knob_state = 0
		simDR_fuel_pump_on = 0
		simDR_igniter_on = 0
		simCMD_engage_starter:stop()
		cmd_start_fired = 0
	end
end
SF50CMD_ignition_down = create_command("laminar/SF50/ignition_down", "Ignition Sel Down", SF50_ignition_down_CMDhandler)

function SF50_ignition_up_CMDhandler(phase, duration)
	if phase == 0 then
		knob_state = 1
		simDR_fuel_pump_on = 1
		simDR_igniter_on = 1
	end
end
SF50CMD_ignition_up = create_command("laminar/SF50/ignition_up", "Ignition Sel Up", SF50_ignition_up_CMDhandler)



-- BUTTON START/STOP FUNCTION
function SF50_eng_start_stop_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_engine_N2 < 9.0 and knob_state == 1 then
			button_state = 1
		elseif knob_state == 0 then
			button_state = 0
		end
	end
end
SF50CMD_eng_start_stop = create_command("laminar/SF50/eng_start_stop_toggle", "Engine start and stop button", SF50_eng_start_stop_CMDhandler)






function sf50_ignition_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_ignition_AI()
		knob_state = 1
		button_state = 1
	end
end
sf50CMD_ignition_quick_start = create_command('laminar/sf50/ai/ignition_quick_start', 'AI Ignition Quick Start Init', sf50_ignition_quick_start_CMDhandler)







--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************-
-- SLOWLY ANIMATE FUNCTION
function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
	SPD_PERIOD = anim_speed * SIM_PERIOD
	if SPD_PERIOD > 1 then SPD_PERIOD = 1 end
	animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * SPD_PERIOD)
	delta = math.abs(animated_VALUE - reference_value)
	if delta < 0.05 then animated_VALUE = reference_value end
	return animated_VALUE
end





function animate_ignition_knob()
	if sf50DR_ignition_pos ~= knob_state then
		sf50DR_ignition_pos = func_animate_slowly(knob_state, sf50DR_ignition_pos, 20)
	end
end




function update_button_systems()

	if button_state == 1 then
		if simDR_engine1_burn_fuel == 0 and simDR_starterisrunning == 0 then
			if cmd_start_fired == 0 then
				simCMD_engage_starter:start()
				cmd_start_fired = 1;
			end
		else
			if simDR_engine_N2 > 54 and simDR_starterisrunning == 1 then
				if cmd_start_fired == 1 then
					simCMD_engage_starter:stop()
					cmd_start_fired = 0
				end
				if simDR_igniter_on == 1 then
					simCMD_igniter_off:once()
				end
			end
		end
	else
		if simDR_starterisrunning == 1 then simCMD_engage_starter:stop() end
		simCMD_shutdown:once()
		autostart_in_progress = 0
	end

end




function update_panel_start_info()

	-- IGNITION MSG:
	if button_state == 1 and simDR_engine1_burn_fuel == 0 then sf50DR_ignition_msg = "engn spooling up" end
	if button_state == 1 and simDR_engine1_burn_fuel == 1 then sf50DR_ignition_msg = "engn burning fuel" end
	if button_state == 1 and simDR_engine_N2 > 54 then sf50DR_ignition_msg = "engn running" end
	if button_state == 1 and simDR_engine_N2 > 54 and simDR_igniter_on+simDR_fuel_pump_on == 0 then sf50DR_ignition_msg = "ready to shut down" end
	if button_state == 0 and simDR_engine_N2 < 54 then sf50DR_ignition_msg = "engn shutting down" end
	if button_state == 0 and simDR_engine_N2 < 10 then sf50DR_ignition_msg = "engn off" end
	if button_state == 0 and knob_state == 1 and simDR_engine_N2 < 10 and simDR_fuel_pump_on == 1 then sf50DR_ignition_msg = "ready to start" end
	-- IGNITERS AND FUEL PUMP MSG:
	if simDR_igniter_on == 0 and simDR_fuel_pump_on == 0 then sf50DR_ign_fpump_msg = "ign and fpump off" end
	if simDR_igniter_on == 1 and simDR_fuel_pump_on == 0 then sf50DR_ign_fpump_msg = "ign on - fpump off" end
	if simDR_igniter_on == 0 and simDR_fuel_pump_on == 1 then sf50DR_ign_fpump_msg = "ign off - fpump on" end
	if simDR_igniter_on == 1 and simDR_fuel_pump_on == 1 then sf50DR_ign_fpump_msg = "ign and fpump on" end

end







--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_ignition_AI()

    if sf50DR_init_ignition_AI == 1 then	-- Monitor AI for auto-board call
        init_ignition_all_modes()
        init_ignition_CD()
        sf50DR_init_ignition_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_ignition_CD()

	sf50DR_ignition_pos = 0
	SF50CMD_ignition_down:once()
	button_state = 0
	knob_state = 0
end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_ignition_ER()

	simDR_engine_mixture = 1
	sf50DR_ignition_pos = 1
	SF50CMD_ignition_up:once()
	button_state = 1
	knob_state = 1

end



--===| INITIALIZE ALL MODES |============================================================
function init_ignition_all_modes()



end



--===| DEFERRED INITIALIZATION |=========================================================
--function deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
--function deferred_processing() end








--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

    -- INITIALIZE ALL MODES -------------------------------------------------------------
    init_ignition_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_ignition_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_ignition_ER()

    end



end

--function flight_crash() end

--function before_physics() end

function after_physics()

	animate_ignition_knob()
	update_button_systems()
	update_panel_start_info()


	sf50DR_TEST = cmd_start_fired




	init_ignition_AI()

end

--function after_replay() end
