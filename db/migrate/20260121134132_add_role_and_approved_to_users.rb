class AddRoleAndApprovedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :approved, :boolean, null: false, default: false
  end
end
