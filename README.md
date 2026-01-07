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

* De applicatie stuurt **GPIO 26** aan
* Via de `pigpio` library wordt een LED aangestuurd (knipperen)

De focus ligt op:

* embedded development
* hardware-aansturing
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
* **GPIO library:** pigpio (meegecompileerd vanuit broncode)
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

## DEEL 2 – STAPPENPLAN

Deze sectie beschrijft **exact** hoe je dit project opzet vanaf een **volledig lege computer**.

---

### Stap 1 – Benodigdheden

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

De code wordt **binnen Docker** gecompileerd:

```bash
gcc -c pigpio/*.c
aar rcs libpigpio.a *.o
gcc main.c -L. -lpigpio -lpthread -o main
```

Hierbij:

* wordt pigpio statisch gelinkt
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
* De LED knippert
* Bij nieuwe `push` wordt alles automatisch herbouwd en herstart

---

## Extra toelichting voor evaluatie

### 1. Architectuuroverzicht (vereenvoudigd schema)

De volledige werking van het project kan als volgt worden samengevat:

```
Ontwikkelaar (lege computer)
        ↓
     GitHub
        ↓
GitHub Actions (CI/CD)
        ↓
Docker container (ARM64 build)
        ↓
Raspberry Pi
        ↓
GPIO 26 → LED
```

**Uitleg voor de leerkracht:**

* De ontwikkelaar pusht code naar GitHub
* GitHub Actions start automatisch
* De code wordt gecompileerd in Docker
* De binary wordt automatisch gedeployed naar de Raspberry Pi
* De Raspberry Pi stuurt GPIO 26 aan

---

### 2. Branching & projectstructuur

Het project maakt gebruik van een duidelijke Git-structuur:

* `main` → productiebranch
* Feature branches → ontwikkeling en testen

Elke feature wordt:

* apart ontwikkeld
* gecommit met **atomic commits**
* gemerged via `main`

Dit zorgt voor:

* overzichtelijke geschiedenis
* traceerbare wijzigingen
* stabiele productiecode

---

### 3. Beperkingen en aandachtspunten

Dit project houdt rekening met enkele belangrijke beperkingen:

* GPIO-aansturing vereist voldoende rechten op de Raspberry Pi
* Docker containers kunnen GPIO niet rechtstreeks gebruiken
* Daarom wordt de **binary gedeployed naar de Pi**, niet uitgevoerd in Docker
* pigpio vereist correcte timing → native execution op de Pi is noodzakelijk

Deze keuzes zijn **bewust** gemaakt om stabiliteit en betrouwbaarheid te garanderen.

---

### 4. Evaluatieverantwoording

Dit project toont aan dat:

* een volledige embedded pipeline opgezet kan worden
* hardware-aansturing correct geïntegreerd is
* CI/CD toepasbaar is in embedded context
* Docker bruikbaar is voor cross-compilatie
* automatische deployment naar fysieke hardware mogelijk is

De complexiteit zit niet in de applicatie zelf, maar in:

* de infrastructuur
* de automatisatie
* de reproduceerbaarheid


---

**Auteur:** Bram J & Timo M
