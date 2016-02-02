{Robot} = require.main.require "hubot"
Path = require "path"

robot = new Robot null, "tfs-teamrooms"
robot.load Path.resolve ".", "scripts"

robot.run()