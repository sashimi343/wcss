require 'sinatra/base'

module AdminRoute
    def self.registered(base)
        # 管理者用ページを表示する
        base.get '/admin' do
            # ユーザがログインしていない場合、ログインページに移動
            redirect '/admin/login' unless session.key? :admin_id

            @page_title = 'Administrator Page'
            @text = 'Hello, Admin'
            erb :index
        end

        # ログインフォームを表示する
        base.get '/admin/login' do
            # ログイン済みの場合、管理者用ページにリダイレクトする
            redirect '/admin' if session.key? :admin_id

            @page_title = 'Administrator Login'
            erb :login
        end

        base.post '/admin/login' do
        end

        base.post '/admin/logout' do
        end
    end
end
