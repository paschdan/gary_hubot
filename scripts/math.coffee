# Description:
#   Allows Hubot to do mathematics.
#
# Commands:
#   hubot math me <expression> - Calculate the given expression.
#   hubot convert me <expression> to <units> - Convert expression to given units.
module.exports = (robot) ->
  robot.respond /(calc|calculate|math)( me)? (.*)/i, (msg) ->
    term = msg.match[3]
    try
      result = eval(term)
      msg.send result
    catch e
      msg.send "Could not compute"
      

  robot.respond /(convert)( me)? (.*)/i, (msg) ->
    msg.send "Sorry, could not convert, this service is closed by google."