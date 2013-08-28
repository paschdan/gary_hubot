# Description:
#   Show open pull requests from a Github repository
#
# Dependencies:
#   "githubot": "0.2.0"
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_API
#
# Commands:
#   hubot show [me] <user/repo> pulls [with <regular expression>] - Shows open pull requests for that project by filtering pull request's title.
#   hubot show [me] hubot pulls -- Show open pulls for a given user IFF HUBOT_GITHUB_USER configured
#
# Notes:
#   HUBOT_GITHUB_API allows you to set a custom URL path (for Github enterprise users)
#
#   You can further filter pull request title by providing a reguar expression.
#   For example, `show me hubot pulls with awesome fix`.
#
# Authors:
#   jingweno, blarghmatey

module.exports = (robot) ->
  github = require("githubot")(robot)
  robot.respond /show\s+(me\s+)?(.*)\s+pulls(\s+with\s+)?(.*)?/i, (msg)->
    repo = github.qualified_repo msg.match[2]
    filter_reg_exp = new RegExp(msg.match[4], "i") if msg.match[3]
    unless (url_api_base = process.env.HUBOT_GITHUB_API)?
        url_api_base = "https://api.github.com"

    github.get "#{url_api_base}/repos/#{repo}/pulls", (pulls) ->
      if pulls.length == 0
          msg.send "Achievement unlocked: open pull requests zero!"
      else
        filtered_result = []
        for pull in pulls
          if filter_reg_exp && pull.title.search(filter_reg_exp) < 0
            continue
          filtered_result.push(pull)

        if filtered_result.length == 0
          summary = "no open pull request is found"
        else if filtered_result.length == 1
          summary = "1 open pull request is found:"
        else
          summary = "#{filtered_result.length} open pull requests are found:"

        msg.send summary

        for pull in filtered_result
          mentioned = pull.body.match(/(^|\s)(@[\w\-]+)/g)
          
          if mentioned
            unique = (array) ->
              output = {}
              output[array[key]] = array[key] for key in [0...array.length]
              value for key, value of output

            mentioned = mentioned.map (nick) -> nick.trim()
            mentioned = unique mentioned
            users_in_brain = robot.brain.data.users
            mention_object = {}
            mention_object[mention] = mention for mention in mentioned
            mention_object["@#{user_object.githubLogin}"] = "@#{user_object.mention_name}" for user_id, user_object of users_in_brain when user_object.githubLogin and "@#{user_object.githubLogin}" in mentioned
            mentioned_line = "\nMentioned: #{(mention for login, mention of mention_object).join(', ')}"
          else
            mentioned_line = ''

          msg.send "\t#{pull.title} - Opened By: #{pull.user.login} - #{mentioned_line}\n#{pull.html_url}"