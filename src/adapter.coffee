{Robot,Adapter,TextMessage,EnterMessage,User} = require.main.require 'hubot'
{TfsApi} = require "./tfsApi"

class TfsTeamroomsAdapter extends Adapter

  send: (envelope, strings...) ->
    if strings.length > 0
      string = strings.shift()
      if typeof(string) == 'function'
        string()
        @send envelope, strings...
      else
        @api.sendMessage string
        @send envelope, strings...

  run: ->
    api = new TfsApi @robot

    api.on "connected", =>
      @robot.logger.info "Connected!"
      api.joinRoom()

    api.on "message", (message) =>
      user = new User 1001, name: 'Sample User'
      message = new TextMessage user, message.content, 'MSG-001'
      @robot.receive message

    api.connect()

    @api = api

exports.use = (robot) ->
  new TfsTeamroomsAdapter robot
