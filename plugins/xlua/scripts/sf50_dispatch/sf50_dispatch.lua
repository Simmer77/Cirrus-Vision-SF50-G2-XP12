--
-- CIRRUS VISION SF50 G2 — ELECTRONIC FLIGHT BAG (EFB) & DISPATCH MANAGER
-- Pure Metric (Kilograms) Dispatch Management
--

local KG_PER_GAL   = 3.064
local LBS_PER_KG   = 2.20462
local OEW_KG       = 1692.0
local MTOW_KG      = 2722.0

----------------------------------------------------------------------------------------------------
-- DATAREFS
----------------------------------------------------------------------------------------------------
simDR_payload_kg     = find_dataref("sim/flightmodel/weight/m_fixed")
simDR_fuel1_kg       = find_dataref("sim/flightmodel/weight/m_fuel1")
simDR_fuel2_kg       = find_dataref("sim/flightmodel/weight/m_fuel2")
simDR_fuel_total_kg  = find_dataref("sim/flightmodel/weight/m_fuel_total")
simDR_total_weight   = find_dataref("sim/flightmodel/weight/m_total")
simDR_groundspeed    = find_dataref("sim/flightmodel/position/groundspeed")

-- Custom Datarefs for 3D Tablet and Dispatch
sf50DR_tablet_show   = create_dataref("laminar/sf50/tablet/show", "number")
sf50DR_tablet_show   = 1.0
sf50DR_tablet_mode   = create_dataref("laminar/sf50/tablet/mode", "number")
sf50DR_tablet_mode   = 0.0 -- 0: Cirrus EFB Dispatch, 1: AviTab Navigraph / Moving Map

sf50DR_pax_count     = create_dataref("laminar/sf50/dispatch/pax_count", "number")
sf50DR_cargo_kg      = create_dataref("laminar/sf50/dispatch/cargo_kg", "number")
sf50DR_fuel_gal      = create_dataref("laminar/sf50/dispatch/fuel_gal", "number")
sf50DR_fuel_kg       = create_dataref("laminar/sf50/dispatch/fuel_kg", "number")
sf50DR_gross_lbs     = create_dataref("laminar/sf50/dispatch/gross_weight_lbs", "number")
sf50DR_gross_kg      = create_dataref("laminar/sf50/dispatch/gross_weight_kg", "number")
sf50DR_mtow_status   = create_dataref("laminar/sf50/dispatch/mtow_status", "number")
sf50DR_simbrief_ok   = create_dataref("laminar/sf50/dispatch/simbrief_loaded", "number")

-- Preset indicators (1 = active, 0 = inactive)
sf50DR_preset_min    = create_dataref("laminar/sf50/dispatch/preset_min", "number")
sf50DR_preset_tabs   = create_dataref("laminar/sf50/dispatch/preset_tabs", "number")
sf50DR_preset_full   = create_dataref("laminar/sf50/dispatch/preset_full", "number")

-- Free Custom sliders for panel display
simDR_slider0        = find_dataref("sim/cockpit2/switches/custom_slider_on[0]")
simDR_slider2        = find_dataref("sim/flightmodel2/misc/custom_slider_ratio[2]")
simDR_slider3        = find_dataref("sim/cockpit2/switches/custom_slider_on[3]")

----------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------------
local function apply_dispatch_kg(pax, cargo_kg, fuel_kg)
	pax      = math.max(1, math.min(5, math.floor(pax + 0.5)))
	cargo_kg = math.max(0.0, math.min(136.0, cargo_kg))
	fuel_kg  = math.max(184.0, math.min(907.0, fuel_kg))

	local payload_kg = (pax * 82.0) + cargo_kg

	simDR_payload_kg = payload_kg
	simDR_fuel1_kg   = fuel_kg * 0.5
	simDR_fuel2_kg   = fuel_kg * 0.5

	sf50DR_pax_count = pax
	sf50DR_cargo_kg  = cargo_kg
	sf50DR_fuel_kg   = fuel_kg
	sf50DR_fuel_gal  = fuel_kg / KG_PER_GAL

	local gross_kg   = OEW_KG + payload_kg + fuel_kg
	sf50DR_gross_kg  = gross_kg
	sf50DR_gross_lbs = gross_kg * LBS_PER_KG
	sf50DR_mtow_status = (gross_kg > MTOW_KG) and 1 or 0

	-- Update presets: MIN 184, TABS 429, FULL 907
	sf50DR_preset_min  = (math.abs(fuel_kg - 184.0) < 5.0) and 1 or 0
	sf50DR_preset_tabs = (math.abs(fuel_kg - 429.0) < 5.0) and 1 or 0
	sf50DR_preset_full = (math.abs(fuel_kg - 907.0) < 5.0) and 1 or 0

	if simDR_slider2 ~= nil then
		simDR_slider2 = cargo_kg
	end
	if simDR_slider3 ~= nil then
		simDR_slider3 = pax
	end
end

local function parse_simbrief_file()
	local paths = {
		"sf50_simbrief.json",
		"Aircraft/Simmr77/output_SF50G2_XP12/sf50_simbrief.json",
		"Aircraft/Extra Aircraft/Cirrus SF-50/sf50_simbrief.json",
		"Aircraft/Cirrus Vision SF50 G2/sf50_simbrief.json"
	}
	for _, p in ipairs(paths) do
		local f = io.open(p, "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content then
				local pax = tonumber(content:match('"pax"%s*:%s*(%d+)'))
				local cargo = tonumber(content:match('"cargo_kg"%s*:%s*([%d%.]+)'))
				local fuel_kg = tonumber(content:match('"fuel_kg"%s*:%s*([%d%.]+)'))
				if not fuel_kg then
					local fuel_gal = tonumber(content:match('"fuel_gal"%s*:%s*([%d%.]+)'))
					if fuel_gal then fuel_kg = fuel_gal * KG_PER_GAL end
				end
				if pax and cargo and fuel_kg then
					return pax, cargo, fuel_kg
				end
			end
		end
	end
	return nil, nil, nil
end

----------------------------------------------------------------------------------------------------
-- COMMAND HANDLERS
----------------------------------------------------------------------------------------------------

avitab_powered    = find_dataref("avitab/panel_powered")
avitab_enabled    = find_dataref("avitab/panel_enabled")
avitab_brightness = find_dataref("avitab/brightness")

function update_avitab_power()
	if avitab_powered == nil then
		avitab_powered = find_dataref("avitab/panel_powered")
	end
	if avitab_enabled == nil then
		avitab_enabled = find_dataref("avitab/panel_enabled")
	end
	if avitab_brightness == nil then
		avitab_brightness = find_dataref("avitab/brightness")
	end

	if sf50DR_tablet_show >= 0.5 and sf50DR_tablet_mode >= 0.5 then
		if avitab_powered ~= nil then avitab_powered = 1 end
		if avitab_enabled ~= nil then avitab_enabled = 1 end
		if avitab_brightness ~= nil then avitab_brightness = 1.0 end
	else
		if avitab_enabled ~= nil then avitab_enabled = 0 end
		if avitab_powered ~= nil then avitab_powered = 0 end
	end

	if simDR_slider0 ~= nil then
		simDR_slider0 = (sf50DR_tablet_show >= 0.5 and sf50DR_tablet_mode < 0.5) and 1.0 or 0.0
	end
end

function tablet_toggle_cmd(phase)
	if phase == 0 then
		if sf50DR_tablet_show >= 0.5 then
			sf50DR_tablet_show = 0.0
		else
			sf50DR_tablet_show = 1.0
		end
		update_avitab_power()
	end
end

function tablet_switch_mode_cmd(phase)
	if phase == 0 then
		if sf50DR_tablet_mode >= 0.5 then
			sf50DR_tablet_mode = 0.0
		else
			sf50DR_tablet_mode = 1.0
		end
		update_avitab_power()
	end
end

function pax_add_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count + 1, sf50DR_cargo_kg, sf50DR_fuel_kg)
	end
end

function pax_sub_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count - 1, sf50DR_cargo_kg, sf50DR_fuel_kg)
	end
end

function cargo_add_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg + 10.0, sf50DR_fuel_kg)
	end
end

function cargo_sub_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg - 10.0, sf50DR_fuel_kg)
	end
end

function fuel_min_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg, 184.0)
	end
end

function fuel_tabs_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg, 429.0)
	end
end

function fuel_full_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg, 907.0)
	end
end

function fuel_add_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg, sf50DR_fuel_kg + 25.0)
	end
end

function fuel_sub_cmd(phase)
	if phase == 0 then
		apply_dispatch_kg(sf50DR_pax_count, sf50DR_cargo_kg, sf50DR_fuel_kg - 25.0)
	end
end

function load_simbrief_cmd(phase)
	if phase == 0 then
		local pax, cargo, fuel = parse_simbrief_file()
		if pax and cargo and fuel then
			apply_dispatch_kg(pax, cargo, fuel)
			sf50DR_simbrief_ok = 1
		else
			apply_dispatch_kg(2, 25.0, 429.0)
			sf50DR_simbrief_ok = 1
		end
	end
end

----------------------------------------------------------------------------------------------------
-- CREATE COMMANDS
----------------------------------------------------------------------------------------------------
create_command("laminar/sf50/tablet/toggle",      "Toggle Tablet EFB",                 tablet_toggle_cmd)
create_command("laminar/sf50/tablet/switch_mode", "Switch Tablet Mode (EFB/AviTab)",   tablet_switch_mode_cmd)
create_command("laminar/sf50/dispatch/pax_add",   "Dispatch: Add 1 Passenger",         pax_add_cmd)
create_command("laminar/sf50/dispatch/pax_sub",   "Dispatch: Remove 1 Passenger",      pax_sub_cmd)
create_command("laminar/sf50/dispatch/cargo_add", "Dispatch: Add 10 kg Cargo",         cargo_add_cmd)
create_command("laminar/sf50/dispatch/cargo_sub", "Dispatch: Remove 10 kg Cargo",      cargo_sub_cmd)
create_command("laminar/sf50/dispatch/fuel_min",  "Dispatch: Set Min Fuel (184 kg)",   fuel_min_cmd)
create_command("laminar/sf50/dispatch/fuel_tabs", "Dispatch: Set Tabs Fuel (429 kg)",  fuel_tabs_cmd)
create_command("laminar/sf50/dispatch/fuel_full", "Dispatch: Set Full Tanks (907 kg)", fuel_full_cmd)
create_command("laminar/sf50/dispatch/fuel_add25", "Dispatch: Add 25 kg Fuel",        fuel_add_cmd)
create_command("laminar/sf50/dispatch/fuel_sub25", "Dispatch: Sub 25 kg Fuel",        fuel_sub_cmd)
create_command("laminar/sf50/dispatch/fuel_add10", "Dispatch: Add 25 kg Fuel",        fuel_add_cmd)
create_command("laminar/sf50/dispatch/fuel_sub10", "Dispatch: Sub 25 kg Fuel",        fuel_sub_cmd)
create_command("laminar/sf50/dispatch/load_simbrief", "Dispatch: Load SimBrief Plan", load_simbrief_cmd)

----------------------------------------------------------------------------------------------------
-- RUNTIME
----------------------------------------------------------------------------------------------------
function flight_start()
	sf50DR_tablet_show = 1.0
	sf50DR_tablet_mode = 0.0
	apply_dispatch_kg(2, 25.0, 429.0)
	update_avitab_power()
end

function after_physics()
	if simDR_slider0 ~= nil then
		simDR_slider0 = (sf50DR_tablet_show >= 0.5 and sf50DR_tablet_mode < 0.5) and 1.0 or 0.0
	end
	if simDR_slider2 ~= nil then
		simDR_slider2 = sf50DR_cargo_kg
	end
	if simDR_slider3 ~= nil then
		simDR_slider3 = sf50DR_pax_count
	end
end
