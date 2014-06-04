# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#   hubot die - End hubot process

Util = require('util')

module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    msg.send "PONG"

  robot.respond /ECHO (.*)$/i, (msg) ->
    msg.send msg.match[1]

  robot.respond /TIME$/i, (msg) ->
    msg.send "Server time is: #{new Date()}"

  robot.respond /DIE$/i, (msg) ->
    msg.send robot.auth.hasRole(msg.envelope.user, 'admin')
    if robot.auth.hasRole(msg.envelope.user,'admin')
      msg.send "Goodbye, cruel world."
      process.exit 0
    else
     msg.send "Only admins can kill me."
    
  robot.respond /ROLES$/i, (msg) ->
    user = msg.envelope.user
    output = Util.inspect(user, false, 4)
    msg.send output
