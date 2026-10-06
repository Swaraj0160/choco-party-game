# CHOCO Architecture Document

## Overview
CHOCO uses a LAN-first, authoritative host architecture. The Godot engine runs as the game host and serves the HTML/JS controller interface directly via an embedded HTTP server, completely eliminating the need for a separate web server.

## Godot Architecture
The project is split into Core and Games.
- `src/core/Boot`: The root level scene managing global UI (Lobby, Results).
- `src/core/GameManager`: Autoload singleton managing the GameState (LOBBY, PLAYING, RESULTS) and minigame rotation.
- `src/network/ServerManager`: Hosts the HTTP server (port 8080) for the controller files and WebSocket server (port 8081) for real-time input.
- `src/network/NetworkManager`: Maintains player identity, scores, and handles WebSocket message parsing.

## Networking
- **WebSocket Protocol**: Raw JSON payloads.
  - Client -> Server: `{"type": "join", "name": "..."}`, `{"type": "ready"}`, `{"type": "input", "action": "..."}`
  - Server -> Client: `{"type": "welcome"}`, `{"type": "state_change"}`, `{"type": "player_joined"}`

## Player Lifecycle
1. Phone connects via IP port 8080.
2. Phone loads static HTML/JS/CSS served directly by Godot using `FileAccess`.
3. Phone JS opens WebSocket to port 8081.
4. Server emits `request_join`.
5. Phone sends `join` with name.
6. Server assigns ID, color, and emits `welcome`.
7. Player interacts with UI, sends `ready`.
8. When all ready, Server changes state to PLAYING, broadcasting state change.
9. Phone swaps UI to D-Pad.
10. Inputs are sent as `"input"` events, routed to active Minigame via `GameManager`.

## Deployment
Because the HTTP server is embedded into Godot, the desktop export is 100% standalone. No external Node or Python server is required. Players just launch the `.exe`, and the game hosts everything.
