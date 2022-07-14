class CreatePermissionHierarchies < ActiveRecord::Migration[5.2]
  def change
    create_table :permission_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :permission_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "permission_anc_desc_idx"

    add_index :permission_hierarchies, [:descendant_id],
      name: "permission_desc_idx"
  end
end
