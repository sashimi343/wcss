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

get '/' do
    @page_title = 'Sample Page'
    @text = 'Hello, Heroku?'
    erb :index
end
