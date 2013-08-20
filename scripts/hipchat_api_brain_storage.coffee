# Description:
#   An HTTP Listener that notifies about new Github pull requests
#
# Dependencies:
#   "querystring": "0.1.0"
#
# Configuration:
#   HUBOT_HIPCHAT_ADMIN_TOKEN - Hipchat API Admin token
#
# Commands:
#   None
#
# URLS:
#
#
# Authors:
#   spajus, blarghmatey

module.exports = (robot) ->

  robot.respond /load hipchat rooms/i, (msg) ->
    token = process.env.HUBOT_HIPCHAT_ADMIN_TOKEN    
    msg.http("https://api.hipchat.com/v1/rooms/list?format=json&auth_token=#{token}")
      .get() (err, res, body) ->
        rooms = JSON.parse body
        robot.brain.set "hipchat", {rooms: rooms.rooms}
        msg.send "Room list updated in brain"