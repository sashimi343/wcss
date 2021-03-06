require 'active_record'

class Compilation < ActiveRecord::Base
    # バリデーション
    VALID_NAME_REGEX = /\A[0-9a-z\_\-]{4,31}\z/
    validates :compilation_name, presence: true
    validates :compilation_name, uniqueness: true
    validates :compilation_name, format: { with: VALID_NAME_REGEX }
    validates :compilation_name, exclusion: { in: %w(dashboard admin login logout register settings progresses) }
    validates :title, presence: true
    validates :title, length: { in: 1..127 }
    validates :description, presence: true
    validates :description, length: { in: 1..1023 }
    validates :requirement, length: { in: 0..1023 }
    validates :deadline, presence: true
    validate :date_cannot_be_in_the_past

    # コンピは一人の主催者により開催される
    belongs_to :administration

    # コンピには複数人の作曲者が参加する
    has_many :participations
    has_many :composers, through: :participations

    # カスタムバリデータ
    # deadlineはコンピ開催時以降である必要がある
    def date_cannot_be_in_the_past
        if !deadline.nil? && deadline < Time.current
            errors.add :deadline, '過去の日時です'
        end
    end

    # 入力された値について、登録情報の更新を行う
    # ==== Args
    # _values_ :: 変更後の値を格納したハッシュ。変更しない項目のキーに対応する値はnil。
    # ==== Raise
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def modify_information(values)
        old_compilation_name = compilation_name
        modifications = values.reject { |k, v| !Compilation.column_names.include? k or v.empty? }
        update! modifications

        # 提出曲用のディレクトリ名も変更する
        dropbox = DropboxClient.new DROPBOX_ACCESS_TOKEN
        dropbox.file_move old_compilation_name, compilation_name
    end

    # 全曲ダウンロード用URLを出力する
    # ==== Return
    # URL :: コンピ楽曲提出ディレクトリのURL
    # '#' :: 提出用ディレクトリがない場合
    def download_all_url
        path = "#{compilation_name}/"
        dropbox = DropboxClient.new DROPBOX_ACCESS_TOKEN

        begin
            share = dropbox.shares path
            share['url']
        rescue => e
            '#'
        end
    end
end
