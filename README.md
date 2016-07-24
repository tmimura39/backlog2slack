# Backlog Notification To Slack

このHubotは、Backlogの更新をSlackに通知させます

## 通知対象
- 課題作成
- 課題更新
    + コメント追加
    + ステータス更新
    + 担当更新
    + ファイル追加
    + ...etc
- お知らせ追加
- Wiki
    + 作成
    + 更新
    + 削除
- Subversion
- Git (PR)

## 導入方法

Hubotディレクトリで以下のコマンドを実行

`$ npm install backlog2slack --save`

以下を `external-scripts.json` に追加

```json
["backlog2slack"]
```

## 各種設定

### Backlog Add webhook

`https://{space_name}.backlog.jp/settings/webhook/{project_name}}/create`

- WebHook URL に以下のURLを設定

`{hubot_url}/backlog2slack`  
(exampleURL: `http:example.com:8080/backlog2slack`)

### 環境変数に HUBOT_SLACK_TOKEN を設定

`export HUBOT_SLACK_TOKEN = {your_slack_API_token}`

### スペース名の設定
- Getパラメータでの指定(優先)  
`http:example.com:8080/backlog2slack?space=hoge_team`

- 環境変数での指定  
`export HUBOT_BACKLOG2SLACK_SPACE = "hoge_team"`

※ この設定をしないとリンクが正常に動作しません

### 通知先の指定(2つの方法)

- Getパラメータでの指定(優先)  
`http:example.com:8080/backlog2slack?destination=backlog-notification-channel`
`http:example.com:8080/backlog2slack?destination=t_mimura`

- 環境変数での指定  
`export HUBOT_BACKLOG2SLACK_DESTINATION = "backlog-notification-channel"`
`export HUBOT_BACKLOG2SLACK_DESTINATION = "private-kosokoso-heya"`

※ 通知先(destination)はCHANNEL, PRIVATE_GROUP, DM(user_name)に対応

### オプション：Hubot通知の色の指定

|Action|Type|defaultColor|
|:-----|:--:|:----------:|
|課題の追加|warning|オレンジ|
|コメント追加|good|Green|
|お知らせ追加|good|Green|
|課題の更新|good|Green|

- Getパラメータでの指定(優先)  
`http:example.com:8080/backlog2slack?good_color=000000`  
`http:example.com:8080/backlog2slack?good_color=ff0000&warning_color=f0f`  
...etc

- 環境変数での指定  
`export HUBOT_BACKLOG2SLACK_GOOD_COLOR = "000"`  
`export HUBOT_BACKLOG2SLACK_WARNING_COLOR = "ffff00"`

※ 色に"#"を含めない
