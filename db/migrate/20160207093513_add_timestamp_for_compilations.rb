class AddTimestampForCompilations < ActiveRecord::Migration
    def change
        change_table :compilations do |t|
            t.timestamps :null => true
        end
    end
end
