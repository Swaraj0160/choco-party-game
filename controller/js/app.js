let ws;
let isReady = false;
let myId = null;

const screens = {
    join: document.getElementById('screen-join'),
    lobby: document.getElementById('screen-lobby'),
    playing: document.getElementById('screen-playing')
};

function showScreen(screenName) {
    Object.values(screens).forEach(s => s.classList.remove('active'));
    screens[screenName].classList.add('active');
}

function initWebSocket() {
    const host = window.location.hostname;
    ws = new WebSocket(`ws://${host}:8081`);
    
    ws.onopen = () => {
        console.log("Connected to game server");
    };
    
    ws.onmessage = async (event) => {
        try {
            let text = event.data;
            if (text instanceof Blob) {
                text = await text.text();
            }
            const msg = JSON.parse(text);
            handleMessage(msg);
        } catch (e) {
            console.error("Invalid message", e);
        }
    };
    
    ws.onclose = () => {
        console.log("Disconnected from server");
        setTimeout(initWebSocket, 2000);
    };
}

function handleMessage(msg) {
    switch (msg.type) {
        case 'request_join':
            showScreen('join');
            break;
            
        case 'welcome':
            myId = msg.id;
            const info = msg.info;
            document.documentElement.style.setProperty('--player-color', info.color);
            document.getElementById('lobby-greeting').innerText = `Hey, ${info.name}!`;
            if (msg.game_state == 1) { // 1 = LOBBY
                showScreen('lobby');
            } else if (msg.game_state == 3) { // 3 = PLAYING
                showScreen('playing');
            }
            break;
            
        case 'state_change':
            if (msg.state == 1) {
                showScreen('lobby');
                isReady = false;
                document.getElementById('btn-ready').innerText = "I'M READY";
                document.getElementById('btn-ready').style.backgroundColor = "var(--surface-color)";
                document.getElementById('btn-ready').style.color = "white";
            } else if (msg.state == 3) {
                showScreen('playing');
            }
            break;
            
        case 'change_controller':
            setControllerLayout(msg.layout);
            break;
            
        case 'hit_feedback':
            if (navigator.vibrate) {
                if (msg.rating === 'perfect') navigator.vibrate([30, 30, 30]);
                else if (msg.rating === 'great') navigator.vibrate([30]);
                else navigator.vibrate(10);
            }
            break;
    }
}

function setControllerLayout(layout) {
    const layoutDiv = document.querySelector('.controller-layout');
    if (layout === 'rhythm') {
        layoutDiv.innerHTML = `
            <div class="rhythm-buttons" style="display:flex; gap:15px; width:100%; justify-content:center; align-items:center;">
                <button class="action-btn" data-action="light" style="width:100px; height:100px;">L</button>
                <button class="action-btn" data-action="heavy" style="width:100px; height:100px;">H</button>
                <button class="action-btn" data-action="dodge" style="width:100px; height:100px;">D</button>
            </div>
        `;
    } else {
        layoutDiv.innerHTML = `
            <div class="dpad">
                <button class="dpad-btn up" data-action="up">▲</button>
                <button class="dpad-btn left" data-action="left">◀</button>
                <button class="dpad-btn right" data-action="right">▶</button>
                <button class="dpad-btn down" data-action="down">▼</button>
            </div>
            <div class="action-buttons">
                <button class="action-btn" data-action="action">ACTION</button>
            </div>
        `;
    }
    bindControllerEvents();
}

function bindControllerEvents() {
    document.querySelectorAll('.dpad-btn, .action-btn').forEach(btn => {
        const action = btn.getAttribute('data-action');
        
        btn.addEventListener('touchstart', (e) => {
            e.preventDefault();
            handleAction(action, 'pressed');
        });
        
        btn.addEventListener('mousedown', (e) => {
            e.preventDefault();
            handleAction(action, 'pressed');
        });
    });
}

function sendMessage(msg) {
    if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(msg));
    }
}

// UI Listeners
document.getElementById('btn-join').addEventListener('click', () => {
    let name = document.getElementById('player-name').value.trim();
    if (!name) name = "Player";
    sendMessage({ type: "join", name: name });
});

document.getElementById('btn-ready').addEventListener('click', () => {
    isReady = !isReady;
    sendMessage({ type: "ready", is_ready: isReady });
    
    const btn = document.getElementById('btn-ready');
    if (isReady) {
        btn.innerText = "READY!";
        btn.style.backgroundColor = "var(--player-color)";
        btn.style.color = "#000";
    } else {
        btn.innerText = "I'M READY";
        btn.style.backgroundColor = "var(--surface-color)";
        btn.style.color = "white";
    }
});

// Controller input listeners
const handleAction = (action, state) => {
    // state could be 'pressed', 'released' - simplified for now
    if (state === 'pressed') {
        sendMessage({ type: "input", action: action });
        if (navigator.vibrate) {
            navigator.vibrate(20);
        }
    }
};

// Prevent zooming
document.addEventListener('gesturestart', function(e) {
    e.preventDefault();
});

// Start
initWebSocket();
bindControllerEvents();
