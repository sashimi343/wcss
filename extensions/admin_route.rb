require 'sinatra/base'

module AdminRoute
    def self.registered(base)
        base.get '/admin' do
            'Hello, Admin'
        end

        base.get '/login' do
        end

        base.get '/logout' do
        end

        base.post '/login' do
        end

        base.post '/logout' do
        end
    end
end
