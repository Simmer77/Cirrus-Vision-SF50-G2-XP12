
-- ANTI ICE:
-- TURN ON ALSO AOA WITH PITOT HEAT
-- TURN ON ALSO PNEUMATIC-BOOT, R AND L SURFACES WITH MAIN SURFACES HEAT


----------------------------------- LOCATE AND/OR CREATE DATAREFS -----------------------------------

pitot_heat_pilot = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_pilot")
pitot_heat_copilot = find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_copilot")

static_heat_pilot = find_dataref("sim/cockpit2/ice/ice_static_heat_on_pilot")
static_heat_copilot = find_dataref("sim/cockpit2/ice/ice_static_heat_on_copilot")

AOA_heat_pilot = find_dataref("sim/cockpit2/ice/ice_AOA_heat_on")
AOA_heat_copilot = find_dataref("sim/cockpit2/ice/ice_AOA_heat_on_copilot")

windshield_heat_max = find_dataref("sim/cockpit2/switches/custom_slider_on[21]")
windshield_heat_high = find_dataref("sim/cockpit2/switches/custom_slider_on[22]")

simDR_startup_running = find_dataref('sim/operation/prefs/startup_running')



simDR_ice_inlet_heat_on_per_engine = find_dataref('sim/cockpit2/ice/ice_inlet_heat_on_per_engine')
simDR_ice_surfce_heat_on = find_dataref('sim/cockpit2/ice/ice_surfce_heat_on')
simDR_ice_tail_heat_on = find_dataref('sim/cockpit2/ice/ice_tail_heat_on')




sf50DR_init_antiice_AI = create_dataref('laminar/sf50/AI/init_antiice', 'number')




--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--

function sf50_antiice_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_antiice_AI()
	end
end
sf50CMD_antiice_quick_start = create_command('laminar/sf50/ai/antiice_quick_start', 'AI Anti-ice Quick Start Init', sf50_antiice_quick_start_CMDhandler)




--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_antiice_AI()

    if sf50DR_init_antiice_AI == 1 then	-- Monitor AI for auto-board call
        init_antiice_all_modes()
        init_antiice_CD()

		pitot_heat_pilot = 0
		pitot_heat_copilot = 0
		static_heat_pilot = 0
		static_heat_copilot = 0
		AOA_heat_pilot = 0
		AOA_heat_copilot = 0

		simDR_ice_inlet_heat_on_per_engine[0] = 0
		simDR_ice_surfce_heat_on = 0
		simDR_ice_tail_heat_on = 0

		windshield_heat_max = 0
		windshield_heat_high = 0

        sf50DR_init_antiice_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_antiice_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_antiice_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_antiice_all_modes()

	sf50DR_init_antiice_AI = 0

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
    init_antiice_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_antiice_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_antiice_ER()

    end

end

--function flight_crash() end

--function before_physics() end

function after_physics()

	-- Set copilot pitot and both aoa probes on or off like the pitot pilot side
	pitot_heat_copilot = pitot_heat_pilot
	static_heat_pilot = pitot_heat_pilot
	static_heat_copilot = pitot_heat_pilot
	AOA_heat_pilot = pitot_heat_pilot
	AOA_heat_copilot = pitot_heat_pilot

	init_antiice_AI()

end

--function after_replay() end
