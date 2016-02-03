class ChangeDbName < ActiveRecord::Migration
    def change
        rename_table :compilations_composers, :participations
    end
end
