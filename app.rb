require 'sinatra'
require 'active_record'
require 'dropbox_sdk'
require './models/administrator'
require './extensions/admin_route'

require 'dotenv'
Dotenv.load

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])

DROPBOX_ACCESS_TOKEN = ENV['DROPBOX_ACCESS_TOKEN']

enable :sessions
register AdminRoute

get '/' do
    @page_title = 'Sample Page'
    @text = 'Hello, Heroku?'
    erb :index
end
