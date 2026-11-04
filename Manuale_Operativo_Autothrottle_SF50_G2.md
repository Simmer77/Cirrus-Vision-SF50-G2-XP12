# Manuale Operativo Autothrottle, FADEC e Autopilota — Cirrus Vision SF50 G2 (X-Plane 12)

Questa guida descrive il funzionamento reale e simulato del pannello digitale **Autothrottle / FADEC (Perspective Touch+)** e dell'autopilota GFC 700 del **Cirrus Vision SF50 G2** durante tutte le fasi del volo.

---

## 1. Panoramica dei Comandi sul Touchscreen (`GTC` Centrale)

Nella schermata principale dell'Autothrottle sul touchscreen centrale sono presenti **8 pulsanti** e **1 manopola (`SPEED SET`)**:

### Colonna di Sinistra (Gestione Velocità e Master Autothrottle)
* **`Auto T` (`ON` / `OFF`)**: Interruttore generale (Master) dell'Autothrottle.
  * Quando è **acceso (Verde)**: l'automanetta regola automaticamente la spinta per mantenere la velocità impostata (`KTS` o `Mach`), attivando contemporaneamente il limite continuo **`MCT`**.
  * Quando viene **premuto di nuovo (Grigio/Spento)**: disinserisce completamente l'automanetta (`Auto T`, `MCT`, `TOGA` e `FMS`), restituendo immediatamente il **controllo manuale al 100%** alla leva fisica della manetta.
* **`KTS`**: Seleziona il mantenimento della velocità indicata in **Nodi (`IAS`, `85 – 250 KIAS`)**. Se si proviene dalla modalità `Mach`, converte automaticamente il numero di Mach corrente nei nodi indicati corrispondenti.
* **`Mach`**: Seleziona il mantenimento della velocità in **Numero di Mach (`0.250 – 0.535 M`)**. Se si proviene dalla modalità `KTS`, converte automaticamente i nodi indicati nel Mach corrispondente alla quota attuale.
* **`FMS`**: Attiva o disattiva la modalità di velocità programmata dal **FMS** (agganciando i profili di crociera `M CRS` / `E CRS`). Premendolo quando è acceso, si passa alla modalità manuale (`MAN`) mantenendo il valore corrente sul selettore.
* **Manopola `SPEED SET` (in basso a destra sullo schermo)**:
  * In modalità **`KTS`**: regola la velocità target a passi di `1 kt` (ghiera piccola) o `10 kts` (ghiera grande).
  * In modalità **`Mach`**: regola il Mach target a passi di `0.001 M` (ghiera piccola) o `0.010 M` (ghiera grande).
  * Se si ruota la manopola mentre è attivo un preset FMS (`M CRS` o `E CRS`), il sistema passa automaticamente dalla modalità `FMS` alla modalità manuale (`Mach`) sul nuovo valore impostato.

### Colonna di Destra (Regimi FADEC e Preset di Crociera G2)
* **`TOGA` (Takeoff / Go-Around)**:
  * Porta dolcemente la manetta al **100% della spinta di decollo (`TLA = 1.00`)**, accende il Flight Director a `+8°` di assetto (se spento) e pre-imposta la velocità di salita a **`160 KIAS`**.
* **`MCT` (Max Continuous Thrust)**:
  * Seleziona il regime di **Massima Spinta Continua (`95%` spinta / `TLA = 0.90`)** e attiva l'Autothrottle (**`Auto T ON`**):
    * Se l'autopilota sta salendo in modalità **`FLC` (Flight Level Change)**, mantiene la manetta fissa sul detent **`MCT`** mentre il beccheggio dell'aereo mantiene la velocità di salita.
    * In **crociera (`ALT`)**, in **salita/discesa `VS` (Vertical Speed)** o in volo manuale, modula linearmente la manetta per **mantenere la velocità selezionata** (`KTS` o `Mach`) senza mai superare il limite continuo `MCT`.
* **`M CRS` (Max Cruise — `0.530 Mach`)**:
  * Imposta automaticamente la modalità **`Mach`**, attiva **`FMS`**, **`Auto T`** e **`MCT`**, e blocca il target di velocità a **`0.530 Mach`** (**~311 KTAS** tra `FL280` e `FL310`, consumo ~`65 gal/h`, autonomia media **950 NM**).
* **`E CRS` (Economy Cruise — `0.489 Mach`)**:
  * Imposta automaticamente la modalità **`Mach`**, attiva **`FMS`**, **`Auto T`** e **`MCT`**, e blocca il target di velocità a **`0.489 Mach`** (**~280 KTAS** a `FL310`, consumo ~`44 gal/h`, autonomia massima **1,275 NM**).

---

## 2. Procedure Operative per Fase di Volo

### Fase 1: Prima del Decollo e Rullaggio (Taxi)
1. **Avviamento e Rullaggio**:
   * Nella pagina **SYSTEMS** del touchscreen, verificare che **`NWS` (Nose Wheel Steering)** sia acceso (**verde**) per manovrare agevolmente a terra con la pedaliera.
   * Estrarre i **Flaps al 50%** ($V_{FE} = 190\text{ KIAS}$).
   * Impostare la quota iniziale autorizzata con il selettore **`ALT`** (scatti precisi di **`100 ft`** per click).
2. **Allineamento in Pista**:
   * Premere **`TOGA`** sul touchscreen:
     * I pulsanti **`TOGA`** e **`Auto T`** si illuminano in verde.
     * Il target di velocità si pre-imposta a **`160 KIAS`**.
     * Il motore Williams FJ33-5A accelera linearmente al **100% di spinta di decollo**.

---

### Fase 2: Decollo e Salita Iniziale
1. **Rotazione e Salita Iniziale**:
   * Ruotare dolcemente a **`90 KIAS`** verso gli `8°–10°` di beccheggio indicati dal Flight Director.
   * Con rateo di salita positivo, retrarre il carrello (**Gear UP**, limite $V_{LO} = 210\text{ KIAS}$).
   * Superati i **`115 KIAS`**, retrarre i **Flaps a 0% (UP)**.
2. **Passaggio a `MCT` e Salita in Quota (`FLC` o `VS`)**:
   * Dopo la retrazione dei flap (ed entro 5 minuti dal decollo), premere **`MCT`** sul touchscreen:
     * `TOGA` si spegne e **`MCT`** + **`Auto T`** restano accesi in verde.
   * **Metodo consigliato — Salita in `FLC` (Flight Level Change)**:
     1. Premere **`FLC`** e **`AP`** sul pannello dell'autopilota G1000.
     2. Con velocità impostata a **`160 KIAS`** (fino a ~FL200–FL220) e poi passando a **`Mach`** (`0.400 – 0.430 M`) salendo verso **`FL280 – FL310`**, il sistema mantiene automaticamente la spinta sul detent **`MCT`** mentre l'autopilota regola il beccheggio per mantenere esattamente i `160 KIAS` / `0.40 M` senza alcuna oscillazione.
   * **Metodo alternativo — Salita in `VS` (Vertical Speed)**:
     1. Premere **`VS`** e impostare il rateo verticale desiderato (es. `+1,500 ft/min` a bassa quota, riducendo a `+600 / +800 ft/min` sopra FL250).
     2. In modalità `VS`, l'Autothrottle (`Auto T` + `MCT`) modula direttamente la manetta per mantenere la velocità selezionata fino al limite massimo continuo `MCT`.

---

### Fase 3: Livellamento e Crociera (`FL280 – FL310`)
Quando l'aereo raggiunge la quota selezionata (es. **`31,000 ft` / `FL310`**), l'autopilota passa automaticamente da `FLC`/`VS` a **`ALT` (Altitude Hold)** e l'automanetta passa istantaneamente al **mantenimento attivo della velocità**.

Si possono scegliere **3 modalità di crociera**:

1. **Crociera Veloce Massima (`M CRS` — `0.530 Mach` / `311 KTAS`)**:
   * Premere **`M CRS`** sul touchscreen.
   * Si illuminano **`M CRS`**, **`FMS`**, **`Mach`**, **`MCT`** e **`Auto T`**.
   * Il display `SPDMach` si fissa su **`0.530`**. L'automanetta mantiene `0.528–0.530 Mach` (~`311 KTAS` in aria standard, consumo ~`65 gal/h`, autonomia **~950 NM**).
2. **Crociera Economica / Massima Autonomia (`E CRS` — `0.489 Mach` / `~280 KTAS`)**:
   * Premere **`E CRS`** sul touchscreen.
   * Si illuminano **`E CRS`**, **`FMS`**, **`Mach`**, **`MCT`** e **`Auto T`**.
   * Il display `SPDMach` si fissa su **`0.489`**. Se l'aereo stava volando più veloce (es. a `0.528 M`), l'automanetta **riduce dolcemente la manetta** (a ~`68–72%`), lascia decelerare l'aereo fino a **`0.489 Mach`** e poi riallinea la spinta per mantenere stabilmente **`0.489 Mach`** (consumo ~`44 gal/h`, autonomia fino a **1,275 NM**).
3. **Crociera a Velocità Personalizzata (`Mach` o `KTS` Manuale)**:
   * Premere **`Mach`** (o **`KTS`**) e ruotare la manopola **`SPEED SET`** sul valore desiderato (es. `0.510 M` oppure `210 KIAS`).

---

### Fase 4: Discesa (`Descent`)
1. Impostare la nuova quota inferiore con il selettore **`ALT`** (es. `10,000 ft` o quota di circuito).
2. **Discesa in `VS` (Vertical Speed — Consigliata)**:
   * Premere **`VS`** e impostare `-1,000` / `-1,500 ft/min`.
   * Premere **`KTS`** (quando sotto FL240) e impostare la velocità desiderata con **`SPEED SET`** (es. **`220 – 240 KIAS`**, sotto il limite $V_{MO} = 250\text{ KIAS}$).
   * L'Autothrottle (`Auto T` + `MCT`) riduce dolcemente la manetta per mantenere esattamente la velocità impostata durante tutta la discesa.
3. **Discesa in `FLC`**:
   * Se si seleziona **`FLC`** con una quota inferiore, l'automanetta porta dolcemente il motore al minimo di volo (`12%` TLA) mentre l'autopilota regola il beccheggio per scendere alla velocità selezionata; una volta livellato alla nuova quota (`ALT`), l'automanetta riprende automaticamente a dare motore per mantenere la velocità.

---

### Fase 5: Avvicinamento, Atterraggio e Riattaccata (`Approach & Landing`)
1. **Riduzione Velocità e Configurazione**:
   * In avvicinamento iniziale, ruotare **`SPEED SET`** (in modalità **`KTS`**) a **`180 KIAS`**: l'automanetta riduce spinta e stabilizza `180 KIAS`.
   * Sotto **`210 KIAS`** ($V_{LO}$), estrarre il carrello (**Gear DOWN**).
   * Sotto **`190 KIAS`** ($V_{FE\ 50\%}$), estrarre **Flaps 50%** e impostare **`135 – 140 KIAS`** sul selettore velocità.
   * In finale, sotto **`150 KIAS`** ($V_{FE\ 100\%}$), estrarre **Flaps 100%** e ridurre la velocità sul selettore fino alla velocità di riferimento finale (**`85 – 90 KIAS`**; velocità di stallo $V_{SO} = 67\text{ KIAS}$).
2. **Atterraggio (Disinserimento Automanetta)**:
   * A circa `200 – 300 ft AGL` (o prima della flare), premere il pulsante **`Auto T`** per **spegnere l'Autothrottle** (tutti gli indicatori `Auto T` e `MCT` si spengono) e portare manualmente la manetta su **Idle** per la toccata.
3. **Riattaccata (`Go-Around`)**:
   * In caso di mancato avvicinamento, premere semplicemente **`TOGA`**: l'automanetta avanza dolcemente al **100% di spinta** e imposta il target a **`160 KIAS`**; retrarre subito i flap al **50%**, con rateo positivo retrarre il carrello, e sopra **`115 KIAS`** retrarre i flap a **0%** e premere **`MCT`**.

---

## 4. Profilo Pianificazione Volo SimBrief

È disponibile un profilo aeromobile ufficiale pre-calibrato per SimBrief, con tutti i dati certificati del nostro Cirrus Vision Jet SF50 G2 in X-Plane 12 (quota massima FL310, consumi Williams FJ33-5A, MTOW 2.722 kg / 6.000 lbs, pesi e avionica PBN) pronto da aggiungere con 1 clic alla tua flotta SimBrief:
* 🌐 **[Clicca qui per importare il profilo SimBrief ufficiale](https://dispatch.simbrief.com/airframes/share/eyJiYXNldHlwZSI6IlNGNTAiLCJpY2FvIjoiU0Y1MCIsInJlZyI6IkFMUDUxNiIsImZpbiI6IiIsInNlbGNhbCI6IiIsImhleGNvZGUiOiIiLCJwbGFuZm9ybWF0IjoiIiwiZmxpZ2h0cnVsZXMiOiIiLCJmbGlnaHR0eXBlIjoiZyIsInBsYW51bml0cyI6IjAiLCJhbHRuc2Fkdl9yYWRpdXMiOiIyODgiLCJhbHRuc2Fkdl91bml0c19yd3kiOiJmdCIsImFsdG5zYWR2X3J3eSI6IjM1MDAiLCJuYW1lIjoiVmlzaW9uIEpldCBTRjUwIEcyIiwiZW5naW5lcyI6IkZKMzMtNUEiLCJjb21tZW50cyI6IkNJUlJVUyBTRjUwIEcyIC0gWFAxMiBOQVRJVkUgT1ZFUkhBVUwiLCJwZXIiOiJCIiwiY2F0IjoiTCIsImV0b3BzdGhyZXNob2xkIjoiNjAiLCJldG9wc3JhbmdlIjoiIiwiZXF1aXAiOiJCREdSU1dZIiwidHJhbnNwb25kZXIiOiJMQjJVMiIsInBibiI6IkIyQzJEMk8yUzIiLCJleHRyYXJtayI6IkRBVC9WIFJNSy9TRjUwIEcyIFhQMTIiLCJtYW51YWxybWsiOiJDSVJSVVMgVklTSU9OIEpFVCBTRjUwIEcyIChYUDEyIE9WRVJIQVVMKS4gTVRPVyA2MDAwIExCUyAvIDI3MjIgS0csIENFSUxJTkcgRkwzMTAsIFdJTExJQU1TIEZKMzMtNUEgRkFERUMuIENPTVBMSUFOVCBXSVRIIFJWU00gQU5EIFBCTiBSTkFWL1JOUC4iLCJ3Z3R1bml0cyI6IktHUyIsIm1heHBheCI6IjUiLCJwYXh3Z3QiOiI4MiIsImJhZ3dndCI6IjEwIiwib2V3IjoiMTY5MiIsIm16ZnciOiIyMjIzIiwibXRvdyI6IjI3MjIiLCJtbHciOiIyNTE3IiwibWF4ZnVlbCI6IjkwNyIsIm1heGNhcmdvIjoiMTM2IiwiY2FyZ29tb2RlIjoiIiwiY29udHBjdCI6IiIsInJlc3ZydWxlIjoiIiwidGF4aWZ1ZWwiOiIyOSIsIm1pbmZvYiI6IiIsIm1pbmZvYl91bml0cyI6IndndCIsIm1pbmZvZCI6IiIsIm1pbmZvZF91bml0cyI6IndndCIsIm1lbGZ1ZWwiOiIiLCJtZWxmdWVsX3VuaXRzIjoid2d0IiwiYXRjZnVlbCI6IiIsImF0Y2Z1ZWxfdW5pdHMiOiJ3Z3QiLCJ3eHhmdWVsIjoiIiwid3h4ZnVlbF91bml0cyI6IndndCIsImFkZGVkZnVlbF9sYWJlbCI6ImV4dHJhIiwiYWRkZWRmdWVsIjoiIiwiYWRkZWRmdWVsX3VuaXRzIjoid2d0IiwidGFua2VyaW5nIjoiIiwidGFua2VyaW5nX3VuaXRzIjoid2d0IiwiZnVlbGZhY3RvciI6IlAwMCIsImNydWlzZW9mZnNldCI6IlAwMDAwIiwiY2VpbGluZyI6IjMxMDAwIiwiZGVmYXVsdGNydWlzZSI6Ik5PUk0iLCJkZWZhdWx0Y2kiOiIiLCJkZWZhdWx0Y2xpbWIiOiJOT1JNIiwiZGVmYXVsdGRlc2NlbnQiOiJOT1JNIiwidGhydXN0X3VuaXRzIjoibGJmIiwidGhydXN0IjoiMjA1MCIsImZsYXRyYXRpbmciOiIifQ--)
