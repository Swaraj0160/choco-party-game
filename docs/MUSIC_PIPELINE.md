# CHOCO Music Pipeline

CHOCO features a robust, reusable rhythm engine designed for seamless syncing between the host PC and all phone controllers.

## RhythmClock
The core `RhythmClock.gd` calculates the exact playback position by reading Godot's `AudioStreamPlayer.get_playback_position()`, correcting for `AudioServer.get_time_since_last_mix()`, and subtracting the output latency.

This provides microsecond-accurate timing for evaluating player inputs against the beatmap.

## Beatmaps
Beatmaps are defined programmatically or loaded from JSON via `Beatmap.gd`. They contain notes (events) associated with specific beats, actions, and lanes. 

## Audio Sync and Multiplayer
Because the PC is authoritative, phones simply send raw timestamps and inputs (e.g., `pressed L`). The PC matches this against the RhythmClock to determine accuracy (Perfect, Great, Good, Miss) and calculates points, applying combat actions and VFX.

To create an entirely new song for CHOCO:
1. Provide the `.ogg` or `.wav`.
2. Define the BPM and offset.
3. Call `Beatmap.generate_simple_4_4_map` or load a custom JSON layout.
