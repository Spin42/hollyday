class AddAmPmToEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :entries, :am, :boolean, default: true, null: false
    add_column :entries, :pm, :boolean, default: true, null: false
  end
end
