require 'sinatra'
require 'active_record'
require 'dropbox_sdk'
require './models/administrator'
require './models/composer'
require './models/compilation'
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
set :session_secret, 'himitsu desuno'
register AdminRoute, UserRoute

# トップページを表示する
get '/' do
    @page_title = 'WCSS alpha'
    @compilations = Compilation.all.select { |e| e.deadline >= Time.current }
    @past_compilations = Compilation.all.select { |e| e.deadline < Time.current }
    erb :top
end

# コンピ情報を表示する
get '/:compi_name' do |compi_name|
    @compilation = Compilation.find_by compilation_name: compi_name
    halt 404 unless @compilation

    @page_title = @compilation.title
    erb :compilation
end

# コンピに楽曲を提出する (要ユーザログイン)
get '/:compi_name/submit' do |compi_name|
    @compilation = Compilation.find_by compilation_name: compi_name
    halt 404 unless @compilation

    # 参加者のみ提出フォームを利用できる
    if @compilation.composers.exists? registration_id: session[:user_id]
        @page_title = "Submission page for #{@compilation.title}"
        erb :submission
    else
        @page_title = 'Permission denied'
        @text = "You are not participant of #{@compilation.title}"
        erb :index
    end
end
