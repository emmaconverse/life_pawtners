class AddUniqueIndexToFavs < ActiveRecord::Migration[5.2]
  def change
    add_index :favorites, [:user_id, :pet_id], unique: true
  end
end
