var socket = io.connect(window.location.hostname);
	console.log();
	socket.emit('joinRoom', 0);

	socket.on('playSong', function(data) {
	  console.log("received timestamp");
	  window.timestamp = data;
	  console.dir(window.playlist);
	  playSong(data.songId, data.serverTime);
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
				return "<li data-id="+track.stream_url+"<a class='btn btn-primary' href='#'><strong>" + track.title + "</strong></a></li><br>";
			}).join('');
			$('#searchResults').html(htmlString);
			$('#searchResults li a').click(function(e) {
				var url = $(e.currentTarget.parentNode).attr('data-url');
				console.log(url);
			});
		});
	});

});


var gSound;

//id is the unique track id that exists for every song. Obtain from tracks[i].id
function playSong (id, startedTimestamp) {
	var started = new Date(startedTimestamp).getTime()
	console.log("started: " + started);

	//resource: http://www.schillmania.com/projects/soundmanager2/doc/#smsound-setposition
	SC.whenStreamingReady(function() {
		var sound = SC.stream(id, {autoLoad: true});
		console.dir(sound);
		sound.setVolume(0);
		sound.play();
		setTimeout(function() {
			var current = new Date().getTime();
			console.log("current: " + current);
			var offset = current - started;
			console.log("offset: " + offset);
			sound.setPosition(offset);
			sound.setVolume(100);
		},5000);
});



	/*SC.whenStreamingReady(function() {
		var sound = SC.stream(id, {
			from: offset,
			autoLoad: true,
			autoPlay: true,
			onplay: function() { console.log(this.position); }
		});
	}); */
}
