config = require './config'

module.exports = (body = {}, query = {}) ->

  fields = []
  color = query?.good_color || config.setting.good_color
  space = query?.space || config.setting.space
  backlog_url = "https://#{space}.backlog.jp/"
  title_link = "#{backlog_url}git/#{body.project?.projectKey}/#{body.content?.repository.name}/pullRequests/#{body.content?.number}"


  # 通知対象者
  notifications = body.notifications?.map (n) -> " #{n.user.name}"
  if notifications?.length > 0
    fields.push(
      title: "To"
      value: "#{notifications}"
    )

  # PR追加
  if body.type == 18
    color = query?.warning_color || config.setting.warning_color
    if body.content?.description? && body.content.description.trim() != ""
      fields.push(
        {
          title: "詳細"
          value: body.content.description
        }
      )

  # PR更新
  if body.content?.changes?
    for change in body.content.changes
      title = null
      value = "#{config.decorate(change.old_value)} → #{config.decorate(change.new_value)}"
      short = true

      switch change.field
        when "summary" then title = "件名変更"
        when "attachment" then title = "添付ファイル変更"
        when "assigner" then title = "担当者変更"
        when "issue" then title = "関連課題変更"
        when "status"
          title = "状態変更"
          value = "#{config.pr_status[change.old_value]} → #{config.pr_status[change.new_value]}"
          color = query?.warning_color || config.setting.warning_color
        when "description"
          title = "詳細変更"
          value = "#{config.decorate(change.old_value)}\n ↓ \n#{config.decorate(change.new_value)}"
          short = false

      if title?
        fields.push(
          title: title
          value: value
          short: short
        )

  # コメント
  if body.content?.comment? && body.content.comment.content?.trim() != ""
    color = query?.warning_color || config.setting.warning_color
    title_link += "#comment-#{body.content.comment.id}"
    fields.push(
      title: "コメント"
      value: body.content.comment.content
    )

  if body.content?.issue?
    title = "[#{body.project?.projectKey}-#{body.content?.issue?.key_id}] #{body.content?.summary}"
  else
    title = "[#{body.project?.projectKey}] #{body.content?.summary}"

  # メッセージ整形
  msg =
    username: "#{config.type[body.type]}: by #{body.createdUser?.name}"
    icon_url: "https://raw.githubusercontent.com/mito5525/backlog2slack/master/icon/backlog.png"
    content:
      fallback: "#{config.type[body.type]}: [#{body.content?.summary}] by #{body.createdUser?.name}"
      color: color
      title: title
      title_link: title_link
      fields: fields
