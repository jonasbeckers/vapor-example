function Chat(host, user) {
	var chat = this;
	
	chat.username = user;
	chat.ws = new WebSocket(host);
                  
	chat.ws.onopen = function(event) {
		var username = 'Jonas';
		var json = JSON.stringify({ 'username': chat.username });
		chat.ws.send(json);
	}
                   
	chat.ws.onmessage = function(msg) {
		var json = JSON.parse(msg.data);
		chat.addMessage(json.username, json.message);
	}
                   
	$('#send').click(function() {
		var message = $('#message').val();
		if(message.length > 0) {
			var json = JSON.stringify({ 'message': message });
			chat.ws.send(json);
			chat.addMessage(chat.username, message);
			$('#message').val('');
		}
	});
	
	chat.addMessage = function(user, message) {
		var div = $('<div>').addClass('row').addClass('message-bubble');
		var u = $('<p>').addClass('text-muted').text(user);
		var m = $('<p>').text(message)
		div = div.append(u);
		div = div.append(m);
		$('#chat').append(div);
	}
	
};