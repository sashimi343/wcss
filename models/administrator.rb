require 'active_record'

class Administrator < ActiveRecord::Base
    # バリデーション
    VALID_ID_REGEX = /[0-9a-z\_\-]{4,31}/i
    validates :registration_id, presence: true
    validates :registration_id, uniqueness: true
    validates :registration_id, format: { with: VALID_ID_REGEX }
    validates :name, presence: true
    validates :name, length: { in: 1..63 }

    # 管理者は複数のコンピを主催する
    has_many :compilations

    # パスワードを暗号化する
    has_secure_password

    # 新しいコンピを開催する
    # ==== Args
    # _values_ :: コンピ情報を格納したハッシュ
    # ==== Raise
    # ArgumentError :: passwordとpassword_confirmationが一致しない場合に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def hold_new_compilation(values)
        Time.zone = 'Asia/Tokyo'
        p Time.zone.parse(values[:deadline]).to_s
        p Time.current.to_s

        compilation = compilations.create!(
            compilation_name: values[:compilation_name],
            title: values[:title],
            description: values[:description],
            requirement: values[:requirement],
            deadline: Time.zone.parse(values[:deadline])
        )
    end
end
