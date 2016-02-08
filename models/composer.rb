require 'active_record'

class Composer < ActiveRecord::Base
    # バリデーション
    # contact以外の項目は全て必須、IDは一意
    validates :registration_id, presence: true
    validates :registration_id, uniqueness: true
    validates :name, presence: true

    # 作曲者は複数のコンピに参加する
    has_many :participations
    has_many :compilations, through: :participations

    # パスワードを暗号化する
    has_secure_password

    # 入力された値について、登録情報の更新を行う
    # ==== Args
    # _values_ :: 変更後の値を格納したハッシュ。変更しない項目のキーに対応する値はnil。
    # ==== Raise
    # ArgumentError :: passwordとpassword_confirmationが一致しない場合に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def modify_information(values)
        unless values[:password] == values[:password_confirmation]
            raise ArgumentError.new('The passwords you entered do not match')
        end

        modifications = values.reject { |k, v| !Composer.column_names.include? k or v.empty? }
        update_attributes modifications
        save!
    end

    # コンピの参加者リストに追加する
    # ==== Args
    # _compilation_ :: 参加するコンピのモデル
    # ==== Raise
    # ArgumentError :: 作曲者が既にコンピに参加している場合に発生
    def join_compilation(compilation)
        if compilation.composers.find_by registration_id: registration_id
            raise ArgumentError.new "Composer #{name} is already participate in compilation #{compilation.title}"
        end

        compilation.composers << self
    end
end
