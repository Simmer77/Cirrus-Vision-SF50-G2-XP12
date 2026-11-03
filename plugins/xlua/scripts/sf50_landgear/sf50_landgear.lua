
----------------------------------------------------------------------------------
-- ************DEALING WITH LANDING GEAR HANDLE/DETENT CUSTOM DATAREFS************
-- NOW JUST CREATING THE CUSTOM DETENT DATAREF, SINCE FROM X-PLANE 11.40 WE ALREADY
-- HAVE ANIMATED HANDLE DATAREF (sim/cockpit2/controls/gear_handle_animation)
----------------------------------------------------------------------------------


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running = find_dataref("sim/operation/prefs/startup_running")




--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
landing_gear_detents = create_dataref("laminar/sf50/controls/landing_gear_detents","number",landing_gear_detents_func) --> the lift amount of the handle, used by the cockpit manipulator

sf50DR_init_gear_AI = create_dataref('laminar/sf50/AI/init_gear', 'number')




--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--
function sf50_gear_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_gear_AI()
	end
end
sf50CMD_gear_quick_start = create_command('laminar/sf50/ai/gear_quick_start', 'AI Gear Quick Start Init', sf50_gear_quick_start_CMDhandler)





--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--
-- ANIMATIONS OF THE GEAR HANDLE/DETENTS
-- function update_gear_handle()
--	landing_gear_handle = landing_gear_handle + ((gear_handle_down - landing_gear_handle) * (10 * SIM_PERIOD))
-- end

function update_gear_detents()
	landing_gear_detents = landing_gear_detents + ((0 - landing_gear_detents) * (10 * SIM_PERIOD))
end




function landing_gear_detents_func()
	-- do nothing
end





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_gear_AI()

    if sf50DR_init_gear_AI == 1 then	-- Monitor AI for auto-board call
        init_gear_all_modes()
        init_gear_CD()
        sf50DR_init_gear_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_gear_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_gear_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_gear_all_modes()



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

--function flight_start() end

--function flight_crash() end

--function before_physics() end

function after_physics()

	if landing_gear_detents > 0 then update_gear_detents() end





	init_gear_AI()

end

--function after_replay() end


