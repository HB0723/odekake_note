class CreatePackingItems < ActiveRecord::Migration[8.1]
  def change
    create_table :packing_items do |t|
      t.references :outing, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :checked, null: false, default: false

      t.timestamps
    end
  end
end
