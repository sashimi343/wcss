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

    # ファイルダウンロード用URLを出力する
    # ==== Return
    # URL :: wavファイルを提出済みの場合
    # '#' :: wavファイル未提出の場合
    def download_url
        path = "#{compilation.compilation_name}/#{id}_#{composer.registration_id}.wav"
        dropbox = DropboxClient.new DROPBOX_ACCESS_TOKEN

        begin
            media = dropbox.media path
            "#{media['url']}?dl=1"
        rescue => e
            '#'
        end
    end

    # 提出が締め切り時刻を過ぎているか判定する
    # ==== Return
    # true :: 提出時刻が締め切り時刻以前、または現在時刻が締め切り前
    # false :: 提出時刻が締め切り時刻より後、または締め切りを過ぎているのに未提出
    def late?
        (submission ? submission : Time.current) > compilation.deadline
    end
end
