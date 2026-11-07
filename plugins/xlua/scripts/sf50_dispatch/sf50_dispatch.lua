--
-- CIRRUS VISION SF50 G2 — ELECTRONIC FLIGHT BAG (EFB) & DISPATCH MANAGER
-- Pure Metric (Kilograms) Dispatch Management
--

local KG_PER_GAL   = 3.064
local LBS_PER_KG   = 2.20462
local OEW_KG       = 1692.0
local MTOW_KG      = 2722.0
local PAX_WEIGHT_KG = 77.0 -- 170 lbs (Standard FAA / FSEconomy adult passenger weight)

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

-- Live Digit Datarefs for 3D Numeric Readouts
sf50DR_cargo_d1      = create_dataref("laminar/sf50/dispatch/cargo_d1", "number")
sf50DR_cargo_d2      = create_dataref("laminar/sf50/dispatch/cargo_d2", "number")
sf50DR_cargo_d3      = create_dataref("laminar/sf50/dispatch/cargo_d3", "number")

sf50DR_fuel_d1       = create_dataref("laminar/sf50/dispatch/fuel_d1", "number")
sf50DR_fuel_d2       = create_dataref("laminar/sf50/dispatch/fuel_d2", "number")
sf50DR_fuel_d3       = create_dataref("laminar/sf50/dispatch/fuel_d3", "number")

sf50DR_pay_d1        = create_dataref("laminar/sf50/dispatch/pay_d1", "number")
sf50DR_pay_d2        = create_dataref("laminar/sf50/dispatch/pay_d2", "number")
sf50DR_pay_d3        = create_dataref("laminar/sf50/dispatch/pay_d3", "number")

sf50DR_tow_d1        = create_dataref("laminar/sf50/dispatch/tow_d1", "number")
sf50DR_tow_d2        = create_dataref("laminar/sf50/dispatch/tow_d2", "number")
sf50DR_tow_d3        = create_dataref("laminar/sf50/dispatch/tow_d3", "number")
sf50DR_tow_d4        = create_dataref("laminar/sf50/dispatch/tow_d4", "number")

-- Free Custom sliders for panel display
simDR_slider0        = find_dataref("sim/cockpit2/switches/custom_slider_on[0]")
simDR_slider2        = find_dataref("sim/flightmodel2/misc/custom_slider_ratio[2]")
simDR_slider3        = find_dataref("sim/cockpit2/switches/custom_slider_on[3]")

----------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------------
local function apply_dispatch_kg(pax, cargo_kg, fuel_kg, explicit_payload_kg)
	pax      = math.max(1, math.min(5, math.floor(pax + 0.5)))
	cargo_kg = math.max(0.0, math.min(136.0, cargo_kg))
	fuel_kg  = math.max(184.0, math.min(907.0, fuel_kg))

	local payload_kg
	if explicit_payload_kg ~= nil and explicit_payload_kg > 0 then
		payload_kg = explicit_payload_kg
	else
		payload_kg = (pax * PAX_WEIGHT_KG) + cargo_kg
	end

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

	-- Update live digit datarefs
	local c = math.floor(cargo_kg + 0.5)
	sf50DR_cargo_d1 = (c >= 100) and (math.floor(c / 100) % 10) or -1
	sf50DR_cargo_d2 = (c >= 10) and (math.floor(c / 10) % 10) or -1
	sf50DR_cargo_d3 = c % 10

	local f = math.floor(fuel_kg + 0.5)
	sf50DR_fuel_d1  = math.floor(f / 100) % 10
	sf50DR_fuel_d2  = math.floor(f / 10) % 10
	sf50DR_fuel_d3  = f % 10

	local p = math.floor(payload_kg + 0.5)
	sf50DR_pay_d1   = (p >= 100) and (math.floor(p / 100) % 10) or -1
	sf50DR_pay_d2   = math.floor(p / 10) % 10
	sf50DR_pay_d3   = p % 10

	local t = math.floor(gross_kg + 0.5)
	sf50DR_tow_d1   = math.floor(t / 1000) % 10
	sf50DR_tow_d2   = math.floor(t / 100) % 10
	sf50DR_tow_d3   = math.floor(t / 10) % 10
	sf50DR_tow_d4   = t % 10

	if simDR_slider2 ~= nil then
		simDR_slider2 = cargo_kg
	end
	if simDR_slider3 ~= nil then
		simDR_slider3 = pax
	end
end

local function get_aircraft_dir_paths(filename)
	return {
		filename,
		"Aircraft/Cirrus Vision SF50 G2/" .. filename,
		"Aircraft/Simmr77/Cirrus Vision SF50 G2/" .. filename,
		"Aircraft/Cirrus Vision SF50 G2 XP12/" .. filename,
		"Aircraft/output_SF50G2_XP12/" .. filename,
		"Aircraft/Simmr77/output_SF50G2_XP12/" .. filename,
		"Aircraft/Extra Aircraft/Cirrus SF-50/" .. filename
	}
end

local function get_simbrief_user()
	local paths = get_aircraft_dir_paths("simbrief_user.txt")
	for _, p in ipairs(paths) do
		local f = io.open(p, "r")
		if f then
			for raw_line in f:lines() do
				local trimmed = raw_line:match("^%s*(.-)%s*$")
				if trimmed and #trimmed > 0 and not trimmed:match("^#") and not trimmed:match("^YOUR_") then
					f:close()
					local clean = trimmed:match("%w+")
					if clean and #clean > 0 then
						return clean
					end
				end
			end
			f:close()
		end
	end
	return nil
end

local function parse_simbrief_raw(content)
	if not content or #content < 50 then return nil end

	local units = content:match('"units"%s*:%s*"([^"]+)"') or "kgs"
	local is_lbs = (units:lower() == "lbs")
	local LBS_TO_KG = 1.0 / 2.20462

	local pax = tonumber(content:match('"pax_count"%s*:%s*"?(%d+)"?'))
		or tonumber(content:match('"pax"%s*:%s*(%d+)'))
		or 2

	local payload = tonumber(content:match('"payload"%s*:%s*"?([%d%.]+)"?'))
		or tonumber(content:match('"payload_kg"%s*:%s*([%d%.]+)'))

	local cargo = tonumber(content:match('"cargo_kg"%s*:%s*([%d%.]+)'))
		or tonumber(content:match('"cargo"%s*:%s*"?([%d%.]+)"?'))
		or 0

	local fuel_ramp = tonumber(content:match('"plan_ramp"%s*:%s*"?([%d%.]+)"?'))
		or tonumber(content:match('"block_fuel_kg"%s*:%s*([%d%.]+)'))
		or tonumber(content:match('"fuel_kg"%s*:%s*([%d%.]+)'))
	local fuel_takeoff = tonumber(content:match('"plan_takeoff"%s*:%s*"?([%d%.]+)"?'))
	local fuel = fuel_ramp or fuel_takeoff

	if not fuel then
		local fuel_gal = tonumber(content:match('"fuel_gal"%s*:%s*([%d%.]+)'))
		if fuel_gal then fuel = fuel_gal * KG_PER_GAL end
	end
	if not fuel then fuel = 429.0 end

	if is_lbs then
		if payload then payload = payload * LBS_TO_KG end
		cargo = cargo * LBS_TO_KG
		fuel = fuel * LBS_TO_KG
	end

	-- Clamping to SF50 bounds
	if pax < 1 then pax = 1 end
	if pax > 5 then pax = 5 end
	if fuel < 184.0 then fuel = 184.0 end
	if fuel > 907.0 then fuel = 907.0 end

	-- FSEconomy / SimBrief exact payload matching:
	-- If explicit payload is given (e.g. 308 kg), preserve it exactly and determine cargo by difference:
	local total_cargo = cargo
	if payload and payload > 0 then
		total_cargo = math.max(0.0, payload - (pax * PAX_WEIGHT_KG))
		if total_cargo < 1.0 then total_cargo = 0.0 end
		total_cargo = math.floor(total_cargo + 0.5)
	else
		total_cargo = math.floor((total_cargo / 5.0) + 0.5) * 5.0
		payload = (pax * PAX_WEIGHT_KG) + total_cargo
	end

	fuel = math.floor(fuel + 0.5)

	local origin = content:match('"origin"%s*:%s*{(.-)}')
	local orig_icao = origin and origin:match('"icao_code"%s*:%s*"([^"]+)"') or content:match('"origin"%s*:%s*"([^"]+)"') or "----"
	local dest = content:match('"destination"%s*:%s*{(.-)}')
	local dest_icao = dest and dest:match('"icao_code"%s*:%s*"([^"]+)"') or content:match('"destination"%s*:%s*"([^"]+)"') or "----"
	local flt = content:match('"general"%s*:%s*{(.-)}')
	local flt_num = flt and flt:match('"flight_number"%s*:%s*"([^"]+)"') or content:match('"flight_number"%s*:%s*"([^"]+)"') or "516"

	return pax, total_cargo, fuel, orig_icao, dest_icao, flt_num, payload
end

local function save_simbrief_json(pax, cargo, fuel, orig, dest, flt, payload)
	local content = string.format('{\n    "flight_number": "%s",\n    "origin": "%s",\n    "destination": "%s",\n    "pax": %d,\n    "cargo_kg": %.1f,\n    "payload_kg": %.1f,\n    "fuel_kg": %.1f,\n    "block_fuel_kg": %.1f,\n    "comments": "CIRRUS SF50 G2 LIVE SIMBRIEF SYNC (FSECONOMY COMPATIBLE)"\n}\n',
		flt or "516", orig or "----", dest or "----", pax, cargo, payload or (pax * PAX_WEIGHT_KG + cargo), fuel, fuel)
	local paths = get_aircraft_dir_paths("sf50_simbrief.json")
	for _, p in ipairs(paths) do
		local f = io.open(p, "w")
		if f then
			f:write(content)
			f:close()
		end
	end
end

local function sync_simbrief_live()
	local user = get_simbrief_user()
	local content = nil

	if user and #user > 0 then
		local is_num = tostring(user):match("^%d+$")
		local param = is_num and "userid=" or "username="
		local url = "https://www.simbrief.com/api/xml.fetcher.php?" .. param .. tostring(user) .. "&json=1"

		local dbg = io.open("/tmp/sf50_simbrief_debug.log", "a")
		if dbg then
			dbg:write("\n[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] Sync requested for user: " .. tostring(user) .. " URL: " .. url .. "\n")
		end

		-- Run curl with clean LD_LIBRARY_PATH (bypasses Steam Linux Runtime library conflict)
		local cmd = 'LD_LIBRARY_PATH="" curl -k -s -L -m 8 "' .. url .. '" 2>/dev/null || curl -k -s -L -m 8 "' .. url .. '" 2>/dev/null'
		local pipe = io.popen(cmd)
		if pipe then
			content = pipe:read("*a")
			pipe:close()
		end

		if dbg then
			dbg:write("Curl response bytes: " .. tostring(content and #content or 0) .. "\n")
			if content and #content < 200 then
				dbg:write("Short response: " .. tostring(content) .. "\n")
			end
		end

		if content and #content > 200 and (content:find('"params"') or content:find('"weights"')) then
			local p, c, f, orig, dest, flt, pay = parse_simbrief_raw(content)
			if p and c and f then
				save_simbrief_json(p, c, f, orig, dest, flt, pay)
				if dbg then
					dbg:write(string.format("Parsed OK: Pax=%d Cargo=%.1f Fuel=%.1f Payload=%.1f %s->%s Flight=%s\n", p, c, f, pay or 0, orig or "?", dest or "?", flt or "?"))
					dbg:close()
				end
				return p, c, f, orig, dest, flt, pay
			end
		end
	end

	if dbg then
		dbg:write("Live fetch failed or incomplete. Falling back to local file.\n")
	end

	local paths = get_aircraft_dir_paths("sf50_simbrief.json")
	for _, path in ipairs(paths) do
		local file = io.open(path, "r")
		if file then
			local local_content = file:read("*a")
			file:close()
			local p, c, f, orig, dest, flt, pay = parse_simbrief_raw(local_content)
			if p and c and f then
				if dbg then
					dbg:write("Loaded from local file: " .. path .. "\n")
					dbg:close()
				end
				return p, c, f, orig, dest, flt, pay
			end
		end
	end

	if dbg then
		dbg:write("Fallback to hardcoded defaults.\n")
		dbg:close()
	end
	return 2, 0.0, 429.0, "----", "----", "516", 154.0
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
		local pax, cargo, fuel, orig, dest, flt, explicit_payload = sync_simbrief_live()
		apply_dispatch_kg(pax, cargo, fuel, explicit_payload)
		sf50DR_simbrief_ok = 1
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
