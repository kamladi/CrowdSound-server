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
	console.log("yoyoyo")
	res.render 'index'

app.get '/:roomId', (req, res) ->
	roomId = parseInt req.params.roomId
	if !ROOMS[roomId]?
		res.send 404, "invalid room"
	else
		playlist = ROOMS.getPlaylist roomId
		res.render 'room'

app.get '/search', (req, res) ->
	console.log req.query
	# get query string from url
	queryObj = qs.parse url.query
	params = {
		client_id: '9e7bd4599a033c7207a6c683203bd2ef'
		q: queryObj.q
	}
	queryString = qs.stringify(params)

	# request soundcloud api with query
	SOUNDCLOUD_URL = "https://api.soundcloud.com/tracks.json?"
	request SOUNDCLOUD_URL + queryString, (err, response, body) ->
		if err
			console.log "ERROR requesting soundcloud api"
			res.send 404, "You suck"
		else
			# return subset of json result
			json = JSON.parse body
			results = json.map (track) ->
				return {
					stream_url: track.stream_url
					uri: track.uri
					title: track.title
					duration: track.duration
				}
			res.json results

server.listen 8000, ->
	console.log "listening on port 8000"


# Socket.IO handlers
io = require('socket.io').listen(server)
io.sockets.on 'connection', (socket) ->

	socket.on 'joinRoom', (room) ->
		socket.join room
		# create new room if room doesn't exist
		if !ROOMS[room]?
			ROOMS.newRoom room
		ROOMS.addUser room, socket.id
		# save room id in socket object for easy reference
		socket.room = room

		# send playlist and current song packet to client
		playlist = ROOMS.getPlaylist(room)
		socket.emit 'playlist', playlist
		now = moment()
		packet =
			url: playlist[0]
			songTime: now.diff(ROOMS.getTimestamp room)
			serverTime: now
		socket.emit 'timestamp', packet

  # when client adds new song to playlist
  socket.on 'addSong', (songURL) ->
  	roomId = socket.room
  	newPlaylist = ROOMS.addSongToPlaylist roomId, songURL
  	io.sockets.in(roomId).emit 'playlist', ROOMS.getPlaylist(roomId)

