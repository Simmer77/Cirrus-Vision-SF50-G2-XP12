
-- MASTER OXYGEN BUTTON (ACTUALLY ON THE SLIDER[19] -> cmd slider_20)
-- AND OXYGEN VALVE OPEN COMMAND (CLICKING ON COCKPIT MASKS)

-- The master button open or close oxy flow (demand_flow_setting)
-- while clicking on masks open or close o2 valve (o2_valve_on)
-- so opening o2 valve (wearing masks) will play breathing sound regardless if there is an actual oxy flow or not

--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
master_oxygen_button = find_dataref("sim/cockpit2/switches/custom_slider_on[19]") --> THE COCKPIT BUTTON
demand_flow_setting = find_dataref("sim/cockpit2/oxygen/actuators/demand_flow_setting") --> 0 off / 2 now
o2_valve_on = find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
simDR_startup_running = find_dataref('sim/operation/prefs/startup_running')




--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
sf50DR_init_o2_AI = create_dataref('laminar/sf50/AI/init_o2', 'number')





--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--


-- Commands for simpits, not used here (XPD-13256)

function handle_oxy_master_on(phase, duration)
	if phase == 0 then
		master_oxygen_button = 1
	end
end
create_command("laminar/SF50/oxygen_master_on","Oxygen master on", handle_oxy_master_on)

function handle_oxy_master_off(phase, duration)
	if phase == 0 then
		master_oxygen_button = 0
	end
end
create_command("laminar/SF50/oxygen_master_off","Oxygen master off", handle_oxy_master_off)




function sf50_o2_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_o2_AI()
	end
end
sf50CMD_o2_quick_start = create_command('laminar/sf50/ai/o2_quick_start', 'AI Oxygen Quick Start Init', sf50_o2_quick_start_CMDhandler)







--*************************************************************************************--
--** 				       X-PLANE 'WRAP' COMMANDS & HANDLERS               	     **--
--*************************************************************************************--
-- OXYGEN VALVE TOGGLE (CLICKING ON MASKS)
--function func_oxy_before(phase, duration)
	--NONE
--end
--function func_oxy_after(phase, duration)
--	if phase == 0 and master_oxygen_button == 0 then
		-- KEP THE O2 CLOSE IF MASTER BUTTON OFF
--		o2_valve_on = 0
--	end
--end


-- MASTER OXY BUTTON TOGGLE (SLIDER[19])
function func_oxymaster_before(phase, duration)
	--NONE
end

function func_oxymaster_after(phase, duration)
	if phase == 0 then
		if master_oxygen_button == 1 then
		demand_flow_setting = 2 -- OPEN NOW
		else
		demand_flow_setting = 0 -- CLOSE
		end
	end
end
cmd_oxy_master = wrap_command("sim/operation/slider_20", func_oxymaster_before, func_oxymaster_after) --> THE OXY MASTER BUTTON COMMAND (ON SLIDER[19])









--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_o2_AI()

    if sf50DR_init_o2_AI == 1 then	-- Monitor AI for auto-board call
        init_o2_all_modes()
        init_o2_CD()

		master_oxygen_button = 0

        sf50DR_init_o2_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_o2_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_o2_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_o2_all_modes()



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
    init_o2_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_o2_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_o2_ER()

    end

end

--function flight_crash() end

--function before_physics() end

function after_physics()

	if demand_flow_setting > 0 then master_oxygen_button = 1 else master_oxygen_button = 0 end






	init_o2_AI()

end

--function after_replay() end
