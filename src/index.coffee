{Robot,Adapter,TextMessage,EnterMessage,User} = require.main.require './hubot/index'
{TfsApi} = require './tfsApi'
Path = require "path"

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


robot = new Robot null, "tfs-teamrooms"
robot.load Path.resolve ".", "scripts"

robot.run()