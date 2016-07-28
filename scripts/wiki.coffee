config = require './config'

module.exports = (body = {}, query = {}) ->

  fields = []
  color = query?.good_color || config.setting.good_color
  space = query?.space || config.setting.space
  backlog_url = "https://#{space}.backlog.jp/"

  # コメント
  if body.content?.comment? && body.content.comment.trim() != ""
    fields.push(
      title: "コメント"
      value: "#{body.content.comment}"
    )

  # メッセージ整形
  msg =
    username: "#{config.type[body.type]}: by #{body.createdUser?.name}"
    icon_url: "https://raw.githubusercontent.com/mito5525/backlog2slack/master/icon/backlog.png"
    content:
      fallback: "#{config.type[body.type]}: by #{body.createdUser?.name}"
      color: color
      title: body.content?.name
      title_link: "#{backlog_url}wiki/#{body.project?.projectKey}/#{body.content?.name}"
      fields: fields
