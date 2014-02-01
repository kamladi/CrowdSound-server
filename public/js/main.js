var socket = io.connect('http://localhost:8080');

console.log(window.location.pathname);
console.log("THIS IS A TEST LOOKOUT");
socket.emit('joinRoom', 0);

socket.on('timestamp', function(data) {
  console.log("timestamp");
  console.dir(data);
});

socket.on('playlist', function(data) {
  console.log("playlist:");
  console.dir(data);
});

function soundcloudSearch (query) {
	SC.initialize({
		client_id: '9e7bd4599a033c7207a6c683203bd2ef'
	});
	SC.get('/tracks', { q: query}, function(tracks) {
		console.log(tracks);
	});
}

