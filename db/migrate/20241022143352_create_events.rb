class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.datetime :date
      t.string :location
      t.integer :capacity
      t.string :visibility, null: false
      t.bigint :group_id

      t.timestamps
    end
  end
end
