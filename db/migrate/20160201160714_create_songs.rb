class CreateSongs < ActiveRecord::Migration
    def change
        create_table :songs do |t|
            t.integer :composer_id      # foreign key for composers table
            t.integer :compilation_id   # foreign key for compilations table
            t.string :title
            t.string :artist
            t.text :comment
            t.datetime :submission
        end
    end
end
