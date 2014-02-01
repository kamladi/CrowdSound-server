var socket = io.connect('http://localhost:8080');

console.log(window.lcoation.pathname);
socket.emit('joinRoom', 0);

socket.on('timestamp', function(data) {
  console.log("timestamp");
  console.dir(data);
});

socket.on('playlist', function(data) {
  console.log("playlist:");
  console.dir(data);
});
