-- THIS SCRIPT HANDLES THE "EMERGENCY" WING LEVELER BLUE BUTTON,
-- PRECISION ALTITUDE SELECTOR, AND THE G2 PERSPECTIVE TOUCH+
-- DIGITAL AUTOTHROTTLE, FADEC & SYSTEMS/NWS PANELS

----------------------------------- LOCATE AND/OR CREATE DATAREFS -----------------------------------

airspeed_dial_kts_mach = find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts_mach")
airspeed_is_mach       = find_dataref("sim/cockpit2/autopilot/airspeed_is_mach")
airspeed_kts_pilot     = find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
mach_pilot             = find_dataref("sim/cockpit2/gauges/indicators/mach_pilot")
airspeed_accel_kts_s   = find_dataref("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot")

altitude_dial_ft       = find_dataref("sim/cockpit2/autopilot/altitude_dial_ft")
altitude_mode          = find_dataref("sim/cockpit2/autopilot/altitude_mode")
indicated_altitude_ft  = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")

autothrottle_enabled   = find_dataref("sim/cockpit2/autopilot/autothrottle_enabled")
throttle_ratio_all     = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio_all")
throttle_ratio         = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio")
onground_any           = find_dataref("sim/flightmodel/failures/onground_any")

sync_hold_pitch_deg    = find_dataref("sim/cockpit2/autopilot/sync_hold_pitch_deg")
sync_hold_roll_deg     = find_dataref("sim/cockpit2/autopilot/sync_hold_roll_deg")
flight_director_mode   = find_dataref("sim/cockpit2/autopilot/flight_director_mode") -- 0 off, 1 fd only, 2 fd+servos
simDR_efis_page        = find_dataref("sim/cockpit2/EFIS/EFIS_page")
simDR_startup_running  = find_dataref("sim/operation/prefs/startup_running")

-- G2 Systems & Nosewheel Steering panel datarefs
nosewheel_steer_on       = find_dataref("sim/cockpit2/controls/nosewheel_steer_on")
parking_brake_ratio      = find_dataref("sim/cockpit2/controls/parking_brake_ratio")
simDR_parkbrake          = find_dataref("sim/flightmodel/controls/parkbrake")
simDR_park_brake_valve   = find_dataref("sim/cockpit2/controls/park_brake_valve")
simDR_ice_surfce_heat_on = find_dataref("sim/cockpit2/ice/ice_surfce_heat_on")
simDR_ice_surfce_left    = find_dataref("sim/cockpit2/ice/ice_surfce_heat_left_on")
simDR_ice_surfce_right   = find_dataref("sim/cockpit2/ice/ice_surfce_heat_right_on")
simDR_ice_tail           = find_dataref("sim/cockpit2/ice/ice_tail_heat_on")

-- Commands for reliable Parking Brake actuation
simCMD_brakes_toggle_max  = find_command("sim/flight_controls/brakes_toggle_max")
simCMD_park_brake_set     = find_command("sim/flight_controls/park_brake_set")
simCMD_park_brake_release = find_command("sim/flight_controls/park_brake_release")
simCMD_valve_close        = find_command("sim/flight_controls/park_brake_valve_close")
simCMD_valve_open         = find_command("sim/flight_controls/park_brake_valve_open")

local function safe_cmd_once(cmd)
	if cmd ~= nil and cmd.cmd ~= nil then
		pcall(function() cmd:once() end)
	end
end

-- Native X-Plane custom slider switches (indices 10..18) bound to the G2 touchscreen buttons
btn_at_pwr     = find_dataref("sim/cockpit2/switches/custom_slider_on[10]") -- Auto T ON
btn_toga       = find_dataref("sim/cockpit2/switches/custom_slider_on[11]") -- TOGA
btn_mct        = find_dataref("sim/cockpit2/switches/custom_slider_on[12]") -- MCT
btn_spd_kts    = find_dataref("sim/cockpit2/switches/custom_slider_on[13]") -- KTS
btn_spd_mach   = find_dataref("sim/cockpit2/switches/custom_slider_on[14]") -- Mach
btn_fms        = find_dataref("sim/cockpit2/switches/custom_slider_on[15]") -- FMS
btn_max_crz    = find_dataref("sim/cockpit2/switches/custom_slider_on[16]") -- M CRS (0.530M)
btn_econ_crz   = find_dataref("sim/cockpit2/switches/custom_slider_on[17]") -- E CRS (0.489M)
btn_park_brake = find_dataref("sim/cockpit2/switches/custom_slider_on[18]") -- G2 Systems Parking Brake

function sf50_g2_fms_mode_DRhandler() end
sf50DR_init_autopilot_AI = create_dataref("laminar/sf50/AI/init_autopilot", "number")
sf50DR_g2_fms_speed_mode = create_dataref("laminar/sf50/g2/fms_speed_mode", "number", sf50_g2_fms_mode_DRhandler)

-- G2 Autothrottle & FADEC State Machine Variables
-- g2_at_active   : 0 = Speed hold OFF, 1 = Speed hold ON (Auto T ON)
-- g2_thrust_mode : 0 = Normal/Manual, 1 = TOGA (100% thrust), 2 = MCT (Max Continuous Thrust)
-- g2_fms_mode    : 0 = Manual speed, 1 = FMS cruise speed mode
-- g2_crz_preset  : 0 = None, 1 = M CRS (0.530M), 2 = E CRS (0.489M)
local g2_at_active     = 0
local g2_thrust_mode   = 0
local g2_fms_mode      = 0
local g2_crz_preset    = 0
local g2_cmd_throttle  = 0.0
local filt_accel_kts_s = 0.0

-- Altitude knob hold-repeat state
local alt_hold_next_step = 0.0

-- Previous frame button states for edge detection
local prev_btn_at         = 0
local prev_btn_toga       = 0
local prev_btn_mct        = 0
local prev_btn_kts        = 1
local prev_btn_mach       = 0
local prev_btn_fms        = 0
local prev_btn_max_crz    = 0
local prev_btn_econ_crz   = 0
local prev_btn_park_brake = 0
local prev_wing_ice       = 0

-- Linear FADEC Thrust Lever Angle (TLA) constants matching CirrusSF50.acf _fadec_tla table:
-- TLA 1.00 -> 1.00 (100% Takeoff Thrust / TOGA)
-- TLA 0.98 -> 0.98 (98% Max Continuous Thrust / MCT high-altitude cruise ceiling)
-- TLA 0.00..0.98 -> 0.00..0.98 (100% Linear continuous modulation range with zero deadband)
local TLA_TOGA_MAX = 1.000
local TLA_MCT_DET  = 0.980


--*************************************************************************************--
--** 				   MODE TRANSITION HELPERS & CUSTOM COMMANDS				     **--
--*************************************************************************************--

local function clamp(val, lo, hi)
	if val < lo then return lo end
	if val > hi then return hi end
	return val
end

local function enter_toga_mode()
	g2_thrust_mode  = 1
	g2_at_active    = 1
	g2_fms_mode     = 0
	g2_crz_preset   = 0
	sf50DR_g2_fms_speed_mode = 0
	g2_cmd_throttle = clamp(throttle_ratio_all, 0.0, 1.0)
	if airspeed_is_mach == 0 and airspeed_dial_kts_mach < 120.0 then
		airspeed_dial_kts_mach = 160.0
	end
	if flight_director_mode == 0 then
		flight_director_mode = 1
		sync_hold_pitch_deg = 8.0
		sync_hold_roll_deg = 0.0
	end
end

local function enter_mct_mode()
	-- Engaging MCT disengages TOGA, latches MCT ON, and activates Auto T ON speed regulation
	-- from the current throttle lever position (bumpless, linear transition)
	g2_thrust_mode   = 2
	g2_at_active     = 1
	g2_cmd_throttle  = clamp(throttle_ratio_all, 0.0, TLA_MCT_DET)
	filt_accel_kts_s = airspeed_accel_kts_s or 0.0
end

local function enter_at_speed_mode()
	g2_at_active     = 1
	g2_thrust_mode   = 2
	g2_cmd_throttle  = clamp(throttle_ratio_all, 0.0, TLA_MCT_DET)
	filt_accel_kts_s = airspeed_accel_kts_s or 0.0
end

local function select_kts_mode()
	local was_mach = (airspeed_is_mach == 1)
	local cur_dial = airspeed_dial_kts_mach
	airspeed_is_mach = 0
	g2_fms_mode = 0
	g2_crz_preset = 0
	sf50DR_g2_fms_speed_mode = 0

	if was_mach or cur_dial <= 1.0 then
		local cur_ias  = airspeed_kts_pilot or 150.0
		local cur_mach = mach_pilot or 0.0
		if cur_ias > 65.0 and cur_mach > 0.10 and cur_dial > 0.15 and cur_dial <= 0.60 then
			local conv_kts = math.floor(cur_dial * (cur_ias / cur_mach) + 0.5)
			airspeed_dial_kts_mach = clamp(conv_kts, 85.0, 250.0)
		elseif cur_ias > 85.0 then
			airspeed_dial_kts_mach = clamp(math.floor(cur_ias + 0.5), 85.0, 250.0)
		else
			airspeed_dial_kts_mach = 160.0
		end
	else
		airspeed_dial_kts_mach = clamp(math.floor(cur_dial + 0.5), 85.0, 250.0)
	end
end

local function select_mach_mode(target_mach)
	local was_kts  = (airspeed_is_mach == 0)
	local cur_dial = airspeed_dial_kts_mach
	airspeed_is_mach = 1

	if target_mach ~= nil then
		airspeed_dial_kts_mach = target_mach
	elseif was_kts or cur_dial > 1.0 then
		local cur_ias  = airspeed_kts_pilot or 0.0
		local cur_mach = mach_pilot or 0.0
		if cur_ias > 65.0 and cur_mach > 0.10 and cur_dial >= 80.0 then
			local conv_mach = cur_dial * (cur_mach / cur_ias)
			conv_mach = math.floor(conv_mach * 1000.0 + 0.5) / 1000.0
			airspeed_dial_kts_mach = clamp(conv_mach, 0.250, 0.530)
		elseif cur_mach >= 0.250 then
			local sync_m = math.floor(cur_mach * 1000.0 + 0.5) / 1000.0
			airspeed_dial_kts_mach = clamp(sync_m, 0.250, 0.530)
		else
			airspeed_dial_kts_mach = 0.500
		end
	else
		airspeed_dial_kts_mach = clamp(cur_dial, 0.250, 0.535)
	end
end

local function select_max_crz_preset()
	g2_fms_mode = 1
	g2_crz_preset = 1
	sf50DR_g2_fms_speed_mode = 1
	select_mach_mode(0.530)
	if onground_any == 0 or g2_thrust_mode ~= 0 or g2_at_active == 1 then
		g2_at_active     = 1
		g2_thrust_mode   = 2
		g2_cmd_throttle  = clamp(throttle_ratio_all, 0.0, TLA_MCT_DET)
		filt_accel_kts_s = airspeed_accel_kts_s or 0.0
	end
end

local function select_econ_crz_preset()
	g2_fms_mode = 1
	g2_crz_preset = 2
	sf50DR_g2_fms_speed_mode = 1
	select_mach_mode(0.489)
	if onground_any == 0 or g2_thrust_mode ~= 0 or g2_at_active == 1 then
		g2_at_active     = 1
		g2_thrust_mode   = 2
		g2_cmd_throttle  = clamp(throttle_ratio_all, 0.0, TLA_MCT_DET)
		filt_accel_kts_s = airspeed_accel_kts_s or 0.0
	end
end

-- Custom G2 Commands
function sf50_autopilot_quick_start_CMDhandler(phase, _)
	if phase == 0 then
		init_autopilot_AI()
	end
end
sf50CMD_autopilot_quick_start = create_command("laminar/sf50/ai/autopilot_quick_start", "AI Autopilot Quick Start Init", sf50_autopilot_quick_start_CMDhandler)

function sf50_g2_toga_CMDhandler(phase, _)
	if phase == 0 then
		if g2_thrust_mode ~= 1 then
			enter_toga_mode()
		else
			g2_thrust_mode = 0
			g2_at_active   = 0
		end
	end
end
sf50CMD_g2_toga = create_command("laminar/sf50/g2/toga_thrust", "SF50 G2 FADEC TOGA Thrust", sf50_g2_toga_CMDhandler)

function sf50_g2_mct_CMDhandler(phase, _)
	if phase == 0 then
		enter_mct_mode()
	end
end
sf50CMD_g2_mct = create_command("laminar/sf50/g2/mct_thrust", "SF50 G2 FADEC Max Continuous Thrust (MCT)", sf50_g2_mct_CMDhandler)

function sf50_g2_max_crz_CMDhandler(phase, _)
	if phase == 0 then
		select_max_crz_preset()
	end
end
sf50CMD_g2_max_crz = create_command("laminar/sf50/g2/max_cruise_mach", "SF50 G2 Max Cruise Speed (0.530M)", sf50_g2_max_crz_CMDhandler)

function sf50_g2_econ_crz_CMDhandler(phase, _)
	if phase == 0 then
		select_econ_crz_preset()
	end
end
sf50CMD_g2_econ_crz = create_command("laminar/sf50/g2/econ_cruise_mach", "SF50 G2 Economy Cruise Speed (0.489M)", sf50_g2_econ_crz_CMDhandler)

-- Autothrottle Arm / Toggle Handlers (Auto T ON)
function sf50_g2_at_toggle_CMDhandler(phase, _)
	if phase == 0 then
		if g2_at_active == 0 then
			enter_at_speed_mode()
		else
			g2_at_active   = 0
			g2_thrust_mode = 0
			g2_fms_mode    = 0
			g2_crz_preset  = 0
			sf50DR_g2_fms_speed_mode = 0
		end
	end
end
sf50CMD_g2_at_toggle = create_command("laminar/sf50/g2/autothrottle_toggle", "SF50 G2 Autothrottle Toggle (Auto T ON)", sf50_g2_at_toggle_CMDhandler)
cmd_at_toggle        = replace_command("sim/autopilot/autothrottle_toggle", sf50_g2_at_toggle_CMDhandler)
cmd_at_arm           = replace_command("sim/autopilot/autothrottle_arm",    sf50_g2_at_toggle_CMDhandler)

-- Speed Mode Toggle & Select Handlers (KTS / Mach)
function sf50_g2_speed_toggle_CMDhandler(phase, _)
	if phase == 0 then
		if airspeed_is_mach == 1 then
			select_kts_mode()
		else
			g2_fms_mode = 0
			g2_crz_preset = 0
			sf50DR_g2_fms_speed_mode = 0
			select_mach_mode(nil)
		end
	end
end
sf50CMD_g2_spd_toggle = create_command("laminar/sf50/g2/speed_mode_toggle", "SF50 G2 Speed Mode Toggle (KTS/Mach)", sf50_g2_speed_toggle_CMDhandler)
cmd_spd_toggle        = replace_command("sim/autopilot/knots_mach_toggle",  sf50_g2_speed_toggle_CMDhandler)

function sf50_g2_speed_kts_CMDhandler(phase, _)
	if phase == 0 then
		select_kts_mode()
	end
end
sf50CMD_g2_spd_kts = create_command("laminar/sf50/g2/speed_mode_kts", "SF50 G2 Speed Mode Select Knots (KTS)", sf50_g2_speed_kts_CMDhandler)

function sf50_g2_speed_mach_CMDhandler(phase, _)
	if phase == 0 then
		g2_fms_mode = 0
		g2_crz_preset = 0
		sf50DR_g2_fms_speed_mode = 0
		select_mach_mode(nil)
	end
end
sf50CMD_g2_spd_mach = create_command("laminar/sf50/g2/speed_mode_mach", "SF50 G2 Speed Mode Select Mach", sf50_g2_speed_mach_CMDhandler)

-- Emergency Level Button Handler
function lvl_ebtn_handler(phase, duration)
	if phase == 0 then
		flight_director_mode = 2
		sync_hold_pitch_deg = 0
		sync_hold_roll_deg = 0
	end
end
cmd_lvl_ebtn = replace_command("sim/autopilot/wing_leveler", lvl_ebtn_handler)

-- Precision 100-ft / 1000-ft Altitude Selector Handlers
local function step_altitude_dial(dir, phase, duration)
	local cur_alt = math.floor(((altitude_dial_ft or 0.0) + 50.0) / 100.0) * 100.0
	if phase == 0 then
		altitude_dial_ft = clamp(cur_alt + (dir * 100.0), 0.0, 31000.0)
		alt_hold_next_step = 0.35
	elseif phase == 1 then
		local dur = duration or 0.0
		if dur >= alt_hold_next_step then
			local step = (dur >= 1.50) and 500.0 or 100.0
			altitude_dial_ft = clamp(cur_alt + (dir * step), 0.0, 31000.0)
			alt_hold_next_step = dur + 0.10
		end
	end
end

function sf50_alt_up_CMDhandler(phase, duration)
	step_altitude_dial(1, phase, duration)
end
cmd_alt_up = replace_command("sim/autopilot/altitude_up", sf50_alt_up_CMDhandler)

function sf50_alt_dn_CMDhandler(phase, duration)
	step_altitude_dial(-1, phase, duration)
end
cmd_alt_dn = replace_command("sim/autopilot/altitude_down", sf50_alt_dn_CMDhandler)


--*************************************************************************************--
--** 			  G2 AUTOTHROTTLE & FADEC CLOSED-LOOP SPEED CONTROLLER    			 **--
--*************************************************************************************--

local function run_g2_throttle_servo(dt)
	-- Keep X-Plane's internal C++ autothrottle declutched (0) so our G2 FADEC/AT servo
	-- has 100% deterministic, linear authority over throttle_ratio_all
	if autothrottle_enabled ~= 0 then
		autothrottle_enabled = 0
	end

	-- Low-pass filter airspeed acceleration (1.2s time constant) so pitch attitude changes
	-- or turbulence never cause abrupt throttle twitches
	local raw_accel = airspeed_accel_kts_s or 0.0
	filt_accel_kts_s = filt_accel_kts_s + (raw_accel - filt_accel_kts_s) * (dt / (1.2 + dt))

	-- Mode 1: TOGA (Smooth linear ramp to 100% Max Takeoff / Go-Around Thrust)
	if g2_thrust_mode == 1 then
		g2_cmd_throttle = clamp(g2_cmd_throttle + 0.18 * dt, 0.0, TLA_TOGA_MAX)
		throttle_ratio_all = g2_cmd_throttle
		throttle_ratio[0]  = g2_cmd_throttle
		return
	end

	-- Mode 2: Auto T ON Speed Regulation (with MCT continuous thrust limit)
	if g2_at_active == 1 then
		local cur_ias  = airspeed_kts_pilot or 0.0
		local cur_mach = mach_pilot or 0.0
		local err_kts  = 0.0

		-- IMPORTANT: Never write to sim/cockpit2/autopilot/airspeed_dial_kts here!
		-- In X-Plane 12, writing to airspeed_dial_kts overwrites airspeed_dial_kts_mach
		-- and corrupts the active Mach target (such as 0.489 in E CRS or 0.530 in M CRS).
		if airspeed_is_mach == 0 then
			local target_kts = clamp(airspeed_dial_kts_mach, 80.0, 250.0)
			err_kts = target_kts - cur_ias
		else
			local target_mach = clamp(airspeed_dial_kts_mach, 0.200, 0.550)
			-- Scale Mach error by 600 kts/Mach (TAS equivalent) so high-altitude Mach control
			-- at FL280-FL310 has crisp, accurate authority down to ±0.001 Mach
			err_kts = (target_mach - cur_mach) * 600.0
		end

		-- If Autopilot servos are engaged (flight_director_mode == 2) in active FLC climb/descent
		-- (altitude_mode == 5 and > 150 ft away from target altitude), hold steady MCT climb thrust
		-- (or idle descent thrust) so the autothrottle never fights the elevator for airspeed.
		local ap_alt_mode = altitude_mode or 0
		local cur_alt     = indicated_altitude_ft or 0.0
		local dial_alt    = altitude_dial_ft or cur_alt
		if flight_director_mode == 2 and ap_alt_mode == 5 and math.abs(dial_alt - cur_alt) > 150.0 then
			local target_tla = (dial_alt >= cur_alt) and TLA_MCT_DET or 0.120
			local diff = target_tla - g2_cmd_throttle
			local step = clamp(diff, -0.065 * dt, 0.065 * dt)
			g2_cmd_throttle = clamp(g2_cmd_throttle + step, 0.0, TLA_MCT_DET)
			throttle_ratio_all = g2_cmd_throttle
			throttle_ratio[0]  = g2_cmd_throttle
			return
		end

		-- Smooth, linear PI-D throttle rate law:
		-- Accurately tracks KTS or Mach targets (including 0.530 M CRS and 0.489 E CRS)
		-- without exciting pitch-thrust coupling on the dorsal FJ33 engine.
		local thro_rate = (err_kts * 0.0065) - (filt_accel_kts_s * 0.016)
		thro_rate = clamp(thro_rate, -0.065, 0.065)

		g2_cmd_throttle = clamp(g2_cmd_throttle + thro_rate * dt, 0.0, TLA_MCT_DET)
		throttle_ratio_all = g2_cmd_throttle
		throttle_ratio[0]  = g2_cmd_throttle
		return
	end

	-- Mode 3: Manual Throttle (track current physical lever position for bumpless engagement)
	g2_cmd_throttle = clamp(throttle_ratio_all, 0.0, 1.0)
end


--*************************************************************************************--
--** 				         TOUCHSCREEN PANEL PROCESSING          	     	  		 **--
--*************************************************************************************--

local function update_g2_autothrottle_panel()
	local dt = SIM_PERIOD or 0.016
	if dt <= 0.0 then dt = 0.016 end
	if dt > 0.10 then dt = 0.10 end

	-- 1. Sample all touchscreen button click edges BEFORE mutating any state
	local clicked_at       = (btn_at_pwr   ~= prev_btn_at)
	local clicked_toga     = (btn_toga     ~= prev_btn_toga)
	local clicked_mct      = (btn_mct      ~= prev_btn_mct)
	local clicked_kts      = (btn_spd_kts  ~= prev_btn_kts)
	local clicked_mach     = (btn_spd_mach ~= prev_btn_mach)
	local clicked_fms      = (btn_fms      ~= prev_btn_fms)
	local clicked_max_crz  = (btn_max_crz  ~= prev_btn_max_crz)
	local clicked_econ_crz = (btn_econ_crz ~= prev_btn_econ_crz)
	local clicked_pbrake   = (btn_park_brake ~= prev_btn_park_brake)

	-- 2. Process Thrust & Autothrottle Mode Buttons (TOGA, MCT, Auto T ON)
	if clicked_toga then
		if g2_thrust_mode ~= 1 then
			enter_toga_mode()
		else
			g2_thrust_mode = 0
			g2_at_active   = 0
		end
	elseif clicked_mct then
		enter_mct_mode()
	elseif clicked_at then
		if g2_at_active == 0 then
			enter_at_speed_mode()
		else
			g2_at_active   = 0
			g2_thrust_mode = 0
			g2_fms_mode    = 0
			g2_crz_preset  = 0
			sf50DR_g2_fms_speed_mode = 0
		end
	end

	-- 3. Process Speed Mode & FMS Cruise Preset Buttons (KTS, Mach, FMS, M CRS, E CRS)
	if clicked_kts then
		select_kts_mode()
	elseif clicked_mach then
		g2_fms_mode = 0
		g2_crz_preset = 0
		sf50DR_g2_fms_speed_mode = 0
		select_mach_mode(nil)
	elseif clicked_max_crz then
		select_max_crz_preset()
	elseif clicked_econ_crz then
		select_econ_crz_preset()
	elseif clicked_fms then
		if g2_fms_mode == 0 then
			if g2_crz_preset == 2 then
				select_econ_crz_preset()
			else
				select_max_crz_preset()
			end
		else
			g2_fms_mode = 0
			g2_crz_preset = 0
			sf50DR_g2_fms_speed_mode = 0
		end
	end

	-- 4. Maintain FMS Preset Lock (0.530 for M CRS, 0.489 for E CRS) or Manual Speed Dial
	if g2_fms_mode == 1 and (g2_crz_preset == 1 or g2_crz_preset == 2) then
		local preset_mach = (g2_crz_preset == 2) and 0.489 or 0.530
		if airspeed_is_mach ~= 1 then
			airspeed_is_mach = 1
		end
		local diff = math.abs(airspeed_dial_kts_mach - preset_mach)
		-- If the user rotated the Speed Set knob by a single step (0.001 or 0.010),
		-- switch cleanly to Manual Mach mode at that newly dialed Mach value.
		-- Otherwise, keep the FMS preset strictly locked at 0.530 or 0.489.
		if diff >= 0.0008 and diff <= 0.012 then
			g2_fms_mode = 0
			g2_crz_preset = 0
			sf50DR_g2_fms_speed_mode = 0
			airspeed_dial_kts_mach = clamp(airspeed_dial_kts_mach, 0.250, 0.535)
		else
			airspeed_dial_kts_mach = preset_mach
		end
	elseif airspeed_is_mach == 1 then
		if airspeed_dial_kts_mach > 1.0 then
			airspeed_dial_kts_mach = 0.500
		else
			airspeed_dial_kts_mach = clamp(airspeed_dial_kts_mach, 0.250, 0.535)
		end
	else
		if airspeed_dial_kts_mach < 60.0 then
			airspeed_dial_kts_mach = 160.0
		else
			airspeed_dial_kts_mach = clamp(airspeed_dial_kts_mach, 80.0, 250.0)
		end
		g2_fms_mode = 0
		g2_crz_preset = 0
		sf50DR_g2_fms_speed_mode = 0
	end

	-- 5. Execute the Closed-Loop Autothrottle / FADEC Servo
	run_g2_throttle_servo(dt)

	-- 6. Synchronize all 8 G2 Autothrottle touchscreen button indicator states
	btn_at_pwr   = g2_at_active
	btn_toga     = (g2_thrust_mode == 1) and 1 or 0
	btn_mct      = (g2_thrust_mode == 2) and 1 or 0
	btn_spd_kts  = (airspeed_is_mach == 0) and 1 or 0
	btn_spd_mach = (airspeed_is_mach == 1) and 1 or 0
	btn_fms      = g2_fms_mode
	btn_max_crz  = (g2_fms_mode == 1 and g2_crz_preset == 1) and 1 or 0
	btn_econ_crz = (g2_fms_mode == 1 and g2_crz_preset == 2) and 1 or 0

	prev_btn_at       = btn_at_pwr
	prev_btn_toga     = btn_toga
	prev_btn_mct      = btn_mct
	prev_btn_kts      = btn_spd_kts
	prev_btn_mach     = btn_spd_mach
	prev_btn_fms      = btn_fms
	prev_btn_max_crz  = btn_max_crz
	prev_btn_econ_crz = btn_econ_crz

	-- 7. G2 Systems Panel: Parking Brake button (custom_slider_on[18])
	if clicked_pbrake then
		if btn_park_brake == 1 then
			-- User tapped "Brakes ON": engage brakes firmly
			safe_cmd_once(simCMD_park_brake_set)
			safe_cmd_once(simCMD_valve_close)
			if simDR_parkbrake < 0.5 then
				safe_cmd_once(simCMD_brakes_toggle_max)
			end
			simDR_parkbrake = 1.0
			parking_brake_ratio = 1.0
			simDR_park_brake_valve = 1
		else
			-- User tapped "Brakes OFF": release all brakes
			safe_cmd_once(simCMD_park_brake_release)
			safe_cmd_once(simCMD_valve_open)
			if simDR_parkbrake > 0.5 then
				safe_cmd_once(simCMD_brakes_toggle_max)
			end
			simDR_parkbrake = 0.0
			parking_brake_ratio = 0.0
			simDR_park_brake_valve = 0
		end
	else
		-- Bidirectional synchronization with physical inputs (keyboard 'V', 3D pedestal lever, joystick pedals)
		local is_braking = (simDR_parkbrake > 0.5) or (parking_brake_ratio > 0.5) or (simDR_park_brake_valve == 1)
		if is_braking then
			btn_park_brake = 1
			if simDR_park_brake_valve == 0 then
				simDR_park_brake_valve = 1
			end
			if simDR_parkbrake < 0.5 then
				simDR_parkbrake = 1.0
			end
			if parking_brake_ratio < 0.5 then
				parking_brake_ratio = 1.0
			end
		else
			btn_park_brake = 0
			if simDR_park_brake_valve == 1 then
				simDR_park_brake_valve = 0
			end
			if simDR_parkbrake > 0.5 then
				simDR_parkbrake = 0.0
			end
			if parking_brake_ratio > 0.5 then
				parking_brake_ratio = 0.0
			end
		end
	end
	prev_btn_park_brake = btn_park_brake

	-- 8. G2 Systems Panel: Sync Wing Anti-Ice (surface_heat_on -> left/right wing + tail heat)
	if simDR_ice_surfce_heat_on ~= prev_wing_ice then
		simDR_ice_surfce_left  = simDR_ice_surfce_heat_on
		simDR_ice_surfce_right = simDR_ice_surfce_heat_on
		simDR_ice_tail         = simDR_ice_surfce_heat_on
		prev_wing_ice          = simDR_ice_surfce_heat_on
	end
end


--===| AI INITIALIZE (Auto-Board / Auto-Start) |=========================================
function init_autopilot_AI()
	if sf50DR_init_autopilot_AI == 1 then	-- Monitor AI for auto-board call
		init_autopilot_all_modes()
		init_autopilot_CD()
		sf50DR_init_autopilot_AI = 2
	end
end

--===| INITIALIZE COLD & DARK |==========================================================
function init_autopilot_CD()
end

--===| INITIALIZE ENGINES RUNNING |======================================================
function init_autopilot_ER()
end

--===| INITIALIZE ALL MODES |============================================================
function init_autopilot_all_modes()
	sf50DR_init_autopilot_AI = 0
	sf50DR_g2_fms_speed_mode = 0
	simDR_efis_page[0] = 2
	simDR_efis_page[1] = 7
	nosewheel_steer_on = 1

	g2_at_active     = 0
	g2_thrust_mode   = 0
	g2_fms_mode      = 0
	g2_crz_preset    = 0
	g2_cmd_throttle  = clamp(throttle_ratio_all or 0.0, 0.0, 1.0)
	filt_accel_kts_s = 0.0
	autothrottle_enabled = 0

	if airspeed_is_mach == 0 and airspeed_dial_kts_mach < 60.0 then
		airspeed_dial_kts_mach = 150.0
	end

	btn_at_pwr     = 0
	btn_toga       = 0
	btn_mct        = 0
	btn_spd_kts    = (airspeed_is_mach == 0) and 1 or 0
	btn_spd_mach   = (airspeed_is_mach == 1) and 1 or 0
	btn_fms        = 0
	btn_max_crz    = 0
	btn_econ_crz   = 0
	local is_init_braking = (simDR_parkbrake > 0.5) or (parking_brake_ratio > 0.5) or (simDR_park_brake_valve == 1)
	btn_park_brake = is_init_braking and 1 or 0

	prev_btn_at         = btn_at_pwr
	prev_btn_toga       = btn_toga
	prev_btn_mct        = btn_mct
	prev_btn_kts        = btn_spd_kts
	prev_btn_mach       = btn_spd_mach
	prev_btn_fms        = btn_fms
	prev_btn_max_crz    = btn_max_crz
	prev_btn_econ_crz   = btn_econ_crz
	prev_btn_park_brake = btn_park_brake
	prev_wing_ice       = simDR_ice_surfce_heat_on
end


--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	        			 **--
--*************************************************************************************--

function flight_start()
	init_autopilot_all_modes()
	if simDR_startup_running == 0 then
		init_autopilot_CD()
	elseif simDR_startup_running == 1 then
		init_autopilot_ER()
	end
end

function after_physics()
	init_autopilot_AI()
	update_g2_autothrottle_panel()
end
