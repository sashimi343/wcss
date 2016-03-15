require 'sinatra/base'

module UserRoute
    def self.registered(base)
        # ログインが必要なページ
        %w(/dashboard).each do |route|
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
                session[:user_id] = composer.registration_id    # ログイン済みユーザIDの修正

                {}.to_json
            rescue => e
                { message: e.message }.to_json
            end
        end

        # ログインフォームを表示する
        base.get '/login' do
            # ログイン済みの場合、ユーザ用ページにリダイレクトする
            redirect '/dashboard' if session[:user_id]

            @page_title = 'Login'
            erb :login
        end

        # ログイン処理を行う
        base.post '/login' do
            # ユーザ名、パスワードを検証する
            composer = Composer.find_by registration_id: params[:registration_id]
            if composer and composer.authenticate params[:password]
                # 認証成功
                session[:user_id] = params[:registration_id]

                if params[:from] and Compilation.exists? compilation_name: params[:from]
                    { redirect: "/#{params[:from]}/submit" }.to_json
                else
                    { redirect: '/dashboard' }.to_json
                end
            else
                # 認証失敗
                { message: 'Incorrect ID or password' }.to_json
            end
        end

        # ログアウト処理を行う
        base.post '/logout' do
            session[:user_id] = nil
            redirect '/'
        end
    end
end
