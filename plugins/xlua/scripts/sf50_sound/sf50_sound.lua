-- *******************************************************************
-- Helper datarefs for use on the sound system
-- Daniela Rodríguez Careri <dcareri@gmail.com>
-- Laminar Research
-- *******************************************************************



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
dr_battery = find_dataref("sim/cockpit2/electrical/battery_on[0]")
dr_n2 = find_dataref("sim/flightmodel2/engines/N2_percent[0]")
dr_burning_fuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
dr_on_ground = find_dataref("sim/flightmodel/failures/onground_any")






--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
dr_avionics_init = create_dataref("laminar/sf50/sound/avionics_init", "number")







--*************************************************************************************--
--** 				       X-PLANE 'WRAP' COMMANDS & HANDLERS               	     **--
--*************************************************************************************--
-- Wire avionics init to battery on
function sf50_handle_bat_toggle_before(phase, duration) end
function sf50_handle_bat_toggle_after(phase, duration)
    if phase == 0 and dr_battery == 1 then
        dr_avionics_init = 1
    end
end
wrap_command("sim/electrical/battery_1_toggle", sf50_handle_bat_toggle_before, sf50_handle_bat_toggle_after)





--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--

function update_datarefs()
    sf50_set_avionics_init()
end



-- Stop avionics init sequence under certain conditions
function sf50_set_avionics_init()
    if dr_battery == 0 or dr_n2 > 2 or dr_burning_fuel == 1 or dr_on_ground == 0 then
        dr_avionics_init = 0
    end
end




--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics() end

function after_physics()

    update_datarefs()

end

function after_replay()

    update_datarefs()

end
