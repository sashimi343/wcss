class CreateCompilationsComposers < ActiveRecord::Migration
    def change
        create_table :compilations_composers do |t|
            t.integer :compilation_id   # foreign key for compilations table
            t.integer :composer_id      # foreign key for composers table
        end
    end
end
