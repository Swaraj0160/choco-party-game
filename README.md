# CHOCO - The Ultimate Smartphone-Controlled Party Game

CHOCO is a polished, LAN-first multiplayer party game where your PC acts as the cinematic game console, and every player's smartphone becomes their personal controller.

## Features
- **Frictionless Join**: No app to install. Just scan the QR code on the screen.
- **Zero-Dependency Host**: Godot natively serves the phone UI via HTTP and handles real-time inputs via WebSockets. No Node.js or Python required!
- **Dynamic Minigames**: Includes 3D Physics Brawlers (Chaos Arena) and 2D Twitch games (Reaction Rush).
- **Player Identity**: Consistent player colors on your phone UI and your in-game character.

## How to Play
1. **Visit our Landing Page** for an overview: [CHOCO Public Site](https://landing-peach-eight-88.vercel.app)
2. **Launch the Game**: Run the CHOCO executable (or run from Godot Editor) on your PC.
3. **Scan to Join**: The game will display a QR code on the main screen.
4. **Connect Phones**: Players connect their phones to the same Wi-Fi and scan the code. No app downloads required!
5. **Ready Up**: Once everyone taps "I'M READY" on their phone, the games begin automatically!

## Architecture
- **Engine**: Godot 4.3 (GDScript)
- **Controller**: Vanilla HTML5, CSS3, JS.

## Network Requirements
- Must be played on a Local Area Network (LAN) where devices can see the host PC.
- Uses Port 8080 (HTTP) and Port 8081 (WebSocket).

## License
Built entirely from scratch. See `THIRD_PARTY_LICENSES.md` for tool attributions.
