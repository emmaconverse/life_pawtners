class FavoritesController < ApplicationController
  before_action :authenticate_admin!
    def index
      @favorites = Favorite.all
    end

    def create
      @favorite = Favorite.new(favorites_params)
      @favorite.save
    end

private

def favorites_params
  params.require(:favorite).permit(:user_id, :pet_id)
end

  end
