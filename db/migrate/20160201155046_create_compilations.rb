class CreateCompilations < ActiveRecord::Migration
    def change
        create_table :compilations do |t|
            t.string :compilation_id
            t.integer :administrator_id     # foreign key for administrators table
            t.string :title
            t.text :description
            t.text :requirement
            t.datetime :deadline
        end
    end
end
