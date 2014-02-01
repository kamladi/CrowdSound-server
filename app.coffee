http = require 'http'
moment = require 'moment'
url = require 'url'
qs = require 'querystring'
request = require 'request'
RoomStore = require './RoomStore'

ROOMS = new RoomStore()

httpHandler = (req, res) ->
	url = url.parse req.url
	if url.pathname == '/'
		res.writeHead 200, {"Content-Type": "text/plain"}
		res.end()
	else if url.pathname == '/search'
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
				res.writeHead 404, {"Content-Type": "text/plain"}
				res.end()
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
				res.writeHead 200, {"Content-Type": "application/json"}
				res.end JSON.stringify(results)
	else
		res.writeHead 404, {"Content-Type": "text/plain"}
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

