class CreateUserLoginHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :user_login_histories do |t|
      t.string :email
      t.string :ip
      t.text :user_agent
      t.string :browser
      t.string :os
      t.string :device_type
      t.string :timezone
      t.string :referer
      t.string :environment
      t.string :other
      t.timestamp :logged_at
    end
  end
end