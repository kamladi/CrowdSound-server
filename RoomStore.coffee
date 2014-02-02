moment = require 'moment'

class RoomStore
	constructor: ->
		@rooms = []

		@newRoom()
		@newRoom()

	newRoom: ->
		newId = @rooms.length
		# build default playlist
		darkHorse =
			stream_url: "https://api.soundcloud.com/tracks/110950395/stream"
			uri: "https://api.soundcloud.com/tracks/110950395"
			title: "Katy Perry - Dark Horse ft. Juicy J"
			duration: 219057
			id: 110950395
		rappersDelight =
			stream_url: 'https://api.soundcloud.com/tracks/1954789/stream'
			title: "Sugarhill Gang - Rappers Delight (Full Version)"
			uri: "https://api.soundcloud.com/tracks/1954789"
			duration: 877055
			id: 1954789
		gasPedal =
			stream_url: "https://api.soundcloud.com/tracks/64830027/stream"
			uri: "https://api.soundcloud.com/tracks/64830027"
			title: "Sage The Gemini - Gas Pedal (feat. IAMSU!)"
			duration: 209338
			id: 64830027
		default_playlist = [rappersDelight, gasPedal, darkHorse]

		@rooms.push
			name: "Room #{newId}"
			playlist: default_playlist
			users: []
			timestamp: new Date()

		return newId

	getRoom: (roomId) ->
		return @rooms[roomId]

	getPlaylist: (roomId) ->
		return @rooms[roomId].playlist

	addUser: (roomId, socketId) ->
		return @rooms[roomId].users.push socketId

	getCurrTime: (roomId) ->
		return @rooms[roomId].timestamp

	nextSong: (roomId) ->
		@rooms[roomId].playlist.shift()
		@rooms[roomId].timestamp = new Date()

	getTimestamp: (roomId) ->
		return @rooms[roomId].timestamp

	addSongToPlaylist: (roomId, songURL) ->
		@rooms[roomId].playlist.push songURL

	getName: (roomId) -> return @rooms[roomId].name

module.exports = RoomStore
