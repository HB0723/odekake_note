class CreateScheduleItems < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_items do |t|
      t.references :outing, null: false, foreign_key: true
      t.integer :day_number, null: false, default: 1
      t.time :starts_at
      t.string :title, null: false
      t.text :memo

      t.timestamps
    end

    add_index :schedule_items, [ :outing_id, :day_number, :starts_at ]
  end
end
