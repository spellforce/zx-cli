class AddPassChangedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pass_changed, :datetime
  end
end
