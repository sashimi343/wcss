require 'sinatra/base'

module AdminRoute
    def self.registered(base)
        # ログインが必要なページ
        %w(/admin /admin/composers /admin/composers/* /admin/compilations /admin/compilations/*).each do |route|
            base.before route do
                redirect '/admin/login' unless session[:admin_id]
            end
        end

        # 管理者用ページを表示する
        base.get '/admin' do
            @page_title = 'Administrator page'
            @text = "Hello, #{session[:admin_id]}"
            erb :admin
        end

        # パスワードを変更する
        base.post '/admin' do
            administrator = Administrator.find_by registration_id: session[:admin_id]

            begin
                administrator.change_password(
                    params[:current_password],
                    params[:password],
                    params[:password_confirmation]
                )
                { message: 'Password has been changed' }.to_json
            rescue => e
                { message: e.message }.to_json
            end
        end

        # ログインフォームを表示する
        base.get '/admin/login' do
            # ログイン済みの場合、管理者用ページにリダイレクトする
            redirect '/admin' if session[:admin_id]

            @page_title = 'Administrator login'
            erb :login
        end

        # ログイン処理を行う
        base.post '/admin/login' do
            # ユーザ名、パスワードを検証する
            administrator = Administrator.find_by registration_id: params[:registration_id]
            if administrator and administrator.authenticate params[:password]
                # 認証成功
                session[:admin_id] = params[:registration_id]
                { redirect: '/admin' }.to_json
            else
                # 認証失敗
                { message: 'Incorrect ID or password' }.to_json
            end
        end

        # ログアウト処理を行う
        base.post '/admin/logout' do
            session[:admin_id] = nil
            redirect '/'
        end

        # 作曲者一覧の表示と新規登録フォームを表示する
        base.get '/admin/composers' do
            @page_title = 'Composers'
            @composers = Composer.all
            erb :composers
        end

        # 作曲者の追加処理を行う
        base.post '/admin/composers' do
            begin
                unless params[:password] == params[:password_confirmation]
                    raise ArgumentError.new 'The passwords you entered do not match'
                end

                composer = Composer.create!(
                    registration_id: params[:registration_id],
                    password: params[:password],
                    name: params[:name],
                    contact: params[:contact]
                )
                { message: 'A new composer has been added' }.to_json
            rescue => e
                { message: e.message }.to_json
            end
        end

        # 作曲者情報の表示と編集を行うページを表示する
        base.get '/admin/composers/:reg_id' do |reg_id|
            @composer = Composer.find_by registration_id: reg_id
            halt 404 unless @composer

            @page_title = "#{@composer.name} (#{@composer.registration_id})"
            @error_message = session[:error_message]   # 編集エラーがあれば表示
            session[:error_message] = nil
            erb :composer
        end

        base.post '/admin/composers/:reg_id' do |reg_id|
            composer = Composer.find_by registration_id: reg_id
            halt 404 unless composer

            begin
                composer.modify_information params
                status 200
                {
                    message: 'Composer information has been changed',
                    redirect: "/admin/composers/#{composer.registration_id}"
                }.to_json
            rescue => e
                status 304
                { message: e.message }.to_json
            end
        end

        # コンピ一覧の表示とコンピ追加を行うページを表示する
        base.get '/admin/compilations' do
            organizer = Administrator.find_by registration_id: session[:admin_id]

            @page_title = 'Compilations'
            @compilations = organizer.compilations if organizer
            @error_message = session[:error_message]   # 作成エラーがあれば表示
            session[:error_message] = nil
            erb :compilations
        end

        # コンピの追加処理を行う
        base.post '/admin/compilations' do
            organizer = Administrator.find_by registration_id: session[:admin_id]

            begin
                organizer.hold_new_compilation params
            rescue => e
                session[:error_message] = e.message
            ensure
                redirect '/admin/compilations'
            end
        end

        # コンピ情報管理画面を表示する
        base.get '/admin/compilations/:compi_name' do |compi_name|
            organizer = Administrator.find_by registration_id: session[:admin_id]
            @compilation = organizer.compilations.find_by(compilation_name: compi_name) if organizer
            halt 404 unless @compilation

            @page_title = @compilation.title
            @composers = Composer.all  # TODO: まだ参加していない作曲者のみ表示
            @error_message = session[:error_message]   # 編集エラーがあれば表示
            session[:error_message] = nil
            erb :manage_compilation
        end

        # コンピ情報の編集を行う
        base.post '/admin/compilations/:compi_name' do |compi_name|
            organizer = Administrator.find_by registration_id: session[:admin_id]
            compilation = organizer.compilations.find_by(compilation_name: compi_name) if organizer
            halt 404 unless compilation

            begin
                compilation.modify_information params
                redirect "/admin/compilations/#{compilation.compilation_name}"
            rescue => e
                session[:error_message] = e.message
                redirect "/admin/compilations/#{compi_name}"
            end
        end
        
        # コンピへの作曲者追加の処理を行う
        base.post '/admin/compilations/:compi_name/participations' do |compi_name|
            composer = Composer.find_by registration_id: params[:registration_id]
            compilation = Compilation.find_by compilation_name: compi_name
            halt 400 if composer.nil? or compilation.nil?

            begin
                composer.join_compilation compilation
            rescue => e
                session[:error_message] = e.message
            ensure
                redirect "/admin/compilations/#{compi_name}" 
            end
        end
    end
end
