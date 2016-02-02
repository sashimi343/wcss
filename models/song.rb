require 'active_record'

class Song < ActiveRecord::Base
    # バリデーション
    # comment以外の項目は全て必須
    validates :title, presence: true
    validates :artist, presence: true
    validates :submission, presence: true

    # 曲は1つのコンピに収録される
    belongs_to :compilations

    # 曲は一人の参加者により作成される
    belongs_to :composer
end
