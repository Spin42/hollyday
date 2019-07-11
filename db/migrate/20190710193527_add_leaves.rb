class AddLeaves < ActiveRecord::Migration[5.0]
  def change
    create_table :leaves, force: true do |t|
      t.string :team_id
      t.string :user_id
      t.string :leave_type
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
