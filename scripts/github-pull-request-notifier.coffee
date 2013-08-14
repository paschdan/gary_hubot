# Description:
#   An HTTP Listener that notifies about new Github pull requests
#
# Dependencies:
#   "url": ""
#   "querystring": ""
#
# Configuration:
#   You will have to do the following:
#   1. Get an API token: curl -u 'username' -d '{"scopes":["repo"],"note":"Hooks management"}' \
#                         https://api.github.com/authorizations
#   2. Add <HUBOT_URL>:<PORT>/hubot/gh-pull-requests?room=<room>[&type=<type>] url hook via API:
#      curl -H "Authorization: token <your api token>" \
#      -d '{"name":"web","active":true,"events":["pull_request"],"config":{"url":"<this script url>","content_type":"json"}}' \
#      https://api.github.com/repos/<your user>/<your repo>/hooks
#
# Commands:
#   None
#
# URLS:
#   POST /hubot/gh-pull-requests?room=<room>[&type=<type]
#
# Authors:
#   spajus, blarghmatey

url = require('url')
querystring = require('querystring')

module.exports = (robot) ->

  robot.router.post "/hubot/gh-pull-requests", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    res.send(200)

    user = {}
    user.room = query.room if query.room
    user.type = query.type if query.type

    try
      announcePullRequest req.body.payload, (what) ->
        robot.send user, what
    catch error
      console.log "github pull request notifier error: #{error}. Request: #{req.body}"


announcePullRequest = (data, cb) ->
  json_data = JSON.parse data
  console.log json_data
  # console.log "Action: " + json_data.action
  # console.log "Pull Number: " + json_data.number
  # console.log "Request: " + json_data.pull_request.title

  if json_data.action in ['opened', 'reopened', 'closed']
    mentioned = json_data.pull_request.body.match(/(^|\s)(@[\w\-]+)/g)

    if mentioned
      unique = (array) ->
        output = {}
        output[array[key]] = array[key] for key in [0...array.length]
        value for key, value of output

      mentioned = mentioned.map (nick) -> nick.trim()
      mentioned = unique mentioned

      mentioned_line = "\nMentioned: #{mentioned.join(", ")}"
    else
      mentioned_line = ''

    if json_data.action in ['opened', 'reopened']
      # console.log 'action was opened'
      cb "New pull request \"#{json_data.pull_request.title}\" by #{json_data.pull_request.user.login} for repository #{json_data.repo.name}: #{json_data.pull_request.html_url}#{mentioned_line}"
    if json_data.action == 'closed'
      # console.log 'action was closed'
      action = if data.pull_request.merged_by then 'merged' else 'closed'
      merged_by = if action == 'merged' then ' by ' + json_data.pull_request.merged_by.login else ''
      cb "Pull request #{action} \"#{json_data.pull_request.title}\"#{merged_by} for repository #{json_data.repo.name}: #{json_data.pull_request.html_url}"
