class AddVariousPetInfoColumnsToFavorites < ActiveRecord::Migration[5.2]
  def change
    add_column :favorites, :pet_name, :string
    add_column :favorites, :pet_age, :string
    add_column :favorites, :pet_size, :string
    add_column :favorites, :pet_gender, :string
    add_column :favorites, :pet_breed, :string
    add_column :favorites, :pet_description, :string
    add_column :favorites, :details, :string, array: true, default: '[]'
    add_column :favorites, :personality, :string, array: true, default: '[]'
    add_column :favorites, :shelter, :string
    add_column :favorites, :phone, :string
    add_column :favorites, :email, :string
    add_column :favorites, :status, :string
    add_column :favorites, :avatar_url, :string
    add_column :favorites, :photos_urls, :string, array: true, default: '[]'
  end
end
