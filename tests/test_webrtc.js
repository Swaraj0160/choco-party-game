const puppeteer = require('puppeteer');

(async () => {
    console.log("Launching Host...");
    const browser = await puppeteer.launch({ headless: true });
    
    // 1. Open Host
    const hostPage = await browser.newPage();
    await hostPage.goto('https://landing-peach-eight-88.vercel.app/host.html');
    
    // Wait for the room code to generate (it replaces '----')
    await hostPage.waitForFunction(() => {
        const text = document.getElementById('code-display').innerText;
        return text && text !== '----';
    }, { timeout: 10000 });
    
    const roomCode = await hostPage.$eval('#code-display', el => el.innerText);
    console.log("Room created! Code: " + roomCode);
    
    // 2. Open Phone 1
    console.log("Launching Phone 1...");
    const phonePage = await browser.newPage();
    await phonePage.goto('https://landing-peach-eight-88.vercel.app/join.html');
    
    await phonePage.type('#room-code', roomCode);
    await phonePage.type('#player-name', 'Alice');
    await phonePage.click('#btn-join');
    
    // Wait for connection to succeed and lobby screen to appear
    await phonePage.waitForSelector('#screen-lobby.active', { timeout: 10000 });
    console.log("Phone 1 Connected to Host Lobby!");
    
    // Phone 1 clicks ready
    await phonePage.click('#btn-ready');
    console.log("Phone 1 is Ready!");
    
    // Wait for the game to start on the host
    await hostPage.waitForSelector('#game-container[style*="display: flex"]', { timeout: 5000 });
    console.log("Game successfully transitioned to PLAYING state on Host!");
    
    // Wait for fighter to appear
    const fighterCount = await hostPage.$$eval('.fighter', els => els.length);
    console.log(`Fighters spawned: ${fighterCount}`);
    
    // Send attack from phone
    console.log("Sending attack from Phone 1...");
    await phonePage.evaluate(() => {
        // trigger touchstart or click programmatically
        document.getElementById('btn-light').dispatchEvent(new Event('mousedown'));
    });
    
    // Verify hit fx on host
    await hostPage.waitForFunction(() => {
        const fx = document.querySelector('.hit-fx');
        return fx && fx.style.opacity === '1';
    }, { timeout: 5000 });
    console.log("HIT REGISTERED OVER WEBRTC PUBLIC INTERNET!");
    
    await browser.close();
    console.log("TEST SUCCESSFUL");
})();
