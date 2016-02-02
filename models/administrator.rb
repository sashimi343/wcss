require 'active_record'
require 'bcrypt'

class Administrator < ActiveRecord::Base
    # バリデーション
    # contact以外の項目は全て必須、IDは一意
    validates :registration_id, presence: true
    validates :registration_id, uniqueness: true
    validates :name, presence: true

    # 管理者は複数のコンピを主催する
    has_many :compilations

    # パスワードを暗号化する
    has_secure_password
end
