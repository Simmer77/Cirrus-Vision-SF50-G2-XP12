# Autothrottle, FADEC & Autopilot Operating Manual — Cirrus Vision SF50 G2 (X-Plane 12)

This operational guide provides real-world and simulated operating procedures for the **Perspective Touch+ digital Autothrottle / FADEC system** and the integrated Garmin GFC 700 digital autopilot on the **Cirrus Vision SF50 G2** in X-Plane 12.

---

## 1. Overview of Touchscreen Controls (Center GTC)

On the primary Autothrottle touchscreen page on the Garmin Touchscreen Controller (GTC), there are **8 interactive touch buttons** and **1 dual-concentric rotary knob (`SPEED SET`)**:

### Left Column (Speed Management & Master Autothrottle)
* **`Auto T` (`ON` / `OFF`)**: Master Autothrottle Switch.
  * When **engaged (Green bar)**: The autothrottle actively servos the thrust lever to capture and maintain the selected speed target (`KTS` or `Mach`), while automatically enforcing the continuous rating limit (**`MCT`**).
  * When **pressed again (Off / Gray bar)**: Instantly disconnects the entire autothrottle system (`Auto T`, `MCT`, `TOGA`, and `FMS` links), returning **100% manual throttle authority** to your physical hardware throttle lever with no residual servo bias.
* **`KTS`**: Selects Indicated Airspeed hold mode in **Knots (`IAS`, range `85 – 250 KIAS`)**. If switching from `Mach` mode, it automatically converts the current flight Mach number into the equivalent Indicated Airspeed.
* **`Mach`**: Selects speed hold mode in **Mach Number (`0.250 – 0.535 M`)**. If switching from `KTS` mode, it seamlessly calculates and displays the equivalent Mach number at the current pressure altitude and outside air temperature.
* **`FMS`**: Toggles coupling to the FMS automated speed schedule (coupling into the `M CRS` / `E CRS` cruise profiles). Pressing it while active transitions back to manual speed selection (`MAN`) while maintaining the current target speed.
* **`SPEED SET` Rotary Knob (Bottom-right corner of the touchscreen bezel)**:
  * In **`KTS` mode**: Adjusts target airspeed in increments of `1 kt` (inner knob) or `10 kts` (outer knob).
  * In **`Mach` mode**: Adjusts target Mach in increments of `0.001 M` (inner knob) or `0.010 M` (outer knob).
  * If the knob is rotated while an automated FMS preset (`M CRS` or `E CRS`) is active, the system automatically transitions from `FMS` mode to manual `Mach` mode at the newly dialed value.

### Right Column (FADEC Thrust Ratings & G2 Cruise Presets)
* **`TOGA` (Takeoff / Go-Around)**:
  * Smoothly commands the Williams International FJ33-5A turbofan to **100% Takeoff Rated Thrust (`TLA = 1.00`)**, activates the Flight Director to `+8°` pitch-up target attitude (if off), and pre-sets the climb airspeed bug to **`160 KIAS`**.
* **`MCT` (Maximum Continuous Thrust)**:
  * Enforces the FADEC **Maximum Continuous Thrust limit (`95%` thrust / `TLA = 0.90`)** and activates the Autothrottle (**`Auto T ON`**):
    * If climbing in **`FLC` (Flight Level Change)** autopilot mode: Holds the throttle locked precisely on the **`MCT` detent** while autopilot pitch commands maintain the commanded climb airspeed.
    * In **level cruise (`ALT`)**, **`VS` (Vertical Speed)** climbs/descents, or manual flight: Linearly modulates engine thrust to maintain the selected target speed (`KTS` or `Mach`) without ever exceeding the continuous `MCT` threshold.
* **`M CRS` (Max Cruise — `0.530 Mach`)**:
  * Automatically engages **`Mach` mode**, enables **`FMS`**, **`Auto T`**, and **`MCT`**, and locks the cruise target to **`0.530 Mach`** (**~311 KTAS** between `FL280` and `FL310`, fuel flow ~`65 gal/h`, typical range **950 NM**).
* **`E CRS` (Economy Cruise — `0.489 Mach`)**:
  * Automatically engages **`Mach` mode**, enables **`FMS`**, **`Auto T`**, and **`MCT`**, and locks the cruise target to **`0.489 Mach`** (**~280 KTAS** at `FL310`, fuel flow ~`44 gal/h`, maximum range up to **1,275 NM**).

---

## 2. Standard Operating Procedures (SOP) by Flight Phase

### Phase 1: Pre-Flight, Ground Handling & Taxi
1. **Engine Start & Ground Power (GPU)**:
   * On the **SYSTEMS** page of the center GTC, tap the dedicated **`GPU`** button to connect external ground power (green indicator bar illuminates). All avionics, environmental control, and cabin lights are powered at 28V without draining the main aircraft batteries.
   * *Safety Feature*: The GPU will automatically disconnect as soon as ground roll begins (`groundspeed > 3 kts`) or upon takeoff.
2. **Taxi**:
   * On the **SYSTEMS** page, confirm that **`NWS` (Nose Wheel Steering)** is active (**Green bar**) for smooth rudder-pedal directional control on the ground.
   * Extend **Flaps to 50%** ($V_{FE} = 190\text{ KIAS}$).
   * Set the initial cleared altitude using the **`ALT`** selector knob on the autopilot panel (calibrated to **`100 ft`** per click).
3. **Runway Line-Up**:
   * Once cleared for takeoff, tap **`TOGA`** on the touchscreen:
     * Both **`TOGA`** and **`Auto T`** illuminate green.
     * The airspeed target bug sets automatically to **`160 KIAS`**.
     * The Williams FJ33-5A engine spools up smoothly to **100% Takeoff Thrust**.

---

### Phase 2: Takeoff & Initial Climb
1. **Rotation & Initial Climb**:
   * Smoothly rotate at **`90 KIAS`** toward the `8°–10°` pitch-up bars on the Primary Flight Display (PFD).
   * With a positive rate of climb established, retract the landing gear (**Gear UP**, limit $V_{LO} = 210\text{ KIAS}$).
   * Passing **`115 KIAS`**, retract the **Flaps to 0% (UP)**.
2. **Transition to `MCT` and Enroute Climb (`FLC` or `VS`)**:
   * After flap retraction (and within 5 minutes of takeoff), tap **`MCT`** on the touchscreen:
     * `TOGA` extinguishes; **`MCT`** and **`Auto T`** remain active in green.
   * **Recommended Climb Technique — `FLC` (Flight Level Change)**:
     1. Press **`FLC`** and **`AP`** on the G1000 autopilot control panel.
     2. With speed set to **`160 KIAS`** (up to ~FL200–FL220) and transitioning to **`Mach`** (`0.400 – 0.430 M`) climbing through FL250 towards **`FL280 – FL310`**, the autothrottle holds engine power fixed on the **`MCT` detent** while autopilot pitch control locks climb speed dead-center without oscillation.
   * **Alternative Climb Technique — `VS` (Vertical Speed)**:
     1. Press **`VS`** and dial the desired vertical speed (e.g., `+1,500 ft/min` at low altitude, decaying to `+600 / +800 ft/min` above FL250).
     2. In `VS` mode, the Autothrottle (`Auto T` + `MCT`) modulates the thrust lever continuously to maintain the dialed airspeed up to the continuous `MCT` limit.

---

### Phase 3: Level-Off & Cruise (`FL280 – FL310`)
Upon reaching the target altitude (e.g., **`31,000 ft` / `FL310`**), the autopilot smoothly captures and transitions from `FLC`/`VS` to **`ALT` (Altitude Hold)**. Simultaneously, the autothrottle transitions automatically to **active speed hold**.

Select one of **3 Cruise Profiles**:

1. **Maximum Cruise Profile (`M CRS` — `0.530 Mach` / `311 KTAS`)**:
   * Tap **`M CRS`** on the touchscreen.
   * The status indicators **`M CRS`**, **`FMS`**, **`Mach`**, **`MCT`**, and **`Auto T`** illuminate in green.
   * The target display shows **`0.530 M`**. The autothrottle stabilizes between `0.528 – 0.530 Mach` (~`311 KTAS` at ISA, fuel burn ~`65 gal/h`, practical range **~950 NM**).
2. **Economy / Long-Range Cruise Profile (`E CRS` — `0.489 Mach` / `~280 KTAS`)**:
   * Tap **`E CRS`** on the touchscreen.
   * The status indicators **`E CRS`**, **`FMS`**, **`Mach`**, **`MCT`**, and **`Auto T`** illuminate in green.
   * The target display shows **`0.489 M`**. If previously cruising faster (e.g., at `0.528 M`), the autothrottle **smoothly retards the throttle** (to ~`68–72%` TLA), allows the airframe to decelerate cleanly to **`0.489 Mach`**, and then restabilizes thrust to hold **`0.489 Mach`** (fuel burn ~`44 gal/h`, maximum range up to **1,275 NM**).
3. **Manual Cruise Speed Selection (`Mach` or `KTS`)**:
   * Tap **`Mach`** (or **`KTS`**) and turn the **`SPEED SET`** knob to dial your custom target (e.g., `0.510 M` or `210 KIAS`).

---

### Phase 4: Descent
1. Set the cleared lower altitude using the autopilot **`ALT`** knob (e.g., `10,000 ft` or pattern altitude).
2. **Descent in `VS` (Vertical Speed — Recommended)**:
   * Press **`VS`** and set `-1,000` to `-1,500 ft/min`.
   * Switch to **`KTS`** mode (when descending below FL240) and set the desired descent speed using **`SPEED SET`** (e.g., **`220 – 240 KIAS`**, staying below $V_{MO} = 250\text{ KIAS}$).
   * The Autothrottle (`Auto T` + `MCT`) smoothly reduces thrust to hold the target airspeed down the descent slope.
3. **Descent in `FLC`**:
   * If **`FLC`** is selected with a lower altitude, the autothrottle gently brings the engine to flight idle (`12%` TLA) while the autopilot pitches the nose down to track the dialed airspeed. Once level at the new altitude (`ALT` capture), the autothrottle automatically spools up to restore and hold the target speed.

---

### Phase 5: Approach, Landing & Go-Around
1. **Deceleration & Aircraft Configuration**:
   * On initial approach, dial **`SPEED SET`** (in **`KTS`** mode) to **`180 KIAS`**: the autothrottle reduces thrust and stabilizes at `180 KIAS`.
   * Below **`210 KIAS`** ($V_{LO}$), extend landing gear (**Gear DOWN**).
   * Below **`190 KIAS`** ($V_{FE\ 50\%}$), extend **Flaps 50%** and dial **`135 – 140 KIAS`** on the speed bug.
   * On final approach, below **`150 KIAS`** ($V_{FE\ 100\%}$), extend **Flaps 100%** and reduce the speed selector to final approach reference speed (**`85 – 90 KIAS`**; stall speed in landing configuration $V_{SO} = 67\text{ KIAS}$).
2. **Landing (Autothrottle Disengagement)**:
   * At approximately `200 – 300 ft AGL` (or prior to the landing flare), tap the **`Auto T`** button to **disengage the Autothrottle** (all `Auto T` and `MCT` annunciations extinguish). Manually retard your hardware throttle lever to **Flight Idle** for touchdown.
3. **Go-Around (`Missed Approach`)**:
   * If a missed approach is required, simply press **`TOGA`**:
     * The autothrottle advances smoothly to **100% Takeoff Thrust**.
     * Flight Director commands go-around pitch attitude (`+8°`) and sets target speed to **`160 KIAS`**.
     * Immediately retract flaps to **50%**.
     * With positive climb rate, retract the landing gear (**Gear UP**).
     * Above **`115 KIAS`**, retract flaps to **0% (UP)** and tap **`MCT`** on the GTC to resume standard climb.

---

## 3. Cockpit Amenities & Pop-ups

* **G1000 PFD & MFD 2D Pop-ups**:
  * Clicking anywhere on the active glass screen of either the pilot PFD or copilot MFD instantly pops up a resizable, high-resolution 2D window (`sim/GPS/g1000n1_popup` and `sim/GPS/g1000n3_popup`). Clicking the window again closes it.
* **GTC Overlap-Free Layout**:
  * All secondary pages (Auto Throttle, Weight & Balance, and Systems) have their **Back** and **Home** navigation buttons placed on the dedicated right margin (`POS 460.0`), preventing any overlap with text boxes or system toggles.

---

## 4. SimBrief Flight Planning Airframe

A dedicated, pre-calibrated SimBrief airframe profile matching the native XP12 Cirrus Vision Jet SF50 G2 specifications (FL310 ceiling, Williams FJ33-5A fuel flow, MTOW 6,000 lbs, accurate weights and PBN avionics) is available for 1-click import into your SimBrief fleet:
* 🌐 **[Click here to import the official SimBrief Airframe Profile](https://dispatch.simbrief.com/airframes/share/eyJiYXNldHlwZSI6IlNGNTAiLCJpY2FvIjoiU0Y1MCIsInJlZyI6IkFMUDUxNiIsImZpbiI6IiIsInNlbGNhbCI6IiIsImhleGNvZGUiOiIiLCJwbGFuZm9ybWF0IjoiIiwiZmxpZ2h0cnVsZXMiOiIiLCJmbGlnaHR0eXBlIjoiZyIsInBsYW51bml0cyI6IjAiLCJhbHRuc2Fkdl9yYWRpdXMiOiIyODgiLCJhbHRuc2Fkdl91bml0c19yd3kiOiJmdCIsImFsdG5zYWR2X3J3eSI6IjM1MDAiLCJuYW1lIjoiVmlzaW9uIEpldCBTRjUwIEcyIiwiZW5naW5lcyI6IkZKMzMtNUEiLCJjb21tZW50cyI6IkNJUlJVUyBTRjUwIEcyIC0gWFAxMiBOQVRJVkUgT1ZFUkhBVUwiLCJwZXIiOiJCIiwiY2F0IjoiTCIsImV0b3BzdGhyZXNob2xkIjoiNjAiLCJldG9wc3JhbmdlIjoiIiwiZXF1aXAiOiJCREdSU1dZIiwidHJhbnNwb25kZXIiOiJMQjJVMiIsInBibiI6IkIyQzJEMk8yUzIiLCJleHRyYXJtayI6IkRBVC9WIFJNSy9TRjUwIEcyIFhQMTIiLCJtYW51YWxybWsiOiJDSVJSVVMgVklTSU9OIEpFVCBTRjUwIEcyIChYUDEyIE9WRVJIQVVMKS4gTVRPVyA2MDAwIExCUyAvIDI3MjIgS0csIENFSUxJTkcgRkwzMTAsIFdJTExJQU1TIEZKMzMtNUEgRkFERUMuIENPTVBMSUFOVCBXSVRIIFJWU00gQU5EIFBCTiBSTkFWL1JOUC4iLCJ3Z3R1bml0cyI6IktHUyIsIm1heHBheCI6IjUiLCJwYXh3Z3QiOiI4MiIsImJhZ3dndCI6IjEwIiwib2V3IjoiMTY5MiIsIm16ZnciOiIyMjIzIiwibXRvdyI6IjI3MjIiLCJtbHciOiIyNTE3IiwibWF4ZnVlbCI6IjkwNyIsIm1heGNhcmdvIjoiMTM2IiwiY2FyZ29tb2RlIjoiIiwiY29udHBjdCI6IiIsInJlc3ZydWxlIjoiIiwidGF4aWZ1ZWwiOiIyOSIsIm1pbmZvYiI6IiIsIm1pbmZvYl91bml0cyI6IndndCIsIm1pbmZvZCI6IiIsIm1pbmZvZF91bml0cyI6IndndCIsIm1lbGZ1ZWwiOiIiLCJtZWxmdWVsX3VuaXRzIjoid2d0IiwiYXRjZnVlbCI6IiIsImF0Y2Z1ZWxfdW5pdHMiOiJ3Z3QiLCJ3eHhmdWVsIjoiIiwid3h4ZnVlbF91bml0cyI6IndndCIsImFkZGVkZnVlbF9sYWJlbCI6ImV4dHJhIiwiYWRkZWRmdWVsIjoiIiwiYWRkZWRmdWVsX3VuaXRzIjoid2d0IiwidGFua2VyaW5nIjoiIiwidGFua2VyaW5nX3VuaXRzIjoid2d0IiwiZnVlbGZhY3RvciI6IlAwMCIsImNydWlzZW9mZnNldCI6IlAwMDAwIiwiY2VpbGluZyI6IjMxMDAwIiwiZGVmYXVsdGNydWlzZSI6Ik5PUk0iLCJkZWZhdWx0Y2kiOiIiLCJkZWZhdWx0Y2xpbWIiOiJOT1JNIiwiZGVmYXVsdGRlc2NlbnQiOiJOT1JNIiwidGhydXN0X3VuaXRzIjoibGJmIiwidGhydXN0IjoiMjA1MCIsImZsYXRyYXRpbmciOiIifQ--)
