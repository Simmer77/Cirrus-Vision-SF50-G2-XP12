# Manuale Operativo Autothrottle, FADEC e Sistemi — Cirrus Vision SF50 G2 (X-Plane 12)
**Versione di Rilascio: v1.1.0**

Questa guida operativa descrive in dettaglio le procedure reali e simulate per il pannello digitale **Autothrottle / FADEC (Perspective Touch+)**, l'autopilota integrato Garmin GFC 700 e il nuovo **Electronic Flight Bag (EFB) 3D** a bordo del **Cirrus Vision SF50 G2** per X-Plane 12.

---

## 1. Panoramica dei Comandi sul Touchscreen (`GTC` Centrale)

Nella schermata principale dell'Autothrottle sul touchscreen centrale sono presenti **8 pulsanti tattili** e **1 manopola rotativa concentrica (`SPEED SET`)**:

### Colonna di Sinistra (Gestione Velocità e Master Autothrottle)
* **`Auto T` (`ON` / `OFF`)**: Interruttore generale (Master) dell'Autothrottle.
  * Quando è **acceso (Verde)**: l'automanetta regola automaticamente la spinta per raggiungere e mantenere la velocità impostata (`KTS` o `Mach`), attivando contestualmente il limite continuo **`MCT`**.
  * Quando viene **premuto di nuovo (Grigio/Spento)**: disinserisce completamente l'automanetta (`Auto T`, `MCT`, `TOGA` e `FMS`), restituendo all'istante il **controllo manuale al 100%** alla leva fisica della manetta senza ritardi o offset parassiti.
* **`KTS`**: Seleziona il mantenimento della velocità indicata in **Nodi (`IAS`, range `85 – 250 KIAS`)**. Se si proviene dalla modalità `Mach`, converte in automatico il numero di Mach corrente nei nodi indicati corrispondenti.
* **`Mach`**: Seleziona il mantenimento della velocità in **Numero di Mach (`0.250 – 0.535 M`)**. Se si proviene dalla modalità `KTS`, converte automaticamente i nodi indicati nel Mach corrispondente alla quota barometrica e temperatura esterna attuali.
* **`FMS`**: Attiva o disattiva la modalità di velocità programmata dal **FMS** (agganciando i profili di crociera `M CRS` / `E CRS`). Premendolo quando è attivo, il sistema passa alla modalità manuale (`MAN`) mantenendo il valore di velocità attuale.
* **Manopola `SPEED SET` (in basso a destra sulla cornice del display)**:
  * In modalità **`KTS`**: regola la velocità target a passi di `1 kt` (ghiera interna) o `10 kts` (ghiera esterna).
  * In modalità **`Mach`**: regola il Mach target a passi di `0.001 M` (ghiera interna) o `0.010 M` (ghiera esterna).
  * Se si ruota la manopola mentre è attivo un preset FMS (`M CRS` o `E CRS`), il sistema passa automaticamente dalla modalità automatica a quella manuale (`Mach`) sul nuovo valore impostato.

### Colonna di Destra (Regimi FADEC e Preset di Crociera G2)
* **`TOGA` (Takeoff / Go-Around)**:
  * Comanda dolcemente il turbofan Williams International FJ33-5A al **100% della spinta di decollo (`TLA = 1.00`)**, attiva il Flight Director a `+8°` di assetto a salire (se spento) e pre-imposta la velocità di salita a **`160 KIAS`**.
* **`MCT` (Max Continuous Thrust)**:
  * Seleziona il regime di **Massima Spinta Continua (`95%` spinta / `TLA = 0.90`)** e inserisce l'Autothrottle (**`Auto T ON`**):
    * Se l'autopilota sta salendo in modalità **`FLC` (Flight Level Change)**, mantiene la manetta fissa sul detent **`MCT`** mentre il beccheggio dell'aereo modula l'assetto per mantenere rigorosamente la velocità di salita impostata.
    * In **crociera livellata (`ALT`)**, in salita/discesa in **`VS` (Vertical Speed)** o in volo manuale, modula con precisione la manetta per **mantenere la velocità selezionata** (`KTS` o `Mach`) senza mai superare la soglia continua `MCT`.
* **`M CRS` (Max Cruise — `0.530 Mach`)**:
  * Imposta automaticamente la modalità **`Mach`**, attiva **`FMS`**, **`Auto T`** e **`MCT`**, e blocca la velocità di crociera a **`0.530 Mach`** (**~311 KTAS** tra `FL280` e `FL310`, consumo ~`65 gal/h`, autonomia media **950 NM**).
* **`E CRS` (Economy Cruise — `0.489 Mach`)**:
  * Imposta automaticamente la modalità **`Mach`**, attiva **`FMS`**, **`Auto T`** e **`MCT`**, e blocca la velocità a **`0.489 Mach`** (**~280 KTAS** a `FL310`, consumo ~`44 gal/h`, autonomia massima fino a **1,275 NM**).

---

## 2. Procedure Operative per Fase di Volo

### Fase 1: Prima del Decollo e Rullaggio (Taxi)
1. **Avviamento e Alimentazione da Terra (GPU)**:
   * Nella pagina **SYSTEMS** del touchscreen centrale, toccare il pulsante **`GPU`** per connettere il generatore di terra a 28V (barra verde attiva). Tutta l'avionica e le luci di cabina sono alimentate senza consumare le batterie di bordo.
   * *Sicurezza*: La GPU si disconnette automaticamente non appena il velivolo inizia a muoversi (`groundspeed > 3 kts`) o al decollo.
2. **Rullaggio (Taxi)**:
   * Nella pagina **SYSTEMS**, verificare che **`NWS` (Nose Wheel Steering)** sia attivo (**barra verde**) per manovrare agevolmente a terra con la pedaliera.
   * Estrarre i **Flaps al 50%** ($V_{FE} = 190\text{ KIAS}$).
   * Impostare la quota iniziale autorizzata con il selettore **`ALT`** dell'autopilota (scatti di **`100 ft`** per click).
3. **Allineamento in Pista**:
   * Autorizzati al decollo, premere **`TOGA`** sul touchscreen:
     * I pulsanti **`TOGA`** e **`Auto T`** si illuminano in verde.
     * La velocità target si pre-imposta automaticamente a **`160 KIAS`**.
     * Il motore Williams FJ33-5A accelera linearmente al **100% di spinta di decollo**.

---

### Fase 2: Decollo e Salita Iniziale
1. **Rotazione e Salita Iniziale**:
   * Ruotare dolcemente a **`90 KIAS`** verso gli `8°–10°` di beccheggio indicati dal Flight Director sul PFD.
   * Con rateo di salita positivo accertato, retrarre il carrello (**Gear UP**, limite $V_{LO} = 210\text{ KIAS}$).
   * Superati i **`115 KIAS`**, retrarre i **Flaps a 0% (UP)**.
2. **Passaggio a `MCT` e Salita in Quota (`FLC` o `VS`)**:
   * Dopo aver retratto i flap (ed entro 5 minuti dal decollo), premere **`MCT`** sul touchscreen:
     * `TOGA` si spegne e **`MCT`** + **`Auto T`** restano attivi in verde.
   * **Tecnica Consigliata — Salita in `FLC` (Flight Level Change)**:
     1. Premere **`FLC`** e **`AP`** sul pannello dell'autopilota.
     2. Con velocità impostata a **`160 KIAS`** (fino a circa FL200–FL220) e passando a **`Mach`** (`0.400 – 0.430 M`) salendo verso **`FL280 – FL310`**, il sistema tiene la spinta bloccata sul detent **`MCT`** mentre l'autopilota adegua l'assetto per mantenere esattamente la velocità senza pendolamenti.
   * **Tecnica Alternativa — Salita in `VS` (Vertical Speed)**:
     1. Premere **`VS`** e impostare il variometro desiderato (es. `+1,500 ft/min` a bassa quota, riducendo verso `+600 / +800 ft/min` sopra FL250).
     2. In modalità `VS`, l'Autothrottle modula continuamente la manetta per mantenere la velocità selezionata fino al massimo consentito dal limite `MCT`.

---

### Fase 3: Livellamento e Crociera (`FL280 – FL310`)
Raggiunta la quota di crociera (es. **`31,000 ft` / `FL310`**), l'autopilota passa da `FLC`/`VS` ad **`ALT` (Altitude Hold)** e l'automanetta subentra nel **mantenimento attivo della velocità**.

Sono disponibili **3 profili di crociera**:

1. **Crociera Veloce Massima (`M CRS` — `0.530 Mach` / `311 KTAS`)**:
   * Premere **`M CRS`** sul touchscreen.
   * Si illuminano in verde **`M CRS`**, **`FMS`**, **`Mach`**, **`MCT`** e **`Auto T`**.
   * Il target display mostra **`0.530 M`**. L'aereo si stabilizza tra `0.528 – 0.530 Mach` (~`311 KTAS` a FL310, consumo ~`65 gal/h`, autonomia utile **~950 NM**).
2. **Crociera Economica a Lungo Raggio (`E CRS` — `0.489 Mach` / `~280 KTAS`)**:
   * Premere **`E CRS`** sul touchscreen.
   * Si illuminano **`E CRS`**, **`FMS`**, **`Mach`**, **`MCT`** e **`Auto T`**.
   * Il display mostra **`0.489 M`**. Se si viaggiava più veloci, l'automanetta **riduce dolcemente la potenza**, fa decelerare in modo pulito l'aereo a **`0.489 Mach`** e si stabilizza sul valore (consumo ridotto a ~`44 gal/h`, autonomia massima fino a **1,275 NM**).
3. **Regolazione Manuale del Mach o dei Nodi (`Mach` o `KTS`)**:
   * Premere **`Mach`** (o **`KTS`**) e ruotare la manopola **`SPEED SET`** per impostare qualsiasi valore desiderato (es. `0.510 M` o `210 KIAS`).

---

### Fase 4: Discesa
1. Impostare la nuova quota autorizzata con il selettore **`ALT`** (es. `10,000 ft` o quota circuito).
2. **Discesa in `VS` (Consigliata)**:
   * Premere **`VS`** e impostare `-1,000` / `-1,500 ft/min`.
   * Passare in modalità **`KTS`** (sotto FL240) e impostare la velocità voluta con **`SPEED SET`** (es. **`220 – 240 KIAS`**, entro il limite $V_{MO} = 250\text{ KIAS}$).
   * L'Autothrottle riduce la spinta in modo progressivo per mantenere i nodi impostati lungo la traiettoria di discesa.
3. **Discesa in `FLC`**:
   * In `FLC` con quota inferiore, l'automanetta porta il motore al minimo di volo (`12%` TLA) e l'autopilota scende per seguire i nodi selezionati. Al livellamento (`ALT`), la manetta riaccelera per mantenere la velocità target.

---

### Fase 5: Avvicinamento, Atterraggio e Riattaccata
1. **Decelerazione e Configurazione Velivolo**:
   * In avvicinamento, regolare **`SPEED SET`** su **`180 KIAS`**: la spinta si riduce stabilizzandosi a `180 KIAS`.
   * Sotto **`210 KIAS`** ($V_{LO}$), estrarre il carrello (**Gear DOWN**).
   * Sotto **`190 KIAS`** ($V_{FE\ 50\%}$), estrarre **Flaps 50%** e impostare **`135 – 140 KIAS`**.
   * In finale, sotto **`150 KIAS`** ($V_{FE\ 100\%}$), estrarre **Flaps 100%** e impostare la velocità di riferimento all'atterraggio (**`85 – 90 KIAS`**; stallo con flap estesi $V_{SO} = 67\text{ KIAS}$).
2. **Atterraggio (Disconnessione Autothrottle)**:
   * A circa `200 – 300 ft AGL` (o prima della richiamata), toccare il pulsante **`Auto T`** per **disinserire l'automanetta**. Portare manualmente la manetta fisica su **Flight Idle** per il contatto al suolo.
3. **Mancato Avvicinamento / Riattaccata (`Go-Around`)**:
   * In caso di riattaccata, premere semplicemente **`TOGA`**:
     * L'automanetta avanza linearmente al **100% di spinta di decollo**.
     * Il Flight Director comanda `+8°` di beccheggio e imposta il target a **`160 KIAS`**.
     * Portare subito i flap al **50%**.
     * Con variometro positivo, retrarre il carrello (**Gear UP**).
     * Oltre i **`115 KIAS`**, retrarre i flaps a **0% (UP)** e premere **`MCT`** sul touchscreen per la salita continua.

---

## 3. Dotazioni Cockpit e Finestre Pop-up

* **Finestre Pop-up 2D per PFD e MFD G1000**:
  * Cliccando in qualsiasi punto sullo schermo di vetro del PFD comandante o del MFD copilota si apre istantaneamente una finestra 2D ad alta risoluzione e ridimensionabile (`sim/GPS/g1000n1_popup` e `sim/GPS/g1000n3_popup`). Un ulteriore click chiude la finestra.
* **Layout GTC Ottimizzato Senza Sovrapposizioni**:
  * Tutti i sottomenu del touchscreen centrale presentano i tasti **Back** e **Home** incolonnati sul margine destro (`POS 460.0`), garantendo la totale assenza di sovrapposizioni grafiche con pulsanti e testi.

---

## 4. Profilo Flotta SimBrief Ufficiale

È disponibile il profilo SimBrief ufficiale calibrato per il Cirrus Vision SF50 G2 (quota di certificazione FL310, consumi Williams FJ33-5A, MTOW 2.722 kg, pesi e avionica PBN conformi) importabile con un solo click:
* 🌐 **[Clicca qui per importare il Profilo SimBrief Ufficiale](https://dispatch.simbrief.com/airframes/share/eyJiYXNldHlwZSI6IlNGNTAiLCJpY2FvIjoiU0Y1MCIsInJlZyI6IkFMUDUxNiIsImZpbiI6IiIsInNlbGNhbCI6IiIsImhleGNvZGUiOiIiLCJwbGFuZm9ybWF0IjoiIiwiZmxpZ2h0cnVsZXMiOiIiLCJmbGlnaHR0eXBlIjoiZyIsInBsYW51bml0cyI6IjAiLCJhbHRuc2Fkdl9yYWRpdXMiOiIyODgiLCJhbHRuc2Fkdl91bml0c19yd3kiOiJmdCIsImFsdG5zYWR2X3J3eSI6IjM1MDAiLCJuYW1lIjoiVmlzaW9uIEpldCBTRjUwIEcyIiwiZW5naW5lcyI6IkZKMzMtNUEiLCJjb21tZW50cyI6IkNJUlJVUyBTRjUwIEcyIC0gWFAxMiBOQVRJVkUgT1ZFUkhBVUwiLCJwZXIiOiJCIiwiY2F0IjoiTCIsImV0b3BzdGhyZXNob2xkIjoiNjAiLCJldG9wc3JhbmdlIjoiIiwiZXF1aXAiOiJCREdSU1dZIiwidHJhbnNwb25kZXIiOiJMQjJVMiIsInBibiI6IkIyQzJEMk8yUzIiLCJleHRyYXJtayI6IkRBVC9WIFJNSy9TRjUwIEcyIFhQMTIiLCJtYW51YWxybWsiOiJDSVJSVVMgVklTSU9OIEpFVCBTRjUwIEcyIChYUDEyIE9WRVJIQVVMKS4gTVRPVyA2MDAwIExCUyAvIDI3MjIgS0csIENFSUxJTkcgRkwzMTAsIFdJTExJQU1TIEZKMzMtNUEgRkFERUMuIENPTVBMSUFOVCBXSVRIIFJWU00gQU5EIFBCTiBSTkFWL1JOUC4iLCJ3Z3R1bml0cyI6IktHUyIsIm1heHBheCI6IjUiLCJwYXh3Z3QiOiI4MiIsImJhZ3dndCI6IjEwIiwib2V3IjoiMTY5MiIsIm16ZnciOiIyMjIzIiwibXRvdyI6IjI3MjIiLCJtbHciOiIyNTE3IiwibWF4ZnVlbCI6IjkwNyIsIm1heGNhcmdvIjoiMTM2IiwiY2FyZ29tb2RlIjoiIiwiY29udHBjdCI6IiIsInJlc3ZydWxlIjoiIiwidGF4aWZ1ZWwiOiIyOSIsIm1pbmZvYiI6IiIsIm1pbmZvYl91bml0cyI6IndndCIsIm1pbmZvZCI6IiIsIm1pbmZvZF91bml0cyI6IndndCIsIm1lbGZ1ZWwiOiIiLCJtZWxmdWVsX3VuaXRzIjoid2d0IiwiYXRjZnVlbCI6IiIsImF0Y2Z1ZWxfdW5pdHMiOiJ3Z3QiLCJ3eHhmdWVsIjoiIiwid3h4ZnVlbF91bml0cyI6IndndCIsImFkZGVkZnVlbF9sYWJlbCI6ImV4dHJhIiwiYWRkZWRmdWVsIjoiIiwiYWRkZWRmdWVsX3VuaXRzIjoid2d0IiwidGFua2VyaW5nIjoiIiwidGFua2VyaW5nX3VuaXRzIjoid2d0IiwiZnVlbGZhY3RvciI6IlAwMCIsImNydWlzZW9mZnNldCI6IlAwMDAwIiwiY2VpbGluZyI6IjMxMDAwIiwiZGVmYXVsdGNydWlzZSI6Ik5PUk0iLCJkZWZhdWx0Y2kiOiIiLCJkZWZhdWx0Y2xpbWIiOiJOT1JNIiwiZGVmYXVsdGRlc2NlbnQiOiJOT1JNIiwidGhydXN0X3VuaXRzIjoibGJmIiwidGhydXN0IjoiMjA1MCIsImZsYXRyYXRpbmciOiIifQ--)

---

## 5. Electronic Flight Bag (EFB), AviTab e Gestione Carico/Carburante Live

### Supporto Tablet 3D e Leva di Sgancio Rapido
* Il cockpit dell'SF50 G2 include un tablet 3D montato sul braccio articolato a sinistra del capitano (`xPad_arm.obj` / `tablet.obj`).
* **Nascondere / Mostrare il Tablet**: È sufficiente fare click sulla levetta di sblocco in alto al centro della cornice del tablet (oppure fare click sullo snodo del braccio di supporto o usare il comando `laminar/sf50/tablet/toggle`).
* **Indicatore LED Notturno**: Per i voli notturni al buio, la levetta superiore dispone di una retroilluminazione LED verde a luminescenza attenuata che ne permette l'individuazione e l'azionamento immediato in qualsiasi condizione di luce.

### Doppia Modalità e Tasto Home
* Il tablet opera in due modalità completamente integrate: **EFB Dispatch Nativo** e **Suite di Navigazione AviTab**.
* **Pulsante Home Fisico e su Schermo**: Un tasto con l'icona Home è posizionato sulla cornice destra del tablet e replicato in basso sullo schermo. Premendolo si passa istantaneamente tra:
  1. **Schermata EFB Dispatch**: Gestione carburante in cabina, passeggeri, calcolo pesi in tempo reale e sincronizzazione SimBrief.
  2. **Navigazione AviTab**: Carte aeronautiche Navigraph, procedure IFR georeferenziate, mappa mobile GPS e visualizzatore OFP di SimBrief (richiede il plugin gratuito AviTab).

### Schermata EFB Dispatch Nativa
* **Grafica ad Alta Leggibilità Dark Mode**: Ottimizzata con palette scura antiriflesso e caratteri tipografici nitidi per la lettura sia su monitor che in visori VR.
* **Gestione Carburante (Fuel Management)**:
  * Tre preset rapidi: **`MIN`** (184 kg), **`TABS`** (429 kg) e **`FULL`** (907 kg).
  * Pulsanti di regolazione fine: **`[-] 25 KG`** e **`[+] 25 KG`** con blocco automatico entro i limiti strutturali (184–907 kg).
* **Gestione Passeggeri e Bagagli (Cabin Payload)**:
  * Selettore rapido cabina a 5 posti con silhouette animate (**`[-] PAX`**, **`[+] PAX`**, da 1 a 5 occupanti).
  * Regolazione peso bagagli (**`[-] 10 KG`**, **`[+] 10 KG`**).
* **Foglio di Carico e Bilanciamento (Load Sheet & Balance)**:
  * Visualizzazione in tempo reale di Peso a Vuoto Operativo (**`OEW: 1.692 KG`**), Carico Utile totale (**`PAYLOAD`**), Carburante attuale (**`FUEL`**) e Peso Stimato al Decollo (**`EST TOW`**).
* **Indicatore di Busta di Peso (Weight Envelope)**:
  * **`WEIGHT ENVELOPE: NORMAL (OK)`** (verde) quando il peso lordo rientra nei limiti.
  * **`WEIGHT ENVELOPE: OVERWEIGHT (CAUTION)`** (ambra/rosso) se si supera il peso massimo al decollo (**MTOW: 2.722 kg / 6.000 lbs**).

### Sincronizzazione 1-Click SimBrief e Compatibilità FSEconomy
* **Configurazione Iniziale (`simbrief_user.txt`)**:
  * Aprire il file `simbrief_user.txt` presente nella cartella principale dell'aereo e inserire il proprio **Pilot ID di SimBrief** (es. `123456`) o il proprio username SimBrief.
* **Sincronizzazione Live con 1 Click**:
  * Premere **`SYNC SIMBRIEF OFP`** sullo schermo del tablet (o azionare il comando `laminar/sf50/dispatch/load_simbrief`).
  * Il modulo XLua scarica istantaneamente l'ultimo piano di volo generato su SimBrief e imposta carburante e carico direttamente nei dataref fisici di X-Plane senza dover riavviare o aprire menu.
* **Calcolo Inverso del Carico per FSEconomy e Virtual Airline**:
  * FSEconomy e gli standard aeronautici commerciali considerano il peso di ciascun passeggero pari a **$77\text{ kg}$ ($170\text{ lbs}$)** e richiedono che il carico complessivo validato corrisponda all'esatto chilogrammo.
  * Il nostro motore di dispatch acquisisce il payload totale generato da SimBrief e calcola automaticamente il cargo per differenza:
    $$\text{Cargo (KG)} = \text{Payload Totale SimBrief} - (\text{Numero Passeggeri} \times 77.0\text{ KG})$$
  * In questo modo, il carburante e il carico utile caricati in X-Plane coincidono esattamente fino all'ultimo chilogrammo sia con SimBrief che con le richieste di FSEconomy e OnAir!

---

## 6. Elenco Completo dei Comandi Assegnabili

Tutti i comandi personalizzati possono essere assegnati a tastiera, joystick, yoke o manette dal consueto menu Impostazioni di X-Plane 12:

| Sistema | Identificatore Comando | Funzione |
| :--- | :--- | :--- |
| **Autothrottle** | `laminar/sf50/g2/autothrottle_toggle` | Attiva / Disattiva Master Autothrottle (`Auto T ON / OFF`) |
| **Spinta FADEC** | `laminar/sf50/g2/toga_thrust` | Spinta massima di decollo / riattaccata (`TOGA`) |
| **Spinta FADEC** | `laminar/sf50/g2/mct_thrust` | Spinta massima continua / salita (`MCT`) |
| **Unità Velocità** | `laminar/sf50/g2/speed_mode_toggle` | Alterna modalità tra Nodi (`KTS`) e `Mach` |
| **Unità Velocità** | `laminar/sf50/g2/speed_mode_kts` | Seleziona direttamente la modalità Nodi (`KTS`) |
| **Unità Velocità** | `laminar/sf50/g2/speed_mode_mach` | Seleziona direttamente la modalità `Mach` |
| **Preset Crociera** | `laminar/sf50/g2/max_cruise_mach` | Attiva preset Max Cruise (`0.530 M`) |
| **Preset Crociera** | `laminar/sf50/g2/econ_cruise_mach` | Attiva preset Economy Cruise (`0.489 M`) |
| **Tablet EFB** | `laminar/sf50/tablet/toggle` | Mostra / Nasconde il tablet EFB 3D |
| **Tablet EFB** | `laminar/sf50/tablet/switch_mode` | Alterna display tablet tra Dispatch e AviTab |
| **Dispatch Live** | `laminar/sf50/dispatch/load_simbrief` | Sincronizzazione live con piano di volo SimBrief |
| **Dispatch Live** | `laminar/sf50/dispatch/pax_add` | Aggiunge 1 passeggero in cabina |
| **Dispatch Live** | `laminar/sf50/dispatch/pax_sub` | Rimuove 1 passeggero dalla cabina |
| **Dispatch Live** | `laminar/sf50/dispatch/cargo_add` | Aggiunge 10 kg di carico/bagaglio |
| **Dispatch Live** | `laminar/sf50/dispatch/cargo_sub` | Riduce 10 kg di carico/bagaglio |
| **Dispatch Live** | `laminar/sf50/dispatch/fuel_min` | Carica preset carburante Minimo (`184 kg`) |
| **Dispatch Live** | `laminar/sf50/dispatch/fuel_tabs` | Carica preset carburante Tabs (`429 kg`) |
| **Dispatch Live** | `laminar/sf50/dispatch/fuel_full` | Carica preset carburante Pieno Serbatoi (`907 kg`) |
| **Dispatch Live** | `laminar/sf50/dispatch/fuel_add25` | Aggiunge 25 kg di carburante |
| **Dispatch Live** | `laminar/sf50/dispatch/fuel_sub25` | Riduce 25 kg di carburante |
| **Avionica Cockpit** | `sim/GPS/g1000n1_popup` | Apre / Chiude finestra 2D PFD Comandante |
| **Avionica Cockpit** | `sim/GPS/g1000n3_popup` | Apre / Chiude finestra 2D MFD Copilota |
| **Impianto Elettrico**| `sim/electrical/GPU_on` / `sim/electrical/GPU_off` | Connette / Disconnette generatore di terra (GPU 28V) |
| **Controlli Volo** | `laminar/sf50/ai/fltControl_quick_start` | Inizializzazione comandi di volo e sterzo |
