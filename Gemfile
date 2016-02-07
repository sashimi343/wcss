source 'https://rubygems.org/'

gem 'sinatra'
gem 'dropbox-sdk'
gem 'bcrypt'
gem 'dotenv'

# Active Record
gem 'sinatra-activerecord'
gem 'activerecord'

# DB
group :development, :test do
    gem 'rake'      # build tool
    gem 'sqlite3'   # SQLite
end
group :production do
    gem 'pg'    # PostgreSQL
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
