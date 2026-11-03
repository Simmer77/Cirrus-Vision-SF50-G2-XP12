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

local autoboard = {
	step = -1,
	phase = {},
	sequence_timeout = false,
	in_progress = 0
}

local autostart = {
	step = -1,
	phase = {},
	sequence_timeout = false,
	in_progress = 0
}

AI_autoboard_phase_timeout = false
AI_autostart_phase_timeout = false




--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running = find_dataref('sim/operation/prefs/startup_running')
simDR_autoboard_in_progress = find_dataref('sim/flightmodel2/misc/auto_board_in_progress')
simDR_autostart_in_progress = find_dataref('sim/flightmodel2/misc/auto_start_in_progress')
simDR_fuel_tank_selector = find_dataref('sim/cockpit2/fuel/fuel_tank_selector')
simDR_battery_on = find_dataref('sim/cockpit2/electrical/battery_on')
simDR_pitot_heat_pilot = find_dataref('sim/cockpit2/ice/ice_pitot_heat_on_pilot')
simDR_pitot_heat_copilot = find_dataref('sim/cockpit2/ice/ice_pitot_heat_on_copilot')
simDR_static_heat_pilot = find_dataref('sim/cockpit2/ice/ice_static_heat_on_pilot')
simDR_static_heat_copilot = find_dataref('sim/cockpit2/ice/ice_static_heat_on_copilot')
simDR_AOA_heat_pilot = find_dataref('sim/cockpit2/ice/ice_AOA_heat_on')
simDR_AOA_heat_copilot = find_dataref('sim/cockpit2/ice/ice_AOA_heat_on_copilot')
simDR_generator_on = find_dataref('sim/cockpit2/electrical/generator_on')
simDR_GPU_can_be_called_for = find_dataref('sim/cockpit2/electrical/GPU_can_be_called_for')
simDR_GPU_generator_volts= find_dataref('sim/cockpit2/electrical/GPU_generator_volts')
simDR_GPU_on = find_dataref('sim/cockpit2/electrical/GPU_generator_on')
simDR_ap_flight_director_mode = find_dataref('sim/cockpit2/autopilot/flight_director_mode')
simDR_strobe_lights_switch_on = find_dataref('sim/cockpit2/switches/strobe_lights_on')
simDR_throttle_ratio = find_dataref('sim/cockpit2/engine/actuators/throttle_ratio[0]')
simDR_engine_ITT_deg_cel = find_dataref('sim/flightmodel2/engines/ITT_deg_cel')
simDR_engine_N1_percent = find_dataref('sim/flightmodel2/engines/N1_percent')
simDR_engine_N2_percent = find_dataref('sim/flightmodel2/engines/N2_percent')
simDR_engine_oil_press_psi = find_dataref('sim/flightmodel/engine/ENGN_oil_press_psi')
simDR_bleed_air_switch = find_dataref("sim/cockpit2/switches/custom_slider_on[20]")




--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--
simCMD_generator_1_on = find_command('sim/electrical/generator_1_on')
simCMD_generator_2_on = find_command('sim/electrical/generator_2_on')
simCMD_GPU_on = find_command('sim/electrical/GPU_on')
simCMD_ground_ops_service_plane = find_command('sim/ground_ops/service_plane')
simCMD_ap_fdir_servos_toggle = find_command('sim/autopilot/servos_toggle')
simCMD_strobe_lights_toggle = find_command('sim/lights/strobe_lights_toggle')




--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
sf50DR_init_antiice_AI = find_dataref('laminar/sf50/AI/init_antiice')
sf50DR_init_autopilot_AI = find_dataref('laminar/sf50/AI/init_autopilot')
sf50DR_init_fuel_AI = find_dataref('laminar/sf50/AI/init_fuel')
sf50DR_init_bleed_AI = find_dataref('laminar/sf50/AI/init_bleed')
sf50DR_init_ignition_AI = find_dataref('laminar/sf50/AI/init_ignition')
sf50DR_init_gear_AI = find_dataref('laminar/sf50/AI/init_gear')
sf50DR_init_o2_AI = find_dataref('laminar/sf50/AI/init_o2')
sf50DR_init_electrical_AI = find_dataref('laminar/sf50/AI/init_electrical')
sf50DR_init_lights_AI = find_dataref('laminar/sf50/AI/init_lights')
sf50DR_init_fltControl_AI = find_dataref('laminar/sf50/AI/init_fltControl')

sf50DR_engine_knob = find_dataref('laminar/SF50/ignition_position')
sf50DR_master_oxygen_button = find_dataref("sim/cockpit2/switches/custom_slider_on[19]")
sf50DR_bleed_air_switch = find_dataref("sim/cockpit2/switches/custom_slider_on[20]")




--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--
sf50CMD_bleed_air_on = find_command("laminar/SF50/fresh_air_on")
sf50CMD_engine_knob_up = find_command('laminar/SF50/ignition_up')
sf50CMD_engine_knob_down = find_command('laminar/SF50/ignition_down')
SF50CMD_eng_start_stop = find_command('laminar/SF50/eng_start_stop_toggle')
sf50CMD_oxy_master = find_command('sim/operation/slider_20')
sf50CMD_pitot_heat_pilot = find_command('sim/ice/pitot_heat0_tog')

sf50CMD_antiice_quick_start = find_command('laminar/sf50/ai/antiice_quick_start')
sf50CMD_autopilot_quick_start = find_command('laminar/sf50/ai/antiice_quick_start')
sf50CMD_bleed_quick_start = find_command('laminar/sf50/ai/bleed_quick_start')
sf50CMD_electrical_quick_start = find_command('laminar/sf50/ai/electrical_quick_start')
sf50CMD_fltControl_quick_start = find_command('laminar/sf50/ai/fltControl_quick_start')
sf50CMD_fuel_quick_start = find_command("laminar/sf50/ai/fuel_quick_start")
sf50CMD_ignition_quick_start = find_command('laminar/sf50/ai/ignition_quick_start')
sf50CMD_gear_quick_start = find_command('laminar/sf50/ai/gear_quick_start')
sf50CMD_lights_quick_start = find_command('laminar/sf50/ai/lights_quick_start')
sf50CMD_o2_quick_start = find_command('laminar/sf50/ai/o2_quick_start')





--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				  CREATE READ-WRITE CUSTOM DATAREFS & HANDLERS                   **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				      X-PLANE 'FILTER' COMMANDS & HANDLERS            			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       X-PLANE 'WRAP' COMMANDS & HANDLERS               	     **--
--*************************************************************************************--

function sim_quick_start_beforeCMDhandler(_, _) end
function sim_quick_start_afterCMDhandler(phase, _)
	if phase == 0 then
		AI_quick_start()
	end
end
wrap_command("sim/operation/quick_start", sim_quick_start_beforeCMDhandler, sim_quick_start_afterCMDhandler)




--*************************************************************************************--
--** 				     X-PLANE 'REPLACE' COMMANDS & HANDLERS              	  	 **--
--*************************************************************************************--

function sim_autoboard_CMDhandler(phase, _)
	if phase == 0 then
		print("")
		print("==> AUTOBOARD COMMAND INVOKED")
		if autoboard.in_progress == 0
			and autostart.in_progress == 0
		then
			if autostart.step < 0 then
				simDR_autoboard_in_progress = 1
			end
			autoboard.in_progress = 1
			autoboard.step = 0
			autoboard.phase = {}
			autoboard.sequence_timeout = false
		end
	end
end
simCMD_autoboard = replace_command("sim/operation/auto_board", sim_autoboard_CMDhandler)




function sim_autostart_CMDhandler(phase, _)
	if phase == 0 then
	print("==> AUTOSTART COMMAND INVOKED")
		if autoboard.in_progress == 0
			and autostart.in_progress == 0
		then
			autostart.step = 0
			simDR_autostart_in_progress = 1
		end
	end
end
simCMD_autostart = replace_command("sim/operation/auto_start", sim_autostart_CMDhandler)




--*************************************************************************************--
--** 					          OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--

function AI_print_sequence_status(step, phase, message)
	local msg = string.format("| Step:%02d/Phase:%02d - %s", step, phase, message)
	print(msg)
end




function AI_print_completed_line()
	print("+----------------------------------------------+")
end




function AI_print_quick_start_init_message()
	print("+----------------------------------------------+")
	print("|             QUICK START INITIATED            |")
	print("+----------------------------------------------+")
end






--====================================| AUTO-BOARD |====================================--
------------------------------------------------------------------------------------------
function AI_autoboard_init()
	if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
		stop_timer(AI_autoboard_phase_timeout)
	end
	autoboard.step = -1
	autoboard.phase = {}
	autoboard.sequence_timeout = false
	autoboard.in_progress = 0
end

function AI_print_autoboard_begin()
	print("+----------------------------------------------+")
	print("|          AUTO-BOARD SEQUENCE BEGIN           |")
	print("+----------------------------------------------+")
end

function AI_print_autoboard_abort()
	print("+----------------------------------------------+")
	print("|         AUTO-BOARD SEQUENCE ABORTED          |")
	print("+----------------------------------------------+")
end

function AI_print_autoboard_completed()
	print("+----------------------------------------------+")
	print("|        AUTO-BOARD SEQUENCE COMPLETED         |")
	print("+----------------------------------------------+")
end

function AI_print_autoboard_monitor(step, phase)
	AI_print_sequence_status(step, phase, "Monitoring...")
end

function AI_print_autoboard_timer_start(step, phase)
	AI_print_sequence_status(step, phase, "Auto-Board Phase Timer Started...")
end

function AI_autoboard_phase_monitor(time)
	if autoboard.phase[autoboard.step] == 2 then
		AI_print_autoboard_monitor(autoboard.step, autoboard.phase[autoboard.step])      	-- PRINT THE MONITOR PHASE MESSAGE
		if is_timer_scheduled(AI_autoboard_phase_timeout) == false then                  	-- START MONITOR TIMER
			run_after_time(AI_autoboard_phase_timeout, time)
		end
		autoboard.phase[autoboard.step] = 3                                                 -- INCREMENT THE PHASE
		AI_print_autoboard_timer_start(autoboard.step, autoboard.phase[autoboard.step])   	-- PRINT THE TIMER MESSAGE
	end
end

function AI_autoboard_step_failed(step, phase)
	AI_print_sequence_status(step, phase, "***  F A I L E D  ***")
	autoboard.sequence_timeout = false
	autoboard.step = 700
end

function AI_autoboard_step_completed(step, phase, message)
	AI_print_sequence_status(step, phase, message)
	AI_print_completed_line()
	autoboard.step = autoboard.step + 1.0
	autoboard.phase[autoboard.step] = 1
end

function AI_autoboard_seq_aborted()
	AI_print_autoboard_abort()
	autoboard.step = 800
	simDR_autoboard_in_progress = 0
	AI_autoboard_init()
	simDR_autostart_in_progress = 0
	AI_autostart_init()
end

function AI_autoboard_seq_completed()
	AI_print_autoboard_completed()
	autoboard.step = 999
	simDR_autoboard_in_progress = 0
	autoboard.in_progress = 0

end

function AI_autoboard_phase_timeout()
	autoboard.sequence_timeout = true
	AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Step Has Timed Out...")
end







--===| AUTO-BOARD SEQUENCE PROCESSING |==================================================
function AI_auto_board_sequence_processing()

	--[ AUTO-BOARD STEP 0 ]: AUTOBOARD COMMAND HAS BEEN INVOKED
	if autoboard.step == 0 then
		AI_print_autoboard_begin()                                                        	-- Print the auto-board header
		autoboard.step = 1                                                                  -- Set the step
		autoboard.phase[autoboard.step] = 1                                                 -- Set the phase

	--[ END AUTO-BOARD STEP 0]



	--[ AUTO-BOARD STEP 1 ]: INIT ALL SYSTEMS TO COLD & DARK STATE
	elseif autoboard.step == 1 then

		--| PHASE 1: SET THE INIT FLAG
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Initialize Aircraft To Cold & Dark...")

			-- Set flag to initialize each system
			sf50DR_init_antiice_AI = 1
			sf50DR_init_autopilot_AI = 1
			sf50DR_init_fuel_AI = 1
			sf50DR_init_bleed_AI = 1
			sf50DR_init_ignition_AI = 1
			sf50DR_init_gear_AI = 1
			sf50DR_init_o2_AI = 1
			sf50DR_init_electrical_AI = 1
			sf50DR_init_lights_AI = 1
			sf50DR_init_fltControl_AI = 1


			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
		--if autoboard.phase[autoboard.step] == 2 then
			AI_autoboard_phase_monitor(5.0)
		--end

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
				print(sf50DR_init_antiice_AI,
						sf50DR_init_autopilot_AI,
						sf50DR_init_fuel_AI,
						sf50DR_init_bleed_AI,
						sf50DR_init_ignition_AI,
						sf50DR_init_gear_AI,
						sf50DR_init_o2_AI,
						sf50DR_init_electrical_AI,
						sf50DR_init_lights_AI,
						sf50DR_init_fltControl_AI)

			else -- Verify the init of all systems

				if sf50DR_init_antiice_AI == 2
					and sf50DR_init_autopilot_AI == 2
					and sf50DR_init_fuel_AI == 2
					and sf50DR_init_bleed_AI == 2
					and sf50DR_init_ignition_AI == 2
					and sf50DR_init_gear_AI == 2
					and sf50DR_init_o2_AI == 2
					and sf50DR_init_electrical_AI == 2
					and sf50DR_init_lights_AI == 2
					and sf50DR_init_fltControl_AI == 2


				then-- Reset the init flags
					sf50DR_init_antiice_AI = 0
					sf50DR_init_autopilot_AI = 0
					sf50DR_init_fuel_AI = 0
					sf50DR_init_bleed_AI = 0
					sf50DR_init_ignition_AI = 0
					sf50DR_init_gear_AI = 0
					sf50DR_init_o2_AI = 0
					sf50DR_init_electrical_AI = 0
					sf50DR_init_lights_AI = 0
					sf50DR_init_fltControl_AI = 0

					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Aircraft is Cold & Dark")
		end

	--[ END AUTO-BOARD STEP 1 ]



	--[ AUTO-BOARD STEP 2 ]: FUEL CONTROL SWITCH TO "AUTO"
	elseif autoboard.step == 2 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Fuel Control Switch to 'AUTO'...")

			simDR_fuel_tank_selector = 4

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_fuel_tank_selector == 4 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Fuel Control Switch set to 'AUTO'")
		end

	--[ END AUTO-BOARD STEP 2 ]



	--[ AUTO-BOARD STEP 3 ]: ENGINE KNOB TO "OFF"
	elseif autoboard.step == 3 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Engine Knob to 'OFF'...")

			if sf50DR_engine_knob == 1 then
				sf50CMD_engine_knob_down:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if sf50DR_engine_knob == 0 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Engine Knob set to 'OFF'")
		end

	--[ END AUTO-BOARD STEP 3 ]



	--[ AUTO-BOARD STEP 4 ]: BATTERY 2 SWITCH TO "ON"
	elseif autoboard.step == 4 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Battery 2 Switch to 'ON'...")

			simDR_battery_on[1] = 1

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_battery_on[1] == 1 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Battery 2 Switch set to 'ON'")
		end

	--[ END AUTO-BOARD STEP 4 ]



	--[ AUTO-BOARD STEP 5 ]: BATTERY 1 SWITCH TO "ON"
	elseif autoboard.step == 5 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Battery 1 Switch to 'ON'...")

			simDR_battery_on[0] = 1

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_battery_on[0] == 1 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Battery 1 Switch set to 'ON'")
		end

	--[ END AUTO-BOARD STEP 5 ]



	--[ AUTO-BOARD STEP 6 ]: OXYGEN MASTER SWITCH TO "ON"
	elseif autoboard.step == 6 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Oxygen Master Switch to 'ON'...")

			if sf50DR_master_oxygen_button == 0 then
				sf50CMD_oxy_master:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if sf50DR_master_oxygen_button == 1 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Oxygen Master Switch set to 'ON'")
		end

	--[ END AUTO-BOARD STEP 6 ]



	--[ AUTO-BOARD STEP 7 ]: PROBE HEAT SWITCH TO "ON"
	elseif autoboard.step == 7 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Probe Heat Switch to 'ON'...")

			if simDR_pitot_heat_pilot == 0 then
				sf50CMD_pitot_heat_pilot:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.5)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
				print(simDR_pitot_heat_pilot,
					simDR_pitot_heat_copilot,
					simDR_static_heat_pilot,
					simDR_static_heat_copilot,
					simDR_AOA_heat_pilot,
					simDR_AOA_heat_copilot)
			else
				if simDR_pitot_heat_pilot == 1
					and simDR_pitot_heat_copilot == 1
					and simDR_static_heat_pilot == 1
					and simDR_static_heat_copilot == 1
					and simDR_AOA_heat_pilot == 1
					and simDR_AOA_heat_copilot == 1
				then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Probe Heat Switch set to 'ON'")
		end

	--[ END AUTO-BOARD STEP 7 ]



	--[ AUTO-BOARD STEP 8 ]: AUTOPILOT TO "ON"
	elseif autoboard.step == 8 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set Autopilot to 'ON'...")

			if simDR_ap_flight_director_mode == 0 then
				simCMD_ap_fdir_servos_toggle:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_ap_flight_director_mode == 2 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Autopilot set to 'ON'")
		end

	--[ END AUTO-BOARD STEP 8 ]



	--[ AUTO-BOARD STEP 9 ]: PRESS AP DISCO BUTTON
	elseif autoboard.step == 9 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Press the Autopilot Disco Button...")

			if simDR_ap_flight_director_mode == 2 then
				simCMD_ap_fdir_servos_toggle:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_ap_flight_director_mode < 2 then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Autopilot Disco Button Pressed")
		end

	--[ END AUTO-BOARD STEP 9 ]



	--[ AUTO-BOARD STEP 10 ]: GENERATOR SWITCHES TO "ON"
	elseif autoboard.step == 10 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the Generator Switches to 'ON'...")

			if simDR_generator_on[0] == 0 then
				simCMD_generator_1_on:once()
			end
			if simDR_generator_on[2] == 0 then
				simCMD_generator_2_on:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_generator_on[0] == 1
					and simDR_generator_on[1] == 1
				then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Generator Switches are set to 'ON'")
		end

	--[ END AUTO-BOARD STEP 10 ]


--[[													-- taking out TURN ON GPU until we get proper commands to do so
	--[ AUTO-BOARD STEP 11 ]: GPU TO "ON"
	elseif autoboard.step == 11 then

		--| PHASE 1: SET THE SWITCH
		if autoboard.phase[autoboard.step] == 1 then
			AI_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Set the GPU to 'ON'...")

			if simDR_GPU_can_be_called_for then
				simCMD_ground_ops_service_plane:once()
			end
			if simDR_GPU_generator_volts > 0.0 then
				simCMD_GPU_on:once()
			end

			autoboard.phase[autoboard.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autoboard_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autoboard.phase[autoboard.step] == 3 then
			if autoboard.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])

			else
				if simDR_GPU_generator_volts > 0.0
					and simDR_GPU_on == 1
			
				then
					if is_timer_scheduled(AI_autoboard_phase_timeout) == true then
						stop_timer(AI_autoboard_phase_timeout)
					end
					autoboard.phase[autoboard.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autoboard.phase[autoboard.step] == 4 then
			AI_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, GPU is 'ON'")
		end

	--[ END AUTO-BOARD STEP 11 ]
]]--


	--[ AUTOBOARD STEPS COMPLETED ]--
	elseif autoboard.step == 11 then
		autoboard.step = 888


	--[ AUTO-BOARD STEP 700: ABORT ]--
	elseif autoboard.step == 700 then
		AI_autoboard_seq_aborted()


	--[ AUTO-BOARD COMPLETED ]--
	elseif autoboard.step == 888 then
		AI_autoboard_seq_completed()

	end

end







--====================================| AUTO-START |====================================--
------------------------------------------------------------------------------------------
function AI_autostart_init()
	if is_timer_scheduled(AI_autostart_phase_timeout) == true then
		stop_timer(AI_autostart_phase_timeout)
	end
	autostart.step = -1
	autostart.phase = {}
	autostart.sequence_timeout = false
	autostart.in_progress = 0
end

function AI_print_autostart_begin()
	print("+----------------------------------------------+")
	print("|          AUTO-START SEQUENCE BEGIN           |")
	print("+----------------------------------------------+")
end

function AI_print_autostart_abort()
	print("+----------------------------------------------+")
	print("|         AUTO-START SEQUENCE ABORTED          |")
	print("+----------------------------------------------+")
end

function AI_print_autostart_completed()
	print("+----------------------------------------------+")
	print("|        AUTO-START SEQUENCE COMPLETED         |")
	print("+----------------------------------------------+")
end

function AI_print_autostart_monitor(step, phase)
	AI_print_sequence_status(step, phase, "Monitoring...")
end

function AI_print_autostart_timer_start(step, phase)
	AI_print_sequence_status(step, phase, "Auto-Start Phase Timer Started...")
end

function AI_autostart_phase_monitor(time)
	if autostart.phase[autostart.step] == 2 then
		AI_print_autostart_monitor(autostart.step, autostart.phase[autostart.step])       	-- PRINT THE MONITOR PHASE MESSAGE
		if is_timer_scheduled(AI_autostart_phase_timeout) == false then                   	-- START MONITOR TIMER
			run_after_time(AI_autostart_phase_timeout, time)
		end
		autostart.phase[autostart.step] = 3                                                 -- INCREMENT THE PHASE
		AI_print_autostart_timer_start(autostart.step, autostart.phase[autostart.step])   	-- PRINT THE TIMER MESSAGE
	end
end

function AI_autostart_step_failed(step, phase)
	AI_print_sequence_status(step, phase, "***  F A I L E D  ***")
	autostart.sequence_timeout = false
	autostart.step = 700
end

function AI_autostart_step_completed(step, phase, message)
	AI_print_sequence_status(step, phase, message)
	AI_print_completed_line()
	autostart.step = autostart.step + 1.0
	autostart.phase[autostart.step] = 1
end

function AI_autostart_seq_aborted()
	AI_print_autostart_abort()
	autostart.step = 800
	simDR_autoboard_in_progress = 0
	AI_autoboard_init()
	simDR_autostart_in_progress = 0
	AI_autostart_init()
end

function AI_autostart_seq_completed()
	AI_print_autostart_completed()
	autostart.step = 999
	simDR_autostart_in_progress = 0
	AI_autoboard_init()
	AI_autostart_init()
end

function AI_autostart_phase_timeout()
	autostart.sequence_timeout = true
	AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Step Has Timed Out...")
end





--===| AUTO-START SEQUENCE PROCESSING |==================================================
function AI_auto_start_sequence_processing()

	--[ AUTO-START STEP 0 ]: AUTOSTART COMMAND HAS BEEN INVOKED
	if autostart.step == 0 then

		-- RUN AUTOBOARD SEQUENCE IF NOT ALREADY PROCESSED
		if autoboard.step < 0 then
			simCMD_autoboard:once()
		else
			-- AUTOBOARD SEQUENCE COMPLETED: BEGIN AUTOSTART
			if autoboard.step == 999 then
				autostart.in_progress = 1
				AI_print_autostart_begin()
				autostart.step = 1
				autostart.phase[autostart.step] = 1
				AI_autoboard_init()
			end
		end




	--[ AUTO-START STEP 1 ]: SET THE STROBE LIGHT SWITCH TO "ON"
	elseif autostart.step == 1 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Set the Strobe Lights Switch to 'ON'...")

			if simDR_strobe_lights_switch_on == 0 then
				simCMD_strobe_lights_toggle:once()
			end

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autostart_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])

			else
				if simDR_strobe_lights_switch_on == 1 then
					if is_timer_scheduled(AI_autostart_phase_timeout) == true then
						stop_timer(AI_autostart_phase_timeout)
					end
					autostart.phase[autostart.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Completed, Strobe Lights Switch set to 'ON'")
		end

	--[ END AUTO-START STEP 1 ]




	--[ AUTO-START STEP 2 ]: SET THRUST LEVER TO IDLE
	elseif autostart.step == 2 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Set the Thrust Lever to 'IDLE'...")

			simDR_throttle_ratio = 0.0

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autostart_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])

			else
				if simDR_throttle_ratio == 0.0 then
					if is_timer_scheduled(AI_autostart_phase_timeout) == true then
						stop_timer(AI_autostart_phase_timeout)
					end
					autostart.phase[autostart.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Completed, Thrust Lever is set to 'IDLE'")
		end

	--[ END AUTO-START STEP 2 ]




	--[ AUTO-START STEP 3 ]: SET THE ENGINE KNOB TO "ON"
	elseif autostart.step == 3 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Set the Engine Knob to 'ON'...")

			if sf50DR_engine_knob == 0 then
				sf50CMD_engine_knob_up:once()
			end

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autostart_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])

			else
				if sf50DR_engine_knob == 1 then
					if is_timer_scheduled(AI_autostart_phase_timeout) == true then
						stop_timer(AI_autostart_phase_timeout)
					end
					autostart.phase[autostart.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Completed, Engime Knob is set to 'ON'")
		end

	--[ END AUTO-START STEP 3 ]




	--[ AUTO-START STEP 4 ]: SET THE ENGINE KNOB TO "ON"
	elseif autostart.step == 4 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Press the Engine Start Button...")

			SF50CMD_eng_start_stop:once()

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
			AI_autostart_phase_monitor(1.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])

			else
				if is_timer_scheduled(AI_autostart_phase_timeout) == true then
					stop_timer(AI_autostart_phase_timeout)
				end
				autostart.phase[autostart.step] = 4

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Completed, Engine Start Button is Pressed")
		end

	--[ END AUTO-START STEP 4 ]




	--[ AUTO-START STEP 5 ]: MONITOR THE ENGINE START
	elseif autostart.step == 5 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Monitor Engine Start...")

			SF50CMD_eng_start_stop:once()

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
		AI_autostart_phase_monitor(20.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
			else
				if simDR_engine_N2_percent[0] > 25.0
					and
					(simDR_engine_ITT_deg_cel[0] < 877.0
					or simDR_engine_N1_percent[0] > 0
					or simDR_engine_oil_press_psi[0] > 35.0)
				then
					if simDR_engine_N2_percent[0] > 50.0 then
						if is_timer_scheduled(AI_autostart_phase_timeout) == true then
							stop_timer(AI_autostart_phase_timeout)
						end
						autostart.phase[autostart.step] = 4
					end
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Completed, Engine Start")
		end

	--[ END AUTO-START STEP 5 ]




	--[ AUTO-START STEP 6 ]: DISCONNECT THE GPU
	elseif autostart.step == 6 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Disconnect the GPU...")

			simDR_GPU_on = 0

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
		AI_autostart_phase_monitor(20.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
			else
				if simDR_GPU_on == 0 then
					if is_timer_scheduled(AI_autostart_phase_timeout) == true then
						stop_timer(AI_autostart_phase_timeout)
					end
					autostart.phase[autostart.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "GPU is Disconnected.")
		end

	--[ END AUTO-START STEP 6 ]




	--[ AUTO-START STEP 7 ]: VERIFY OXYGEN MASTER SWICTH IS ON
	elseif autostart.step == 7 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Verify Oxygen Master Switch is 'ON'")

			if sf50DR_master_oxygen_button == 0 then
				sf50CMD_oxy_master:once()
			end

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
		AI_autostart_phase_monitor(20.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
			else
				if sf50DR_master_oxygen_button == 1 then
					if is_timer_scheduled(AI_autostart_phase_timeout) == true then
						stop_timer(AI_autostart_phase_timeout)
					end
					autostart.phase[autostart.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Oxygen Master Switch is 'ON'")
		end

	--[ END AUTO-START STEP 7 ]




	--[ AUTO-START STEP 8 ]: BLEED AIR SWITCH IS ON "BLEED"
	elseif autostart.step == 8 then

		--| PHASE 1: SET THE SWITCH
		if autostart.phase[autostart.step] == 1 then
			AI_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Set Bleed Air Switch to 'BLEED'")

			if sf50DR_bleed_air_switch == 0 then
				sf50CMD_bleed_air_on:once()
			end

			autostart.phase[autostart.step] = 2
		end

		--| PHASE 2: PRINT MONITOR STATUS / START PHASE TIMER / INCREMENT THE STEP
		AI_autostart_phase_monitor(20.0)

		--| PHASE 3: MONITOR THE STATUS
		if autostart.phase[autostart.step] == 3 then
			if autostart.sequence_timeout == true then -- Systems initialization has exceeded the expected processing time
				AI_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
			else
				if sf50DR_bleed_air_switch == 1 then
					if is_timer_scheduled(AI_autostart_phase_timeout) == true then
						stop_timer(AI_autostart_phase_timeout)
					end
					autostart.phase[autostart.step] = 4
				end

			end

		end

		--| PHASE 4: COMPLETE THE STEP
		if autostart.phase[autostart.step] == 4 then
			AI_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "Bleed Air Switch is on 'BLEED'")
		end

	--[ END AUTO-START STEP 8 ]


	--[ AUTOSTART STEPS COMPLETED ]--
	elseif autostart.step == 9 then
		autostart.step = 888


	--[ AUTOSTART STEP 700: ABORT ]--
	elseif autostart.step == 700 then
		AI_autostart_seq_aborted()


	--[ AUTOSTART COMPLETED ]--
	elseif autostart.step == 888 then
		AI_autostart_seq_completed()

	end

end








function AI_quick_start()


	AI_print_quick_start_init_message()

	init_AI()

	sf50CMD_antiice_quick_start:once()
	sf50CMD_autopilot_quick_start:once()
	sf50CMD_bleed_quick_start:once()
	sf50CMD_electrical_quick_start:once()
	sf50CMD_fltControl_quick_start:once()
	sf50CMD_fuel_quick_start:once()
	sf50CMD_ignition_quick_start:once()
	sf50CMD_gear_quick_start:once()
	sf50CMD_lights_quick_start:once()
	sf50CMD_o2_quick_start:once()

end






--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start |==========================================
function init_AI()

	init_AI_all_modes()
	init_AI_CD()
	init_AI_ER()

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_AI_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_AI_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_AI_all_modes()



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
    init_AI_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_AI_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_AI_ER()

    end

end



--===| BEFORE PHYSICS |==================================================================
-- function before_physics() end



--===| AFTER PHYSICS |===================================================================
function after_physics()

	AI_auto_board_sequence_processing()
	AI_auto_start_sequence_processing()

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

