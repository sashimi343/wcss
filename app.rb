require 'sinatra'
require 'active_record'
require 'dropbox_sdk'
require 'json'
require 'cgi'
require './models/administrator'
require './models/composer'
require './models/compilation'
require './models/progress'
require './models/participation'
require './extensions/admin_route'
require './extensions/user_route'

require 'dotenv'
Dotenv.load

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])

# time zone
Time.zone = 'Asia/Tokyo'
ActiveRecord::Base.default_timezone = :local

DROPBOX_ACCESS_TOKEN = ENV['DROPBOX_ACCESS_TOKEN']

enable :sessions
set :session_secret, ENV['SESSION_SECRET']
set :progresses, {}
register AdminRoute, UserRoute

# トップページを表示する
get '/' do
    @page_title = 'Index'
    @compilations = Compilation.all.select { |e| e.deadline >= Time.current }
    @past_compilations = Compilation.all.select { |e| e.deadline < Time.current }
    erb :top
end

# 各種処理の進捗情報を返す
get '/progresses' do
    halt 400 unless params[:key]

    progress = settings.progresses[params[:key]]
    
    if progress
        progress.to_json
    else
        halt 404
    end
end

# コンピ情報を表示する
get '/:compi_name' do |compi_name|
    @compilation = Compilation.find_by compilation_name: compi_name
    halt 404 unless @compilation

    @page_title = @compilation.title
    erb :compilation
end

# コンピへの楽曲提出用ページを表示する (要ユーザログイン)
get '/:compi_name/submit' do |compi_name|
    redirect "/login?from=#{compi_name}" unless session[:user_id]

    compilation = Compilation.find_by compilation_name: compi_name
    halt 404 unless compilation

    # 参加者のみ提出フォームを利用できる
    if compilation.composers.exists? registration_id: session[:user_id]
        @page_title = "提出ページ: #{compilation.title}"
        @deadline_unix = compilation.deadline.to_i
        erb :submission
    else
        @page_title = 'エラー'
        @text = "あなたはコンピ'#{compilation.title}'に参加していません"
        erb :index
    end
end

# コンピに楽曲を提出する
post '/:compi_name/submit' do |compi_name|
    compilation = Compilation.find_by compilation_name: compi_name
    halt 404 unless compilation
    composer = compilation.composers.find_by registration_id: session[:user_id]
    halt 401 unless composer

    progress = Progress.new
    settings.progresses[progress.key] = progress

    # 楽曲提出の処理を別スレッドで行う
    Thread.new do
        begin
            # ファイルの存在確認
            raise IOError.new('No wav file specified') unless params[:wav_file]

            composer.submit_song(
                compilation,
                progress,
                params[:song_title],
                params[:artist],
                params[:wav_file][:tempfile],
                params[:comment]
            )
        rescue => e
            progress.update error_message: e.message
            # debug
            p progress.to_json
        end
    end

    # クライアントに進捗情報問い合わせキーを送信する
    #progress.to_json
    # とりあえずクライアントに返信 (現在のJS処理に合わせた暫定仕様)
    {
        message: "別スレッドで楽曲のアップロードを開始しました\nそのうち完了すると思います",
        redirect: '/dashboard'
    }.to_json
end
