require 'active_record'

class Composer < ActiveRecord::Base
    # バリデーション
    VALID_NAME_REGEX = /\A[0-9a-z\_\-]{4,31}\z/i
    validates :registration_id, presence: true
    validates :registration_id, uniqueness: true
    validates :registration_id, format: { with: VALID_NAME_REGEX }
    validates :name, presence: true
    validates :name, length: { in: 1..63 }

    # 作曲者は複数のコンピに参加する
    has_many :participations
    has_many :compilations, through: :participations

    # パスワードを暗号化する
    has_secure_password

    # 入力された値について、登録情報の更新を行う
    # ==== Args
    # _values_ :: 変更後の値を格納したハッシュ。変更しない項目のキーに対応する値はnil。
    # ==== Raise
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def modify_information(values)
        unless values[:password] == values[:password_confirmation]
            raise ArgumentError.new 'The passwords you entered do not match'
        end

        modifications = values.reject { |k, v| !Composer.column_names.include? k or v.empty? }
        update! modifications
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

    # コンピに楽曲を提出する
    # ==== Args
    # _compilation_ :: 楽曲を提出するコンピのモデル
    # _wav_file :: 提出するwavファイル
    # _song_title :: 曲名
    # _artist_ :: アーティスト名
    # _comment_ :: 曲コメント (省略可)
    # ==== Raise
    # ArgumentError :: 作曲者がコンピに参加していない場合に発生
    # IOError :: ファイルをアップロードできない場合に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def submit_song(compilation, song_title, artist, wav_file, comment)
        participation = compilation.participations.find_by composer_id: id
        unless participation
            raise ArgumentError.new "Composer #{name} is not participate in compilation #{compilation.title}"
        end

        # 提出ファイルのバリデーション
        wav_file_size = ('%.2f' % (wav_file.size.to_f / 2**20)).to_f  # MiB
        raise IOError.new "Song file exceeds size limit (#{wav_file_size} MiB > 200 MiB)" if wav_file_size > 200.0

        # ユーザのアップロード済みファイルを削除する (ユーザID変更対策)
        dropbox = DropboxClient.new DROPBOX_ACCESS_TOKEN
        dropbox.search(compilation.compilation_name, "#{participation.id}_").each do |metadata|
            dropbox.file_delete metadata['path']
        end

        # Dropboxに曲ファイルをアップロードする (古いファイルは上書きする)
        dropbox.put_file "#{compilation.compilation_name}/#{participation.id}_#{registration_id}.wav", wav_file

        # 楽曲情報を記録する
        participation.song_title = song_title
        participation.artist = artist
        (participation.comment = comment) unless comment.empty?
        participation.submission = Time.current
        participation.save!
    end
end
