class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.string :name
      t.integer :party_count
      t.datetime :start_time
      t.references :table, null: false, foreign_key: true

      t.timestamps
    end
  end
end
