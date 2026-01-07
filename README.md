# IoT GPIO Pipeline Project – Raspberry Pi

---

## DEEL 1 – OPDRACHT, CONTEXT EN VEREISTEN

### 1. Opdrachtomschrijving

Dit project werd uitgevoerd in het kader van het vak **IoT Technologie**. Het doel van de opdracht is **niet** om een complexe applicatie te bouwen, maar om een **volledig werkende en goed gedocumenteerde embedded pipeline** op te zetten.

De pipeline moet ervoor zorgen dat:

* code lokaal of in CI kan worden gecompileerd
* de build reproduceerbaar is via Docker
* de applicatie automatisch gedeployed wordt naar een Raspberry Pi
* GPIO-pinnen effectief gebruikt worden

De volledige workflow moet gedocumenteerd zijn zodat **iemand met een lege computer** het project kan opzetten en uitvoeren.

---

### 2. Wat doet dit project?

De applicatie is geschreven in **C** en draait op een **Raspberry Pi**.

Functionaliteit:

* **GPIO 26**: LED-indicator (statusfeedback)
* **GPIO 16**: drukknop (mode-wissel)
* **PWM / Servo (GPIO 18 – pin 12)**: servo-aansturing via `bcm2835`

De applicatie werkt met **drie modi**, die met een drukknop worden doorlopen:

1. **IDLE**

   * LED uit
   * Servo gecentreerd

2. **SWEEP**

   * Servo beweegt continu heen en weer
   * LED knippert mee met de beweging

3. **CENTER**

   * Servo blijft gecentreerd
   * LED blijft aan

De focus ligt op:

* embedded development
* hardware-aansturing (LED, knop en servo)
* automatisatie (CI/CD)

---

### 3. Projectvereisten (volgens opdracht)

Dit project voldoet aan de volgende vereisten:

* Team van 2 personen
* GitHub repository met correcte naamgeving
* Duidelijke commit-structuur
* Embedded C-code
* Gebruik van GPIO-pinnen (**GPIO 26**)
* Gebruik van een externe library (**pigpio**)
* Build en uitvoering via **Docker**
* Automatische build & deploy via **GitHub Actions**
* Documentatie op GitHub

---

### 4. Gebruikte technologieën

* **Programmeertaal:** C (C11)
* **Hardware:** Raspberry Pi
* **GPIO libraries:**

  * `pigpio` (digitale IO, knop, LED)
  * `bcm2835` (hardware PWM voor servo)
* **Build tools:** GCC, CMake
* **Containerisatie:** Docker + Buildx + QEMU
* **CI/CD:** GitHub Actions
* **Remote execution:** SSH + tmux

---

### 5. Repository structuur

```
.
├── .github/workflows/        # CI/CD pipeline
├── pigpio/                   # Externe library (broncode)
├── main.c                    # Hoofdprogramma
├── command.c
├── command.h
├── CMakeLists.txt
├── Dockerfile
└── README.md
```

---

## DEEL 2 – STAPPENPLAN (VAN LEGE COMPUTER TOT WERKEND PROJECT)

Deze sectie beschrijft **exact** hoe je dit project opzet vanaf een **volledig lege computer**.

---

### Stap 1 – Benodigdheden (lege computer)

Installeer eerst **deze software**:

1. **Git**

   * Nodig om de repository te clonen

2. **Docker Desktop**

   * Nodig voor build en compilatie
   * Zorg dat Docker effectief draait

3. **GitHub account**

   * Nodig voor GitHub Actions

⚠️ Je hoeft **geen** GCC, CMake of pigpio lokaal te installeren.

---

### Stap 2 – Repository clonen

```bash
git clone <repository-url>
cd <repository-folder>
```

---

### Stap 3 – Raspberry Pi voorbereiden

Op de Raspberry Pi:

1. Installeer Raspberry Pi OS
2. Zorg dat **SSH actief** is
3. Installeer `tmux`

```bash
sudo apt update
sudo apt install tmux -y
```

4. Noteer:

* IP-adres of hostname
* Gebruikersnaam

---

### Stap 4 – SSH-sleutel instellen

1. Genereer lokaal een SSH-sleutel:

```bash
ssh-keygen
```

2. Plaats de **public key** op de Raspberry Pi:

```bash
ssh-copy-id <user>@<pi-ip>
```

3. Voeg in GitHub **Secrets** toe:

* `PI_HOST` → IP of hostname van de Pi
* `PI_USER` → gebruikersnaam
* `PI_PRIVATE_KEY` → inhoud van de private key

---

### Stap 5 – Docker build (automatisch)

Bij elke `push` naar `main`:

* GitHub Actions start automatisch
* Een Docker image wordt gebouwd voor **ARM64**

Dockerfile bevat alle build tools:

* GCC
* CMake
* Debug tools

---

### Stap 6 – Compilatie in Docker

De code wordt **binnen Docker** gecompileerd.

In deze variant wordt niet langer statisch gecompileerd, maar gelinkt tegen de op de Raspberry Pi aanwezige libraries:

```bash
gcc main.c -o main \
  -lpigpio \
  -lbcm2835 \
  -lpthread \
  -lrt
```

Hierbij:

* worden `pigpio` en `bcm2835` gebruikt als externe libraries
* ontstaat de executable `main`

---

### Stap 7 – Automatische deployment

Na een succesvolle build:

* wordt `main` via **SCP** naar de Raspberry Pi gekopieerd
* bestand komt terecht in `/home/<user>/main`

---

### Stap 8 – Programma starten op de Raspberry Pi

Via SSH wordt:

* het programma executable gemaakt
* een oude sessie gestopt
* een nieuwe `tmux` sessie gestart

```bash
tmux new -d -s bramj ./main
```

Het programma draait nu continu op de Raspberry Pi en stuurt **GPIO 26** aan.

---

### Stap 9 – Controleren

* Sluit een LED aan op **GPIO 26** (met weerstand)
* Sluit een drukknop aan op **GPIO 16** (pull-up actief)
* Sluit een servo aan op **GPIO 18 (pin 12)**
* Druk op de knop om tussen modi te wisselen
* De servo en LED reageren overeenkomstig
* Bij elke nieuwe `push` wordt alles automatisch herbouwd en herstart

---

**Auteur:** Bram J & Timo M
