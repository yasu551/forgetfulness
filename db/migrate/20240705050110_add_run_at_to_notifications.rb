class AddRunAtToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :run_at, :datetime, null: false
  end
end
