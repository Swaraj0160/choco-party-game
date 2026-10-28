# CHOCO — The LAN-First Smartphone Party Game

[![Godot Engine](https://img.shields.io/badge/Engine-Godot_4.x-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Networking](https://img.shields.io/badge/Networking-WebSocket_%2B_HTTP-blueviolet?style=for-the-badge)](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
[![Controller](https://img.shields.io/badge/Controller-Zero--Install_Mobile_Web-success?style=for-the-badge)](https://developer.mozilla.org/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

> **PC acts as the cinematic big-screen game console; every player's smartphone becomes their personal touch controller.**  
> Zero app downloads. Zero Node.js or Python backend dependencies. 100% standalone Godot binary.

---

## Architecture & System Overview

CHOCO uses an authoritative LAN-first architecture. The Godot engine executable hosts both the game simulation and an **embedded HTTP + WebSocket server**, serving mobile web controller clients directly from memory without requiring external runtime dependencies:

```mermaid
flowchart TD
    subgraph Host["Desktop Console (Godot 4 Engine)"]
        Display["Big-Screen Main Display<br/>(Lobby QR, Minigame Arena, Leaderboards)"]
        GameMgr["GameManager (Autoload Singleton)<br/>(State Machine: LOBBY → PLAYING → RESULTS)"]
        HTTPServer["Embedded HTTP Server (:8080)<br/>(Serves HTML5/JS Mobile Controller via FileAccess)"]
        WSServer["Embedded WebSocket Server (:8081)<br/>(Real-time JSON Input & Telemetry Engine)"]
    end

    subgraph Mobile["Player Smartphones (Zero-Install Mobile Browsers)"]
        Phone1["Player 1 Smartphone<br/>(D-Pad / Action Buttons / Haptic Feedback)"]
        Phone2["Player 2 Smartphone<br/>(Dynamic UI per Minigame)"]
        PhoneN["Player N Smartphone<br/>(Instant Join via QR Code)"]
    end

    Display --> GameMgr
    GameMgr --> WSServer
    HTTPServer -->|1. Scan QR / Load Web Assets| Mobile
    Mobile -->|2. Sub-10ms Input Payloads (JSON)| WSServer
    WSServer --> GameMgr
```

---

## Key Highlights & Mechanics

### 1. Frictionless QR-Code Join Flow
1. The host launches the CHOCO desktop executable on a PC or laptop connected to a local Wi-Fi or LAN hotspot.
2. The lobby screen dynamically renders a join QR code embedding the host machine's local IP (`http://<HOST_IP>:8080`).
3. Players point their smartphone camera at the QR code — loading the lightweight mobile controller instantly in Chrome, Safari, or Firefox without downloading any native app.

### 2. Zero-Dependency Standalone Host
Unlike traditional web-based party games that require hosting external Node.js, Python, or Docker processes, CHOCO embeds the static web server directly inside Godot using `FileAccess`. The entire game ships as a **single, portable `.exe` binary**.

### 3. Dynamic Minigames Suite
- **Chaos Arena (3D Physics Brawler):** Fast-paced physics combat where players navigate 3D dynamic arenas, knock opponents off platforms, and dodge environmental hazards.
- **Reaction Rush (2D Twitch Reflex):** Split-second reflex challenges testing input latency, pattern recognition, and timing.

### 4. WebSocket Input Protocol
Real-time inputs stream via raw, low-overhead JSON payloads over WebSocket port `8081`:
- **Client → Server:**
  - `{"type": "join", "name": "PlayerName"}`
  - `{"type": "ready"}`
  - `{"type": "input", "action": "move", "x": 0.85, "y": -0.12}`
  - `{"type": "input", "action": "button_a"}`
- **Server → Client:**
  - `{"type": "welcome", "id": 1, "color": "#FF5722"}`
  - `{"type": "state_change", "state": "PLAYING", "minigame": "chaos_arena"}`
  - `{"type": "haptic", "pattern": [50, 100, 50]}`

---

## Directory Topology

```text
choco-party-game/
├── controller/               # Mobile touch web controller source
│   ├── index.html            # Responsive phone controller view (D-Pad, Action buttons)
│   ├── css/                  # Low-latency touchscreen styling
│   └── js/                   # WebSocket client & haptic vibration integration
├── docs/                     # Architectural specifications & audits
│   ├── ARCHITECTURE.md       # Networking and Godot lifecycle documentation
│   ├── DEPLOYMENT.md         # Windows standalone build & firewall guide
│   ├── GAME_DESIGN.md        # Minigame rules and progression loops
│   ├── MUSIC_PIPELINE.md     # Dynamic audio and SFX pipeline
│   └── RESEARCH_AND_LICENSE_AUDIT.md # Third-party licensing audit
├── games/                    # Individual minigame scenes and scripts
│   ├── chaos_arena/          # 3D physics brawler level & player rigs
│   └── reaction_rush/        # 2D rapid reflex level
├── landing/                  # Landing page and promotional web materials
├── src/                      # Core Godot engine systems
│   ├── core/                 # GameManager, Boot scene, lobby & leaderboard UI
│   ├── network/              # ServerManager (HTTP :8080) & WebSocket server (:8081)
│   └── utils/                # QR generator, IP resolution, color allocators
├── tests/                    # Network load and latency test scripts (`test_ws.js`)
├── project.godot             # Godot 4 project configuration
├── export_presets.cfg        # Standalone desktop export profiles
└── BUILD_STATUS.md           # Compilation status & engine parity record
```

---

## Getting Started

### Prerequisites
- **Godot Engine 4.x** (Standard 64-bit edition)
- Windows, macOS, or Linux host machine
- Smartphones connected to the same local Wi-Fi / LAN network

### Running in Godot Editor
1. Clone the repository:
   ```bash
   git clone https://github.com/Swaraj0160/choco-party-game.git
   cd choco-party-game
   ```
2. Open Godot Engine 4.x, click **Import**, and select `project.godot`.
3. Press **F5** to run the project. The host will initialize HTTP on `:8080` and WebSocket on `:8081`.
4. Scan the on-screen QR code from any smartphone to join.

### Building Standalone Desktop Executable
1. In Godot, go to **Project → Export...**
2. Select **Windows Desktop** (or Linux/macOS preset).
3. Ensure embedded controller web assets in `controller/` are included in export filters.
4. Click **Export Project** to generate the standalone `.exe`.

---

## Automated Network Testing

A synthetic load-testing suite is included in `tests/` to benchmark WebSocket packet velocity and multi-client connection stability:

```bash
cd tests
npm install ws
node test_ws.js
```

---

## Contributing & Code Guidelines

Contributions to new minigames, mobile controller haptics, and networking performance are welcomed!
- Review [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for network packet standards.
- Follow Godot GDScript style guidelines.
- Submit pull requests with descriptive test logs.

---

## License & Attribution

- **Game Architecture & Code:** [MIT License](LICENSE). Copyright (c) 2026 Swaraj Ingale.
- **Engine:** Built with the open-source [Godot Engine](https://godotengine.org/) (MIT License).
- **Third-Party Details:** Full dependency audit cataloged in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md).
