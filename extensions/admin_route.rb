require 'sinatra/base'

module AdminRoute
    def self.registered(base)
        # ログインが必要なページ
        %w(/admin /admin/composers).each do |route|
            base.before route do
                redirect '/admin/login' unless session[:admin_id]
            end
        end

        # 管理者用ページを表示する
        base.get '/admin' do
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

        # 作曲者一覧の表示と新規登録フォームを表示する
        base.get '/admin/composers' do
            # 各作曲者の情報を表示
            @page_title = 'Composers'
            @text = "Composers"
            erb :index
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
