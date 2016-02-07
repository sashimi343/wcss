require 'active_record'

class Compilation < ActiveRecord::Base
    # バリデーション
    # 全項目必須、IDは一意
    validates :compilation_name, presence: true
    validates :compilation_name, uniqueness: true
    validates :compilation_name, exclusion: {in: %w(dashboard admin login logout register settings)}
    validates :title, presence: true
    validates :deadline, presence: true
    validate :date_cannot_be_in_the_past

    # コンピは一人の主催者により開催される
    belongs_to :administration

    # コンピには複数人の作曲者が参加する
    has_many :participations

    # カスタムバリデータ
    # deadlineはコンピ開催時以降である必要がある
    def date_cannot_be_in_the_past
        if !deadline.nil? && deadline < Time.current
            errors.add :deadline, 'is the past date and time'
        end
    end
end
