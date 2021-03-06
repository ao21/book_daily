# README

# 📖Book Daily

### " 読書 × 習慣化 " 
読書を習慣化できるサービスです。読む本を登録すると、毎日何ページまで読むかの目標が設定され、管理できます。

## URL

https://book-daily.com/  
ヘッダーの「LOGIN」-> 「ゲストログイン」ボタンからログインをお願いいたします。

開発の経緯や工夫した点などを Qiita の記事にアウトプットいたしました。  
https://qiita.com/ao_21/items/1e00df0460dc1bf24a00

## 💡 どんなアプリ？

- **毎日何ページまで読めばいいのか、目標がひと目で確認できます！** 
  - 読む本を登録 -> 読み終わる日を設定 -> 毎日の目標が設定
  - 日々の読んだページ数の記録も簡単できます。
  ![movie](https://user-images.githubusercontent.com/77653031/148927740-d0034aa2-77de-4d1d-b684-a972106211a9.gif)
  
- **進捗や達成率をわかりやすく表示し、モチベーションをアップ。**
　　- 
  <img width="600" src="https://user-images.githubusercontent.com/77653031/149058755-27348cc4-f225-424a-b314-5a14fb77ce2e.png">

## 🐾 制作背景

アプリを制作するにあたって、誰かの課題を解決するものを作りたいと考えました。  
そこで、本を中々読み終えられないとこぼしていた友人に連絡。  
・試験や会議に合わせた期日までに本を読み終えたい  
・電車通勤の時間に読みたいがつい YouTube を見てしまう  
といった課題を聞き出し、本ごとに期日管理ができ、かつ毎日目標を意識できるサービスが必要と考え、本アプリの制作を決めました。  
制作にあたり、定期的に友人からフィードバックをもらい、ユーザーの使いやすさを特に意識しました。

## 🍀 機能一覧

| 実装内容 | gem 等 |
| :---: | :---: |
| ログイン・ログアウト<br>アカウント登録・編集 | devise |
| ゲストログイン | |
| 書籍検索 | GoogleBooksAPI |
| 書籍登録機能 | |
| タスク登録機能(CRUD) | |
| 進捗登録機能(CRUD) | |
| カレンダー機能 | Simple Calendar |
| グラフ表示 | Chartkick |

## 💻 使用技術

**フロントサイド**

- HTML (erb)
- CSS (Scss)
- JavaScript (JQuery,erb)
- Bootstrap

**バックエンド**

- Ruby (2.7.2)
- Ruby on Rails (6.1.3)

**サーバー**

- Nginx(WEB サーバー)
- Puma(アプリケーションサーバー)

**DB**

- PostgreSQL (13.2)

**インフラ**

- AWS(VPC,RDS,EC2,S3,Route 53,ACM,ALB,IAM）

**解析ツール**

- Rails_best_practice (1.20)

**テスト**

- RSpec (3.1.0)
- factory_bot (6.2.0)

## ER 図
![ER図](https://user-images.githubusercontent.com/77653031/149062726-6d050f29-05cd-4047-967c-b60553c047d0.png)


## 今後追加を予定している機能

- オリジナル書籍登録機能
- CI/CD パイプラインの構築
- Docker の導入


