require 'sinatra/base'

module UserRoute
    def self.registered(base)
        # ログインが必要なページ
        %w(/dashboard /*/submit).each do |route|
            base.before route do
                redirect '/login' unless session[:user_id]
            end
        end

        # ユーザ用ページを表示する
        base.get '/dashboard' do
            @composer = Composer.find_by registration_id: session[:user_id]
            unless @composer
                session[:user_id] = nil
                redirect '/'
            end

            @page_title = 'Dashboard'
            @text = "Hello, #{session[:user_id]}"
            @participations = @composer.participations
            erb :dashboard
        end

        # ユーザ情報の編集を行う
        base.post '/dashboard' do
            composer = Composer.find_by registration_id: session[:user_id]

            begin
                composer.modify_information params

                if params.key? 'registration_id' and !params[:registration_id].empty?
                    session[:user_id] = params[:registration_id]
                end

                { message: 'User information has been changed' }.to_json
            rescue => e
                { message: e.message }.to_json
            end
        end

        # ログインフォームを表示する
        base.get '/login' do
            # ログイン済みの場合、ユーザ用ページにリダイレクトする
            redirect '/dashboard' if session[:user_id]

            @page_title = 'Login'
            @error_message = session[:error_message]  # ログインエラーがあればそれを表示
            session[:error_message] = nil             # エラー情報のリセット
            erb :login
        end

        # ログイン処理を行う
        base.post '/login' do
            # ユーザ名、パスワードを検証する
            composer = Composer.find_by registration_id: params[:registration_id]
            if composer and composer.authenticate params[:password]
                # 認証成功
                session[:user_id] = params[:registration_id]
                redirect '/dashboard'
            else
                # 認証失敗
                session[:error_message] = 'Incorrect ID or password'
                redirect '/login'
            end
        end

        # ログアウト処理を行う
        base.post '/logout' do
            session[:user_id] = nil
            redirect '/'
        end
    end
end
