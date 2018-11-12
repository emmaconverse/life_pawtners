class FavoritesController < ApplicationController
  before_action :authenticate_user!
    def index
      @favorites = Favorite.all
    end

    def create
      @favorite = Favorite.new(pet_id: params["pet_id"], user: current_user)
      @favorite.save
      redirect_back(fallback_location: root_path)
    end

    # def add_to_favorites
    #   tak ethe elements data attr of pet id
    #   send that id  to api call for that pet-id
    # end


  end
