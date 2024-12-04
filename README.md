# 『Event Station』

## サービスURL
https://event-station.onrender.com

## サービス概要
イベントやゲーム、あそびなどの参加者募集を簡単に行えるサービスです。

## このサービスへの思い・作りたい理由
私は麻雀を趣味としているのですが、ひとりひとり麻雀を打てる友人を思い出して連絡を取り、
人数を集めて日程調整をするという過程が億劫に感じていました。<br />
グループ全員の出欠確認・日程調整ができるサービスはよく見かけますが、
そうではなく、「やりたいこと」を提示し、誘いたい人だけにそれを表示させることができるサービスがあればいいなと思ったのがきっかけです。

## ユーザー層について
- イベントやあそびを企画したい人
- 休日に参加できるイベントを探したい人

## サービスの利用イメージ
ユーザーログイン、フレンド登録をおこない、登録した友達をグループ分けできる。<br />
あそびのオーナーは「やりたいこと・日時・場所」などを書き込み、それを誘いたいグループのみに公開することができる。<br />
参加者側は誘われているイベントリストから自分が参加したいものに対してのみ参加リクエストを送信。<br />
[![Image from Gyazo](https://i.gyazo.com/bdb939c45bd2915540c55b30bcabc47a.png)](https://gyazo.com/bdb939c45bd2915540c55b30bcabc47a)
<br />
利点：
- オーナーは人が集まるまで何人も連絡を取り続ける手間が省ける
- 参加者はすべてに出欠の回答をする必要がない
- 参加確定したイベントをカレンダー表示し、スケジュールを確認できる
- 参加したイベントの前日にLINEで通知することができる


## サービスの差別化ポイント・推しポイント
グループ全員の出欠確認サービスとの差別化を考えています。
- イベントに応じて誘いたいグループを変更できる点
- 参加したいイベントにだけ反応すればよく、すべてに出欠回答をしなくていい点
- 〇月〇日に来れる人を集めたい、とりあえず人数だけ集めたいなどイベントごとに募集内容を柔軟に決められる点

## 使用技術
| カテゴリ | 技術内容 |
| ---- | ---- |
| サーバーサイド | Ruby on Rails 7.2.1・Ruby 3.2.3 |
| フロントエンド | bootstrap 5.3.3・JavaScript |
| データーベース | PostgreSQL |
| 認証 | devise 4.9.4 |
| CI/CD | Github Actions |
| インフラ | Render.com |


## 画面遷移図
Figma：https://www.figma.com/design/wUiWWk80G99q1SMMyMA9Xo/portfolio?node-id=9-52&node-type=canvas&t=Nuj3TFeS8vPFE6CS-0

## ER図
[![Image from Gyazo](https://i.gyazo.com/9d601eed3a6bde22c0f2c2754870b4bf.png)](https://gyazo.com/9d601eed3a6bde22c0f2c2754870b4bf)