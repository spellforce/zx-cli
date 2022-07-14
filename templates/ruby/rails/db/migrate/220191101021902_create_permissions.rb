class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.string :kind
      t.string :name
      t.string :code
      t.integer :parent_id
      t.text :description
      t.string :url
      t.timestamps
    end
  end
end
