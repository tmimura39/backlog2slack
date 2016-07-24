# Description:
#   backlog to Slack
#
# Configuration:
#   MUST: (環境変数)
#     HUBOT_SLACK_TOKEN
#   OPTION:
#   (環境変数)
#     HUBOT_BACKLOG2SLACK_DESTINATION
#     HUBOT_BACKLOG2SLACK_SPACE
#     HUBOT_BACKLOG2SLACK_GOOD_COLOR
#     HUBOT_BACKLOG2SLACK_WARNING_COLOR
#     HUBOT_BACKLOG2SLACK_DANGER_COLOR
#     HUBOT_BACKLOG2SLACK_INFOMATION_COLOR
#   (GET パラメータ)
#     http:.../backlog2slack?destination=example_user
#     http:.../backlog2slack?good_color=000000
#     http:.../backlog2slack?warning_color=ff0000&danger_color=ff00ff
#     ...etc
#
#     - 色の指定に"#"を含めない
#     - Getパラメータは環境変数より優先
#
# Author:
#   t_mimura

querystring = require 'querystring'
config = require './config'

module.exports = (robot) ->

  robot.router.post "/backlog2slack", (req, res) ->

    query = querystring.parse(req._parsedUrl.query)
    { destination } = query
    { destination } = config.setting unless destination?
    { body } = req

    try

      switch body.type
        # 課題
        when 1, 2, 3, 4, 17
          issue = require './issue'
          msg = issue(body, query)
        when 5, 6, 7
          wiki = require './wiki'
          msg = wiki(body, query)
        when 11
          svn = require './svn'
          msg = svn(body, query)
        when 12, 13
          git = require './git'
          msg = git(body, query)
        else
          simple = require './simple'
          msg = simple(body, query)

      msg.channel = destination
      robot.emit 'slack-attachment', msg
      res.end "OK"

    catch error
      robot.messageRoom destination, "error:" + error
      robot.send
      res.end "Error"
