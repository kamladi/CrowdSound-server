http = require 'http'
moment = require 'moment'
RoomStore = require './RoomStore'

ROOMS = new RoomStore()

httpHandler = (req, res) ->
	res.writeHead 200, {"Content-Type": "text/plain"}
	res.end()

app = http.createServer(httpHandler)
app.listen(8080, () -> console.log "listening on port 8080")

io = require('socket.io').listen(app)

io.sockets.on 'connection', (socket) ->

	socket.on 'joinRoom', (room) ->
		socket.join room
		ROOMS.addUser room, socket.id
		# save room id in socket object for easy reference
		socket.room = room

		# send playlist and current song packet to client
		playlist = ROOMS.getPlaylist(room)
		socket.emit 'playlist', playlist
		now = moment()
		packet = {
			url: playlist[0]
			songTime: now.diff(ROOMS.getTimestamp room)
			serverTime: now
		}
		socket.emit 'timestamp', packet

  # when client adds new song to playlist
  socket.on 'addSong', (songURL) ->
  	roomId = socket.room
  	newPlaylist = ROOMS.addSongToPlaylist roomId, songURL
  	io.sockets.in(roomId).emit 'playlist', ROOMS.getPlaylist(roomId)

