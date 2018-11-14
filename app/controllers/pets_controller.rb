require "ibm_watson/visual_recognition_v3"
require "httparty"
# require 'will_paginate/array'

class PetsController < ApplicationController

  def index
    @breed = params[:breed]
    @color = params[:color]
    @animal_type = params[:animal_type]
    @age_1 = params[:age_1]
    @age_2 = params[:age_2]
    @page = (params[:page] || 1).to_i
    @next_page = pets_path(params.merge(page: @page + 1).permit(:breed, :color, :animal_type, :animal_age, :page))
    @previous_page = pets_path(params.merge(page: @page - 1).permit(:breed, :color, :animal_type, :animal_age, :page))



    @request = HTTParty.get("https://www.petfinder.com/search/?page=#{@page}&limit[]=24&status=adoptable&distance[]=100&type[]=#{@animal_type}&sort[]=nearest&age[]=#{@age_1}&age[]=#{@age_2}&breed[]=#{@breed}&color[]=#{@color}&location_slug[]=us%2Fsc%2Fgreenville",
      {headers: {"Content-Type" => "application/json", "x-requested-with" => "XMLHttpRequest"}
    })


    @pets = @request["result"]["animals"]
    @pagination = @request["result"]["pagination"]
    @current_page = @pagination["current_page"]
    @total_pages = @pagination["total_pages"]
    @number_of_results = @request["summary"]["num_search_results"]


    @locations = {}
    @grouped_pets = @pets.group_by{ |pet| pet["location"]["geo"]["latitude"].to_s + "," + pet["location"]["geo"]["longitude"].to_s }.keys.each {|key| @locations[key] = [] }
    @pushed_pets = @pets.each { |pet| key = (key = pet["location"]["geo"]["latitude"].to_s + "," + pet["location"]["geo"]["longitude"].to_s), @locations[key].push(pet) }
    @animals_at_location = @locations.map { |key, values| values.map { |value| value["animal"] }}

  end

  def new
    @visual_recognition = IBMWatson::VisualRecognitionV3.new
  end

  def create
    visual_recognition = IBMWatson::VisualRecognitionV3.new(
      version: "2018-03-19",
      iam_apikey: ENV["WATSON_API_KEY"]
    )

    File.open(params[:file_upload][:uploaded_file].tempfile) do |image|
      result = visual_recognition.classify(
        images_file: image,
        threshold: 0,
        classifier_ids: ["default"]
      ).result["images"][0]["classifiers"][0]["classes"]

      @animal_type = result.any? { |result| result["class"].include? "dog" } ? "dogs" : "cats"
      @sorted_classes = remove_banned_class_names(result).sort_by { |hash| hash["score"] }
      @breed = @sorted_classes.reject { |result|
                result["class"].include? "color"
              }.take(2).map { |breed|
                breed["class"].remove(" dog", " cat", "-dog", "-cat", "(dog)", "(cat")
              }.first.try :titleize
      @watson_color = @sorted_classes.select { |result|
                      result["class"].include? "color"
                    }.map { |color| color["class"].remove("light ", "dark ", " color")
                    }.max_by { |result|
                      result["score"] }
      @color = determine_color(@watson_color)

      @age_result = visual_recognition.classify(
        images_file: image,
        threshold: 0.5,
        owners: ["me"]
      ).result["images"][0]["classifiers"][0]["classes"]

      animal_age = @age_result.any? { |result| result["class"].include? "adult_dog" || "adult_cat" } ? ["Adult", "Senior"] : ["Baby", "Young"]
      @age_1 = animal_age[0]
      @age_2 = animal_age[1]
    end

    redirect_to pets_path(breed: @breed, color: @color, animal_type: @animal_type, age_1: @age_1, age_2: @age_2)
  end

  # def edit
  # end

  def update

  end


private

  def remove_banned_class_names(classes)
    classes.reject do |class_data|
      banned_class_names.include?(class_data["class"])
    end
  end

  def banned_class_names
    ["cat", "canine", "puppy", "kitten", "feline", "dog", "carnivore", "mammal", "animal", "domestic animal"]
  end

  def determine_color(color)
    COLOR_MAP[color] || ""
  end

end
