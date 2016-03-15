require 'active_record'

class Administrator < ActiveRecord::Base
    # バリデーション
    VALID_ID_REGEX = /\A[0-9a-z\_\-]{4,31}\z/i
    validates :registration_id, presence: true
    validates :registration_id, uniqueness: true
    validates :registration_id, format: { with: VALID_ID_REGEX }
    validates :name, presence: true
    validates :name, length: { in: 1..63 }

    # 管理者は複数のコンピを主催する
    has_many :compilations

    # パスワードを暗号化する
    has_secure_password

    # パスワードを変更する
    # ==== Args
    # _current_password_ :: 現在のパスワード
    # _password_ :: 新しいパスワード
    # _password_confirmation_ :: 新しいパスワード (確認用)
    # ==== Raise
    # ArgumentError :: current_passwordの間違い、またはpasswordとpassword_confirmationの不一致時に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def change_password(current_password, password, password_confirmation)
        raise ArgumentError.new('現在のパスワードが違います') unless authenticate current_password
        raise ArgumentError.new('パスワードと確認用パスワードが一致しません') unless password == password_confirmation

        update! password: password
    end

    # 新しいコンピを開催する
    # ==== Args
    # _values_ :: コンピ情報を格納したハッシュ
    # ==== Raise
    # ArgumentError :: passwordとpassword_confirmationが一致しない場合に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def hold_new_compilation(values)
        Time.zone = 'Asia/Tokyo'

        compilation = compilations.create!(
            compilation_name: values[:compilation_name],
            title: values[:title],
            description: values[:description],
            requirement: values[:requirement],
            deadline: Time.zone.parse(values[:deadline])
        )

        # コンピ楽曲保存用のディレクトを作成する
        dropbox = DropboxClient.new DROPBOX_ACCESS_TOKEN
        dropbox.file_create_folder compilation.compilation_name
    end
end
