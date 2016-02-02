class CreateComposers < ActiveRecord::Migration
    def change
        create_table :composers do |t|
            t.string :registration_id
            t.string :password_digest, null: false
            t.string :name
            t.text :contact
            t.timestamps :null => true
        end
    end
end
