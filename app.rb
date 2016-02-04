require 'sinatra'
require 'active_record'
require 'dropbox_sdk'
require './models/administrator'
require './extensions/user_auth'
require './extensions/admin'

# .envファイルの読み込み
require 'dotenv'
Dotenv.load

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])

DROPBOX_ACCESS_TOKEN = ENV['DROPBOX_ACCESS_TOKEN']

enable :sessions
helpers UserAuth, Admin

get '/' do
    @page_title = 'Sample Page'
    @text = 'Hello, Heroku?'
    erb :index
end
