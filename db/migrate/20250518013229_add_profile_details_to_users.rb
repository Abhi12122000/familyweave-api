class AddProfileDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :date_of_birth, :date
    add_column :users, :gender, :string
    add_column :users, :profile_picture_url, :string
    add_column :users, :cover_photo_url, :string
    add_column :users, :current_city, :string
    add_column :users, :bio, :text
    add_column :users, :relationship_status, :string
  end
end
