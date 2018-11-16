class FavoritesController < ApplicationController
  before_action :authenticate_user!
    def index
      @favorites = Favorite.all.where(user_id: current_user)
    end

    def create
      @favorite = Favorite.new(
        pet_id: params["pet_id"],
        user: current_user,
        pet_name: params["pet_name"],
        pet_age: params["pet_age"],
        pet_size: params["pet_size"],
        pet_gender: params["pet_gender"],
        pet_breed: params["pet_breed"],
        pet_description: params["pet_description"],
        # details: params["details"],
        # personality: params["personality"],
        shelter: params["shelter"],
        phone: params["phone"],
        email: params["email"],
        status: params["status"],
        avatar_url: params["avatar_url"],
        # photos_urls: params["photos_urls"]
      )
      @favorite.save
      redirect_back(fallback_location: root_path)
    end

    def destroy
      @favorite = Favorite.find(params[:id])
      @favorite.destroy
      redirect_to favorites_path
    end

end
