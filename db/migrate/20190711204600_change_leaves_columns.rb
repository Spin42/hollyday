class ChangeLeavesColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :leaves, :type, :leave_type
  end
end
