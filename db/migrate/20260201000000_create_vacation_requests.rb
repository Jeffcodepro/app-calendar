class CreateVacationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :vacation_requests, [:start_date, :end_date]
  end
end
