$(function() {
	var socket = io.connect('http://localhost:8000');
	var roomId =
	console.log();
	console.log("THIS IS A TEST LOOKOUT");
	socket.emit('joinRoom', 0);

	socket.on('timestamp', function(data) {
	  console.log("received timestamp");
	  window.timestamp = data;
	  console.dir(data);
	});

	socket.on('playlist', function(data) {
	  console.log("received playlist");
	  window.playlist = data;
	});

	//Soundcloud stuff
	SC.initialize({
		client_id: '9e7bd4599a033c7207a6c683203bd2ef'
	});

	$("#searchButton").click(function(e) {
	var query = $('#searchText').val();
	console.log(encodeURIComponent(query));
	$.getJSON('/search', {q: encodeURIComponent(query)}, function(data) {
		console.log("search complete");
		console.log(data);
		htmlString = data.map(function(track) {
			return "<li data-url="+track.stream_url+"<strong>" + track.title + "</strong><a class='btn btn-primary' href='#'>Add Song</a></li>";
		}).join('')
		$('#searchResults').html(htmlString);
		$('#searchResults li a').click(function(e) {
			var url = $(e.currentTarget.parentNode).attr('data-url');
			console.log(url);
		});
	});
});
})


