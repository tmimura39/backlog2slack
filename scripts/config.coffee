module.exports =
  # 環境設定
  setting: {
    destination: process.env.HUBOT_BACKLOG2SLACK_DESTINATION
    backlog_url: "https://#{process.env.HUBOT_BACKLOG2SLACK_SPACE}.backlog.jp/"
    good_color: process.env.HUBOT_BACKLOG2SLACK_GOOD_COLOR || "good"
    warning_color: process.env.HUBOT_BACKLOG2SLACK_WARNING_COLOR || "warning"
    danger_color: process.env.HUBOT_BACKLOG2SLACK_DANGER_COLOR || "danger"
    information_color: process.env.HUBOT_BACKLOG2SLACK_INFOMATION_COLOR || "439FE0"
  }

  # 更新内容
  type: {
     1: "課題追加",          2: "課題更新",          3: "コメント追加", 4: "課題削除"
     5: "Wiki追加",          6: "Wiki更新",          7: "Wiki削除"
     8: "共有ファイル追加",  9: "共有ファイル更新", 10: "共有フォルダ削除"
    11: "Subversionコミット"
    12: "Gitプッシュ",      13: "Gitリポジトリ作成"
    14: "課題まとめて更新"
    15: "プロジェクト参加", 16: "プロジェクト脱退"
    17: "お知らせに追加"
    18: "PR追加",           19: "PR更新",           20: "PRコメント追加"
  }

  # ステータス
  status: { 1: "未対応", 2: "処理中", 3: "処理済み", 4: "完了" }

  # 完了理由
  resolution: { 0: "対応済み", 1: "対応しない", 2: "無効", 3: "重複", 4: "再現しない" }

  # 空の場合：未設定を返す
  decorate: (s) ->
    if !s? || s.trim?() is ""
      return "未設定"
    return s

