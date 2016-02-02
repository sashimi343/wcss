require 'sinatra'
require 'active_record'
require 'dropbox_sdk'
require './models/administrator'

# .envファイルの読み込み
require 'dotenv'
Dotenv.load

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])

DROPBOX_ACCESS_TOKEN = ENV['DROPBOX_ACCESS_TOKEN']

get '/' do
    @page_title = 'Sample Page'
    @text = 'Hello, Heroku?'
    erb :index
end

# パラメータで指定したファイルをdropboxにアップロードする
post '/files' do
    halt 400 unless params.key? 'upload_file_path'

    client = DropboxClient.new DROPBOX_ACCESS_TOKEN
    client.put_file '/new_file', open(params['upload_file_path'])

    @page_title = 'Upload'
    @text = 'Upload Success'
    erb :index
end

# DBの導入テスト
get '/administrators' do
    Administrator.all.to_json
end
post '/administrators' do
    administrator = Administrator.new(
        registration_id: params[:registration_id],
        password: params[:password],
        name: params[:name],
        contact: params[:contact]
    )
    @text = administrator.save ? 'Administrator creation success' : 'Error'
    erb :index
end
post '/login' do
    administrator = Administrator.find_by registration_id: params[:registration_id]

    if administrator.authenticate params[:password]
        @text = 'Login success'
    else
        @text = 'Incorrect password'
    end
    erb :index
end
