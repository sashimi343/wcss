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

        # 作曲者一覧の表示と新規登録フォームを表示する
        base.get '/admin/composers' do
            @page_title = 'Composers'
            @composers = Composer.all
            @error_message = session[:composer_addition_error]   # 作成エラーがあれば表示
            session[:composer_addition_error] = nil
            erb :composers
        end

        # 作曲者の追加処理を行う
        base.post '/admin/composers' do
            unless params[:password] == params[:password_confirmation]
                session[:composer_addition_error] = 'The passwords you entered do not match'
                redirect '/admin/composers'
            end

            composer = Composer.new(
                registration_id: params[:registration_id],
                password: params[:password],
                name: params[:name],
                contact: params[:contact]
            )

            if composer.valid?
                composer.save
            else
                session[:composer_addition_error] = composer.errors.messages
            end

            redirect '/admin/composers'
        end

        # 作曲者情報の表示と編集を行うページを表示する
        base.get '/admin/composers/:user' do |user|
            @composer = Composer.find_by registration_id: user
            halt 404 unless @composer

            @page_title = "#{@composer.name} (#{@composer.registration_id})"
            @error_message = session[:composer_modification_error]   # 作成エラーがあれば表示
            session[:composer_modification_error] = nil
            erb :composer
        end

        base.post '/admin/composers/:user' do |user|
            composer = Composer.find_by registration_id: user
            halt 404 unless composer

            begin
                composer.modify_information({
                    registration_id: params[:registration_id],
                    password: params[:password],
                    password_confirmation: params[:password_confirmation],
                    name: params[:name],
                    contact: params[:contact]
                })
            rescue => e
                session[:composer_modification_error] = e.message
            ensure
                redirect "/admin/composers/#{composer.registration_id}"
            end

        end
    end
end
