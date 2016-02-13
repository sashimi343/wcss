require 'active_record'

class Participation < ActiveRecord::Base
    # バリデーション
    validates :artist, presence: true
    validates :artist, length: { in: 1..63 }
    validates :song_title, presence: true
    validates :song_title, length: { in: 1..63 }
    validates :comment, length: { maximum: 1023 }

    # 参加するのはある作曲者
    belongs_to :composer

    # 参加はコンピ単位
    belongs_to :compilation
end
