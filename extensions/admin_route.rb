require 'sinatra/base'

module AdminRoute
    def self.registered(base)
        # 管理者用ページを表示する
        base.get '/admin' do
            # ユーザがログインしていない場合、ログインページに移動
            redirect '/admin/login' unless session[:admin_id]

            @page_title = 'Administrator Page'
            @text = "Hello, #{session[:admin_id]}"
            erb :admin
        end

        # ログインフォームを表示する
        base.get '/admin/login' do
            # ログイン済みの場合、管理者用ページにリダイレクトする
            redirect '/admin' if session[:admin_id]

            @page_title = 'Administrator Login'
            @error_message = session[:login_error]  # ログインエラーがあればそれを表示
            session[:login_error] = nil             # エラー情報のリセット
            erb :login
        end

        # ログイン処理を行う
        base.post '/admin/login' do
            # ユーザ名、パスワードを検証する
            administrator = Administrator.find_by registration_id: params[:registration_id]
            if administrator and administrator.authenticate params[:password]
                # 認証成功
                session[:admin_id] = params[:registration_id]
                redirect '/admin'
            else
                # 認証失敗
                session[:login_error] = 'Incorrect ID or password'
                redirect '/admin/login'
            end
        end

        # ログアウト処理を行う
        base.post '/admin/logout' do
            session[:admin_id] = nil
            redirect '/admin/login'
        end
    end
end
