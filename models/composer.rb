require 'active_record'
require 'json'

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
            raise ArgumentError.new 'パスワードと確認用パスワードが一致しません'
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
        if compilation.composers.exists? registration_id: registration_id
            raise ArgumentError.new "#{name}は既にコンピ'#{compilation.title}'の参加者です"
        end

        compilation.composers << self
    end

    # コンピに楽曲を提出する
    # ==== Args
    # _compilation_ :: 楽曲を提出するコンピのモデル
    # _progress_ :: 進捗情報管理用オブジェクト
    # _wav_file :: 提出するwavファイル
    # _song_title :: 曲名
    # _artist_ :: アーティスト名
    # _comment_ :: 曲コメント (省略可)
    # ==== Raise
    # ArgumentError :: 作曲者がコンピに参加していない場合に発生
    # IOError :: ファイルをアップロードできない場合に発生
    # ActiveRecord::RecordInvalid :: その他のバリデーションエラー時に発生
    def submit_song(compilation, progress, song_title, artist, wav_file, comment)
        participation = compilation.participations.find_by composer_id: id
        unless participation
            raise ArgumentError.new "#{name}はコンピ'#{compilation.title}'に参加していません"
        end

        # 提出ファイルのバリデーション
        wav_file_size = ('%.2f' % (wav_file.size.to_f / 2**20)).to_f  # MiB
        raise IOError.new "ファイルサイズが大きすぎます (#{wav_file_size} MiB > 200 MiB)" if wav_file_size > 200.0

        # 提出処理を行うトランザクション
        ActiveRecord::Base.transaction do
            # 楽曲情報を記録する
            participation.song_title = song_title
            participation.artist = artist
            participation.comment = comment
            participation.submission = Time.current
            participation.save!

            # ユーザのアップロード済みファイルを削除する (ユーザID変更対策)
            dropbox = DropboxClient.new DROPBOX_ACCESS_TOKEN
            dropbox.search(compilation.compilation_name, "#{participation.id}_").each do |metadata|
                dropbox.file_delete metadata['path']
            end

            # Dropboxに曲ファイルをアップロードする
            chunked_uploader = dropbox.get_chunked_uploader wav_file, wav_file.size
            while chunked_uploader.offset < wav_file.size do
                chunked_uploader.upload 1024**2 * 2
                progress.update progress: chunked_uploader.offset.to_f / wav_file.size
            end
            chunked_uploader.finish "#{compilation.compilation_name}/#{participation.id}_#{registration_id}.wav"
        end
    end
end

# dropbox sdk 1.6.5 のチャンクアップロードを
# 1回アップロードするごとにreturnさせるパッチ
class DropboxClient
    class ChunkedUploader
        def upload(chunk_size = 1024**2 * 4)
            @file_obj.seek(@offset) unless @file_obj.pos == @offset
            data = @file_obj.read chunk_size

            begin
                response = @client.partial_chunked_upload data, @upload_id, @offset
            rescue => e
                response = JSON.parse(e.http_response) rescue {}
                raise e unless response.body['offset']
            end

            metadata = JSON.parse response.body
            @upload_id = metadata['upload_id']
            @offset = metadata['offset'].to_i
        end
    end
end
