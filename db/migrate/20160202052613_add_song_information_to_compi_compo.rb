class AddSongInformationToCompiCompo < ActiveRecord::Migration
    def change
        change_table :compilations_composers do |t|
            t.string :song_title
            t.string :artist
            t.string :comment
            t.datetime :submission
            t.timestamps :null => true
        end
    end
end
