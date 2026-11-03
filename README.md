# Cirrus Vision SF50 G2 — Native X-Plane 12 Community Overhaul

[![X-Plane 12 Compatible](https://img.shields.io/badge/X--Plane-12.00%2B-blue.svg)](https://www.x-plane.com/)
[![Version](https://img.shields.io/badge/version-v2.0.0-green.svg)](https://github.com/Simmer77/Cirrus-Vision-SF50-G2-XP12/releases)
[![Aircraft](https://img.shields.io/badge/Type-Very%20Light%20Jet%20(VLJ)-orange.svg)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-lightgrey.svg)](https://www.gnu.org/licenses/gpl-3.0)

A comprehensive, community-driven modernization and native systems overhaul bringing the **Cirrus Vision Jet SF50 G2** to **X-Plane 12**. 

Built upon the default Laminar Research Cirrus SF50 base airframe, this package delivers an authentic G2 experience with real-world flight performance, full digital autothrottle integration, Garmin Perspective Touch+ enhancements, and deep systems modeling calibrated directly against official Cirrus Flight Manuals.

---

## ✈️ Key Features in v2.0.0

### 1. Digital Autothrottle, FADEC & Autopilot Overhaul
* **Dedicated Autothrottle State Machine (`sf50_autopilot.lua`)**: Fully modeled digital autothrottle with native support for `Auto T`, `TOGA`, `MCT`, `KTS`, `Mach`, `FMS`, `M CRS`, and `E CRS`.
* **Smooth Throttle Servo & Linear FADEC Dynamics**: Progressive, realistic throttle movement without sudden power spikes. Disengaging `Auto T` returns instantaneous 100% manual control to your physical throttle hardware with zero latency or phantom trim offsets.
* **Elimination of Autopilot Porpoising**: Flight Level Change (`FLC`), Altitude Hold (`ALT`), and Vertical Speed (`VS`) pitch modes are fully decoupled from throttle hunting, providing rock-solid climb, level-off, and cruise holding up to **FL310**.
* **Calibrated G2 Cruise Presets**:
  * **`M CRS` (Max Cruise — 0.530 Mach / ~311 KTAS)**: Stabilizes ~65 gal/h fuel flow for standard 950 NM missions.
  * **`E CRS` (Economy Cruise — 0.489 Mach / ~280 KTAS)**: Stabilizes ~44 gal/h fuel flow for long-range endurance up to 1,275 NM.

### 2. Garmin Perspective Touch+ (GTC) & Cockpit Ergonomics
* **Interactive GPU (Ground Power Unit) Touchscreen Button**: Located directly on the Center GTC **Systems** page. Tapping the button connects external 28V ground power with a vivid neon-green active indicator bar, allowing full cockpit and avionics configuration without draining main batteries.
  * *Safety Feature*: Automatically disconnects when ground roll begins (`groundspeed > 3 kts`) or upon takeoff.
* **2D Resizable Pop-up Displays**: Click anywhere on the pilot's Primary Flight Display (PFD) or copilot's Multi-Function Display (MFD) glass screens to instantly pop up high-resolution, scalable 2D windows.
* **Zero-Overlap Touchscreen Layout**: Completely re-engineered GTC coordinate geometry across all secondary pages (`Systems`, `Auto Throttle`, and `Weight & Balance`). Navigation controls (`Back` and `Home`) are positioned along the dedicated right bezel margin (`POS 460.0`), eliminating overlaps with system text boxes and buttons.
* **Native Touchscreen Visuals**: Restored the authentic dark metallic Garmin GTC palette with clean, pixel-perfect contrast.

### 3. Flight Dynamics & Systems
* **Real-World G2 Flight Envelope**: Certified maximum ceiling of **FL310** (upgraded from G1 FL280), Williams International FJ33-5A turbofan high-altitude thrust tables, and accurate V-speeds ($V_{SO}$ 67 KIAS, $V_{FE}$ 150 KIAS, $V_{MO}$ 250 KIAS / 0.530 M).
* **Restored Control Subsystems**: Functional Nose Wheel Steering (`NWS`) toggle with active indicator, operational Cabin Pressure Dump (`CABIN DUMP`), and working TKS/IPS anti-ice boots.
* **Native XP12 Engine**: Native 3D rain and ice windshield shaders (`ATTR_rain_glass`), photometric exterior and cabin LED lighting, and 64-bit XLua architecture.

---

## 📖 Pilot Operating Handbooks (Included)

Detailed pilot operating handbooks are included directly within the aircraft folder:
* 🇬🇧 [**`Autothrottle_Operating_Manual_SF50_G2.md`**](Autothrottle_Operating_Manual_SF50_G2.md) — Comprehensive operating manual in English covering system theory, GTC controls, and Standard Operating Procedures (SOP) across all flight phases.
* 🇮🇹 [**`Manuale_Operativo_Autothrottle_SF50_G2.md`**](Manuale_Operativo_Autothrottle_SF50_G2.md) — Manuale operativo completo e dettagliato in lingua italiana.

---

## 🕹️ Quick Flight Profiles Guide

| Flight Phase | Recommended Mode | Target Speed / Setting | Notes |
| :--- | :--- | :--- | :--- |
| **Taxi** | `NWS ON`, `GPU OFF` | Ground Idle | Set Flaps 50%, Pre-set initial altitude |
| **Takeoff** | Tap `TOGA` | 100% Takeoff Thrust (`TLA = 1.00`) | Target bug sets to 160 KIAS, FD pitches +8° |
| **Initial Climb** | Rotate at 90 KIAS | Gear UP, Flaps UP at 115 KIAS | Accelerate toward 160 KIAS |
| **Enroute Climb** | Tap `MCT`, Select `FLC` | 160 KIAS / 0.40–0.43 Mach | Throttle locked on MCT detent; AP pitches for airspeed |
| **Level-Off** | Auto `ALT` Capture | Transitions to active speed hold | Level-off at FL280 – FL310 |
| **Max Cruise** | Tap `M CRS` | **0.530 Mach** (~311 KTAS) | Fuel burn ~65 gal/h, ~950 NM range |
| **Economy Cruise** | Tap `E CRS` | **0.489 Mach** (~280 KTAS) | Fuel burn ~44 gal/h, up to 1,275 NM range |
| **Descent** | Select `VS` (-1,000 to -1,500 fpm) | 220–240 KIAS (below FL240) | Autothrottle reduces thrust to hold speed |
| **Approach** | Dial `SPEED SET` to 180 KIAS | Gear DOWN < 210 KIAS | Flaps 50% < 190 KIAS, Flaps 100% < 150 KIAS |
| **Final & Touchdown** | Vref 85–90 KIAS | Tap `Auto T` to Disconnect | Disengage at 200–300 ft AGL; manual idle touchdown |

---

## 📥 Installation

1. Go to the [**Releases**](https://github.com/Simmer77/Cirrus-Vision-SF50-G2-XP12/releases) page and download `Cirrus_Vision_SF50_G2_XP12_v2.0.0.zip`.
2. Extract the archive into your X-Plane 12 aircraft directory:
   ```text
   X-Plane 12/Aircraft/Cirrus Vision SF50 G2/
   ```
3. Launch **X-Plane 12** and select the **Cirrus Vision SF50 G2**.

---

## 📜 Credits & License

* **Base Aircraft & 3D Models**: Laminar Research.
* **G2 Flight Dynamics, Systems & Autothrottle Overhaul**: Simmer77 and community contributors.
* **License**: Released under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE) for the community.
