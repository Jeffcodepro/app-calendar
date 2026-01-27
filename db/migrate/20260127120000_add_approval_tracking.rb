class AddApprovalTracking < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :approved_by_id, :bigint
    add_index :users, :approved_by_id
    add_foreign_key :users, :users, column: :approved_by_id

    add_column :vacation_requests, :approved_by_id, :bigint
    add_column :vacation_requests, :rejected_by_id, :bigint
    add_index :vacation_requests, :approved_by_id
    add_index :vacation_requests, :rejected_by_id
    add_foreign_key :vacation_requests, :users, column: :approved_by_id
    add_foreign_key :vacation_requests, :users, column: :rejected_by_id
  end
end
