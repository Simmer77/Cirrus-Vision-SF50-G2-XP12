
----------------------------------- LOCATE AND/OR CREATE DATAREFS -----------------------------------
fuel_tank_selector = find_dataref("sim/cockpit2/fuel/fuel_tank_selector") -- (0=none,1=left,2=center,3=right,4=all)

--example_custom = create_dataref("laminar/SF50/example_custom","number") -- description

simDR_startup_running = find_dataref('sim/operation/prefs/startup_running')

sf50DR_init_fuel_AI = create_dataref('laminar/sf50/AI/init_fuel', 'number')






--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--

function cmd_fuel_selector_up(phase, duration)
	if phase == 0 then
		if (fuel_tank_selector == 1) then
			fuel_tank_selector = 4
		elseif (fuel_tank_selector == 4) then
			fuel_tank_selector = 3
		elseif (fuel_tank_selector == 3) then
			fuel_tank_selector = 3
		else
			fuel_tank_selector = 4
		end
	end
end
create_command("laminar/SF50/fuel_selector_up","Move the fuel selector up one",cmd_fuel_selector_up)

function cmd_fuel_selector_dwn(phase, duration)
	if phase == 0 then
		if (fuel_tank_selector == 1) then
			fuel_tank_selector = 1
		elseif (fuel_tank_selector == 4) then
			fuel_tank_selector = 1
		elseif (fuel_tank_selector == 3) then
			fuel_tank_selector = 4
		else
			fuel_tank_selector = 4
		end
	end
end
create_command("laminar/SF50/fuel_selector_dwn","Move the fuel selector down one",cmd_fuel_selector_dwn)




function sf50_fuel_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_fuel_AI()
	end
end
sf50CMD_fuel_quick_start = create_command('laminar/sf50/ai/fuel_quick_start', 'AI Fuel Quick Start Init', sf50_fuel_quick_start_CMDhandler)








--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_fuel_AI()

    if sf50DR_init_fuel_AI == 1 then	-- Monitor AI for auto-board call
        init_fuel_all_modes()
        init_fuel_CD()
        sf50DR_init_fuel_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_fuel_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_fuel_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_fuel_all_modes()

	fuel_tank_selector = 4
	sf50DR_init_fuel_AI = 0

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
    init_fuel_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_fuel_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_fuel_ER()

    end

end

--function flight_crash() end

--function before_physics() end

function after_physics()
	init_fuel_AI()
end

--function after_replay() end
