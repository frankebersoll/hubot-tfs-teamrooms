{EventEmitter}  = require "events"
signalr         = require "signalr-client"

baseUrl = "https://vs4tc4tebrtzd56zwavr.visualstudio.com"
apiKey = "smjbpk5x2xca5fntish7gbfrs24eocue3rawaxcmgny2s6s2m6vq"
collectionName = "defaultcollection"
roomName = "Woah"

class TfsApi extends EventEmitter

  CHAT_HUB = "chathub"

  constructor: (@robot) ->
    @collectionId = null
    @chatRoomId = null

    @http = @robot.http(baseUrl)
    @http.auth apiKey
    @signalr = new signalr.client baseUrl.replace(/^https/, "wss") + "/signalr",
      [ CHAT_HUB ],  # Hubs
      10,             # Reconnect timeout seconds
      true            # Disable autostart


  connect: ->
    Promise.all [
      @getCollectionId() .then (id) => @collectionId = id
      @getChatRoomId() .then (id) => @chatRoomId = id
    ]
      .then () => @connectSignalr()
      .then () => @emit "connected"
      .catch (error) => @emit "error", error


  connectSignalr: ->
    new Promise (resolve, reject) =>
      @robot.logger.info "Connecting to SignalR endpoint..."

      @signalr.queryString.contextToken = @collectionId
      @signalr.headers["Authorization"] = "Basic " + new Buffer("#{ apiKey }:").toString "base64"

      @signalr.handlers[CHAT_HUB] =
        messagereceived: (room, message) => @emit "message", message

      @signalr.serviceHandlers =
        connected: resolve
        onUnauthorized: reject

      @signalr.start()


  joinRoom: ->
    @signalr.invoke CHAT_HUB, "JoinRoom", @chatRoomId
    console.log "Joined room '#{ roomName }'."

    # @http.scope "defaultcollection/_apis/chat/rooms/#{ @chatRoomId }/users/b02b5dd1-78ee-4758-be55-4acf89bc1c07", (client) =>
    #   user =
    #     usedId: "b02b5dd1-78ee-4758-be55-4acf89bc1c07"
    #   client.query({"api-version": "1.0"})
    #     .header("accept", "application/json")
    #     .header("content-type", "application/json")
    #     .put(JSON.stringify user) (err, res, body) =>
    #       console.log(body)

  sendMessage: (message) ->
    @signalr.invoke CHAT_HUB, "SendMessage", @chatRoomId, message
    console.log "Sent message '#{ message }'."

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