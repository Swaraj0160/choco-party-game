# Research & License Audit

We audited multiple party game architectures before choosing the zero-dependency Godot embedded server.

| Name | Category | What we learned | License | Reused Code? | Reused Assets? | What CHOCO reused | Why |
|---|---|---|---|---|---|---|---|
| Godot Phone Mass Controllers | Architecture | How to structure WebSocket messaging between Godot and JS. | MIT | No | No | Conceptual architecture. | We wrote our own raw `WebSocketPeer` server instead of Godot's `WebSocketMultiplayerPeer` to maintain standard JS WebSocket compatibility. |
| AirConsole | Platform | How they handle player sessions and UI synchronization. | Proprietary | No | No | Nothing | Learned the value of zero-install frictionless joining. |
| Jackbox Games | Inspiration | UI design and lobby flow. | Proprietary | No | No | Nothing | Showed that 4-digit room codes or QR codes are the gold standard. |

All code written in CHOCO is 100% original and written from scratch to ensure complete ownership and license compliance.
