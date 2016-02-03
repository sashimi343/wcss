class ChangeCompilationsColumnName < ActiveRecord::Migration
    def change
        rename_column :compilations, :compilation_id, :compilation_name
    end
end
