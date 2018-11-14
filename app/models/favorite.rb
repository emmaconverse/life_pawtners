class Favorite < ApplicationRecord
  belongs_to :user
  validates :pet_id, uniqueness: { scope: :user_id }

  def self.already_favorited?(user, pet_id)
    # favorite = find_by(user: user, pet_id: pet_id)
    exists?(user: User.last, pet_id: pet_id)
  end

end
