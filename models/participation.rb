require 'active_record'

class Participation < ActiveRecord::Base
    # 参加するのはある作曲者
    belongs_to :composer

    # 参加はコンピ単位
    belongs_to :compilation
end
