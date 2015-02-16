namespace Hsyngkby\Support;

class Socket
{
	/* Socket Options
	
	host = 'localhost'; //host
	port = '9000'; //port
	null = NULL; //null var	
	
	*/
	protected opt;

	protected socket;
	
	protected client;

	public function __construct(opt = null)
	{
		error_log("LOG Socket  __construct");

		if opt == null{
			return this;	
		}else{
			return this->setOpt(opt);

		}
	}
	public function setOpt (opt) {
		let this->opt = opt;
		error_log("LOG opt = ".json_encode(opt));			
		return this;
	}
	public function getOpt () {
		return this->opt;
	}

	public function createSocket () {
		var changed;
		var header;
		var ip,socket_new;
		var response;
		var buf;
		var received_text;
		var tst_msg;
		var user_name;
		var user_message;
		var user_color;
		var response_text;
		var found_socket;

		//Create TCP/IP sream socket
		let this->socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
		//reuseable port
		socket_set_option(this->socket, SOL_SOCKET, SO_REUSEADDR, 1);

		//bind socket to specified host
		socket_bind(this->socket, 0, this->opt['port']);

		//listen to port
		socket_listen(this->socket);

		//create & add listning socket to the list
		let this->clients = [this->socket];
		
		//start endless loop, so that our script doesn't stop
		while (true) {
			//manage multipal connections
			
			let changed = this->clients;
			//returns the socket resources in changed array
			socket_select(changed, this->opt['null'], this->opt['null'], 0, 10);
			
			//check for new socket
			if (in_array(this->socket, changed)) {
				let socket_new = socket_accept(this->socket); //accpet new socket
				let this->clients[] = socket_new; //add socket to client array
				
				let header = socket_read(socket_new, 1024); //read data sent by the socket
				this->perform_handshaking(header, socket_new, this->opt['host'], this->opt['port']); //perform websocket handshake
				
				socket_getpeername(socket_new, ip); //get ip address of connected socket
				
				let response = this->mask(
					json_encode(
						[	
							'type':'system', 
							'message':ip.' connected'
						]
					)
				); //prepare json data
				send_message(response); //notify all users about new connection
				
				//make room for new socket				
				let found_socket = array_search(this->socket, changed);
				unset(changed[found_socket]);
			}
			
			//loop through all connected sockets
			for changed_socket in changed {	
				
				//check for any incomming data
				while(socket_recv(changed_socket, buf, 1024, 0) >= 1)
				{
					let received_text = this->unmask(buf); //unmask data
					let tst_msg = json_decode(received_text); //json decode 
					let user_name = tst_msg->name; //sender name
					let user_message = tst_msg->message; //message text
					let user_color = tst_msg->color; //color
					
					//prepare data to be sent to client
					let response_text = this->mask(
						json_encode(
							[
								'type':'usermsg', 
								'name':user_name, 
								'message':user_message, 
								'color':user_color
							]
						)
					);
					send_message(response_text); //send data
					break; //exist this loop
				}
				
				let buf = @socket_read(changed_socket, 1024, PHP_NORMAL_READ);
				if (buf === false) { // check disconnected client
					// remove client for $clients array
					found_socket = array_search(changed_socket, this->clients);
					socket_getpeername(changed_socket, ip);
					unset(this->clients[found_socket]);
					
					//notify all users about disconnected connection
					let response = this->mask(json_encode(array('type'=>'system', 'message'=>ip.' disconnected')));
					send_message(response);
				}
			}
		}
		// close the listening socket
		socket_close(this->socket);

		return this;
	}


	public function send_message(msg)
	{
		var changed_socket;

		for changed_socket in this->clients
		{
			@socket_write(changed_socket,msg,strlen(msg));
		}
		return true;
	}


	//Unmask incoming framed message
	public function unmask(text) 
	{
		var length;
		var masks;
		var data;

		let length = ord(text[1]) & 127;
		if(length == 126) {
			let masks = substr(text, 4, 4);
			let data = substr(text, 8);
		}
		elseif(length == 127) {
			masks = substr(text, 10, 4);
			data = substr(text, 14);
		}
		else {
			masks = substr(text, 2, 4);
			data = substr(text, 6);
		}
		text = "";
		var _loop = strlen(data);
		var i;
		let i = 0;
		while _loop {			
			text .= data[i] ^ masks[i%4];
			let i += 1 ;
		}
		return text;
	}

	//Encode message for transfer to client.
	public function mask(text)
	{
		var b1,length,header;

		let b1 = 0x80 | (0x1 & 0x0f);
		let length = strlen(text);
		
		if length <= 125{
			let header = pack('CC', b1, length);
		}
		elseif length > 125 && length < 65536{
			let header = pack('CCn', b1, 126, length);
		}
		elseif length >= 65536{
			let header = pack('CCNN', b1, 127, length);
		}
		return header.text;
	}

	//handshake new client.
	public function perform_handshaking(receved_header,client_conn, host, port)
	{
		var headers,lines,matches;
		var secKey,secAccept,upgrade;

		let headers = array();
		let lines = preg_split("/\r\n/", receved_header);
		for line in lines
		{
			line = chop(line);
			if(preg_match('/\A(\S+): (.*)\z/', line, matches))
			{
				headers[matches[1]] = matches[2];
			}
		}

		let secKey = $headers['Sec-WebSocket-Key'];
		let secAccept = base64_encode(pack('H*', sha1(secKey . md5('B8576AC4-87F4-4C0A-A075-986CF82B02BF'))));
		//hand shaking header
		let upgrade  = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n" .
		"Upgrade: websocket\r\n" .
		"Connection: Upgrade\r\n" .
		"WebSocket-Origin: $host\r\n" .
		"WebSocket-Location: ws://$host:$port/demo/shout.php\r\n".
		"Sec-WebSocket-Accept:$secAccept\r\n\r\n";
		socket_write(client_conn,upgrade,strlen(upgrade));
	}

}