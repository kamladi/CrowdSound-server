var socket = io.connect('http://localhost:8000');
	console.log();
	socket.emit('joinRoom', 0);

	socket.on('timestamp', function(data) {
	  console.log("received timestamp");
	  window.timestamp = data;
	  console.dir(window.playlist);
	  playSong(window.playlist[0].id, data.serverTime);
	});

	socket.on('playlist', function(data) {
	  console.log("received playlist");
	  window.playlist = data;
	});

$(function() {

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
				return "<li data-id="+track.stream_url+"<strong>" + track.title + "</strong><a class='btn btn-primary' href='#'>Add Song</a></li>";
			}).join('');
			$('#searchResults').html(htmlString);
			$('#searchResults li a').click(function(e) {
				var url = $(e.currentTarget.parentNode).attr('data-url');
				console.log(url);
			});
		});
	});

});



//id is the unique track id that exists for every song. Obtain from tracks[i].id
function playSong (id, startedTimestamp) {
	console.log("/tracks/" + String(id));
	SC.stream("/tracks/" + String(id), function(sound){
		console.dir(sound);
		sound.onload = function() {
			var currentTimestamp = new Date();
			var offset = currentTimestamp - startedTimestamp;
			sound.setPosition(offset);
			sound.play();
		}
		sound.load();
	});
}
