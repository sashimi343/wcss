require 'active_record'

class Compilation < ActiveRecord::Base
    # バリデーション
    # 全項目必須、IDは一意
    validates :compilation_id, presence: true
    validates :compilation_id, uniqueness: true
    validates :title, presence: true

    # コンピは一人の主催者により開催される
    belongs_to :administrations

    # コンピには複数人の作曲者が参加する
    has_many :composers

    # コンピには複数の曲が投稿される
    has_many :songs
end
