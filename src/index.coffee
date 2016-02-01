{Robot,Adapter,TextMessage,User} = require.main.require './hubot/index'
{TfsApi} = require './tfsApi'

class TfsTeamroomsAdapter extends Adapter

  constructor: ->
    super
    @api = new TfsApi (@robot.http.bind(@robot))

  send: (envelope, strings...) ->
    @robot.logger.info "Send"

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  run: ->
    @robot.logger.info "Run"
    @connect()
    @emit "connected"
    user = new User 1001, name: 'Sample User'
    message = new TextMessage user, 'Some Sample Message', 'MSG-001'
    @robot.receive message

  connect: ->
    @api.connect()

exports.use = (robot) ->
  new TfsTeamroomsAdapter robot


robot = new Robot null, "tfs-teamrooms"

robot.run()