moment = require 'moment'

class RoomStore
	constructor: ->
		@rooms = []

	newRoom: ->
		@rooms.push { playlist: [], users: [], timestamp: 0 }

	getPlaylist: (roomId) ->
		return @rooms[roomId].playlist

	addUser: (roomId, socketId) ->
		return @rooms[roomId].users.push socket

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
