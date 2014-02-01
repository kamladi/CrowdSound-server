moment = require 'moment'

class RoomStore
	constructor: ->
		@rooms = []

	newRoom: ->
		# build default playlist
		rappersDelight =
			stream_url: 'https://api.soundcloud.com/tracks/1954789/stream'
			title: "Sugarhill Gang - Rappers Delight (Full Version)"
			uri: "https://api.soundcloud.com/tracks/1954789"
			duration: 877055
		gasPedal =
			stream_url: "https://api.soundcloud.com/tracks/64830027/stream"
			uri: "https://api.soundcloud.com/tracks/64830027"
			title: "Sage The Gemini - Gas Pedal (feat. IAMSU!)"
			duration: 209338
		darkHorse =
			stream_url: "https://api.soundcloud.com/tracks/110950395/stream"
			uri: "https://api.soundcloud.com/tracks/110950395"
			title: "Katy Perry - Dark Horse ft. Juicy J"
			duration: 219057
		default_playlist = [rappersDelight, gasPedal, darkHorse]

		@rooms.push
			playlist: default_playlist
			users: []
			timestamp: 0

	getPlaylist: (roomId) ->
		return @rooms[roomId].playlist

	addUser: (roomId, socketId) ->
		console.dir @rooms
		return @rooms[roomId].users.push socketId

	getCurrTime: (roomId) ->
		return @rooms[roomId].timestamp

	nextSong: (roomId) ->
		@rooms[roomId].playlist.shift()
		@rooms[roomId].timestamp = moment()

	getTimestamp: (roomId) ->
		return @rooms[roomId].timestamp

	addSongToPlaylist: (roomId, songURL) ->
		@rooms[roomId].playlist.push songURL

module.exports = RoomStore
