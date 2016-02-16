require 'active_record'

class Participation < ActiveRecord::Base
    # バリデーション
    # 提出時以外はバリデーションを行わない
    validates :artist, presence: true, on: :update
    validates :artist, length: { in: 1..63 }, on: :update
    validates :song_title, presence: true, on: :update
    validates :song_title, length: { in: 1..63 }, on: :update
    validates :comment, length: { maximum: 1023 }, on: :update

    # 参加するのはある作曲者
    belongs_to :composer

    # 参加はコンピ単位
    belongs_to :compilation
end
