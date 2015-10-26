# Backlog Notification To Slack

このHubotは、Backlogの更新(課題関係のみ)をSlackに通知させます

## 通知対象
- 課題作成
- 課題更新
    + コメント追加
    + ステータス更新
    + 担当更新
    + ファイル追加
    + ...etc
- お知らせ追加

## 使い方

Hubotディレクトリで以下のコマンドを実行

`$ npm install backlog2slack --save`

以下を `external-scripts.json` に追加する

```json
["backlog2slack"]
```

## 設定

### Backlog Add webhook

`https://{space_name}.backlog.jp/settings/webhook/{project_name}}/create`

- WebHook URL に以下のURLを設定してください

`{hubot_url}/backlog2slack/{space_name}/{Channel_name}`  
(exampleURL: `http:example.com:8080/backlog2slack/example-space/bb-notification-channel`)

### 環境変数に HUBOT_SLACK_TOKEN を設定する

`export HUBOT_SLACK_TOKEN = {your_slack_API_token}`
