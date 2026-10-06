# CHOCO Game Design Document

## Vision
CHOCO is a shared-screen multiplayer party game where the main PC handles the cinematic world and physics, and each player's smartphone becomes their personal controller.

## Design Principles
- **No App Install**: Joining must be frictionless via a browser and QR code.
- **Identity Consistency**: A player's assigned color is reflected on their phone and their in-game character.
- **Authoritative Host**: Phones only send intents (e.g. "Action Pressed"). The host decides what happens.

## Game Modes
Currently implemented two polished games:

1. **Chaos Arena (3D)**
   - **Goal**: Survive and knock opponents off the platform.
   - **Controls**: D-Pad to apply physics impulses, Action to jump.
   - **Duration**: 30 seconds of physics chaos.

2. **Reaction Rush (2D)**
   - **Goal**: Be the first to press the requested button on your phone.
   - **Controls**: Match the on-screen prompt (e.g., PRESS: UP).
   - **Win Condition**: First player to 3 correct reactions wins the game.

## Flow & Progression
- **Lobby**: Players scan QR and input their names.
- **Match**: Cycles automatically between games when everyone readies up.
- **Results**: Displays scores across all rounds. Pressing Action on the phone continues to the next game in the cycle.
