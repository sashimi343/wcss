require 'active_record'

class Compilation < ActiveRecord::Base
    # バリデーション
    # 全項目必須、IDは一意
    validates :compilation_name, presence: true
    validates :compilation_name, uniqueness: true
    validates :title, presence: true

    # コンピは一人の主催者により開催される
    belongs_to :administration

    # コンピには複数人の作曲者が参加する
    has_many :participations
end
