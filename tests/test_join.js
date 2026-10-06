const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    page.on('pageerror', err => console.log('PAGE ERROR:', err.message));
    
    await page.goto('http://127.0.0.1:8080/');
    
    // wait for join screen
    await page.waitForSelector('#screen-join.active');
    console.log("Join screen is active");
    
    await page.type('#player-name', 'TestPlayer');
    await page.click('#btn-join');
    
    console.log("Clicked join");
    
    // wait a bit to see if screen changes
    await new Promise(r => setTimeout(r, 2000));
    
    const isLobby = await page.$eval('#screen-lobby', el => el.classList.contains('active'));
    const isPlaying = await page.$eval('#screen-playing', el => el.classList.contains('active'));
    const isJoin = await page.$eval('#screen-join', el => el.classList.contains('active'));
    
    console.log(`Lobby active: ${isLobby}, Playing active: ${isPlaying}, Join active: ${isJoin}`);
    
    await browser.close();
})();
