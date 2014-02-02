http = require 'http'
express = require 'express'
moment = require 'moment'
url = require 'url'
jade = require 'jade'
qs = require 'querystring'
path = require 'path'
fs = require 'fs'
request = require 'request'
RoomStore = require './RoomStore'

app = express()
server = http.createServer(app)
ROOMS = new RoomStore()

# express config
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.logger('dev')
app.use express.methodOverride()
app.use express.static(path.join(__dirname, 'public'))


# URL Routes
app.get '/', (req, res) ->
	res.render 'index'

app.get '/newRoom', (req, res) ->
	newRoomId = ROOMS.newRoom()
	res.redirect "/#{newRoomId}"

app.get '/search', (req, res) ->
	# get query string from url
	params = {
		client_id: '9e7bd4599a033c7207a6c683203bd2ef'
		q: req.query.q
		limit: 5
	}
	queryString = qs.stringify(params)

	# request soundcloud api with query
	SOUNDCLOUD_URL = "https://api.soundcloud.com/tracks.json?"
	console.log SOUNDCLOUD_URL + queryString
	request SOUNDCLOUD_URL + queryString, (err, response, body) ->
		if err
			console.log "ERROR requesting soundcloud api"
			res.send 404, "You suck"
		else
			# return subset of json result
			json = JSON.parse body
			console.log json[0].id
			results = json.map (track) ->
				return {
					id: track.id
					stream_url: track.stream_url
					uri: track.uri
					title: track.title
					duration: track.duration
				}
			res.json results

app.get '/:roomId', (req, res) ->
	roomId = parseInt req.params.roomId
	room = ROOMS.getRoom roomId
	console.dir room
	if !room?
		res.send 404, "invalid room"
	else
		res.render 'room',
			name: room.name,
			playlist: room.playlist


port = process.env.PORT || 8000;
server.listen port, ->
	console.log "listening on port #{port}"


# Socket.IO handlers
io = require('socket.io').listen(server)

io.configure 'development', ->
  io.set "transports", ["websocket", "xhr-polling"]
  io.set "polling duration", 10

io.configure 'production', ->
	io.set "transports", ["websocket", "flashsocket", "xhr-polling"]
	io.enable('browser client minification');  # send minified client
	io.enable('browser client etag');          # apply etag caching logic based on version number
	io.enable('browser client gzip');          # gzip the file
	io.set('log level', 1);                    # reduce logging

io.sockets.on 'connection', (socket) ->

	socket.on 'joinRoom', (roomId) ->
		socket.join roomId
		# create new room if room doesn't exist
		if !ROOMS[roomId]?
			ROOMS.newRoom roomId
		ROOMS.addUser roomId, socket.id
		# save room id in socket object for easy reference
		socket.room = roomId

		# send playlist and current song packet to client
		room = ROOMS.getRoom roomId
		socket.emit 'playlist', room.playlist
		packet =
			songId: room.playlist[0].id
			serverTime: room.timestamp
		setTimeout room.duration, ->
			nextSong roomId, socket
		socket.emit 'playSong', packet

  # when client adds new song to playlist
  socket.on 'addSong', (songURL) ->
  	roomId = socket.room
  	newPlaylist = ROOMS.addSongToPlaylist roomId, songURL
  	io.sockets.in(roomId).emit 'playlist', ROOMS.getPlaylist(roomId)

nextSong = (roomId) ->
	room = ROOMS.getRoom roomId
	ROOMS.nextSong(roomId)
	packet =
			songId: room.playlist[0].id
			serverTime: room.timestamp roomId
	io.sockets.in(roomId).emit('playSong', packet)

