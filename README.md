# IoT GPIO Pipeline Project – Raspberry Pi

---

## DEEL 1 – OPDRACHT, CONTEXT EN VEREISTEN

### 1. Opdrachtomschrijving

Dit project werd uitgevoerd in het kader van het vak **IoT Technologie**. Het doel van de opdracht is **niet** om een complexe applicatie te bouwen, maar om een **volledig werkende en goed gedocumenteerde embedded pipeline** op te zetten.

De nadruk ligt op:

* automatisatie
* correct gebruik van embedded technologie
* duidelijke documentatie

De pipeline moet ervoor zorgen dat:

* code lokaal of in CI kan worden gecompileerd
* de build reproduceerbaar is via Docker
* de applicatie automatisch gedeployed wordt naar een Raspberry Pi
* GPIO-pinnen effectief gebruikt worden

De volledige workflow moet gedocumenteerd zijn zodat **iemand met een lege computer** het project kan opzetten en uitvoeren.

---

### 2. Wat doet dit project?

De applicatie is geschreven in **C** en draait op een **Raspberry Pi**.

Hardwarefunctionaliteit

De hardware-opstelling is als volgt:

* **LED** – verbindt één been via een weerstand (330–470 Ω) met GPIO 26, het andere been met GND.
* **Drukknop** – sluit één kant aan op GPIO 16 en de andere op GND. Het systeem gebruikt interne pull-up, dus geen extra weerstand nodig.
* **Servo motor** – signaaldraad op GPIO 18 (pin 12), VCC op 5V, GND op GND.

Functionaliteit:

**GPIO 26 - LED**:
* Wordt gebruikt als status-indicator
* Geeft feedback bij mode-wissels en servo-activiteit
**GPIO 16 - DRUKKNOP**:
* Wordt gebruikt om tussen verschillende systeemmodi te wisselen
* Werkt met interne pull-up weerstand
**PWM / Servo (GPIO 18 – pin 12)**:
* Wordt aangestuurd via hardware PWM
*PWM-signaal wordt gegenereerd via de bcm2835 library

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
* **Gebruikte libraries:**
1. **C libraries**
   * `stdio.h`	(Voor standaard input/output (printf))
   * `unistd.h`	(Voor tijdsfuncties zoals usleep())
   * `time.h`	(Voor tijd-gerelateerde functies, zoals logging of delays)
   * `pthread.h`	(Voor threading ondersteuning (wordt door pigpio gebruikt))
2. GPIO / hardware libraries
   * `pigpio.h` (digitale IO, knop, LED)
   * `bcm2835.h` (hardware PWM voor servo)
3. Build / system libraries
   * `-lrt`  (Realtime timers (wordt gebruikt bij PWM timing en delays))

* **Build tools:** GCC, CMake
* **Containerisatie:** Docker + Buildx + QEMU
* **CI/CD:** GitHub Actions
* **Remote execution:** SSH + tmux

---

### 5. Repository structuur

```
├── .github/workflows/        # CI/CD pipeline definitie
├── pigpio/                   # Externe GPIO library
├── main.c                    # Applicatielogica
├── command.c / command.h     # Command parsing (legacy / uitbreidbaar)
├── CMakeLists.txt            # Build configuratie
├── Dockerfile                # Build omgeving
└── README.md                 # Documentatie
```

---

## DEEL 2 – STAPPENPLAN 

Deze sectie beschrijft **exact** hoe je dit project opzet vanaf een **volledig lege computer**.

---

### Stap 1 – Benodigdheden (lege computer)

Installeer eerst **deze software**:

1. **Git**

   * Nodig om de repository te clonen
   * Download: https://git-scm.com/

2. **Docker Desktop**

   * Nodig voor build en compilatie
   * Zorg dat Docker effectief draait
   * Download: https://www.docker.com/products/docker-desktop/

3. **GitHub account**

   * Nodig voor GitHub Actions

⚠️ Je hoeft **geen** GCC, CMake of pigpio lokaal te installeren.

---

### Stap 2 – Repository clonen

```bash
git clone <repository-url>
cd <repository-folder>
```
Dit downloadt alle code en configuratiebestanden.
---

### Stap 3 – Raspberry Pi voorbereiden

Installatie Raspberry Pi OS

* Download Raspberry Pi Imager: https://www.raspberrypi.com/software/
* Plaats een SD-kaart in je computer
* Start Raspberry Pi Imager
* Kies je OS: Raspberry Pi OS Lite (zonder desktop)
* Selecteer je SD-kaart
* Klik in de Imager op het tandwiel-icoon (instellingen). Vink "Enable SSH" aan
* Stel een gebruikersnaam (PI_USER) en wachtwoord in
* Configureer je Wi-Fi
* Klik op Write en wacht tot de installatie klaar is

**SSH activeren**

* Na installatie, open de SD-kaart op je computer
* Maak een leeg bestand aan in de root van de boot-partitie genaamd ssh (zonder extensie)
* Dit activeert SSH automatisch bij eerste boot

**tmux installeren**

SSH naar je Pi:
```bash
ssh pi@<ip-adres-van-pi>
sudo apt update
sudo apt install tmux -y
```
**Waarom tmux?**
tmux laat toe dat een programma blijft draaien, zelfs als je de SSH-sessie sluit.

---


### Stap 4 – GitHub Secrets instellen

In de GitHub repository:

1. Ga naar Settings → Secrets and Variables → Actions
2. Voeg de volgende secrets toe:
* PI_HOST → IP-adres van de Pi
* PI_USER → gebruikersnaam op de Pi (pi)
* PI_PRIVATE_KEY → inhoud van je private key (id_rsa_bramj)

Deze worden gebruikt door GitHub Actions om automatisch verbinding te maken.

---

### Stap 5 – Docker build via GitHub Actions

Docker zorgt dat je code identiek wordt gebouwd voor ARM64 (Raspberry Pi) vanaf een x86 computer.

1. GitHub Actions gebruikt QEMU om ARM-code te emuleren
2. Buildx maakt multi-platform builds mogelijk
3. De Dockerfile installeert alle dependencies (pigpio, bcm2835, etc.)

In je .yml staat al de actie om dit automatisch te doen bij elke push.

---

### Stap 6 – Compilatie in Docker

**Docker container starten**
Je code wordt gecompileerd binnen de container, zodat je alle afhankelijkheden hebt.
```bash
docker run --rm -v $(pwd):/work bramj_builder bash -c "
cd /work
gcc main.c -o main -lpigpio -lbcm2835 -lpthread -lrt
"
```
**Uitleg**
* -v $(pwd):/work → mount je lokale folder in de container
* -lpigpio → GPIO functies
* -lbcm2835 → hardware PWM
* -lpthread → threading ondersteuning
* -lrt → realtime timers

Na dit commando heb je een main executable in je folder.

---

### Stap 7 – SCP: binary kopiëren naar Raspberry Pi

Na compilatie moet de binary naar de Pi:
```bash
scp -i ~/.ssh/id_rsa_bramj main pi@<pi-ip>:/home/pi/main
```

Dit kopieert het bestand main naar de home-directory van de Pi.

---

### Stap 8 – Programma starten via SSH

Op de Pi:
```bash
chmod +x ~/main
tmux kill-session -t bramj || true
tmux new -d -s bramj ./main
```
**Uitleg:**

* chmod +x → maakt het bestand uitvoerbaar
* tmux kill-session → stopt een oude sessie (indien actief)
* tmux new -d -s bramj ./main → start het programma in een detach sessie

Nu draait het programma continu, zelfs als je de SSH-sessie sluit.

---

### Stap 9 - Hardwaare controleren

1. LED op GPIO 26 moet branden of knipperen
2. Drukknop op GPIO 16 wisselt modi
3. Servo op GPIO 18 beweegt correct

Vergeet niet de LED met weerstand aan te sluiten, en de drukknop correct te verbinden zoals eerder beschreven.

---

## DEEL 3 – Uitleg van main.c

Hier volgt een regel-voor-regel uitleg van main.c:

```c
#include <stdio.h>       // Voor printf()
#include <unistd.h>      // Voor usleep()
#include <pigpio.h>      // GPIO library
#include <bcm2835.h>     // Servo PWM library
#include <time.h>        // Tijd functies
```
* Importeert standaard- en hardwarelibraries.


```c
#define LED_GPIO_PIN 26
#define BUTTON_GPIO_PIN 16
#define SERVO_GPIO_PIN RPI_V2_GPIO_P1_12
```
* GPIO-nummers van LED, knop en servo.


```c
#define SERVO_MIN 1000
#define SERVO_MAX 2000
```
* PWM-pulsbreedte voor servo (1000–2000 µs).


```c
typedef enum
{
	MODE_IDLE = 0,
	MODE_SWEEP,
	MODE_CENTER
} system_mode_t;
```
* Definieert de drie systeemmodi.


```c
system_mode_t currentMode = MODE_IDLE;
int lastButtonState = 1;
```
* currentMode start op IDLE
* lastButtonState onthoudt vorige knopstatus

**Hulpfuncties**

```c
void setup_servo()
{
	bcm2835_gpio_fsel(SERVO_GPIO_PIN, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_pwm_set_clock(192);
	bcm2835_pwm_set_mode(1, 1, 1);
	bcm2835_pwm_set_range(1, 2000);
}
```
* Initialiseert hardware PWM voor servo.


```c
void set_servo_pulse(int pulse)
{
	if (pulse < SERVO_MIN) pulse = SERVO_MIN;
	if (pulse > SERVO_MAX) pulse = SERVO_MAX;
	bcm2835_pwm_set_data(1, pulse);
}
```
*Zorgt dat servo binnen limieten beweegt.


```c
void blink_led(int times, int delayMs)
{
	for (int i = 0; i < times; i++)
	{
		gpioWrite(LED_GPIO_PIN, PI_ON);
		usleep(delayMs * 1000);
		gpioWrite(LED_GPIO_PIN, PI_OFF);
		usleep(delayMs * 1000);
	}
}
```
*Knippert LED een aantal keer met opgegeven vertraging.


```c
void log_mode(system_mode_t mode)
{
	switch (mode)
	{
	case MODE_IDLE:
		printf("[MODE] IDLE\n");
		break;
	case MODE_SWEEP:
		printf("[MODE] SWEEP\n");
		break;
	case MODE_CENTER:
		printf("[MODE] CENTER\n");
		break;
	}
}
```
*Print huidige modus naar console.

**Input**
```c
void check_button()
{
	int state = gpioRead(BUTTON_GPIO_PIN);
	if (state == 0 && lastButtonState == 1)
	{
		currentMode++;
		if (currentMode > MODE_CENTER)
			currentMode = MODE_IDLE;
		log_mode(currentMode);
		blink_led(2, 100);
	}
	lastButtonState = state;
}
```
*Detecteert knopdruk
*Wisselt modus cyclisch
*Knippert LED 2x als feedback

**Modi**
```c
void mode_idle()
{
	gpioWrite(LED_GPIO_PIN, PI_OFF);
	set_servo_pulse(1500);
	usleep(200000);
}

void mode_center()
{
	gpioWrite(LED_GPIO_PIN, PI_ON);
	set_servo_pulse(1500);
	usleep(200000);
}

void mode_sweep()
{
	static int angle = 0;
	static int direction = 1;

	int pulse = SERVO_MIN + (angle * (SERVO_MAX - SERVO_MIN)) / 180;
	set_servo_pulse(pulse);

	gpioWrite(LED_GPIO_PIN, (angle % 20 < 10) ? PI_ON : PI_OFF);

	angle += direction * 5;
	if (angle >= 180) direction = -1;
	if (angle <= 0) direction = 1;

	usleep(100000);
}
```
*mode_idle() → servo gecentreerd, LED uit
*mode_center() → servo gecentreerd, LED aan
*mode_sweep() → servo heen en weer, LED knippert synchroon

**Main**
```c
int main(void)
{
	printf("System start...\n");

	if (gpioInitialise() < 0) { ... } // init pigpio
	gpioSetMode(LED_GPIO_PIN, PI_OUTPUT);
	gpioSetMode(BUTTON_GPIO_PIN, PI_INPUT);
	gpioSetPullUpDown(BUTTON_GPIO_PIN, PI_PUD_UP);

	if (!bcm2835_init()) { ... } // init PWM
	setup_servo();
	log_mode(currentMode);

	while (1)
	{
		check_button();
		switch (currentMode)
		{
		case MODE_IDLE: mode_idle(); break;
		case MODE_SWEEP: mode_sweep(); break;
		case MODE_CENTER: mode_center(); break;
		}
	}

	gpioTerminate();
	bcm2835_close();
	return 0;
}
```
*Initialiseert GPIO en PWM
*Start oneindige loop die modus controleert en LED/servo aanstuurt
*Zorgt voor correcte afsluiting van libraries

---

## DEEL 4 – Uitleg van .yml bestand (GitHub Actions)

```yml
name: Bramj Continuous Deployment
```
* Naam van de pipeline


```yml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```
* Start pipeline bij push of PR naar main.

**Jobs**
```yml
jobs:
  build-and-deploy:
    runs-on: self-hosted
```
* Pipeline draait op een self-hosted runner (jouw PC of server)

**Stappen jobs**

1. Checkout code → haalt repository op
2. Set up QEMU & Docker Buildx → emuleert ARM64 op x86
3. Build Docker image → bouwt container met dependencies
4. Compile inside Docker → compileert main.c tot executable
5. Ensure SSH directory → maakt .ssh folder op Windows
6. Write SSH private key → schrijft key uit GitHub secrets
7. Upload binary → SCP naar Raspberry Pi
8. Restart program → stopt oude sessie en start nieuwe tmux sessie met main

Alles wordt automatisch uitgevoerd bij elke push naar main.

--- 
**Auteur:** Bram J & Timo M
