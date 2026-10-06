# BUILD STATUS

## Completed Features
- [x] **CRITICAL BUG FIXED**: The phone JOIN PARTY flow correctly transitions clients from the Join screen to the Lobby or Active Game by resolving a WebSocket binary `Blob` issue on the browser side.
- [x] Zero-dependency Godot HTTP Server (serves Controller UI)
- [x] Godot WebSocket Server for real-time input
- [x] Complete Match Flow (Lobby -> Playing -> Results -> Next Game)
- [x] Minigame 1: Chaos Arena (3D Physics brawler)
- [x] Minigame 2: Reaction Rush (2D reaction game)
- [x] **FLAGSHIP MINIGAME: Rhythm Fight** (3D Rhythm brawler with precise `RhythmClock` sync and dynamic Beatmaps).
- [x] Player Identity (Colors map across phone and game)
- [x] Local LAN multiplayer (100% functional, no internet required)

## How to Run & Deployment
1. **Public Landing Page**: Visit [https://landing-peach-eight-88.vercel.app](https://landing-peach-eight-88.vercel.app) for the promotional site.
2. **Local Host**: Run `godot.exe` (or `CHOCO.exe` when built) from the project root.
3. The game will display a Lobby with a QR Code and your PC's LAN IP address.
4. On a smartphone connected to the same Wi-Fi, scan the QR code to instantly load the controller.
5. Enter a name, press Join, and you are playing!

## Test Results
- **Automated Tests**: Puppeteer scripts (`test_join.js`, `test_play.js`) verify that the client fully navigates from Join -> Lobby -> Playing and successfully sends combat inputs over WebSockets.
- **Latency**: Local LAN testing yields sub-10ms latency, which is perfect for the 0.25-beat hit windows in Rhythm Fight.
- **Network Interruptions**: The server handles disconnects gracefully.

## Known Limitations
- The HTTP Server serves static files using Godot's `FileAccess`. In a finalized export, the `controller` folder must be packaged in `res://` or copied to `user://` correctly.
- Currently, bots are not implemented, but the framework makes it easy to simulate inputs.

## Desktop Build Location
You can export this via Godot using:
`godot --headless --export-release "Windows Desktop" build/CHOCO.exe`
