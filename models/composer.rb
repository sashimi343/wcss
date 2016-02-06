require 'active_record'

class Composer < ActiveRecord::Base
    # バリデーション
    # contact以外の項目は全て必須、IDは一意
    validates :registration_id, presence: true
    validates :registration_id, uniqueness: true
    validates :name, presence: true

    # 作曲者は複数のコンピに参加する
    has_many :participations

    # 作曲者は複数の曲を作成する
    has_many :songs

    # パスワードを暗号化する
    has_secure_password

    # 入力された値について、登録情報の更新を行う
    # ==== Args
    # _values_ :: 変更後の値を格納したハッシュ。変更しない項目のキーに対応する値はnil。
    # ==== Raise
    # ArgumentError :: passwordとpassword_confirmationが一致しない場合に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def modify_information(values)
        raise ArgumentError.new('The passwords you entered do not match') unless values[:password] == values[:password_confirmation]
        modifications = values.reject { |k, v| k == :password_confirmation or v.empty? }

        update_attributes modifications
        save!
    end
end
