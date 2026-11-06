--
-- CIRRUS VISION SF50 G2 — ELECTRONIC FLIGHT BAG (EFB) & DISPATCH MANAGER
-- Handles 3D Cockpit Tablet Mount, Live Fuel Loading, Passenger Payload & SimBrief Integration
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
sf50DR_pax_count     = create_dataref("laminar/sf50/dispatch/pax_count", "number")
sf50DR_cargo_kg      = create_dataref("laminar/sf50/dispatch/cargo_kg", "number")
sf50DR_fuel_gal      = create_dataref("laminar/sf50/dispatch/fuel_gal", "number")
sf50DR_fuel_kg       = create_dataref("laminar/sf50/dispatch/fuel_kg", "number")
sf50DR_gross_lbs     = create_dataref("laminar/sf50/dispatch/gross_weight_lbs", "number")
sf50DR_gross_kg      = create_dataref("laminar/sf50/dispatch/gross_weight_kg", "number")
sf50DR_mtow_status   = create_dataref("laminar/sf50/dispatch/mtow_status", "number")
sf50DR_simbrief_ok   = create_dataref("laminar/sf50/dispatch/simbrief_loaded", "number")

----------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------------
local function apply_dispatch(pax, cargo, fuel_gal)
	pax      = math.max(1, math.min(5, math.floor(pax + 0.5)))
	cargo    = math.max(0.0, math.min(136.0, cargo))
	fuel_gal = math.max(20.0, math.min(296.0, fuel_gal))

	local fuel_kg    = fuel_gal * KG_PER_GAL
	local payload_kg = (pax * 82.0) + cargo

	simDR_payload_kg = payload_kg
	simDR_fuel1_kg   = fuel_kg * 0.5
	simDR_fuel2_kg   = fuel_kg * 0.5

	sf50DR_pax_count = pax
	sf50DR_cargo_kg  = cargo
	sf50DR_fuel_gal  = fuel_gal
	sf50DR_fuel_kg   = fuel_kg

	local gross_kg   = OEW_KG + payload_kg + fuel_kg
	sf50DR_gross_kg  = gross_kg
	sf50DR_gross_lbs = gross_kg * LBS_PER_KG
	sf50DR_mtow_status = (gross_kg > MTOW_KG) and 1 or 0
end

local function parse_simbrief_file()
	local paths = {
		"sf50_simbrief.json",
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
				local fuel = tonumber(content:match('"fuel_gal"%s*:%s*([%d%.]+)'))
				if pax and cargo and fuel then
					return pax, cargo, fuel
				end
			end
		end
	end
	return nil, nil, nil
end

----------------------------------------------------------------------------------------------------
-- COMMAND HANDLERS
----------------------------------------------------------------------------------------------------
function tablet_toggle_cmd(phase)
	if phase == 0 then
		if sf50DR_tablet_show >= 0.5 then
			sf50DR_tablet_show = 0.0
		else
			sf50DR_tablet_show = 1.0
		end
	end
end

function pax_add_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count + 1, sf50DR_cargo_kg, sf50DR_fuel_gal)
	end
end

function pax_sub_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count - 1, sf50DR_cargo_kg, sf50DR_fuel_gal)
	end
end

function cargo_add_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg + 10.0, sf50DR_fuel_gal)
	end
end

function cargo_sub_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg - 10.0, sf50DR_fuel_gal)
	end
end

function fuel_min_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg, 60.0) -- 60 gal legal min
	end
end

function fuel_tabs_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg, 140.0) -- 140 gal tabs
	end
end

function fuel_full_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg, 296.0) -- 296 gal full
	end
end

function fuel_add10_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg, sf50DR_fuel_gal + 10.0)
	end
end

function fuel_sub10_cmd(phase)
	if phase == 0 then
		apply_dispatch(sf50DR_pax_count, sf50DR_cargo_kg, sf50DR_fuel_gal - 10.0)
	end
end

function load_simbrief_cmd(phase)
	if phase == 0 then
		local pax, cargo, fuel = parse_simbrief_file()
		if pax and cargo and fuel then
			apply_dispatch(pax, cargo, fuel)
			sf50DR_simbrief_ok = 1
		else
			-- Standard default balanced load (2 PAX, 25 kg baggage, 140 gal Tabs)
			apply_dispatch(2, 25.0, 140.0)
			sf50DR_simbrief_ok = 1
		end
	end
end

----------------------------------------------------------------------------------------------------
-- CREATE COMMANDS
----------------------------------------------------------------------------------------------------
create_command("laminar/sf50/tablet/toggle",      "Toggle Tablet EFB",                 tablet_toggle_cmd)
create_command("laminar/sf50/dispatch/pax_add",   "Dispatch: Add 1 Passenger",         pax_add_cmd)
create_command("laminar/sf50/dispatch/pax_sub",   "Dispatch: Remove 1 Passenger",      pax_sub_cmd)
create_command("laminar/sf50/dispatch/cargo_add", "Dispatch: Add 10 kg Cargo",         cargo_add_cmd)
create_command("laminar/sf50/dispatch/cargo_sub", "Dispatch: Remove 10 kg Cargo",      cargo_sub_cmd)
create_command("laminar/sf50/dispatch/fuel_min",  "Dispatch: Set Min Fuel (60 gal)",   fuel_min_cmd)
create_command("laminar/sf50/dispatch/fuel_tabs", "Dispatch: Set Tabs Fuel (140 gal)", fuel_tabs_cmd)
create_command("laminar/sf50/dispatch/fuel_full", "Dispatch: Set Full Tanks (296 gal)",fuel_full_cmd)
create_command("laminar/sf50/dispatch/fuel_add10","Dispatch: Add 10 gal Fuel",         fuel_add10_cmd)
create_command("laminar/sf50/dispatch/fuel_sub10","Dispatch: Sub 10 gal Fuel",         fuel_sub10_cmd)
create_command("laminar/sf50/dispatch/load_simbrief", "Dispatch: Load SimBrief Plan", load_simbrief_cmd)

----------------------------------------------------------------------------------------------------
-- RUNTIME
----------------------------------------------------------------------------------------------------
function flight_start()
	sf50DR_tablet_show = 1.0 -- Mount tablet deployed by default
	sf50DR_simbrief_ok = 0

	-- Read current fuel and payload from simulator state
	local current_fuel_kg = (simDR_fuel1_kg + simDR_fuel2_kg)
	local current_fuel_gal = current_fuel_kg / KG_PER_GAL
	if current_fuel_gal < 20.0 or current_fuel_gal > 300.0 then
		current_fuel_gal = 140.0 -- default to tabs
	end

	local current_payload = simDR_payload_kg
	local est_pax = math.max(1, math.min(5, math.floor(current_payload / 82.0)))
	local est_cargo = math.max(0.0, math.min(136.0, current_payload - (est_pax * 82.0)))

	apply_dispatch(est_pax, est_cargo, current_fuel_gal)
end

function after_physics()
	-- Keep gross weight and MTOW status actively synchronized
	local current_fuel_kg = simDR_fuel1_kg + simDR_fuel2_kg
	sf50DR_fuel_kg = current_fuel_kg
	sf50DR_fuel_gal = current_fuel_kg / KG_PER_GAL

	local gross_kg = OEW_KG + simDR_payload_kg + current_fuel_kg
	sf50DR_gross_kg = gross_kg
	sf50DR_gross_lbs = gross_kg * LBS_PER_KG
	sf50DR_mtow_status = (gross_kg > MTOW_KG) and 1 or 0
end
