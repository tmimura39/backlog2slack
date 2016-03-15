config = require './config'

module.exports = (body, query) ->

  color = query?.good_color || config.setting.good_color

  # メッセージ整形
  msg =
    username: "#{config.type[body.type]}: by #{body.createdUser?.name}"
    icon_url: "https://raw.githubusercontent.com/mito5525/backlog2slack/master/icon/backlog.png"
    content:
      fallback: "#{config.type[body.type]}: [#{body.content?.summary}] by #{body.createdUser?.name}"
      color: color
