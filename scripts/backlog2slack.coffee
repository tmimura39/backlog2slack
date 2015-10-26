# Description:
#   backlog to Slack
#
# Configuration:
#   HUBOT_SLACK_TOKEN
#
# Author:
#   t_mimura


module.exports = (robot) ->

  # 空の場合：未設定を返す
  decorate = (s) ->
    if !s? || s.trim?() is ''
      return "未設定"
    return s

  robot.router.post "/backlog2slack/:space/:room", (req, res) ->
    { room, space } = req.params
    { body } = req

    backlogUrl = "https://#{space}.backlog.jp/"

    # ステータス
    status = {
      "1": "未対応"
      "2": "処理中"
      "3": "処理済み"
      "4": "完了"
    }

    # 完了理由
    resolution = {
      "0": "対応済み"
      "1": "対応しない"
      "2": "無効"
      "3": "重複"
      "4": "再現しない"
    }

    try

      msg =
        message:
          room: room

      fields = []

      switch body.type
        # 課題追加
        when 1
          label = "課題追加"
          color = "warning"
          fields.push(
            title: "詳細"
            value: body.content.description
          )
        # 課題更新
        when 2
          label = "課題更新"
          color = "good"
        # コメント追加
        when 3
          label = "コメント追加"
          color = "good"
        when 17
          label = "お知らせに追加"
          color = "good"

        # その他未対応(Wikiとか)

      if body.content.changes?
        for change in body.content.changes
          switch change.field
            # 詳細
            when "description"
              title = "詳細変更"
              value = change.new_value
            # 担当者
            when "assigner"
              title = "担当者変更"
              value = "#{decorate(change.old_value)} => #{decorate(change.new_value)}"
            # ステータス
            when "status"
              title = "ステータス変更"
              value = "#{decorate(status[change.old_value])} => #{decorate(status[change.new_value])}"
            # マイルストーン
            when "milestone"
              title = "マイルストーン変更"
              value = "#{decorate(change.old_value)} => #{decorate(change.new_value)}"
            # 期限日
            when "limitDate"
              title = "期限日変更"
              value = "#{decorate(change.old_value)} => #{decorate(change.new_value)}"
            # 完了理由
            when "resolution"
              title = "完了理由変更"
              value = "#{decorate(resolution[change.old_value])} => #{decorate(resolution[change.new_value])}"

          fields.push(
            title: title
            value: value
            short: true
          )

      # 添付ファイル
      if body.content.attachments?
        value = ""
        for attachment in body.content.attachments
          url = "#{backlogUrl}downloadAttachment/#{attachment.id}/#{attachment.name}"
          value += "\t- #{url}\n"

        fields.push(
          title: "添付ファイル"
          value: value
        )

      # コメント
      if body.content.comment? && body.content.comment.content.trim() != ""
        fields.push(
          title: "コメント"
          value: "#{body.content.comment.content}"
        )

      # 通知対象者取得
      notifications = body.notifications.map (n) -> " #{n.user.name}"

      if label?
        msg.content =
          pretext: "To:#{notifications}"
          fallback: "#{label}: [#{body.content.summary}] by #{body.createdUser.name}"
          color: color
          author_name: "#{label}: [#{body.project.name}]"
          author_icon: "http://www.backlog.jp/img/common/footer/icon_b_55x57.png"
          title: body.content.summary
          title_link: "#{backlogUrl}view/#{body.project.projectKey}-#{body.content.key_id}"
          fields: fields

        robot.emit 'slack-attachment', msg
        res.end "OK"
      else
        robot.messageRoom room, "[#{body.project.name}]\n何か動きがありました\n"

        res.end "OK"

    catch error
      robot.messageRoom room, "error:" + error
      robot.send
      res.end "Error"
