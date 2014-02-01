// Generated by CoffeeScript 1.7.1
(function() {
  var ROOMS, RoomStore, app, http, io, moment;

  http = require('http');

  moment = require('moment');

  RoomStore = require('./RoomStore');

  ROOMS = new RoomStore();

  app = http.createServer(function(req, res) {
    res.writeHead(200, {
      "Content-Type": "text/plain"
    });
    return res.end();
  });

  io = require('socket.io').listen(app);

  app.listen(80);

  io.sockets.on('connection', function(socket) {
    return socket.on('joinRoom', function(room) {
      var now, packet, playlist;
      socket.join(room);
      ROOMS.addUser(room, socket.id);
      socket.room = room;
      playlist = ROOMS.getPlaylist(room);
      socket.emit('playlist', playlist);
      now = moment();
      packet = {
        url: playlist[0],
        songTime: now.diff(ROOMS.getTimestamp(room)),
        serverTime: now
      };
      socket.emit('timestamp', packet);
      return socket.on('addSong', function(songURL) {
        var newPlaylist, roomId;
        roomId = socket.room;
        newPlaylist = ROOMS.addSongToPlaylist(roomId, songURL);
        return io.sockets["in"](roomId).emit('playlist', ROOMS.getPlaylist(roomId));
      });
    });
  });

}).call(this);
