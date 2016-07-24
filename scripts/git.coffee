config = require './config'

module.exports = (body = {}, query = {}) ->

  fields = []
  color = query?.good_color || config.setting.good_color

  # revision
  if body.content?.revision_type
    fields.push(
      title: "revision_type"
      value: "#{body.content.revision_type}"
    )

  # commit
  if body.content?.revisions?
    for revision in body.content.revisions
      url = "#{config.setting.backlog_url}git/#{body.project?.projectKey}/#{body.content?.repository.name}/commit/#{revision.rev}"
      fields.push(
        title: "rev"
        value: "#{url}"
      )
      fields.push(
        title: "コメント"
        value: "#{revision.comment}"
      )

  # メッセージ整形
  msg =
    username: "#{config.type[body.type]}: by #{body.createdUser?.name}"
    icon_url: "https://raw.githubusercontent.com/mito5525/backlog2slack/master/icon/backlog.png"
    content:
      fallback: "#{config.type[body.type]}: by #{body.createdUser?.name}"
      color: color
      title: "リポジトリ: #{body.content?.repository.name}"
      title_link: "#{config.setting.backlog_url}git/#{body.project?.projectKey}/#{body.content?.repository.name}"
      fields: fields
