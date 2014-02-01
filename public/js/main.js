var socket = io.connect('http://localhost:8080');

console.log(window.location.pathname);
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
		//somehow propogate the search results on the page
	});



*/
	$.getJSON('/search', {q: encodeURIComponent(query)}, function(data) {
		console.log("search complete");
		console.log(data);
	})
}


//id is the unique track id that exists for every song. Obtain from tracks[i].id
function playSong (id, startedTimestamp) {
	//resource: http://www.schillmania.com/projects/soundmanager2/doc/#smsound-setposition
	SC.stream("/tracks/" + String(id), function(sound){
		sound.onload = function() {
			var currentTimestamp = new Date();
			var offset = currentTimestamp - startedTimestamp;
			sound.setPosition(offset);
			sound.play();
		}
		sound.load();
	});
}