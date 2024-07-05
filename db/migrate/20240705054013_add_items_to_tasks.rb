class AddItemsToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :items, :string, null: false, default: ''
  end
end
