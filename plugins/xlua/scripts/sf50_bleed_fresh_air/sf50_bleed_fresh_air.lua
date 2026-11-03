
-- THIS SCRIPT HANDLE THE "BLEED / FRESH AIR" BUTTON
-- CONTROLLING THE CENTER BLEED-AIR PACK (SO THE PRESSURIZATION TOO!!!) OPEN OR CLOSED
-- (THE BUTTON ITSELF RELY ON THE SLIDER[20], "BLEED" POSITION = 1 OPEN / "FRESH" = 0 CLOSED)


----------------------------------- LOCATE AND/OR CREATE DATAREFS -----------------------------------

slider_bleed_button = find_dataref("sim/cockpit2/switches/custom_slider_on[20]") --> THE BUTTON IN THE COCKPIT 0=FRESH 1=BLEED
pack_center = find_dataref("sim/cockpit2/bleedair/actuators/pack_center") --> THE BLEED AIR ON OR OFF

simDR_startup_running = find_dataref('sim/operation/prefs/startup_running')

sf50DR_init_bleed_AI = create_dataref('laminar/sf50/AI/init_bleed', 'number')








--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--


-- Commands for simpits, not used here (XPD-13256)
function handle_fresh_air_on(phase, duration)
	if phase == 0 then
		slider_bleed_button = 1
	end
end
create_command("laminar/SF50/fresh_air_on","Bleed Air On", handle_fresh_air_on)

function handle_fresh_air_off(phase, duration)
	if phase == 0 then
		slider_bleed_button = 0
	end
end
create_command("laminar/SF50/fresh_air_off","Bleed Air Off", handle_fresh_air_off)




function sf50_bleed_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_bleed_AI()
	end
end
sf50CMD_bleed_quick_start = create_command('laminar/sf50/ai/bleed_quick_start', 'AI Bleed Quick Start Init', sf50_bleed_quick_start_CMDhandler)





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_bleed_AI()

    if sf50DR_init_bleed_AI == 1 then	-- Monitor AI for auto-board call
        init_bleed_all_modes()
        init_bleed_CD()

		slider_bleed_button = 0

        sf50DR_init_bleed_AI = 2
    end

end



--===| INITIALIZE COLD & DARK |==========================================================
function init_bleed_CD()



end



--===| INITIALIZE ENGINES RUNNING |======================================================
function init_bleed_ER()



end



--===| INITIALIZE ALL MODES |============================================================
function init_bleed_all_modes()










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
    init_bleed_all_modes()

    -- INITIALIZE TO COLD & DARK --------------------------------------------------------
    if simDR_startup_running == 0 then
        init_bleed_CD()

    -- INITIALIZE TO ENGINES RUNNING ----------------------------------------------------
    elseif simDR_startup_running == 1 then
		init_bleed_ER()

    end

end

--function flight_crash() end

function before_physics()

	pack_center = slider_bleed_button	-- JUST KEEP THE PACK SYNC WITH THE BUTTON






	init_bleed_AI()

end

--function after_physics() end

--function after_replay() end
