# 概要

Webコンピレーションにおける楽曲提出・管理を支援するシステムです。
このシステムでは、

* コンピ主催者のコンピ情報の登録
* コンピ参加者の楽曲提出
* 楽曲情報の管理

をWebベースで実現します (する予定です)


# インストール

以下の存在を前提とします

* Dropboxアカウント (このアカウントの/アプリ/<アプリ名>以下に楽曲を保存します)
* Dropbox APIのアクセストークン
* Herokuアカウント
* Heroku Toolbelt

```console
$ git clone https://github.com/sashimi343/wcss.git /your/favorite/path
$ cd /your/favorite/path
$ heroku login
#$ heroku create <app name>
$ heroku git:remote -a <app name>
$ bundle install --path vendor/bundle

# Dropbox access token
$ echo DROPBOX_ACCESS_TOKEN=<your own access token> >>.env
$ heroku config:set DROPBOX_ACCESS_TOKEN=<your own access token>

# DB
$ echo RACK_ENV=development >>.env
$ heroku addons:create heroku-postgresql
$ heroku config
=== wcss Config Vars
DATABASE_URL: postgres://username:password@host:port/database
# これを基に、heroku config:set で以下のキーを設定
DATABASE_USERNAME=username
DATABASE_PASSWORD=password
DATABASE_HOST=host
DATABASE=database

$ git push heroku master
$ heroku run rake db:migrate
$ heroku open
```
