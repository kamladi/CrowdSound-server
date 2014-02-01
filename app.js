http = require 'http'

app = http.createServer (req, res) ->
  res.writeHead 200
  res.end()

io = require 'socket.io'
io.listen app

app.listen 80

io.sockets.on 'connection', (socket) ->
  socket.emit 'news', { hello: 'world' }
  socket.on'my other event', (data) ->
    console.log(data)
