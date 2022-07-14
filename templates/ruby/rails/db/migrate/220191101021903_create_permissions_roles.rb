class CreatePermissionsRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions_roles do |t|
      t.integer :role_id
      t.integer :permission_id

      t.timestamps
    end
  end
end
