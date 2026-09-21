class CreateOutings < ActiveRecord::Migration[8.1]
  def change
    create_table :outings do |t|
      t.string :title, null: false
      t.date :start_on, null: false
      t.date :end_on
      t.string :place
      t.text :memo
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
