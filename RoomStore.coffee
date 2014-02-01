exports.RoomStore = RoomStore

class RoomStore
	constructor: ->
		@rooms = []


	newRoom: ->
		@rooms.push { playlist: [] }

	getPlaylist: (id) ->
		return @rooms[id].playlist

	addSongToPLaylist: (id, song) ->
		@rooms[id]

