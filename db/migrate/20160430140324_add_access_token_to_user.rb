class AddAccessTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :access_token_key, :string
    add_column :users, :access_token_secret, :string
  end
end
