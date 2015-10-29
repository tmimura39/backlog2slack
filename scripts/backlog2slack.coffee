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

querystring = require('querystring')

module.exports = (robot) ->

  config =
    destination: process.env.HUBOT_BACKLOG2SLACK_DESTINATION
    space: process.env.HUBOT_BACKLOG2SLACK_SPACE
    good_color: process.env.HUBOT_BACKLOG2SLACK_GOOD_COLOR || "good"
    warning_color: process.env.HUBOT_BACKLOG2SLACK_WARNING_COLOR || "warning"
    danger_color: process.env.HUBOT_BACKLOG2SLACK_DANGER_COLOR || "danger"
    information_color: process.env.HUBOT_BACKLOG2SLACK_INFOMATION_COLOR || "439FE0"

  # 空の場合：未設定を返す
  decorate = (s) ->
    if !s? || s.trim?() is ""
      return "未設定"
    return s

  robot.router.post "/backlog2slack", (req, res) ->
    query = querystring.parse(req._parsedUrl.query)
    { destination, space } = query
    { destination } = config unless destination?
    { space } = config unless space?
    { body } = req

    backlogUrl = "https://#{space}.backlog.jp/"

    # ステータス
    status = {
      1: "未対応"
      2: "処理中"
      3: "処理済み"
      4: "完了"
    }

    # 完了理由
    resolution = {
      0: "対応済み"
      1: "対応しない"
      2: "無効"
      3: "重複"
      4: "再現しない"
    }

    try

      fields = []

      color = query.good_color || config.good_color

      switch body.type
        when 1
          label = "課題追加"
          color = query.warning_color || config.warning_color
          assigner = (body.notifications.filter (n) -> n.reason == 1)[0]
          fields.push(
            {
              title: "担当"
              value: decorate(assigner?.name)
            },
            {
              title: "詳細"
              value: body.content.description
            }
          )
        when 2 then label = "課題更新"
        when 3 then label = "コメント追加"
        when 17 then label = "お知らせに追加"

        # その他未対応(Wikiとか)

      # 課題の変更点
      if body.content.changes?
        for change in body.content.changes
          title = null
          value = "#{decorate(change.old_value)} => #{decorate(change.new_value)}"

          switch change.field
            when "description" then title = "詳細変更"
            when "assigner" then title = "担当者変更"
            when "attachment" then title = "添付ファイル変更"
            when "milestone" then title = "マイルストーン変更"
            when "limitDate" then title = "期限日変更"
            when "status"
              title = "ステータス変更"
              value = "#{decorate(status[change.old_value])} => #{decorate(status[change.new_value])}"
            when "resolution"
              title = "完了理由変更"
              value = "#{decorate(resolution[change.old_value])} => #{decorate(resolution[change.new_value])}"

          if title?
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
        msg =
          channel: destination
          username: "#{label}: [#{body.project.name}]"
          icon_url: "https://raw.githubusercontent.com/mito5525/backlog2slack/master/icon/backlog.png"
          content:
            fallback: "#{label}: [#{body.content.summary}] by #{body.createdUser.name}"
            color: color
            title: "[#{body.project.projectKey}-#{body.content.key_id}] #{body.content.summary}"
            title_link: "#{backlogUrl}view/#{body.project.projectKey}-#{body.content.key_id}"
            fields: fields

        msg.content.pretext = "To: #{notifications}" if notifications.length > 0

        robot.emit 'slack-attachment', msg
        res.end "OK"
      else
        robot.messageRoom destination, "[#{body.project.name}]\n何か動きがありました\n"

        res.end "OK"

    catch error
      robot.messageRoom destination, "error:" + error
      robot.send
      res.end "Error"
