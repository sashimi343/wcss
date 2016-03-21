require 'active_record'
require 'digest/sha1'
require 'json'

class Progress
    include ActiveModel::Model
    attr_accessor :key, :progress, :error_message

    # バリデーション
    validates :key, presence: true
    validates :progress, numericality: {
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 1,
    }

    def initialize
        super
        @key = Digest::SHA1.hexdigest "#{Time.now}#{rand 65535}"
        @progress = 0.0
    end

    # 進捗状況を更新する
    # バリデーションエラー時には元の値にロールバックする
    # ==== Args
    # _attributes_ :: 変更後の値を格納したハッシュ (:progress, :error_messageしか見ない)
    def update(attributes)
        old_value = {
            progress: @progress,
            error_message: @error_message,
        }

        (@progress = attributes[:progress]) if attributes[:progress]
        (@error_message = attributes[:error_message]) if attributes[:error_message]

        # バリデーションエラー時にはロールバックする
        update old_value if invalid?
    end

    # タスクの状態を取得する
    # ==== Return
    # 'running' :: 実行中の場合
    # 'finished' :: 実行完了の場合
    # 'error' :: エラーが発生している場合
    def status
        if @error_message.nil? or @error_message.empty?
            @progress == 1.0 ? 'finished' : 'running'
        else
            'error'
        end
    end

    # 進捗情報をJSON形式で出力する
    # ==== Return
    # json :: 進捗情報
    def to_json
        {
            key: @key,
            status: status,
            progress: @progress,
            error_message: @error_message
        }.to_json
    end
end
