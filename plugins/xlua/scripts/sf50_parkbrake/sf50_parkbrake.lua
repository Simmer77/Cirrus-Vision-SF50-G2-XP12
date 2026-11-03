
--
-- CONTROLS THE PARK BRAKE HANDLE ANIMATION
--

------------------------------- FUNCTIONS: FOR WRITABLE DATAREFS -------------------------------

-- none

----------------------------------- LOCATE AND/OR CREATE DATAREFS -----------------------------------

simDR_park_brake_valve			= find_dataref("sim/cockpit2/controls/park_brake_valve")
sf50DR_park_brake_valve_anim	= create_dataref("laminar/sf50/knobs/parking_brake_valve_anim", "number")

------------------------------- FUNCTIONS -------------------------------
----- ANIMATION UTILITY -----------------------------------------------------------------
function sf50_set_animation_position(current_value, target, min, max, speed)

    local fps_factor = math.min(1.0, speed * SIM_PERIOD)

    if target >= (max - 0.001) and current_value >= (max - 0.001) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.001) then
       return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end



function sf50_park_brake_anim()

	sf50DR_park_brake_valve_anim = sf50_set_animation_position(sf50DR_park_brake_valve_anim, simDR_park_brake_valve, 0, 1, 3)

end


------------------------------- FUNCTIONS: COMMANDS CALLBACK -------------------------------

-- none

------------------------------- LOCATE AND/OR CREATE COMMANDS -------------------------------

-- none

----------------------------------- RUNTIME CODE -----------------------------------


-- DO THIS EACH FLIGHT START
--function flight_start()
	-- none
--end


-- REGULAR RUNTIME
function after_physics()
	
	sf50_park_brake_anim()

end

function after_replay()
	
	sf50_park_brake_anim()

end

