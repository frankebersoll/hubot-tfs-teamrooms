signalr = require "signalr-client"

baseUrl = "https://vs4tc4tebrtzd56zwavr.visualstudio.com"
apiKey = "2aklpr3q6i2ycnezjopwv3yrrsivm6uh63ovyfndvvjzi4v3p35q"
collectionName = "defaultcollection"
roomName = "Woah"
ChatHub = "chathub"

class TfsApi

  constructor: (http) ->
    @collectionId = null
    @chatRoomId = null

    @http = http(baseUrl)
    @http.auth apiKey
    @signalr = new signalr.client baseUrl.replace(/^https/, "wss") + "/signalr",
      [ ChatHub ],  # Hubs
      10,             # Reconnect timeout seconds
      true            # Disable autostart

  connect: ->
    promises = [
      @getCollectionId() .then (id) => @collectionId = id
      @getChatRoomId() .then (id) => @chatRoomId = id
    ]

    Promise.all promises
      .then () => @connectSignalr()
      .then () => @joinRoom()
      .catch (error) ->
        console.log error

  connectSignalr: ->
    console.log "Connecting..."

    @signalr.queryString.contextToken = @collectionId
    @signalr.headers["Authorization"] =
      "Basic " + new Buffer "#{ apiKey }:"
        .toString "base64"

    @signalr.handlers[ChatHub] =
      messagereceived: @onMessageReceived.bind(@)

    handlers = @signalr.serviceHandlers

    new Promise (resolve, reject) =>
      handlers.connected = resolve
      handlers.onUnauthorized = reject
      handlers.bindingError = reject
      @signalr.start()

  onMessageReceived: (room, message) ->
    @signalr.invoke ChatHub, "SendMessage", @chatRoomId, message.content + " OK!"

  joinRoom: ->
    @signalr.invoke ChatHub, "JoinRoom", @chatRoomId
    console.log "Joined room #{ 'roomName' }."

  getCollectionId: ->
    @getResource "_apis/projectcollections/#{collectionName}/?api-version=1.0"
      .then (data) -> data.id

  getChatRoomId: ->
    @getResource "#{collectionName}/_apis/chat/rooms?api-version=1.0"
      .then (data) ->
        rooms = data.value
        (room.id for room in rooms when room.name is roomName)[0]

  getResource: (resource) ->
    new Promise (resolve, reject) =>
      @http.scope resource, (client) ->
        client.get() (err, res, body) ->

          return reject err if err?

          error = switch res.statusCode
            when 200 then null
            when 404 then new Error "Could not find TFS collection '#{collectionName}'"
            when 302 then new Error "Unauthorized"
            else new Error "Unknown"

          return reject error if error?

          data = JSON.parse body
          resolve data

exports.TfsApi = TfsApi