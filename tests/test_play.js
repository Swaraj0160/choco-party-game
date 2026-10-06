const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    
    await page.goto('http://127.0.0.1:8080/');
    
    await page.waitForSelector('#screen-join.active');
    await page.type('#player-name', 'TestPlayer');
    await page.click('#btn-join');
    
    await page.waitForSelector('#screen-lobby.active');
    console.log("In Lobby");
    
    await page.click('#btn-ready');
    console.log("Clicked Ready");
    
    await page.waitForSelector('#screen-playing.active');
    console.log("Game Started! We are in Playing screen.");
    
    // send some action inputs
    for (let i = 0; i < 10; i++) {
        await page.click('button[data-action="light"]').catch(() => {});
        await new Promise(r => setTimeout(r, 500));
    }
    
    await browser.close();
})();
