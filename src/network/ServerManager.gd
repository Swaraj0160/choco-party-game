extends Node

const HTTP_PORT = 8080
const WS_PORT = 8081

var http_server : TCPServer
var ws_tcp_server : TCPServer
var http_clients = []
var ws_peers = {} # Dictionary of id -> WebSocketPeer
var next_peer_id = 1

signal phone_connected(id)
signal phone_disconnected(id)
signal phone_message_received(id, message)

func _ready():
	_start_http_server()
	_start_ws_server()

func _start_http_server():
	http_server = TCPServer.new()
	var err = http_server.listen(HTTP_PORT)
	if err == OK:
		print("HTTP Server listening on port %d" % HTTP_PORT)
	else:
		print("Failed to start HTTP Server")

func _start_ws_server():
	ws_tcp_server = TCPServer.new()
	var err = ws_tcp_server.listen(WS_PORT)
	if err == OK:
		print("WebSocket Server listening on port %d" % WS_PORT)
	else:
		print("Failed to start WebSocket Server")

func _process(_delta):
	# Handle HTTP Connections
	if http_server and http_server.is_connection_available():
		var peer = http_server.take_connection()
		http_clients.append(peer)
	
	var to_remove = []
	for peer in http_clients:
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			if peer.get_available_bytes() > 0:
				var request = peer.get_utf8_string(peer.get_available_bytes())
				_handle_http_request(peer, request)
				to_remove.append(peer)
		else:
			to_remove.append(peer)
			
	for peer in to_remove:
		if peer in http_clients:
			http_clients.erase(peer)

	# Handle WebSocket Connections
	if ws_tcp_server and ws_tcp_server.is_connection_available():
		var tcp_peer = ws_tcp_server.take_connection()
		var ws_peer = WebSocketPeer.new()
		# removed supported_protocols to allow raw connections easily
		var err = ws_peer.accept_stream(tcp_peer)
		if err == OK:
			var id = next_peer_id
			next_peer_id += 1
			ws_peers[id] = {"peer": ws_peer, "connected": false}

	# Poll existing WebSockets
	var ws_to_remove = []
	for id in ws_peers:
		var peer_data = ws_peers[id]
		var ws_peer = peer_data["peer"] as WebSocketPeer
		ws_peer.poll()
		var state = ws_peer.get_ready_state()
		
		if state == WebSocketPeer.STATE_OPEN:
			if not peer_data["connected"]:
				peer_data["connected"] = true
				print("Phone connected: ", id)
				phone_connected.emit(id)
				
			while ws_peer.get_available_packet_count() > 0:
				var packet = ws_peer.get_packet()
				var msg_str = packet.get_string_from_utf8()
				var json = JSON.new()
				if json.parse(msg_str) == OK:
					phone_message_received.emit(id, json.get_data())
		elif state == WebSocketPeer.STATE_CLOSED:
			if peer_data["connected"]:
				print("Phone disconnected: ", id)
				phone_disconnected.emit(id)
			ws_to_remove.append(id)

	for id in ws_to_remove:
		ws_peers.erase(id)


func _handle_http_request(peer: StreamPeerTCP, request: String):
	var lines = request.split("\n")
	if lines.size() > 0:
		var req_line = lines[0].strip_edges()
		var parts = req_line.split(" ")
		if parts.size() >= 2:
			var method = parts[0]
			var path = parts[1]
			_serve_file(peer, path)
	peer.disconnect_from_host()

func _serve_file(peer: StreamPeerTCP, path: String):
	if path == "/":
		path = "/index.html"
	
	if "?" in path:
		path = path.split("?")[0]
		
	if ".." in path:
		_send_404(peer)
		return
		
	var file_path = "res://controller" + path
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var content = file.get_buffer(file.get_length())
		var ext = path.get_extension().to_lower()
		var content_type = "text/plain"
		
		match ext:
			"html": content_type = "text/html"
			"css": content_type = "text/css"
			"js": content_type = "application/javascript"
			"png": content_type = "image/png"
			"jpg", "jpeg": content_type = "image/jpeg"
			"svg": content_type = "image/svg+xml"
			"json": content_type = "application/json"
			
		var response = "HTTP/1.1 200 OK\r\n"
		response += "Content-Type: " + content_type + "\r\n"
		response += "Connection: close\r\n"
		response += "Access-Control-Allow-Origin: *\r\n\r\n"
		
		peer.put_data(response.to_utf8_buffer())
		peer.put_data(content)
	else:
		_send_404(peer)

func _send_404(peer: StreamPeerTCP):
	var response = "HTTP/1.1 404 Not Found\r\n"
	response += "Content-Length: 0\r\n"
	response += "Connection: close\r\n\r\n"
	peer.put_data(response.to_utf8_buffer())

func send_message(id: int, msg: Dictionary):
	if ws_peers.has(id):
		var ws_peer = ws_peers[id]["peer"] as WebSocketPeer
		if ws_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			ws_peer.put_packet(JSON.stringify(msg).to_utf8_buffer())

func broadcast_message(msg: Dictionary):
	var data = JSON.stringify(msg).to_utf8_buffer()
	for id in ws_peers:
		var ws_peer = ws_peers[id]["peer"] as WebSocketPeer
		if ws_peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			ws_peer.put_packet(data)
