http = require 'http'
RoomStore = require 'RoomStore'

ROOMS = new RoomStore()

app = http.createServer (req, res) ->
	res.writeHead 200
  res.end()

io = require 'socket.io'
io.listen app

app.listen 80

io.sockets.on 'connection', (socket) ->

	socket.on 'joinRoom', (room) ->
		socket.join room

		# save room id in socket object for easy reference
		socket.room = room

  # when client adds song to playlist
  socket.on 'play', (data) ->
    console.log(data)

  # when client adds new song to playlist
  socket.on 'addSong', (songURL) ->
  	roomId = socket.room
  	ROOMS.addSongToPlaylist roomId, songURL


