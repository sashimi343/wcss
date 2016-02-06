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
end
