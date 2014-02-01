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


//test search
$("#searchButton").click(soundcloudSearch('satisfaction'));

function soundcloudSearch (query) {
	/*
	SC.get('/tracks', { q: query}, function(tracks) {
		console.log(tracks);
	});
*/
	$.getJSON('/search', {q: encodeURIComponent(query)}, function(data) {
		console.log("search complete");
		console.log(data);
	})
}

