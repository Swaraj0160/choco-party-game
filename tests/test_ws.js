const WebSocket = require('ws');
const ws = new WebSocket('ws://127.0.0.1:8081');

ws.on('open', () => {
  console.log('Connected');
});

ws.on('message', (data) => {
  console.log('Received:', data.toString());
  const msg = JSON.parse(data);
  if (msg.type === 'request_join') {
    ws.send(JSON.stringify({ type: 'join', name: 'BotPlayer' }));
  } else if (msg.type === 'welcome') {
    console.log('Got welcome, sending ready');
    ws.send(JSON.stringify({ type: 'ready', is_ready: true }));
    
    // send some inputs periodically
    setInterval(() => {
        ws.send(JSON.stringify({ type: 'input', action: 'right' }));
    }, 100);
  }
});
