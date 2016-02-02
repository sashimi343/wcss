class CreateAdministrators < ActiveRecord::Migration
    def change
        create_table :administrators do |t|
            t.string :registration_id
            t.string :password_digest, null: false
            t.string :name
            t.text :contact
            t.timestamps :null => true
        end
    end
end
