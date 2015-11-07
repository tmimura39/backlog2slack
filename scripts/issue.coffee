config = require './config'

module.exports = (body = {}, query = {}) ->

  fields = []
  color = query?.good_color || config.setting.good_color

  # 課題追加
  if body.type == 1
    color = query?.warning_color || config.setting.warning_color
    # TODO: 課題を作成したユーザーが担当の場合はお知らせに追加されない
    # TODO: そのため、担当が決まっているのも関わらず「未設定」となってしまう
    assigner = (body.notifications.filter (n) -> n.reason == 1)[0]
    fields.push(
      {
        title: "担当"
        value: config.decorate(assigner?.user?.name)
      },
      {
        title: "詳細"
        value: body.content.description
      }
    )

  # 課題変更
  if body.content?.changes?
    for change in body.content.changes
      title = null
      value = "#{config.decorate(change.old_value)} => #{config.decorate(change.new_value)}"

      switch change.field
        when "description" then title = "詳細変更"
        when "assigner" then title = "担当者変更"
        when "attachment" then title = "添付ファイル変更"
        when "milestone" then title = "マイルストーン変更"
        when "limitDate" then title = "期限日変更"
        when "status"
          title = "ステータス変更"
          value = "#{config.decorate(status[change.old_value])} => #{config.decorate(status[change.new_value])}"
        when "resolution"
          title = "完了理由変更"
          value = "#{config.decorate(resolution[change.old_value])} => #{config.decorate(resolution[change.new_value])}"

      if title?
        fields.push(
          title: title
          value: value
          short: true
        )

  # 添付ファイル
  if body.content?.attachments?
    value = ""
    for attachment in body.content.attachments
      url = "#{config.setting.backlog_url}downloadAttachment/#{attachment.id}/#{attachment.name}"
      value += "\t- #{url}\n"
      fields.push(
        title: "添付ファイル"
        value: value
      )

  # コメント
  if body.content?.comment? && body.content.comment.content?.trim() != ""
    fields.push(
      title: "コメント"
      value: "#{body.content.comment.content}"
    )

  # 通知対象者取得
  notifications = body.notifications?.map (n) -> " #{n.user.name}"

  # メッセージ整形
  msg =
    username: "#{config.type[body.type]}: [#{body.project?.name}] by #{body.createdUser?.name}"
    icon_url: "https://raw.githubusercontent.com/mito5525/backlog2slack/master/icon/backlog.png"
    content:
      fallback: "#{config.type[body.type]}: [#{body.content?.summary}] by #{body.createdUser?.name}"
      color: color
      title: "[#{body.project?.projectKey}-#{body.content?.key_id}] #{body.content?.summary}"
      title_link: "#{config.setting.backlog_url}view/#{body.project?.projectKey}-#{body.content?.key_id}"
      fields: fields

  msg.content.pretext = "To: #{notifications}" if notifications?.length > 0
  msg
