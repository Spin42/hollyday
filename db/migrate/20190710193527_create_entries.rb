class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries, force: true do |t|
      t.string :team_id
      t.string :user_id
      t.string :entry_type
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
