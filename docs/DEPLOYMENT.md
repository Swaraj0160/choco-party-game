# CHOCO Deployment & Architecture

## The HTTPS / Mixed Content Challenge
In modern browsers, if a website is served over HTTPS (e.g. deployed to Vercel, Netlify, etc.), it is strictly forbidden from making WebSocket connections to non-secure `ws://` endpoints, especially local network IPs. This is known as Mixed Content policy.

## The CHOCO Solution
Instead of forcing players to download an app or deploying complex cloud infrastructure with SSL certificates for local IPs, CHOCO uses a completely standalone zero-dependency approach:

1. **Embedded HTTP Server**: CHOCO hosts its own web server directly inside Godot on port 8080.
2. **Local HTTP Delivery**: Players scan a QR code that points to `http://<LOCAL_IP>:8080`.
3. **No Mixed Content**: Because the HTML is served over local HTTP, the browser happily allows connections to the local `ws://` WebSocket server on port 8081.

## Why this is superior for local party games
- **Zero Install**: Just run the `CHOCO.exe` and it hosts everything.
- **Zero Latency**: Traffic never leaves your local Wi-Fi router.
- **Zero Cloud Costs**: You don't pay for Vercel, AWS, or Heroku.
- **Always Available**: Even if your internet goes down, you can still play locally.

If public internet multiplayer is desired, a proper relay server (like Godot's dedicated server mode) would be deployed with SSL termination. But for a local shared-screen party game, the current architecture is the gold standard.
